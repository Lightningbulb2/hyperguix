#!/usr/bin/env python3
"""Move the packages listed in contrib/updates.toml to their latest release.

For each package: find the newest release tag upstream (or, for a package
that tracks a branch, the branch's head); if the pin in the channel is on
another commit, fetch it, check that the channel's patches still apply,
compute its hash, rewrite the version, commit and hash in the package
module, regenerate the dependency modules its group shares and update the
version in the README's package table.  updates.toml documents the keys.

Usage:
  auto-update.py [--check] [--commit] [--summary FILE] [--failures FILE]
                 [PACKAGE ...]
  auto-update.py --lint

  --lint           check updates.toml against the channel, offline: every
                   pin is found exactly once, every project of a crates
                   module is listed, every patch exists, and every .scm
                   file reads as Scheme
  --check          only report what is out of date; change nothing
  --commit         make one git commit per update
  --summary FILE   write a Markdown report there (appended)
  --failures FILE  write what could not be updated there, as JSON
  PACKAGE ...      only look at these packages (or groups)

This checks that sources can be fetched, that patches apply and that the
modules still read as Scheme.  It does NOT build anything.

Needs Python 3.11+, git, patch, network access and `guix hash' (or
nix-hash); git-lfs, PyYAML and curl for the packages that use them.
Checkouts are kept in $GIT_CACHE_DIR (default ~/.cache/lightningbulb-git).
"""
import argparse
import filecmp
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tomllib
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.environ.get("GIT_CACHE_DIR",
                       os.path.expanduser("~/.cache/lightningbulb-git"))
DEFAULT_TAGS = r"^v?(\d+(?:\.\d+)+)$"
GIT_ENV = {**os.environ, "GIT_TERMINAL_PROMPT": "0"}


class Skip(Exception):
    """This update cannot be made; the message says why."""


# ---------------------------------------------------------------------------
# Small helpers.

def run(*args, **kw):
    result = subprocess.run(args, capture_output=True, text=True, **kw)
    if result.returncode != 0:
        raise Skip(f"`{' '.join(args)}` failed: "
                   f"{(result.stderr or result.stdout).strip()[-600:]}")
    return result.stdout


def read(path):
    with open(os.path.join(ROOT, path), encoding="utf-8") as f:
        return f.read()


def write(path, text):
    with open(os.path.join(ROOT, path), "w", encoding="utf-8") as f:
        f.write(text)


def version_key(version):
    return [int(part) for part in re.findall(r"\d+", version)]


