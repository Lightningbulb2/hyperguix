# AGENTS.md

Notes for whoever maintains this channel, human or coding agent. The
README is for people *using* the channel: what it is, how to add it, the
package table and how the packages behave at run time. Everything about
working *on* the channel goes here instead.

## What this is

A Guix channel. Package modules are `hyperguix/packages/NAME.scm`,
named `(hyperguix packages NAME)`. It depends on nonguix
(`.guix-channel`).

Related repositories:

- `Lightningbulb2/MyGuixConfig` (private): the owner's `config.scm`, which
  pins this channel. `~/config.scm` is a symlink into its checkout.
- `Lightningbulb2/FineConfig`: a fill-in template of that config. It holds
  exactly three files (README.md, config.scm, LICENSE); keep its structure
  and its hyperguix pin in step when the config's design changes.
- `Lightningbulb2/CodeCanvas`: source of `codecanvas` (`rust/`),
  `codecanvas-vscode` (`vscode/`) and `codecanvas-zed-bridge` (`zed/`), all
  at one pinned commit. The automated updates follow its `main` branch:
  every push there becomes an update (commit, hash, the three version
  strings, the npm tarballs the VS Code build unpacks, and the crates
  module).
- `Lightningbulb2/AskBash`: source of `ask` (plain Python, no dependency
  module). The automated updates follow its `main` branch. The package
  wires in `llama-cpp/latest`, `man-db` and `bubblewrap` by `substitute*`
  on `ask/config.py` and `ask/sources.py`, and a phase checks that each
  substitution took. The models and the index are per user, not packaged.

## Workflow

1. Edit, then build what you touched: `guix build -L . PACKAGE`.
2. Commit and **push** (`main`). The config fetches this channel from
   GitHub, so an unpushed commit does not exist as far as Guix is concerned.
3. `guix bump hyperguix` moves the pin in the config and pulls; add `-H` to
   install into the home environment, `-S` for system packages and services.

Never tell the owner to `guix install` or `guix upgrade` something: the
config is the only description of the machine.

## Conventions

- **Commits:** a plain description of the change. No tool or AI attribution
  of any kind (no `Co-Authored-By` trailers, no "generated with" lines), in
  commit messages, PR text or files. Commit with the identity configured in
  the repository (a GitHub no-reply address); never a personal email.
- **Fix causes, not symptoms.** When one package fails for a reason that
  could affect its siblings (a toolchain change, a helper), check them too.
- **Say what was tested.** "Built" means `guix build` succeeded here;
  "evaluated" means only a dry run; say which, and what was not run.
- **Don't reconfigure for the owner.** Building and pulling are fine;
  `guix home reconfigure` and `sudo guix system reconfigure` are theirs to
  run unless they ask.
- **`.scm` files anywhere in the channel are compiled by `guix pull`.** A
  Scheme file that is not a channel module (for example the `guix bump`
  extension sources in `aux-files/guix-bump/`) must not end in `.scm`: use
  `.scm.in` and rename it at install time.
- **Generated modules are never edited by hand** (list below).
- `reboot-to-bios.scm` is the owner's own module; don't regenerate it.
- Keep the README's package table current when adding, removing or bumping
  a package. Maintenance notes go in this file, not the README.

## Layout

- `hyperguix/packages/*.scm`: package modules (see the README table).
- `hyperguix/packages/aux-files/`: patches, launcher scripts and other
  files the packages install.
- `contrib/`: generators for the dependency modules, and the updater.
- `.github/workflows/`: automated updates and checks.

Support modules:

- **Generated** (never edit by hand): `cosmic-crates.scm`, `craft-crates.scm`,
  `ladybird-crates.scm`, `rust-crates.scm`, `node-deps.scm`,
  `r2modman-deps.scm`, `solidcraft-crates.scm`, `codecanvas-crates.scm`.
