#!/usr/bin/env python3
"""Turn Cargo.lock files into a Guix module of crate origins.

For every crates.io crate in the given lockfiles an origin is emitted (its hash
is the Cargo.lock checksum, re-encoded).  Crates locked to git sources are
emitted as `git-crate' entries pointing into pinned `git-checkout' origins,
for (Lightningbulb packages cargo-git).  Git checkouts are fetched (shallow,
recursively when the repository has submodules) to compute their hashes and
to find each crate's directory, so this needs git, rsync, network access and
`guix hash' (or nix-hash).

Usage:
  cargo-lock-to-guix.py MODULE-NAME OUTPUT.scm PROJECT=path/to/Cargo.lock ...

Defines PROJECT-cargo-inputs and PROJECT-git-crates for each PROJECT.
"""
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
import tomllib

CACHE = os.environ.get("GIT_CACHE_DIR", os.path.expanduser("~/.cache/lightningbulb-git"))
CH = "0123456789abcdfghijklmnpqrsvwxyz"


def nix_b32(b):
    n = (len(b) * 8 - 1) // 5 + 1
    out = []
    for i in range(n - 1, -1, -1):
        j, k = divmod(i * 5, 8)
        c = b[j] >> k
        if j + 1 < len(b):
            c |= b[j + 1] << (8 - k)
        out.append(CH[c & 0x1F])
    return "".join(out)


def run(*args, **kw):
    return subprocess.run(args, check=True, capture_output=True, text=True, **kw).stdout


def fetch_url(url):
    url = url.rstrip("/")
    head, rest = url.split("://", 1)
    while "//" in rest:
        rest = rest.replace("//", "/")
    return f"{head}://{rest}"


def checkout(url, commit):
    key = hashlib.sha1(f"{url}@{commit}".encode()).hexdigest()[:12]
    d = os.path.join(CACHE, key)
    if not os.path.exists(os.path.join(d, ".lb-done")):
        shutil.rmtree(d, ignore_errors=True)
        run("git", "init", "-q", d)
        run("git", "-C", d, "fetch", "-q", "--depth", "1", url, commit)
        run("git", "-C", d, "checkout", "-q", "FETCH_HEAD")
        recursive = os.path.exists(os.path.join(d, ".gitmodules"))
        if recursive:
            run("git", "-C", d, "submodule", "update", "--init", "--recursive",
                "--depth", "1", "-q")
        with open(os.path.join(d, ".lb-done"), "w") as f:
            f.write("recursive" if recursive else "")
    with open(os.path.join(d, ".lb-done")) as f:
        return d, f.read() == "recursive"


_hashes = {}


def nar_hash(d):
    if d in _hashes:
        return _hashes[d]
    tmp = tempfile.mkdtemp()
    try:
        tree = os.path.join(tmp, "tree")
        run("rsync", "-a", "--exclude=.git", "--exclude=.lb-done", d + "/", tree + "/")
        if shutil.which("guix"):
            h = run("guix", "hash", "-r", tree).strip()
        else:
            h = run("nix-hash", "--type", "sha256", "--base32", tree).strip()
    finally:
        shutil.rmtree(tmp)
    _hashes[d] = h
    return h


def crate_dirs(d):
    found = {}
    for root, dirs, files in os.walk(d):
        dirs[:] = [x for x in dirs if x not in (".git", "target")]
        if "Cargo.toml" in files:
            try:
                with open(os.path.join(root, "Cargo.toml"), "rb") as f:
                    pkg = tomllib.load(f).get("package")
            except Exception:
                continue
            if pkg and "name" in pkg:
                found.setdefault(pkg["name"], []).append(
                    (os.path.relpath(root, d), pkg.get("version")))
    return found


def ident(s):
    return s.replace("+", "-").replace("_", "_")


