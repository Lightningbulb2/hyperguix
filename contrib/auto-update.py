#!/usr/bin/env python3
"""Move the packages listed in contrib/updates.toml to their latest release.

For each package: find the newest release tag upstream (or, for a package
that tracks a branch, the branch's head); if the pin in the channel is on
another commit, fetch it, compute its hash, rewrite the version, commit and
hash in the package module, regenerate the crates module its group shares
(contrib/cargo-lock-to-guix.py) and update the version in the README's
package table.  A source that holds several packages can list further
version strings to read from its files, and npm tarballs to keep in step
with a package-lock.json.

Usage:
  auto-update.py [--check] [--commit] [--summary FILE] [PACKAGE ...]
  auto-update.py --lint

  --lint          check updates.toml against the channel, offline: every
                  pin is found exactly once, every project of a crates
                  module is listed, and every .scm file reads as Scheme
  --check         only report what is out of date; change nothing
  --commit        make one git commit per updated package
  --summary FILE  write a Markdown report there (appended)
  PACKAGE ...     only look at these packages

This checks that sources can be fetched and that the modules still read as
Scheme.  It does NOT build anything: build an updated package with
`guix build -L . PACKAGE' before relying on it.

Needs Python 3.11+, git, network access and `guix hash' (or nix-hash).
Checkouts are kept in $GIT_CACHE_DIR (default ~/.cache/lightningbulb-git).
"""
import argparse
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


class Skip(Exception):
    """This package cannot be updated; the message says why."""


def run(*args, **kw):
    result = subprocess.run(args, capture_output=True, text=True, **kw)
    if result.returncode != 0:
        raise Skip(f"`{' '.join(args)}` failed: "
                   f"{(result.stderr or result.stdout).strip()[-400:]}")
    return result.stdout


def read(path):
    with open(os.path.join(ROOT, path), encoding="utf-8") as f:
        return f.read()


def write(path, text):
    with open(os.path.join(ROOT, path), "w", encoding="utf-8") as f:
        f.write(text)


def version_key(version):
    return [int(part) for part in version.split(".")]


def latest_release(url, tags_rx):
    """Return (version, commit) of the newest tag of URL matching TAGS_RX."""
    out = run("git", "ls-remote", "--tags", url,
              env={**os.environ, "GIT_TERMINAL_PROMPT": "0"})
    commits = {}                # tag -> commit; "^{}" lines win
    for line in out.splitlines():
        commit, ref = line.split("\t")
        tag = ref.removeprefix("refs/tags/")
        if tag.endswith("^{}"):  # the commit an annotated tag points at
            commits[tag[:-3]] = commit
        else:
            commits.setdefault(tag, commit)
    releases = []
    for tag, commit in commits.items():
        m = re.match(tags_rx, tag)
        if m:
            releases.append((version_key(m.group(1)), m.group(1), commit))
    if not releases:
        raise Skip(f"no release tag matching {tags_rx} in {url}")
    _, version, commit = max(releases)
    return version, commit


def checkout(url, commit):
    """Return a directory holding URL at COMMIT, without .git."""
    key = hashlib.sha1(f"update:{url}@{commit}".encode()).hexdigest()[:12]
    d = os.path.join(CACHE, key)
    if not os.path.exists(os.path.join(d, ".lb-done")):
        shutil.rmtree(d, ignore_errors=True)
        os.makedirs(CACHE, exist_ok=True)
        run("git", "init", "-q", d)
        run("git", "-C", d, "fetch", "-q", "--depth", "1", url, commit,
            env={**os.environ, "GIT_TERMINAL_PROMPT": "0"})
        run("git", "-C", d, "checkout", "-q", "FETCH_HEAD")
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


def pin_regex(group, package, name):
    pattern = package.get("pin", group["pin"]).replace("{name}",
                                                       re.escape(name))
    return re.compile(pattern, re.S)