- `rust-next.scm`: `rust-1.97` (Guix master's definition, bootstrapped from
  the pinned Guix's rust-1.96), until the Guix pin has it.
- `cargo-git.scm` with `aux-files/vendor-git-crates.py` vendors crates that
  lockfiles take from git, as `cargo vendor` would, so cargo builds offline.
  It drops `[dev-dependencies]` and the feature entries that name them, and
  `contrib/cargo-lock-to-guix.py` also vendors `[[patch.unused]]` git crates.
- `js-offline.scm` serves pinned npm tarballs from a throw-away 127.0.0.1
  registry during a build, so `npm ci` / `pnpm install --frozen-lockfile` run
  unmodified.
- `aux-files/` holds patches and launcher scripts the packages install.

## `guix bump` and `guix nightly`

Package `guix-bump`; sources `aux-files/guix-bump/bump.scm.in` and
`nightly.scm.in`, installed as Guix extensions (`share/guix/extensions`).

- It finds every `(channel ...)` form in the config by scanning the text
  (comments and strings skipped) and rewrites the `(commit "...")` inside.
  It never evaluates the config.
- The config file is `$GUIX_BUMP_CONFIG` or `~/config.scm`, resolved through
  symlinks. If it is in a git repository, each change that was pulled or
  applied is committed and pushed.
- `guix bump --check` lists installed packages (home and system profile
  manifests) whose version differs in the Guix of the latest commits. It
  reads those versions with `guix time-machine -C` on a temporary copy of
  the config with the pins moved, so it costs what a pull costs the first
  time, and changes nothing.
- `guix bump APP`: a name that is not a channel is a package. Its channel
  (`package-channels`, preferring any channel other than `guix`) is bumped
  and pulled, then the home is applied, or the system if that is where the
  package is installed. `guix` asks first and takes `nonguix` along.
- After applying, it lists what changed version, which of those are still
  running from the old store item (`/proc/*/exe` and `cmdline`), and
  suggests a reboot when `/run/current-system/kernel` differs from
  `/run/booted-system/kernel`.
- With `home-with-system-service` in the config (the system applies the
  home), `--system` covers the home and no separate home reconfigure runs.
- `guix-updates` (source `aux-files/guix-bump/updates.py.in`, Python with
  GTK 4, libadwaita and VTE) is the window "Updates". It only reads `guix
  bump --check --porcelain` (tab-separated `channel` / `package` lines,
  then `done`, on standard output) and runs `guix bump ...` commands in its
  terminal pane; keep all logic in `bump.scm.in`. Don't launch it from a
  shell with `LD_LIBRARY_PATH` set (a session started by another app): a
  second GLib breaks PyGObject.
- State is in `~/.local/state/guix-bump`: `previous-pins.scm` (for `--undo`)
  and the logs written by `--log`.
- To try a change without installing it: build the package, then run with
  `GUIX_EXTENSIONS_PATH=$(guix build -L . guix-bump)/share/guix/extensions`
  and `GUIX_BUMP_CONFIG` pointing at a scratch copy of the config.

## Automated updates (GitHub Actions)

- `contrib/updates.toml` lists what is updated automatically, and documents
  its own keys. `contrib/auto-update.py` does the work: `--check` only
  reports, `--lint` checks the manifest offline. Run it locally under
  `guix shell python python-pyyaml curl git-lfs --` (the npm/pnpm
  generators need PyYAML, the COSMIC LFS sources git-lfs).
- What an update is, by kind of package:
  - **Release tags** (Craft suite, SolidCraft, MailCraft, Isocast, Pandora,
    scrcpy, scrcpy-gui, FAForever, r2modman): newest tag; version, commit,
    hash; dependency modules regenerated (crates, npm, pnpm); scrcpy's
    prebuilt server re-hashed.
  - **A branch** (CodeCanvas `main`, AskBash `main`, Ladybird `master`):
    every new head.
  - **A whole release** (COSMIC, `atomic`): all components move to the same
    `epoch-X.Y.Z` tag in one commit, once every component has the tag.
- **Guards**, each of which turns the update into a failure instead of a
  commit: a patch listed under `patches` no longer applies (`patch
  --dry-run` against the new source); a path listed under `unchanged`
  differs between the old and new source (FAForever's `scripts/ensure-*.mjs`,
  which name the helper binaries pinned by hand; Ladybird's
  `Meta/CMake/vcpkg`, which Skia/ANGLE/FFmpeg/pdf.js follow); a download or
  a generator fails; a module no longer reads as Scheme.
- `.github/workflows/update-packages.yml` runs it daily and on demand, one
  commit per update, merged straight into `main` after `--lint` passes.
  (Set the repository variable `AUTO_UPDATE_TARGET` to `pull-request` to get
  a branch `auto-update` and a pull request to review instead.) Each failure
  opens an issue labelled `auto-update`, titled "Automatic update failed:
  NAME"; it is closed by the first run in which NAME is fine. Fixing one
  means doing that update by hand.
  `.github/workflows/check.yml` runs `--lint` on every push.
- **The workflow builds nothing**, and the owner chose to merge anyway and
  fix afterwards. So `main` can hold an update that doesn't compile: when a
  build fails right after an "update to" commit, fix the package or `git
  revert` that one commit (each update is its own commit for this reason),
  then push.
- Not covered, and why: `xwayland-with-idle-time` has no pin of its own (it
  patches the Xwayland of the pinned Guix, so it moves with the `guix`
  channel pin); the smithay patch applies to a vendored crate, not to a
  component's source; `substitute*` edits can't be checked without a build;
  COSMIC's explicit `#:version` strings (cosmic-comp, cosmic-workspaces,
  pop-launcher) and the craft-fonts pins are left alone.
