#!/usr/bin/env python3
"""Regenerate hyperguix/packages/rust-crates.scm and node-deps.scm.

Usage:
  update-lockfile-deps.py OUT_DIR SCRCPY_GUI_SRC FAFOREVER_SRC [PNPM_VERSION]

OUT_DIR is the hyperguix/packages directory; the *_SRC arguments are
checkouts of the commits the packages point at.  Crate hashes come straight
from Cargo.lock (no download).  npm tarballs are downloaded once (into
$NPM_CACHE_DIR, default ~/.cache/lightningbulb-npm), checked against the
lockfile's sha512 integrity, and their sha256 is recorded.
Needs Python 3.11+ and PyYAML; curl for downloads.
"""
import base64, hashlib, json, os, re, subprocess, sys, tomllib
from concurrent.futures import ThreadPoolExecutor
import yaml

CACHE = os.environ.get("NPM_CACHE_DIR", os.path.expanduser("~/.cache/lightningbulb-npm"))
os.makedirs(CACHE, exist_ok=True)

def crates_from_lock(path):
    lock = tomllib.load(open(path, "rb"))
    out = []
    for p in lock["package"]:
        src = p.get("source", "")
        if src.startswith("registry+https://github.com/rust-lang/crates.io-index"):
            out.append((p["name"], p["version"], nix_b32(bytes.fromhex(p["checksum"]))))
        elif src:
            raise SystemExit(f"unsupported source {src} for {p['name']}")
    return out

def scm_crate_var(name, version):
    return f"rust-{name}-{version}".replace("+", "-")

def platform_ok(os_list, cpu_list):
    def ok(lst, want):
        if not lst: return True
        pos = [x for x in lst if not x.startswith("!")]
        neg = [x[1:] for x in lst if x.startswith("!")]
        if want in neg: return False
        return (not pos) or want in pos
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

def npm_lock_items(path):
    lock = json.load(open(path))
    items = []
    for k, v in lock["packages"].items():
        if not k or v.get("link"): continue
        if not platform_ok(v.get("os"), v.get("cpu")): continue
        url = v["resolved"]
        regpath = url.split("https://registry.npmjs.org/", 1)[1]
        items.append((regpath, url, v["integrity"]))
    return sorted(set(items))

def pnpm_lock_items(path):
    lock = yaml.safe_load(open(path))
    items = []
    for key, v in lock["packages"].items():
        if not platform_ok(v.get("os"), v.get("cpu")): continue
        name, version = key.rsplit("@", 1)
        base = name.split("/")[-1]
        regpath = f"{name}/-/{base}-{version}.tgz"
        items.append((regpath, "https://registry.npmjs.org/" + regpath, v["resolution"]["integrity"]))
    return sorted(set(items))

def resolve_npm(items):
    with ThreadPoolExecutor(16) as ex:
        return list(ex.map(fetch, items))

CH = "0123456789abcdfghijklmnpqrsvwxyz"
def nix_b32(b: bytes) -> str:
    n = (len(b) * 8 - 1) // 5 + 1
    out = []
    for i in range(n - 1, -1, -1):
        bit = i * 5
        j, k = divmod(bit, 8)
        c = b[j] >> k
        if j + 1 < len(b):
            c |= b[j + 1] << (8 - k)
        out.append(CH[c & 0x1f])
    return "".join(out)

def main():
    OUT, SG, FA = sys.argv[1:4]
    pnpm_version = sys.argv[4] if len(sys.argv) > 4 else json.load(open(f"{FA}/package.json"))["packageManager"].split("@")[1]
    res = {
        "scrcpy-gui": resolve_npm(npm_lock_items(f"{SG}/package-lock.json")),
        "faforever": resolve_npm(pnpm_lock_items(f"{FA}/pnpm-lock.yaml")),
    }
    meta = json.loads(subprocess.run(["curl", "-sSfL", f"https://registry.npmjs.org/pnpm/{pnpm_version}"], check=True, capture_output=True).stdout)
    res["pnpm"] = resolve_npm([(f"pnpm/-/pnpm-{pnpm_version}.tgz", meta["dist"]["tarball"], meta["dist"]["integrity"])])
    emit(OUT, SG, FA, res)

HDR=";;; GENERATED FILE -- do not edit by hand.\n;;; Regenerate with the scripts in contrib/ when the upstream lockfiles change.\n\n"

def emit(OUT, SG, FA, res):

    projects=[("scrcpy-gui", f"{SG}/src-tauri/Cargo.lock"),
              ("faforever-client", f"{FA}/Cargo.lock")]
    allc={}; per={}
    for name, lock in projects:
        cs=crates_from_lock(lock); per[name]=cs
        for n,v,h in cs: allc[(n,v)]=h
    def var(n,v): return f"rust-{n}-{v}".replace("+","-")
    L=[HDR, """;;; Crate sources for the Rust applications in this channel, one origin per
;;; entry in each upstream Cargo.lock.  The hashes are the Cargo.lock
;;; checksums (sha256 of the .crate file) re-encoded in nix-base32, so they
;;; can be checked against the lockfile without downloading anything.

(define-module (hyperguix packages rust-crates)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:export (scrcpy-gui-cargo-inputs
            faforever-client-cargo-inputs))

(define (crate name version hash)
  (origin
    (method url-fetch)
    (uri (crate-uri name version))
    (file-name (string-append "rust-" name "-" version ".tar.gz"))
    (sha256 (base32 hash))))

"""]
    for (n,v),h in sorted(allc.items()):
        L.append(f'(define {var(n,v)}\n  (crate "{n}" "{v}" "{h}"))\n')
    for name,cs in per.items():
        L.append(f"\n(define {name}-cargo-inputs\n  (list " + "\n        ".join(var(n,v) for n,v,_ in cs) + "))\n")
    open(f"{OUT}/rust-crates.scm","w").write("".join(L))

    # ---- npm tarballs
    L=[HDR, """;;; npm registry tarballs needed to build the web front ends of the Tauri
;;; applications, taken from each upstream lockfile (package-lock.json or
;;; pnpm-lock.yaml) and restricted to what installs on x86_64-linux.  Each
;;; entry is (REGISTRY-PATH . ORIGIN); see (hyperguix packages js-offline).

(define-module (hyperguix packages node-deps)
  #:use-module (hyperguix packages js-offline)
  #:export (scrcpy-gui-npm-tarballs
            faforever-client-npm-tarballs
            faforever-client-pnpm-tarball))

"""]
    def lst(name, items):
        return f"(define {name}\n  (list " + "\n        ".join(f'(npm-tarball "{p}"\n                     "{h}")' for p,h in items) + "))\n\n"
    L.append(lst("scrcpy-gui-npm-tarballs", res["scrcpy-gui"]))
    L.append(lst("faforever-client-npm-tarballs", res["faforever"]))
    p,h=res["pnpm"][0]
    L.append(f'(define faforever-client-pnpm-tarball\n  (cdr (npm-tarball "{p}"\n                    "{h}")))\n')
    open(f"{OUT}/node-deps.scm","w").write("".join(L))
    print("ok", len(allc))

if __name__ == "__main__":
    main()
