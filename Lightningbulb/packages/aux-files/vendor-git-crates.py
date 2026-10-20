#!/usr/bin/env python3
"""Vendor crates that a Cargo.lock pins to git sources, without network.

Guix fetches each git dependency as an ordinary pinned checkout.  This script
turns the locked crates inside those checkouts into entries of a cargo
"directory source", roughly what `cargo vendor` produces:

  * each crate is copied to VENDOR/<name>-<version>-git;
  * its Cargo.toml is normalized: values inherited from the enclosing
    workspace (`foo.workspace = true`) are filled in, path dependencies are
    pointed at the sibling vendored copies, and workspace-only sections are
    dropped (the original is kept as Cargo.toml.orig);
  * a [source."git+..."] replacement for every git source is appended to the
    cargo configuration, redirecting it to the vendored directory.

Cargo only accepts vendored git sources together with a Cargo.lock (which
Guix's configure phase deletes), so the original lock is put back and every
vendored registry crate gets its Cargo.lock checksum as package checksum.

Usage: vendor-git-crates.py SPEC VENDOR-DIR CARGO-CONFIG LOCKFILE

SPEC has one tab-separated line per locked git crate:
  name  version  source  checkout  subdir
where SOURCE is the Cargo.lock source string ("git+URL?rev=R#COMMIT").
"""
import json
import os
import shutil
import sys
import tomllib
from urllib.parse import parse_qsl

DEP_TABLES = ("dependencies", "build-dependencies", "dev-dependencies")


def load(path):
    with open(path, "rb") as f:
        return tomllib.load(f)


def find_workspace_root(crate_dir, checkout):
    d = crate_dir
    while True:
        manifest = os.path.join(d, "Cargo.toml")
        if os.path.exists(manifest):
            t = load(manifest)
            if "workspace" in t:
                return d, t["workspace"]
        if os.path.samefile(d, checkout) or d == "/":
            return None, {}
        d = os.path.dirname(d)


# ---- TOML output (just enough for Cargo manifests) -------------------------

def key(k):
    return json.dumps(k, ensure_ascii=False)