- When you reformat a pin by hand, add a patch, or add a project to a
  shared crates module, update `updates.toml` and run `--lint`: a pin the
  pattern no longer finds is never updated, and a patch that isn't listed is
  never checked.

## Updating

Each package pins an upstream commit or tag and its hash. To move to a new
one, change `commit`/`version`, set the hash to zeros, build once
(`guix build -L . -S PACKAGE`) and paste the reported hash.

Then regenerate its dependency module from the new lockfiles:

```sh
# Rust packages with git dependencies (COSMIC, Craft, Ladybird):
python3 contrib/cargo-lock-to-guix.py "hyperguix packages cosmic-crates" \
        hyperguix/packages/cosmic-crates.scm NAME=path/to/Cargo.lock ...
# scrcpy-gui and the FAForever client (Cargo.lock + npm/pnpm locks):
python3 contrib/update-lockfile-deps.py hyperguix/packages \
        ~/src/scrcpy-gui ~/src/FAForeverRustClient
# r2modman (pnpm-lock.yaml; also takes the pnpm version as a 5th argument):
python3 contrib/pnpm-lock-to-guix.py "hyperguix packages r2modman-deps" \
        hyperguix/packages/r2modman-deps.scm r2modman path/to/pnpm-lock.yaml
```

The generators need git, network access and `guix hash`; set
`GIT_CACHE_DIR` to reuse checkouts between runs.

Upstream HEAD is sometimes an automated dependency bump that doesn't
compile (cadcraft and soundcraft both had one). When a build fails in
upstream code right after such a bump, look for a later "fix build" commit
upstream before suspecting the generator.

Before rebuilding, check that each `substitute*` pattern still matches the
new source: in this Guix a pattern that matches nothing is **not** an error,
so a stale patch silently does nothing.

Pitfalls for new Rust packages:

- Use `#:rust rust-1.95` (or newer); the default `rust` is too old.
- cargo-build-system forces system libraries through `*_SYS_USE_PKG_CONFIG`
  and similar variables: grep each `Cargo.lock` for `libgit2-sys`,
  `libsqlite3-sys`, `zstd-sys`, `onig_sys`, `libsodium-sys`, `libssh2-sys`
  and add the matching inputs.
- `-sys` crates that build bundled C code may need `cmake` (`aws-lc-sys`);
  prefer the system library. Check `[target.'cfg(...)']` sections first:
  many -sys crates in lockfiles only build on Windows or macOS.
- No `/usr/bin/env`, no `.git` and no network in the build sandbox.
- Repositories that keep images in Git LFS need `git-fetch/lfs`; a plain
  checkout only has text pointers (`cosmic-wallpapers`,
  `cosmic-initial-setup`, `cosmic-greeter` use `#:lfs? #t`).

## Channel pins and updating a single app

The config pins every channel to a commit, this one included; `guix bump`
moves the pins. A `guix` commit pins *every* package Guix provides, so
bumping it updates (and may rebuild) everything at once.

- **Packages in this channel** pin their own upstream commits. Updating one
  (see *Updating*) changes only that package, whatever the `guix` pin.
- **A newer version of a package Guix itself provides**: add an override to
  this channel that inherits the Guix package and changes only its version
  and source. It builds against the pinned Guix, nothing else moves, and it
  stays reproducible:

  ```scheme
  (define-public foo/newer
    (package
      (inherit foo)
      (version "1.2.3")
      (source (origin
                (inherit (package-source foo))
                (uri ...)                ;same form as Guix's, new version
                (sha256 (base32 "..."))))))
  ```

  Then use `foo/newer` instead of `foo` in the config.
- **When a newer Guix's whole recipe is needed** (new dependencies, a
  rewritten build): take just that package from a newer Guix commit with an
  inferior (`(guix inferior)`, `inferior-for-channels`). It costs a one-time
  build of that Guix, and the package brings its own newer dependencies.
- Transformations such as `--with-version`/`with-latest` are quick but not
  hash-pinned, so not reproducible; avoid them in the config.
- Bump the `guix` pin deliberately (for example monthly, for security fixes)
  and `nonguix` together with it: `guix bump guix nonguix`. The config's git
  history records every set of pins that was pulled.