def nix_b32(b):
    alphabet = "0123456789abcdfghijklmnpqrsvwxyz"
    out = []
    for i in range((len(b) * 8 - 1) // 5, -1, -1):
        j, k = divmod(i * 5, 8)
        c = b[j] >> k
        if j + 1 < len(b):
            c |= b[j + 1] << (8 - k)
        out.append(alphabet[c & 0x1F])
    return "".join(out)


def download_hash(url):
    """The sha256 of the file at URL, as Guix writes it."""
    request = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return nix_b32(hashlib.sha256(response.read()).digest())
    except OSError as error:
        raise Skip(f"could not download {url}: {error}")


def replace_groups(text, match, values):
    """Return TEXT with the named groups of MATCH replaced by VALUES."""
    for name, start in sorted(((n, match.start(n)) for n in values),
                              key=lambda item: -item[1]):
        text = text[:start] + values[name] + text[match.end(name):]
    return text


def unique_match(pattern, path, what):
    found = list(re.compile(pattern, re.S).finditer(read(path)))
    if len(found) != 1:
        raise Skip(f"the pattern for {what} matches {len(found)} times in "
                   f"{path} (expected once)")
    return found[0]


def balanced(path):
    """Whether PATH still reads as Scheme: parentheses and strings close."""
    text, depth, i = read(path), 0, 0
    while i < len(text):
        c = text[i]
        if c == ";":
            i = text.find("\n", i)
            if i < 0:
                break
        elif c == '"':
            i += 1
            while i < len(text) and text[i] != '"':
                i += 2 if text[i] == "\\" else 1
            if i >= len(text):
                return False
        elif c == "#" and text[i + 1:i + 2] == "\\":
            i += 2
        elif c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
            if depth < 0:
                return False
        i += 1
    return depth == 0


# ---------------------------------------------------------------------------
# Upstream.

def tag_commits(url):
    """Return {tag: commit} for URL, annotated tags resolved."""
    out = run("git", "ls-remote", "--tags", url, env=GIT_ENV)
    commits = {}
    for line in out.splitlines():
        commit, ref = line.split("\t")
        tag = ref.removeprefix("refs/tags/")
        if tag.endswith("^{}"):  # the commit an annotated tag points at
            commits[tag[:-3]] = commit
        else:
            commits.setdefault(tag, commit)
    return commits


def releases(url, tags_rx):
    """Return {version: commit} for the tags of URL matching TAGS_RX."""
    found = {}
    for tag, commit in tag_commits(url).items():
        m = re.match(tags_rx, tag)
        if m:
            found[m.group(1)] = commit
    if not found:
        raise Skip(f"no release tag matching {tags_rx} in {url}")
    return found


def branch_head(url, branch):
    out = run("git", "ls-remote", url, f"refs/heads/{branch}", env=GIT_ENV)
    if not out.strip():
        raise Skip(f"no branch {branch} in {url}")
    return out.split()[0]


def checkout(url, commit, lfs=False):
    """Return a directory holding URL at COMMIT, without .git."""
    key = hashlib.sha1(f"update:{url}@{commit}:{lfs}".encode()).hexdigest()[:12]
    d = os.path.join(CACHE, key)
    if not os.path.exists(os.path.join(d, ".lb-done")):
        shutil.rmtree(d, ignore_errors=True)
        os.makedirs(CACHE, exist_ok=True)
        run("git", "init", "-q", d)
        run("git", "-C", d, "fetch", "-q", "--depth", "1", url, commit,
            env=GIT_ENV)
        run("git", "-C", d, "checkout", "-q", "FETCH_HEAD")
        if lfs:
            # Replace the pointer files by what Git LFS stores.
            run("git", "-C", d, "remote", "add", "origin", url)
            run("git", "-C", d, "lfs", "install", "--local")
            run("git", "-C", d, "lfs", "pull", "origin", env=GIT_ENV)
        shutil.rmtree(os.path.join(d, ".git"))
        open(os.path.join(d, ".lb-done"), "w").close()
    return d


def nar_hash(tree):
    """The hash Guix's git-fetch expects for TREE."""
    marker = os.path.join(tree, ".lb-done")
    os.remove(marker)           # not part of the source
    try:
        if shutil.which("guix"):
            return run("guix", "hash", "-r", tree).strip()
        return run("nix-hash", "--type", "sha256", "--base32", tree).strip()
    finally:
        open(marker, "w").close()


def version_in(tree, path):
    """The version a Cargo.toml or package.json in TREE declares."""
    file = os.path.join(tree, path)
    if not os.path.exists(file):
        raise Skip(f"no {path} in the source")
    if path.endswith(".json"):
        with open(file, encoding="utf-8") as f:
            return json.load(f)["version"]
    with open(file, "rb") as f:
        data = tomllib.load(f)
    version = data.get("package", {}).get("version")
    if not isinstance(version, str):
        version = data.get("workspace", {}).get("package", {}).get("version")
    if not isinstance(version, str):
        raise Skip(f"{path} declares no version")
    return version


# ---------------------------------------------------------------------------
# The manifest.

def package_file(group, package):
    return package.get("file") or group["file"]


def group_files(group):
    """Every file an update of GROUP may touch."""
    files = [group["file"]] if "file" in group else []
    files += [p["file"] for p in group["packages"].values() if "file" in p]
    files += filter(None, [group.get("crates")])
    files += group.get("generated", [])
    return list(dict.fromkeys(files)) + ["README.md"]


def pin_pattern(group, package, name):
    return package.get("pin", group.get("pin", "")).replace("{name}",
                                                            re.escape(name))


def current_pin(group, package, name):
    return unique_match(pin_pattern(group, package, name),
                        package_file(group, package), f"`{name}'")


def group_version(group):
    """The version the whole group shares, or None."""
    if "version-pin" not in group:
        return None
    return unique_match(group["version-pin"], group["file"],
                        "the group's version").group("version")


def pinned(group, package, name):
    """Return (match, version or None, commit or None) as pinned now."""
    match = current_pin(group, package, name)
    groups = match.re.groupindex
    version = match.group("version") if "version" in groups \
        else group_version(group)
    commit = match.group("commit") if "commit" in groups else None
    return match, version, commit


def pinned_commit(group, package, name):
    """The commit NAME is pinned to; looked up from its tag if the module
    only records a version."""
    _, version, commit = pinned(group, package, name)
    if commit:
        return commit
    tags = releases(package["url"], package.get("tags", group.get("tags",
                                                             DEFAULT_TAGS)))
    if version not in tags:
        raise Skip(f"{name}: no tag for the pinned version {version}")
    return tags[version]


def source_tree(group, package, name):
    """A checkout of NAME at its pinned commit, for reading its lockfiles
    (so without Git LFS content, which those never are)."""
    return checkout(package["url"], pinned_commit(group, package, name))


# ---------------------------------------------------------------------------
# Finding and making one update.

def target(group, package, name, force_version=None):
    """Return what NAME should move to, as a dict, or None when it is
    already there.  FORCE_VERSION asks for that release, not the newest."""
    _, old_version, old_commit = pinned(group, package, name)
    if "branch" in package:
        commit = branch_head(package["url"], package["branch"])
        if commit == old_commit:
            return None
        return {"old": old_commit[:10], "new": commit[:10], "version": None,
                "old_version": None, "old_commit": old_commit,
                "commit": commit}
    tags = releases(package["url"],
                    package.get("tags", group.get("tags", DEFAULT_TAGS)))
    version = force_version or max(tags, key=version_key)
    if version not in tags:
        raise Skip(f"no release {version} in {package['url']} yet")
    commit = tags[version]
    if commit == old_commit or (version == old_version and not force_version):
        # The same version on another commit: pinned past the tag on purpose.
        return None
    if old_version and version_key(version) < version_key(old_version):
        raise Skip(f"pinned {old_version} is newer than the latest release "
                   f"{version}")
    return {"old": old_version, "new": version, "version": version,
            "old_version": old_version,
            "old_commit": old_commit or tags.get(old_version),
            "commit": commit}


def check_patches(package, tree):
    for patch in package.get("patches", []):
        result = subprocess.run(
            ["patch", "-p1", "--dry-run", "--force", "--batch", "-d", tree,
             "-i", os.path.join(ROOT, patch)],
            capture_output=True, text=True)
        if result.returncode != 0:
            failed = "\n".join(line for line in result.stdout.splitlines()
                               if "FAILED" in line or "can't find" in line
                               or "No such file" in line)
            raise Skip(f"the patch {patch} no longer applies:\n"
                       f"{failed or result.stdout.strip()[-600:]}")


def same(a, b):
    """Whether the files or directories A and B have the same content."""
    if os.path.isdir(a) != os.path.isdir(b) or \
       os.path.exists(a) != os.path.exists(b):
        return False
    if not os.path.exists(a):
        return True
    if not os.path.isdir(a):
        return filecmp.cmp(a, b, shallow=False)
    comparison = filecmp.dircmp(a, b)
    if comparison.left_only or comparison.right_only or comparison.funny_files:
        return False
    _, mismatch, errors = filecmp.cmpfiles(a, b, comparison.common_files,
                                           shallow=False)
    return not mismatch and not errors and all(
        same(os.path.join(a, d), os.path.join(b, d))
        for d in comparison.common_dirs)


def check_unchanged(package, tgt, tree):
    paths = package.get("unchanged", [])
    if not paths or not tgt["old_commit"]:
        return
    old = checkout(package["url"], tgt["old_commit"],
                   package.get("lfs", False))
    changed = [path for path in paths
               if not same(os.path.join(old, path), os.path.join(tree, path))]
    if changed:
        raise Skip("upstream changed " + ", ".join(changed) + ", which the "
                   "package's other pins are taken from: "
                   + package.get("unchanged-hint", "they need a look"))


NPM_TARBALL = re.compile(
    r'\(npm-tarball "(?P<path>[^"]+)"\s+"(?P<hash>[0-9a-z]{52})"\)')
NPM_REGISTRY = "https://registry.npmjs.org/"


def update_npm_tarballs(file, lock_file):
    """Move each (npm-tarball ...) in FILE to the version LOCK_FILE locks.
    Return notes on what changed."""
    with open(lock_file, encoding="utf-8") as f:
        locked = json.load(f)["packages"]
    notes = []
    while True:
        text = read(file)
        for match in NPM_TARBALL.finditer(text):
            name = match.group("path").split("/-/")[0]
            entry = locked.get(f"node_modules/{name}")
            if entry is None:
                raise Skip(f"{name} is no longer in the package lock; the "
                           f"build needs a look")
            resolved = entry.get("resolved", "")
            if not resolved.startswith(NPM_REGISTRY):
                raise Skip(f"{name} is not locked to the npm registry")
            path = resolved.removeprefix(NPM_REGISTRY)
            if path == match.group("path"):
                continue
            write(file, replace_groups(text, match,
                                       {"path": path,
                                        "hash": download_hash(resolved)}))
            notes.append(f"npm {name} -> {entry['version']}")
            break               # positions moved: read the file again
        else:
            return notes


def apply(group, package, name, tgt):
    """Rewrite NAME's pins for the update TGT.  Return (notes, README
    changes); raise Skip, leaving files half-changed, if it can't be done."""
    file = package_file(group, package)
    tree = checkout(package["url"], tgt["commit"], package.get("lfs", False))
    check_patches(package, tree)
    check_unchanged(package, tgt, tree)

    match = current_pin(group, package, name)
    groups = match.re.groupindex
    values = {"hash": nar_hash(tree)}
    if "commit" in groups:
        values["commit"] = tgt["commit"]
    if "version" in groups and tgt["version"]:
        values["version"] = tgt["version"]
    text = replace_groups(read(file), match, values)
    # The commit also appears where a build can't read it from .git, and
    # the tag in comments.
    if tgt["old_commit"]:
        text = text.replace(tgt["old_commit"], tgt["commit"])
    if tgt["old_version"] and tgt["version"]:
        text = text.replace(f";tag v{tgt['old_version']}",
                            f";tag v{tgt['version']}")
    write(file, text)

    notes, readme = [], []
    if "version" in values:
        readme.append((name, tgt["old_version"], tgt["version"]))

    # Files fetched next to the source, such as a prebuilt release asset.
    for entry in package.get("downloads", []):
        url = entry["url"].replace("{version}", tgt["version"] or "")
        found = unique_match(entry["pin"], file, f"a download of `{name}'")
        write(file, replace_groups(read(file), found,
                                   {"hash": download_hash(url)}))

    # Version strings read from the source's own files.
    for entry in package.get("versions", []):
        found = unique_match(entry["pin"], file,
                             f"the version of `{entry['name']}'")
        before, after = found.group("version"), version_in(tree,
                                                           entry["source"])
        if after != before:
            write(file, replace_groups(read(file), found, {"version": after}))
            notes.append(f"{entry['name']} {before} -> {after}")
            readme.append((entry["name"], before, after))

    if "npm-lock" in package:
        notes += update_npm_tarballs(file,
                                     os.path.join(tree, package["npm-lock"]))
    return notes, readme


# ---------------------------------------------------------------------------
# Generated dependency modules.

def crate_projects(crates_file):
    """The projects of a generated crates module, in its own order."""
    export = re.search(r"#:export \(([^)]*)\)", read(crates_file)).group(1)
    return [s.removesuffix("-cargo-inputs")
            for s in export.split() if s.endswith("-cargo-inputs")]


def project_source(group, project):
    """Return (package name, package, lockfile path) for PROJECT of the
    group's crates module, or None if updates.toml doesn't cover it."""
    spec = group.get("projects", {}).get(project)
    if spec:
        return (spec["package"], group["packages"][spec["package"]],
                spec.get("lock", "Cargo.lock"))
    package = group["packages"].get(project)
    if package is None:
        return None
    return project, package, package.get("lock", "Cargo.lock")


def regenerate(group):
    """Rebuild the dependency modules of GROUP from its pinned sources."""
    if "crates" in group:
        args = []
        for project in crate_projects(group["crates"]):
            source = project_source(group, project)
            if source is None:
                raise Skip(f"{group['crates']} also covers `{project}', "
                           f"which updates.toml doesn't list")
            name, package, lock_path = source
            lock = os.path.join(source_tree(group, package, name), lock_path)
            if not os.path.exists(lock):
                raise Skip(f"{project}: no {lock_path} in its source")
            args.append(f"{project}={lock}")
        run(sys.executable,
            os.path.join(ROOT, "contrib/cargo-lock-to-guix.py"),
            group["module"], os.path.join(ROOT, group["crates"]), *args)
    for command in group.get("generate", []):
        argv = []
        for word in command:
            m = re.fullmatch(r"\{src:([^}]+)\}(.*)", word)
            if m:
                package = group["packages"][m.group(1)]
                word = source_tree(group, package, m.group(1)) + m.group(2)
            argv.append(sys.executable if word == "{python}" else word)
        run(*argv, cwd=ROOT)
    for path in group_files(group):
        if path.endswith(".scm") and not balanced(path):
            raise Skip(f"{path} no longer reads as Scheme after the update")


def update_readme(changes):
    readme = updated = read("README.md")
    for name, before, after in changes:
        if before and after:
            updated = updated.replace(f"`{name}` {before}",
                                      f"`{name}` {after}")
    if updated != readme:
        write("README.md", updated)


# ---------------------------------------------------------------------------
# Updating a package, or a whole group at once.

def update_package(group, name, package, check_only):
    """Return a result dict, or None when NAME is up to date."""
    tgt = target(group, package, name)
    if tgt is None:
        return None
    result = {"name": name, "url": package["url"], "old": tgt["old"],
              "new": tgt["new"], "old_commit": tgt["old_commit"],
              "commit": tgt["commit"], "notes": [],
              "builds": package.get("builds", [name])}
    if check_only:
        return result
    result["notes"], readme = apply(group, package, name, tgt)
    regenerate(group)
    update_readme(readme)
    return result


def update_group(group_name, group, check_only):
    """Move every package of an `atomic' group to one release together.
    Return a result dict, or None when the group is up to date."""
    members = {name: package for name, package in group["packages"].items()
               if not package.get("frozen")}
    old_version = group_version(group)
    tags = group.get("tags", DEFAULT_TAGS)
    newest = {name: max(releases(package["url"], package.get("tags", tags)),
                        key=version_key)
              for name, package in members.items()}
    version = max(newest.values(), key=version_key)
    if version == old_version:
        return None
    if version_key(version) < version_key(old_version):
        raise Skip(f"pinned {old_version} is newer than the latest release "
                   f"{version}")
    behind = sorted(name for name, v in newest.items() if v != version)
    if behind:
        # A release in progress; not a failure.
        print(f"{group_name}: waiting, {version} is not tagged yet in "
              f"{', '.join(behind)}")
        return None
    result = {"name": group_name, "url": group.get("url", ""),
              "old": old_version, "new": version, "old_commit": None,
              "commit": None, "notes": [],
              "builds": group.get("builds", [group_name])}
    if check_only:
        return result
    readme = [(group_name, old_version, version)]
    for name, package in members.items():
        tgt = target(group, package, name, force_version=version)
        if tgt is None:
            continue
        notes, changes = apply(group, package, name, tgt)
        result["notes"].append(f"{name} -> {tgt['commit'][:10]}")
        result["notes"] += notes
        readme += changes
    found = unique_match(group["version-pin"], group["file"],
                         "the group's version")
    write(group["file"], replace_groups(read(group["file"]), found,
                                        {"version": version}))
    regenerate(group)
    update_readme(readme)
    if "readme-version" in group:
        # How the README names the group's release, e.g. "epoch {version}".
        write("README.md", read("README.md").replace(
            group["readme-version"].replace("{version}", old_version),
            group["readme-version"].replace("{version}", version)))
    return result


# ---------------------------------------------------------------------------
# Checking the manifest.

def lint(groups):
    """Check the manifest against the channel; return the problems found."""
    problems = []
    for group_name, group in groups.items():
        for name, package in group["packages"].items():
            file = package_file(group, package)
            try:
                current_pin(group, package, name)
                for entry in package.get("versions", []):
                    unique_match(entry["pin"], file,
                                 f"the version of `{entry['name']}'")
                for entry in package.get("downloads", []):
                    unique_match(entry["pin"], file,
                                 f"a download of `{name}'")
            except Skip as reason:
                problems.append(f"{name}: {reason}")
            for patch in package.get("patches", []):
                if not os.path.exists(os.path.join(ROOT, patch)):
                    problems.append(f"{name}: no such patch: {patch}")
        try:
            group_version(group)
        except Skip as reason:
            problems.append(f"{group_name}: {reason}")
        if "crates" in group:
            for project in crate_projects(group["crates"]):
                if project_source(group, project) is None:
                    problems.append(f"{group['crates']} covers `{project}', "
                                    f"which updates.toml doesn't list")
    for directory, _, files in os.walk(os.path.join(ROOT, "hyperguix")):
        for file in files:
            if file.endswith((".scm", ".scm.in")):
                path = os.path.relpath(os.path.join(directory, file), ROOT)
                if not balanced(path):
                    problems.append(f"{path}: unbalanced parentheses or "
                                    f"an unterminated string")
    return problems


# ---------------------------------------------------------------------------

def commit_update(files, result):
    subprocess.run(["git", "-C", ROOT, "add", "--", *files], check=True)
    body = (f"{result['url']}\n" if result["url"] else "")
    if result["commit"] and result["old_commit"]:
        body += f"{result['old_commit']} -> {result['commit']}\n"
    body += "".join(f"{note}\n" for note in result["notes"])
    subprocess.run(
        ["git", "-C", ROOT, "commit", "-q", "-m",
         f"{result['name']}: update to {result['new']}\n\n{body}\n"
         "Automated update: the source was fetched and hashed and the "
         "patches apply; nothing was built."],
        check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--lint", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--commit", action="store_true")
    parser.add_argument("--summary")
    parser.add_argument("--failures")
    parser.add_argument("packages", nargs="*")
    options = parser.parse_args()

    with open(os.path.join(ROOT, "contrib/updates.toml"), "rb") as f:
        groups = tomllib.load(f)["group"]

    if options.lint:
        problems = lint(groups)
        for problem in problems:
            print(problem, file=sys.stderr)
        print(f"{len(problems)} problems")
        sys.exit(1 if problems else 0)

    # The units of work: (name, group, package or None for a whole group).
    units = []
    for group_name, group in groups.items():
        if group.get("atomic"):
            units.append((group_name, group, None))
        else:
            units += [(name, group, package)
                      for name, package in group["packages"].items()
                      if not package.get("frozen")]
    known = {name for name, _, _ in units}
    unknown = set(options.packages) - known
    if unknown:
        sys.exit(f"not in contrib/updates.toml: {', '.join(sorted(unknown))}")

    updated, current, failed = [], [], []
    for name, group, package in units:
        if options.packages and name not in options.packages:
            continue
        files = group_files(group)
        try:
            if package is None:
                result = update_group(name, group, options.check)
            else:
                result = update_package(group, name, package, options.check)
        except Skip as reason:
            # Leave no half-made change behind.
            if not options.check:
                subprocess.run(["git", "-C", ROOT, "checkout", "--", *files],
                               check=True)
            url = package["url"] if package else group.get("url", "")
            failed.append({"name": name, "reason": str(reason), "url": url})
            print(f"{name}: FAILED: {reason}", file=sys.stderr)
            continue
        if result is None:
            current.append(name)
            print(f"{name}: up to date")
            continue
        updated.append(result)
        print(f"{name}: {result['old']} -> {result['new']}"
              + "".join(f"\n  {note}" for note in result["notes"]))
        if options.commit and not options.check:
            commit_update(files, result)

    if options.failures:
        with open(options.failures, "w", encoding="utf-8") as f:
            json.dump({"failed": failed,
                       "fine": current + [r["name"] for r in updated]}, f,
                      indent=1)

    if options.summary:
        verb = "out of date" if options.check else "updated"
        lines = []
        if updated:
            lines += [f"### Packages {verb}", "",
                      "| Package | From | To | Changes |", "|---|---|---|---|"]
            for r in updated:
                compare = (f"[compare]({r['url']}/compare/"
                           f"{r['old_commit'][:10]}...{r['commit'][:10]})"
                           if r["commit"] and r["old_commit"] else "")
                extra = "".join(f"<br>{note}" for note in r["notes"])
                lines.append(f"| `{r['name']}` | {r['old']} | {r['new']}"
                             f"{extra} | {compare} |")
            lines += ["", "Nothing was built. To build them:", "", "```sh",
                      "guix build -L . " + " ".join(
                          " ".join(r["builds"]) for r in updated),
                      "```", ""]
        if failed:
            lines += ["### Could not be updated", ""]
            lines += [f"- `{f['name']}`: {f['reason']}" for f in failed]
            lines.append("")
        if not updated and not failed:
            lines += ["Everything in `contrib/updates.toml` is at its latest "
                      "release.", ""]
        with open(options.summary, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

    print(f"\n{len(updated)} {'out of date' if options.check else 'updated'}, "
          f"{len(current)} up to date, {len(failed)} failed")


if __name__ == "__main__":
    main()
