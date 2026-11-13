# AGENTS.md

Notes for whoever maintains this channel, human or coding agent. The
README is for people *using* the channel: what it is, how to add it, the
package table and how the packages behave at run time. Everything about
working *on* the channel goes here instead.

## What this is

A Guix channel. Package modules are `Lightningbulb/packages/NAME.scm`,
named `(Lightningbulb packages NAME)`. It depends on nonguix
(`.guix-channel`).

Related repositories:

- `Lightningbulb2/MyGuixConfig` (private): the owner's `config.scm`, which
  pins this channel. `~/config.scm` is a symlink into its checkout.
- `Lightningbulb2/FineConfig`: a fill-in template of that config. It holds
  exactly three files (README.md, config.scm, LICENSE); keep its structure
  and its hyperguix pin in step when the config's design changes.
- `Lightningbulb2/CodeCanvas`: source of `codecanvas` (`rust/`) and
  `codecanvas-vscode` (`vscode/`).

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

- `Lightningbulb/packages/*.scm`: package modules (see the README table).
- `Lightningbulb/packages/aux-files/`: patches, launcher scripts and other
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
- State is in `~/.local/state/guix-bump`: `previous-pins.scm` (for `--undo`)
  and the logs written by `--log`.
- To try a change without installing it: build the package, then run with
  `GUIX_EXTENSIONS_PATH=$(guix build -L . guix-bump)/share/guix/extensions`
  and `GUIX_BUMP_CONFIG` pointing at a scratch copy of the config.

## Automated updates (GitHub Actions)

- `contrib/updates.toml` lists the packages that are updated mechanically:
  for each, the upstream repository and a regular expression that finds its
  version, commit and hash in the module. `contrib/auto-update.py` moves
  them to the newest release tag and regenerates the group's crates module.
  `--check` only reports; `--lint` checks the manifest offline.
- `.github/workflows/update-packages.yml` runs it daily and on demand, one
  commit per package, onto the branch `auto-update` with a pull request
  (or straight to `main` if the repository variable `AUTO_UPDATE_TARGET` is
  `main`). `.github/workflows/check.yml` runs `--lint` on every push.
- **The workflow builds nothing.** It proves the source can be fetched and
  hashed and that the modules still read as Scheme. Build the updated
  packages (`guix build -L . PACKAGE...` on the `auto-update` branch) before
  merging; the pull request lists the command.
- Add a package to `updates.toml` only if its update needs no judgment.
  Packages with patches against upstream (COSMIC, Ladybird, Xwayland) stay
  manual. Every project of a shared crates module must be listed.
- When you reformat a pin by hand, run `python3 contrib/auto-update.py
  --lint`: a pin the pattern no longer finds is silently never updated
  otherwise.

## Updating

Each package pins an upstream commit or tag and its hash. To move to a new
one, change `commit`/`version`, set the hash to zeros, build once
(`guix build -L . -S PACKAGE`) and paste the reported hash.

Then regenerate its dependency module from the new lockfiles:

```sh
# Rust packages with git dependencies (COSMIC, Craft, Ladybird):
python3 contrib/cargo-lock-to-guix.py "Lightningbulb packages cosmic-crates" \
        Lightningbulb/packages/cosmic-crates.scm NAME=path/to/Cargo.lock ...
# scrcpy-gui and the FAForever client (Cargo.lock + npm/pnpm locks):
python3 contrib/update-lockfile-deps.py Lightningbulb/packages \
        ~/src/scrcpy-gui ~/src/FAForeverRustClient
# r2modman (pnpm-lock.yaml; also takes the pnpm version as a 5th argument):
python3 contrib/pnpm-lock-to-guix.py "Lightningbulb packages r2modman-deps" \
        Lightningbulb/packages/r2modman-deps.scm r2modman path/to/pnpm-lock.yaml
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