def current_pin(group, package, name):
    text = read(group["file"])
    matches = list(pin_regex(group, package, name).finditer(text))
    if len(matches) != 1:
        raise Skip(f"the `pin' pattern matches {len(matches)} times in "
                   f"{group['file']} (expected once)")
    return matches[0]


def replace_groups(text, match, values):
    """Return TEXT with the named groups of MATCH replaced by VALUES."""
    for name, start in sorted(((n, match.start(n)) for n in values),
                              key=lambda item: -item[1]):
        text = text[:start] + values[name] + text[match.end(name):]
    return text


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
                spec["lock"])
    package = group["packages"].get(project)
    if package is None:
        return None
    return project, package, package.get("lock", "Cargo.lock")


def regenerate_crates(group):
    """Rebuild the group's crates module from every project's lockfile."""
    args = []
    for project in crate_projects(group["crates"]):
        source = project_source(group, project)
        if source is None:
            raise Skip(f"{group['crates']} also covers `{project}', which "
                       f"updates.toml doesn't list")
        name, package, lock_path = source
        commit = current_pin(group, package, name).group("commit")
        tree = checkout(package["url"], commit)
        lock = os.path.join(tree, lock_path)
        if not os.path.exists(lock):
            raise Skip(f"{project}: no {lock_path} at {commit[:10]}")
        args.append(f"{project}={lock}")
    run(sys.executable, os.path.join(ROOT, "contrib/cargo-lock-to-guix.py"),
        group["module"], os.path.join(ROOT, group["crates"]), *args)


def branch_head(url, branch):
    out = run("git", "ls-remote", url, f"refs/heads/{branch}",
              env={**os.environ, "GIT_TERMINAL_PROMPT": "0"})
    if not out.strip():
        raise Skip(f"no branch {branch} in {url}")
    return out.split()[0]


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
            with urllib.request.urlopen(resolved, timeout=60) as response:
                digest = hashlib.sha256(response.read()).digest()
            write(file, replace_groups(text, match,
                                       {"path": path,
                                        "hash": nix_b32(digest)}))
            notes.append(f"npm {name} -> {entry['version']}")
            break               # positions moved: read the file again
        else:
            return notes


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


def update(group, name, package, check_only):
    """Update one package.  Return (old, new, old commit, new commit, notes)
    where OLD and NEW are what to show (versions, or commits for a package
    that tracks a branch), or None when there is nothing to update."""
    match = current_pin(group, package, name)
    old_commit = match.group("commit")
    values = {}
    if "branch" in package:
        commit = branch_head(package["url"], package["branch"])
        if commit == old_commit:
            return None
        old, new = old_commit[:10], commit[:10]
    else:
        old = match.group("version")
        new, commit = latest_release(package["url"],
                                     package.get("tags", DEFAULT_TAGS))
        if commit == old_commit or new == old:
            # Same version on another commit: pinned past the tag on purpose.
            return None
        if version_key(new) < version_key(old):
            raise Skip(f"pinned {old} is newer than the latest release {new}")
        values["version"] = new
    notes = []
    if check_only:
        return old, new, old_commit, commit, notes

    tree = checkout(package["url"], commit)
    values.update(commit=commit, hash=nar_hash(tree))
    write(group["file"], replace_groups(read(group["file"]), match, values))
    readme_changes = [(name, old, new)] if "version" in values else []

    # Version strings read from the source's own files.
    for entry in package.get("versions", []):
        text = read(group["file"])
        found = list(re.compile(entry["pin"], re.S).finditer(text))
        if len(found) != 1:
            raise Skip(f"the version pattern of `{entry['name']}' matches "
                       f"{len(found)} times in {group['file']}")
        before = found[0].group("version")
        after = version_in(tree, entry["source"])
        if after != before:
            write(group["file"],
                  replace_groups(text, found[0], {"version": after}))
            notes.append(f"{entry['name']} {before} -> {after}")
            readme_changes.append((entry["name"], before, after))

    if "npm-lock" in package:
        notes += update_npm_tarballs(group["file"],
                                     os.path.join(tree, package["npm-lock"]))
    if "crates" in group:
        regenerate_crates(group)
    for path in filter(None, (group["file"], group.get("crates"))):
        if not balanced(path):
            raise Skip(f"{path} no longer reads as Scheme after the update")

    readme = updated = read("README.md")
    for package_name, before, after in readme_changes:
        updated = updated.replace(f"`{package_name}` {before}",
                                  f"`{package_name}` {after}")
    if updated != readme:
        write("README.md", updated)
    return old, new, old_commit, commit, notes


