#!/usr/bin/env python3
"""Generate a Guix module listing the npm tarballs of one pnpm-lock.yaml.

Usage:
  pnpm-lock-to-guix.py MODULE-NAME OUT.scm PREFIX PNPM-LOCK [PNPM_VERSION]

e.g.
  guix shell python python-pyyaml curl -- python3 contrib/pnpm-lock-to-guix.py \\
    "hyperguix packages r2modman-deps" \\
    hyperguix/packages/r2modman-deps.scm r2modman ~/src/r2modmanPlus/pnpm-lock.yaml

defines PREFIX-npm-tarballs (a list of (REGISTRY-PATH . ORIGIN) pairs, see
(hyperguix packages js-offline)) and PREFIX-pnpm-tarball (the pnpm
release named by package.json's "packageManager" next to the lockfile, or
PNPM_VERSION).  Tarballs are downloaded once into $NPM_CACHE_DIR (default
~/.cache/lightningbulb-npm), checked against the lockfile's integrity and
recorded by sha256.  Packages that don't install on x86_64-linux are skipped.
"""
import base64, hashlib, json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
import yaml

CACHE = os.environ.get("NPM_CACHE_DIR",
                       os.path.expanduser("~/.cache/lightningbulb-npm"))
CH = "0123456789abcdfghijklmnpqrsvwxyz"


def nix_b32(b):
    n = (len(b) * 8 - 1) // 5 + 1
    out = []
    for i in range(n - 1, -1, -1):
        j, k = divmod(i * 5, 8)
        c = b[j] >> k
        if j + 1 < len(b):
            c |= b[j + 1] << (8 - k)
        out.append(CH[c & 0x1f])
    return "".join(out)


def platform_ok(os_list, cpu_list):
    def ok(lst, want):
        if not lst:
            return True
        pos = [x for x in lst if not x.startswith("!")]
        neg = [x[1:] for x in lst if x.startswith("!")]
        return want not in neg and (not pos or want in pos)
    return ok(os_list, "linux") and ok(cpu_list, "x64")


def fetch(item):
    regpath, url, integrity = item
    alg, b64 = integrity.split("-", 1)
    fn = os.path.join(CACHE, regpath.replace("/", "__"))
    if not os.path.exists(fn):
        subprocess.run(["curl", "-sSfL", "-o", fn + ".part", url], check=True)
        os.rename(fn + ".part", fn)
    data = open(fn, "rb").read()
    if hashlib.new(alg, data).digest() != base64.b64decode(b64):
        raise SystemExit(f"integrity mismatch for {url}")
    return regpath, nix_b32(hashlib.sha256(data).digest())


def lock_items(path):
    lock = yaml.safe_load(open(path))
    items = set()
    for key, v in lock["packages"].items():
        if not platform_ok(v.get("os"), v.get("cpu")):
            continue
        res = v["resolution"]
        if "integrity" not in res:
            raise SystemExit(f"unsupported resolution for {key}: {res}")
        name, version = key.rsplit("@", 1)
        regpath = f"{name}/-/{name.split('/')[-1]}-{version}.tgz"
        items.add((regpath, "https://registry.npmjs.org/" + regpath,
                   res["integrity"]))
    return sorted(items)


def main():
    module, out, prefix, lockfile = sys.argv[1:5]
    if len(sys.argv) > 5:
        pnpm_version = sys.argv[5]
    else:
        pkg = json.load(open(os.path.join(os.path.dirname(lockfile),
                                          "package.json")))
        pnpm_version = pkg["packageManager"].split("@")[1].split("+")[0]
    os.makedirs(CACHE, exist_ok=True)
    meta = json.loads(subprocess.run(
        ["curl", "-sSfL", f"https://registry.npmjs.org/pnpm/{pnpm_version}"],
        check=True, capture_output=True).stdout)
    with ThreadPoolExecutor(16) as ex:
        tarballs = list(ex.map(fetch, lock_items(lockfile)))
    pnpm = fetch((f"pnpm/-/pnpm-{pnpm_version}.tgz", meta["dist"]["tarball"],
                  meta["dist"]["integrity"]))
    entries = "\n        ".join(
        f'(npm-tarball "{p}"\n                     "{h}")' for p, h in tarballs)
    with open(out, "w") as f:
        f.write(f""";;; GENERATED FILE -- do not edit by hand.
;;; Regenerate with contrib/pnpm-lock-to-guix.py when the upstream lockfile
;;; changes.

;;; npm registry tarballs from the upstream pnpm-lock.yaml, restricted to what
;;; installs on x86_64-linux.  Each entry is (REGISTRY-PATH . ORIGIN); see
;;; (hyperguix packages js-offline).

(define-module ({module})
  #:use-module (hyperguix packages js-offline)
  #:export ({prefix}-npm-tarballs
            {prefix}-pnpm-tarball))

(define {prefix}-npm-tarballs
  (list {entries}))

(define {prefix}-pnpm-tarball
  (cdr (npm-tarball "{pnpm[0]}"
                    "{pnpm[1]}")))
""")
    print("ok", len(tarballs))


if __name__ == "__main__":
    main()
