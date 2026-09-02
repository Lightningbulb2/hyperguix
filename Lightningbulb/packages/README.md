# faforever — a Guix channel for Forged Alliance Forever

A **personal/third-party Guix channel** (not upstream Guix material —
`faf-client` repackages an official binary release rather than building
from source; see "Why this isn't upstream Guix material" below).

Four files total:

- **`.guix-channel`** — channel declaration.
- **`faforever.scm`** — both packages, `faf-client` and `fhs-run`.
- **`faf-client-setup.py`** — the interactive setup script `faf-client`
  installs as `faf-client-setup`.
- **`README.md`** — this file.

(An earlier revision had 8 files across 3 extra packages — an
experimental from-source Gradle build, a from-scratch reimplementation
of `faf-linux`'s Proton-downloading approach, and a botched two-package
split. All three turned out to be unnecessary detours; see "Earlier
detours, dropped" at the bottom if you want the history.)

## What's here

- **`faf-client`** — the JavaFX lobby/matchmaking/patcher client
  ([downlords-faf-client](https://github.com/FAForever/downlords-faf-client),
  MIT), packaged by repackaging FAForever's own official prebuilt Linux
  release tarball. Installs two commands:
  - `faf-client` itself.
  - `faf-client-setup` — detects your existing Steam+Proton (or asks
    about plain Wine) setup for Supreme Commander: Forged Alliance,
    which you must already own, and writes `~/.faforever/client.prefs`.
- **`fhs-run`** — a general-purpose "run an arbitrary command inside
  Steam's FHS sandbox" tool, built from nonguix's own `nonguix-container`
  machinery (same library set nonguix's `steam` package uses). Needed
  because nonguix's `steam` package doesn't expose this itself — it's
  architecturally single-purpose (always launches Steam, nothing else),
  unlike nixpkgs' `steam-run`. `faf-client-setup` uses this to build the
  actual game launch command, since FAF needs full control over the
  exact executable and arguments (it launches its own patched game
  files, not just the vanilla Steam install) — `steam -applaunch`
  can't provide that; it only launches Steam's own configured
  executable with extra arguments tacked on.

## Using this channel

```scheme
(cons (channel
        (name 'faforever)
        (url "file:///path/to/this/directory"))
      %default-channels)
```

then `guix pull`, then `guix install faf-client` (this pulls in
`fhs-run` automatically via `propagated-inputs`). For local
iteration without the channel/pull step:

```sh
guix build -L /path/to/this/directory faf-client
guix build -L /path/to/this/directory fhs-run
```

## Setup, start to finish

1. `guix install faf-client` (brings in `fhs-run` with it).
2. Own Supreme Commander: Forged Alliance on Steam. In Steam, right-click
   it → Properties → Compatibility → force a specific Proton version,
   and run it once through Steam normally.
3. Run `faf-client-setup` (interactive, from a terminal) and follow the
   prompts. It should auto-detect Steam and the game; if not, it'll ask
   for the path manually.
4. Run `faf-client` to log in and play.

## Known risk areas

- **If you're updating from an older copy of this channel**: delete any
  leftover `faforever/` subdirectory (containing old `source.scm`,
  `lockfile.scm`, `fhs-run.scm` files from before the consolidation into
  one file) from your checkout. Guix tries to compile every module it
  finds in a channel; a leftover copy of the old `source.scm` will still
  produce a load warning (it used `(current-filename)`, which returns
  `#f` when loaded this way) even though nothing imports it anymore.

- **JDK version.** Needs Java ≥ 25 — check `guix search openjdk` if
  `faf-client` fails to build or run.
- **The source hash** in `faf-client`'s `origin` was computed by hand
  (downloaded the tarball, hashed it, converted to Guix's base32 myself).
  Double-check with `guix download` if it ever fails to verify.
- **`specification->package` lookups** for native-library/tool inputs
  mean a renamed/missing package in your Guix produces a clear error
  naming it, rather than a module-import failure — check `guix search
  <name>` if one comes up.
- **`fhs-run` is newer and less exercised** than `faf-client`. If
  something inside the sandbox can't find a file it expects (a missing
  `/usr/share/...` directory, say), that's the place to look first —
  it reuses nonguix's own library list, but the `env`-based invocation
  itself is new.
- **Sandboxed-home path rewriting.** nonguix's Steam sandbox
  bind-mounts `$HOME/.local/share/guix-sandbox-home` *at* `$HOME`
  itself, inside the container — so a path that's
  `$HOME/.local/share/guix-sandbox-home/foo` from outside the sandbox
  is just `$HOME/foo` from inside it. `faf-client-setup` correctly
  detects Steam using the *outside* (full) form, but the actual game
  launch command — reaper, steam-launch-wrapper, the Steam Linux
  Runtime entry point, Proton, and the game's own install path — all
  run *inside* the sandbox, and need the *short* form instead. Passing
  the outside form to something running inside it resolves to a
  nonexistent, doubly-nested path (confirmed in practice:
  `env: '.../guix-sandbox-home/.local/share/Steam/ubuntu12_32/reaper':
  No such file or directory`, even though that exact path is completely
  real from outside the sandbox). Fixed with a `to_sandbox_path()`
  rewrite applied specifically to those paths — not to
  `preferencesFile` or the vault/mods/maps directories, which the FAF
  *client* itself reads directly as a normal, unsandboxed process, and
  which correctly keep their real, full paths.
- **32-bit Vulkan**, only relevant if you go the plain-Wine (not
  Steam/Proton) route — Steam/Proton already handles this if you're
  using that path instead.

## Why this isn't upstream Guix material

`faf-client` is binary repackaging — reusing FAForever's own
already-built release rather than compiling from source, which Guix's
own package collection doesn't accept regardless of licensing. The one
actually-nonfree piece of the official release — install4j's bundled
runtime/launcher — is deliberately excluded and confirmed unnecessary
(the jar's own manifest shows the real entry point runs fine with a
plain classpath invocation).

`fhs-run` is a reasonable, generally-useful tool that could plausibly
belong in nonguix itself someday, since the gap it fills (no general
FHS-sandbox-entry mechanism outside of Steam specifically) presumably
affects other games/launchers too, not just FAF.

## Earlier detours, dropped

This channel went through a few wrong turns before landing here. Kept
brief for context; ask if you want the full reasoning behind any of it.

1. **First attempt split this into two packages** (`faf-client` +
   `faf-linux`) and tried to reimplement
   [faf-linux](https://github.com/FAForever/faf-linux)'s approach of
   downloading a Steam Runtime image, a GloriousEggroll Proton-GE build,
   DXVK, and a JDK at setup time. Unnecessary — the actual job is
   "detect Steam+Proton and write a config file," not "redistribute a
   Wine/Proton stack," which is what led to today's single-package,
   `faf-client-setup`-based design instead (credit to
   [nix-gaming](https://github.com/fufexan/nix-gaming)'s `faf-client`
   for the actual shape of this approach).
2. **A from-source `faf-client-src`** was built next, using a real,
   tested port of nixpkgs' Gradle-dependency-lockfile decompression
   algorithm plus a new `mitm-cache`-based build (nonguix has
   `mitm-cache`, confirmed from real source) to satisfy Gradle's
   ~195-jar dependency tree without network access mid-build. It worked
   as infrastructure but was never actually needed to get FAF running,
   and having it around materially added to the "too many files" problem
   — dropped for now. The reasoning and a working design are preserved
   in conversation history if you want to resurrect it later.
3. **`steam -applaunch`** was tried as a `fhs-run` alternative before
   `fhs-run` existed, and correctly identified as broken: it launches
   Steam's own configured executable, not FAF's patched one. `fhs-run`
   is the real fix.