def lint(groups):
    """Check the manifest against the channel; return the problems found."""
    problems = []
    for group in groups.values():
        for name, package in group["packages"].items():
            try:
                current_pin(group, package, name)
            except Skip as reason:
                problems.append(f"{name}: {reason}")
            text = read(group["file"])
            for entry in package.get("versions", []):
                found = len(re.compile(entry["pin"], re.S).findall(text))
                if found != 1:
                    problems.append(f"{entry['name']}: the version pattern "
                                    f"matches {found} times in "
                                    f"{group['file']} (expected once)")
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


def touched_files(group):
    return [group["file"], *filter(None, [group.get("crates")]), "README.md"]


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--lint", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--commit", action="store_true")
    parser.add_argument("--summary")
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

    known = {name for group in groups.values() for name in group["packages"]}
    # Package name -> its manifest entry, for the report.
    groups_of = {name: package for group in groups.values()
                 for name, package in group["packages"].items()}
    unknown = set(options.packages) - known
    if unknown:
        sys.exit(f"not in contrib/updates.toml: {', '.join(sorted(unknown))}")

    updated, current, failed = [], [], []
    for group in groups.values():
        for name, package in group["packages"].items():
            if options.packages and name not in options.packages:
                continue
            files = touched_files(group)
            try:
                result = update(group, name, package, options.check)
            except Skip as reason:
                # Leave no half-made change behind.
                if not options.check:
                    subprocess.run(["git", "-C", ROOT, "checkout", "--",
                                    *files], check=True)
                failed.append((name, str(reason)))
                print(f"{name}: FAILED: {reason}", file=sys.stderr)
                continue
            if result is None:
                current.append(name)
                print(f"{name}: up to date")
                continue
            old_version, version, old_commit, commit, notes = result
            updated.append((name, package["url"], *result))
            print(f"{name}: {old_version} -> {version} "
                  f"({old_commit[:10]} -> {commit[:10]})"
                  + "".join(f"\n  {note}" for note in notes))
            if options.commit and not options.check:
                subprocess.run(["git", "-C", ROOT, "add", "--", *files],
                               check=True)
                subprocess.run(
                    ["git", "-C", ROOT, "commit", "-q", "-m",
                     f"{name}: update to {version}\n\n"
                     f"{package['url']}\n{old_commit} -> {commit}\n"
                     + "".join(f"{note}\n" for note in notes) + "\n"
                     "Automated update: the source was fetched and "
                     "hashed; nothing was built."],
                    check=True)

    if options.summary:
        verb = "out of date" if options.check else "updated"
        lines = []
        if updated:
            lines += [f"### Packages {verb}", "",
                      "| Package | From | To | Changes |", "|---|---|---|---|"]
            for (name, url, old_version, version, old_commit, commit,
                 notes) in updated:
                compare = f"{url}/compare/{old_commit[:10]}...{commit[:10]}"
                extra = "".join(f"<br>{note}" for note in notes)
                lines.append(f"| `{name}` | {old_version} | {version}{extra} "
                             f"| [compare]({compare}) |")
            lines += ["",
                      "Nothing was built. Before merging, build them from a "
                      "checkout of this branch:", "", "```sh",
                      "guix build -L . " + " ".join(
                          " ".join(groups_of[u[0]].get("builds", [u[0]]))
                          for u in updated),
                      "```", ""]
        if failed:
            lines += ["### Could not be updated", ""]
            lines += [f"- `{name}`: {reason}" for name, reason in failed]
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
