"""Copy Strata's packaged components (the engine) from the store into the
user's own components folder, $XDG_DATA_HOME/strata/components.

Strata checks every engine file against the SHA-256 in its manifest.  Guix
grafts rewrite store file names inside the engine after the build (a security
fix of glibc, say), so the store copy no longer matches the hashes recorded at
build time and Strata refuses it.  The copy made here gets its manifest's
hashes and sizes recomputed from the files as they are now.  The folder is the
user's own, so `strata update' can also put newer engines there.

Usage: strata-seed-components.py STORE-COMPONENTS USER-COMPONENTS

A copy is only redone when the store folder it came from changes; engines
Strata downloaded itself are never touched.
"""

import hashlib
import json
import os
import shutil
import stat
import sys
from pathlib import Path

MANIFEST = "engine-component.json"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def make_writable(root: Path) -> None:
    for path in [root, *root.rglob("*")]:
        if not path.is_symlink():
            mode = path.stat().st_mode
            path.chmod(mode | stat.S_IWUSR | (stat.S_IXUSR if path.is_dir() else 0))


def seed(package: Path, target: Path) -> None:
    stamp = target.parent / f".guix-{target.name}.source"
    source = str(package.resolve())
    try:
        if target.is_dir() and stamp.read_text(encoding="utf-8").strip() == source:
            return
    except OSError:
        pass
    tmp = target.with_name(f".{target.name}.guix-tmp")
    shutil.rmtree(tmp, ignore_errors=True)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(package, tmp, symlinks=False)
    make_writable(tmp)
    manifest = tmp / MANIFEST
    if manifest.is_file():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        for item in data.get("files", []):
            path = tmp / item["path"]
            item["sha256"] = sha256(path)
            item["bytes"] = path.stat().st_size
        manifest.write_text(json.dumps(data, indent=1) + "\n", encoding="utf-8")
    if target.exists():
        shutil.rmtree(target)
    tmp.rename(target)
    stamp.write_text(source + "\n", encoding="utf-8")


def main(store: str, user: str) -> int:
    store_dir, user_dir = Path(store), Path(user)
    for kind in sorted(p for p in store_dir.iterdir() if p.is_dir()):
        for package in sorted(p for p in kind.iterdir() if p.is_dir()):
            try:
                seed(package, user_dir / kind.name / package.name)
            except OSError as e:
                print(f"strata: could not copy the packaged {kind.name} "
                      f"{package.name} into {user_dir}: {e}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:3]))