def value(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return json.dumps(v, ensure_ascii=False)
    if isinstance(v, list):
        return "[" + ", ".join(value(x) for x in v) + "]"
    if isinstance(v, dict):
        return "{ " + ", ".join(f"{key(k)} = {value(x)}" for k, x in v.items()) + " }"
    raise TypeError(f"cannot serialize {v!r}")


def is_table_array(v):
    return isinstance(v, list) and v and all(isinstance(x, dict) for x in v)


def emit_table(out, path, table):
    scalars = {k: v for k, v in table.items()
               if not isinstance(v, dict) and not is_table_array(v)}
    if path and (scalars or not table):
        out.append("[" + ".".join(key(p) for p in path) + "]")
    for k, v in scalars.items():
        out.append(f"{key(k)} = {value(v)}")
    if scalars or not path:
        out.append("")
    for k, v in table.items():
        if isinstance(v, dict):
            emit_table(out, path + [k], v)
        elif is_table_array(v):
            for item in v:
                out.append("[[" + ".".join(key(p) for p in path + [k]) + "]]")
                for ik, iv in item.items():
                    out.append(f"{key(ik)} = {value(iv)}")
                out.append("")


def dumps(doc):
    out = []
    ordered = {}
    if "package" in doc:
        ordered["package"] = doc["package"]
    ordered.update((k, v) for k, v in doc.items() if k != "package")
    emit_table(out, [], ordered)
    return "\n".join(out) + "\n"


# ---- normalization ---------------------------------------------------------

def normalize(manifest, crate_dir, ws_root, ws, vendored, crate_names):
    """Return a normalized copy of MANIFEST (a dict) for the crate in CRATE_DIR."""
    ws_pkg = ws.get("package", {})
    ws_deps = ws.get("dependencies", {})
    doc = dict(manifest)

    pkg = dict(doc.get("package", {}))
    for k, v in list(pkg.items()):
        if isinstance(v, dict) and v.get("workspace") is True:
            if k in ("readme", "license-file"):
                del pkg[k]                    # paths relative to the workspace
            elif k in ws_pkg:
                pkg[k] = ws_pkg[k]
            else:
                del pkg[k]
    pkg.pop("workspace", None)
    doc["package"] = pkg

    for drop in ("workspace", "patch", "replace", "profile", "lints"):
        doc.pop(drop, None)

    def fix_dep(name, dep):
        base_dir = crate_dir
        if isinstance(dep, dict) and dep.get("workspace") is True:
            inherited = ws_deps.get(dep.get("package", name), ws_deps.get(name))
            if inherited is None:
                raise SystemExit(f"{crate_dir}: {name} not in workspace.dependencies")
            if isinstance(inherited, str):
                inherited = {"version": inherited}
            merged = dict(inherited)
            for k, v in dep.items():
                if k == "workspace":
                    continue
                if k == "features":
                    merged["features"] = list(dict.fromkeys(
                        list(inherited.get("features", [])) + list(v)))
                else:
                    merged[k] = v
            dep = merged
            base_dir = ws_root
        if isinstance(dep, dict) and "path" in dep:
            target = os.path.realpath(os.path.join(base_dir, dep["path"]))
            dep = dict(dep)
            if target in vendored:
                dep["path"] = "../" + vendored[target]
            else:
                # Not part of the locked graph (e.g. an unused optional
                # dependency); let cargo look it up by version instead.
                del dep["path"]
                if "version" not in dep and "git" not in dep:
                    dep["version"] = "*"
        return dep

    def fix_tables(tbl):
        for t in DEP_TABLES:
            if t in tbl:
                if t == "dev-dependencies":
                    del tbl[t]                # never built for dependencies
                    continue
                tbl[t] = {n: fix_dep(n, d) for n, d in tbl[t].items()}

    fix_tables(doc)
    if "target" in doc:
        doc["target"] = {cfg: dict(t) for cfg, t in doc["target"].items()}
        for t in doc["target"].values():
            fix_tables(t)
    return doc


def source_replacement(source):
    """Cargo config lines replacing the git SOURCE with vendored sources."""
    spec = source[len("git+"):].split("#", 1)[0]
    url, _, query = spec.partition("?")
    lines = [f"[source.{key('git+' + spec)}]", f"git = {value(url)}"]
    for k, v in parse_qsl(query):
        if k in ("rev", "branch", "tag"):
            lines.append(f"{k} = {value(v)}")
    lines.append('replace-with = "vendored-sources"')
    return "\n".join(lines) + "\n"


def main():
    spec_file, vendor_dir, config, lockfile = sys.argv[1:5]
    entries = []
    with open(spec_file) as f:
        for line in f:
            if line.strip():
                entries.append(line.rstrip("\n").split("\t"))

    # Where each locked crate lives, and where its copy will go.
    vendored = {}
    for name, version, source, checkout, subdir in entries:
        src = os.path.realpath(os.path.join(checkout, subdir))
        vendored[src] = f"{name}-{version}-git"
    crate_names = {e[0] for e in entries}

    os.makedirs(vendor_dir, exist_ok=True)
    sources = []
    for name, version, source, checkout, subdir in entries:
        src = os.path.realpath(os.path.join(checkout, subdir))
        dest = os.path.join(vendor_dir, vendored[src])
        print(f"vendoring {name} {version} from {source}")
        shutil.copytree(src, dest, symlinks=False, ignore_dangling_symlinks=True,
                        ignore=shutil.ignore_patterns(".git", "target"))
        for root, dirs, files in os.walk(dest):
            for n in dirs + files:
                p = os.path.join(root, n)
                if not os.path.islink(p):
                    os.chmod(p, os.stat(p).st_mode | 0o200)
            os.chmod(root, os.stat(root).st_mode | 0o200)
        manifest_path = os.path.join(dest, "Cargo.toml")
        manifest = load(manifest_path)
        ws_root, ws = find_workspace_root(src, os.path.realpath(checkout))
        doc = normalize(manifest, src, ws_root or src, ws, vendored, crate_names)
        os.replace(manifest_path, manifest_path + ".orig")
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(dumps(doc))
        with open(os.path.join(dest, ".cargo-checksum.json"), "w") as f:
            f.write('{"files":{}}')
        if source not in sources:
            sources.append(source)

    with open(config, "a", encoding="utf-8") as f:
        f.write("\n")
        seen = set()
        for source in sources:
            block = source_replacement(source)
            if block not in seen:
                seen.add(block)
                f.write("\n" + block)


    # Registry crates: tie each vendored copy to its Cargo.lock checksum.
    checksums = {(p["name"], p["version"]): p.get("checksum")
                 for p in load(lockfile).get("package", [])}
    for d in os.listdir(vendor_dir):
        dest = os.path.join(vendor_dir, d)
        manifest = os.path.join(dest, "Cargo.toml")
        if d.endswith("-git") or not os.path.exists(manifest):
            continue
        pkg = load(manifest).get("package", {})
        checksum = checksums.get((pkg.get("name"), pkg.get("version")))
        with open(os.path.join(dest, ".cargo-checksum.json"), "w") as f:
            f.write(json.dumps({"files": {}, "package": checksum})
                    if checksum else '{"files":{}}')


if __name__ == "__main__":
    main()