def main():
    module, output = sys.argv[1:3]
    projects = [a.split("=", 1) for a in sys.argv[3:]]

    crates = {}         # (name, version) -> hash
    per_project = {}    # project -> (registry list, git list)
    checkouts = {}      # (url, commit) -> (var, url, commit, hash, recursive)
    for proj, lock in projects:
        with open(lock, "rb") as f:
            data = tomllib.load(f)
        # [[patch.unused]]: git crates [patch]ed in but not in the graph.
        # Cargo still looks each one up in its (replaced) source and fails
        # when the vendored copy lacks it, so vendor them too, as `cargo
        # vendor' does.
        packages = data["package"] + [
            p for p in data.get("patch", {}).get("unused", [])
            if p.get("source", "").startswith("git+")]
        reg, git = [], []
        for p in packages:
            src = p.get("source", "")
            if src.startswith("registry+"):
                crates[(p["name"], p["version"])] = nix_b32(bytes.fromhex(p["checksum"]))
                reg.append((p["name"], p["version"]))
            elif src.startswith("git+"):
                url = src[4:].split("#")[0].split("?")[0]
                commit = src.split("#")[1]
                furl = fetch_url(url)
                d, recursive = checkout(furl, commit)
                if (furl, commit) not in checkouts:
                    repo = furl.rsplit("/", 1)[1].removesuffix(".git")
                    checkouts[(furl, commit)] = (f"{repo}-{commit[:7]}-checkout", furl, commit,
                                                 nar_hash(d), recursive)
                dirs = crate_dirs(d).get(p["name"], [])
                exact = [x for x, v in dirs if v == p["version"]]
                choice = sorted(exact or [x for x, _ in dirs], key=len)
                if not choice:
                    raise SystemExit(f"{proj}: {p['name']} not found in {furl}@{commit}")
                git.append((p["name"], p["version"], src,
                            checkouts[(furl, commit)][0], choice[0]))
            elif src:
                raise SystemExit(f"unsupported source {src}")
        per_project[proj] = (reg, git)
        print(f"{proj}: {len(reg)} crates.io crates, {len(git)} git crates", file=sys.stderr)

    emit(module, output, [p for p, _ in projects], crates,
         {var: (url, commit, h, rec) for var, url, commit, h, rec in checkouts.values()},
         per_project)


def emit(module, output, project_names, crates, checkouts, per_project):
    """Write the module.  CRATES: (name, version) -> hash; CHECKOUTS:
    var -> (url, commit, hash, recursive); PER_PROJECT: project ->
    (registry [(name, version)], git [(name, version, source, var, subdir)]).

    Everything is quoted data, indexed into two tables: Guile compiles that
    in seconds, where one `define' per crate took minutes per `guix pull'."""
    crate_keys = sorted(crates)
    crate_index = {k: i for i, k in enumerate(crate_keys)}
    checkout_vars = sorted(checkouts)
    checkout_index = {v: i for i, v in enumerate(checkout_vars)}

    def wrap(items, indent):
        lines, line = [], ""
        for item in items:
            if line and len(line) + len(item) + 1 > 78 - indent:
                lines.append(line)
                line = item
            else:
                line = f"{line} {item}" if line else item
        if line:
            lines.append(line)
        return ("\n" + " " * indent).join(lines)

    out = [f""";;; GENERATED by contrib/cargo-lock-to-guix.py -- do not edit by hand.

(define-module ({module})
  #:use-module (Lightningbulb packages cargo-git)
  #:export ({" ".join(f"{p}-cargo-inputs {p}-git-crates" for p in project_names)}))

;;; crates.io crates: (NAME VERSION HASH); projects refer to them by index.
(define %crates
  (crate-table
   '("""]
    out.append("\n     ".join(f'("{n}" "{v}" "{crates[(n, v)]}")' for n, v in crate_keys))
    out.append(")))\n\n;;; Git checkouts, by index.\n(define %git-checkouts\n  (vector")
    for var in checkout_vars:
        url, commit, h, recursive = checkouts[var]
        rec = " #t" if recursive else ""
        name = url.rsplit("/", 1)[1].removesuffix(".git")
        out.append(f'\n   ;; {var}\n   (git-checkout "{name}" "{url}"\n'
                   f'                 "{commit}"\n                 "{h}"{rec})')
    out.append("))\n")
    for proj in project_names:
        reg, git = per_project[proj]
        out.append(f"\n(define {proj}-cargo-inputs\n  (crate-selection\n   %crates\n   '("
                   + wrap([str(crate_index[k]) for k in reg], 5) + ")))\n")
        if git:
            out.append(f"\n(define {proj}-git-crates\n  (git-crate-selection\n   %git-checkouts\n   '("
                       + "\n     ".join(f'("{n}" "{v}" "{s}" {checkout_index[var]} "{sub}")'
                                        for n, v, s, var, sub in git) + ")))\n")
        else:
            out.append(f"\n(define {proj}-git-crates '())\n")
    with open(output, "w") as f:
        f.write("".join(out))


if __name__ == "__main__":
    main()
