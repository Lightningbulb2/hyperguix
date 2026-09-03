# faforever — a Guix channel for Forged Alliance Forever

A **personal/third-party Guix channel** (not upstream Guix material —
`faf-client` repackages an official binary release rather than building
from source; see "Why this isn't upstream Guix material" below).

Four files total:

- **`.guix-channel`** — channel declaration.
- **`faforever.scm`** — both packages, `faf-client` and `fhs-run`.
- **`faf-client-setup.py`** — the fully automatic (no prompts) setup
  script `faf-client` installs as `faf-client-setup`.
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
  - `faf-client-setup` — detects your existing Steam+Proton setup for
    Supreme Commander: Forged Alliance (which you must already own and
    have run at least once via Steam), and writes
    `~/.faforever/client.prefs`. Steam+Proton only — no standalone Wine
    option; relies entirely on Guix's native Steam. Runs once with no
    prompts: it either auto-detects everything and writes the config,
    or fails with a clear message saying what to check. Sets up this
    layout:
    - `~/.config/faforever` — `client.prefs` itself (`~/.faforever` is
      symlinked here, since the client hardcodes that path).
    - `~/.local/share/faforever` — FAF's own managed copy of the game
      (unchanged from before).
    - `~/.config/Gas-Powered-Games/Supreme-Commander-Forged-Alliance` —
      `Game.prefs`, symlinked in from the Proton prefix's
      `AppData/Local/Gas Powered Games/Supreme Commander Forged
      Alliance`.
    - `~/.local/share/Gas-Powered-Games/Supreme-Commander-Forged-Alliance`
      — mods/maps, symlinked in from the Proton prefix's `My
      Documents/My Games/Gas Powered Games/Supreme Commander Forged
      Alliance` (a *different* in-prefix location than Game.prefs —
      see the script's own docstring for why both are needed).
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
3. Run `faf-client-setup`. No prompts — it auto-detects Steam, the
   game, Proton, and the Steam Linux Runtime, and writes
   `client.prefs`. If any of those can't be found, it exits with a
   message explaining what's missing rather than asking you to type a
   path; `FAF_GAME_PATH`, `FAF_PROTON_PATH`, and `FAF_RUNTIME_PATH`
   environment variables are available to override detection for a
   specific piece if you need to.
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
  Runtime entry point, and Proton — all run *inside* the sandbox, and
  need the *short* form instead. Passing the outside form to something
  running inside it resolves to a nonexistent, doubly-nested path
  (confirmed in practice:
  `env: '.../guix-sandbox-home/.local/share/Steam/ubuntu12_32/reaper':
  No such file or directory`, even though that exact path is completely
  real from outside the sandbox). Fixed with a `to_sandbox_path()`
  rewrite applied specifically to those paths — not to
  `preferencesFile`, `installationPath`, or the vault/mods/maps
  directories, which the FAF *client* itself reads directly as a
  normal, unsandboxed process (never passed into the launch command at
  all), and which correctly keep their real, full paths. An earlier
  revision of this script *did* wrongly wrap `installationPath` in
  `to_sandbox_path()` — fixed now, but if you're on an old copy of the
  channel, regenerate `client.prefs` after updating.
- **No Wine support.** `faf-client-setup` only knows how to detect a
  Steam+Proton install. If you'd rather use a standalone Wine prefix,
  you'll need to write `client.prefs` by hand (see downlords-faf-client's
  own docs) — this channel doesn't help with that path.
- **Two different in-prefix directories, easy to conflate.** Proton
  prefixes have both an `AppData/Local/Gas Powered Games/...` (where
  Game.prefs lives) and a separate `My Documents/My Games/Gas Powered
  Games/...` (where mods/maps live) — `faf-client-setup` redirects both,
  to `~/.config/...` and `~/.local/share/...` respectively. Redirecting
  only one of the two is a real, previously-reported failure mode
  (mods/maps silently not showing up in-game) if you're hand-editing
  this later.
- **Steam's own config files also need un-sandboxing.** It's not just
  the launch command that needs `to_sandbox_path()` — Steam itself
  writes `libraryfolders.vdf` from *inside* its own sandbox, so the
  `"path"` field it records for each library is in the short,
  in-sandbox form too. Read literally by this (unsandboxed) script,
  that path doesn't exist on disk, so an app can be correctly listed
  under a library's `"apps"` map and still get reported as "not
  found" — this silently broke game, Proton, *and* Steam Linux Runtime
  detection all at once, since they all resolve library paths through
  the same code path. Fixed with `from_sandbox_path()`, the inverse of
  `to_sandbox_path()`, applied where library paths are read out of the
  vdf.
- **Quoting in `executableDecorator` must use double quotes, not
  single.** There's no real shell involved in launching the game — the
  FAF client tokenizes this string itself and execs the result
  directly (its own logs show a literal `["env",
  "PROTON_NO_ESYNC=1", ...]` array). Its parser doesn't treat single
  quotes as grouping, only double quotes (matching its own convention
  of always writing the substitution placeholder as `"%s"`). Any path
  in the chain with a space in it — a Proton build like `Proton -
  Experimental` is the common case — needs `"..."`, not POSIX
  `'...'`-style quoting, or it gets silently torn into multiple broken
  arguments and the game exits immediately without actually launching.
  Fixed with a small `faf_quote()` helper used throughout `command()`
  in place of `shlex.quote()`.
- **`fhs-internal` (nonguix's own, not this channel's) silently drops
  everything after the LAST `--` in its own argv.** Shared by every
  `nonguix-container`, not specific to `fhs-run` — see nonguix's
  `nonguix/multiarch-container.scm`, `make-internal-script`:
  `(package-args (if fhs-args (reverse (cdr (member "--" (reverse
  all-args)))) all-args))`. It's designed to let you pass FHS-specific
  options (like `--asound32`) after a trailing `--`, on the assumption
  that the wrapped command's own argv has at most one meaningful `--`.
  The Steam Linux Runtime launch chain needs three of its own (reaper's,
  steam-launch-wrapper's, and `_v2-entry-point`'s — the last one right
  before `proton ... game.exe` itself), so fhs-internal's "last `--`"
  is always one of *ours*, and it was unconditionally truncating the
  command right there — silently discarding `proton waitforexitandrun
  ForgedAlliance.exe` and every game argument after it (`/init`,
  `/gpgnet`, `/savereplay`, ...), leaving `_v2-entry-point` with
  nothing to run at all. Confirmed in practice: the client's own log
  shows "Launching coreutils in sandbox" (fhs-run starting up fine)
  immediately followed by `_v2-entry-point[N]: Error: A command to run
  is required`. Not fixable by reshuffling `--`s — fhs-internal drops
  whatever's after the *last* one no matter where it falls. Fixed by
  having `command()` write the whole reaper/wrapper/runtime/proton
  chain out as a real, on-disk shell script (`faf-launch.sh`, quoted
  with plain `shlex.quote()`) and invoking that (via an explicit
  `/bin/sh`) with a single substituted argument, instead of building
  one long string with embedded `--`s — so fhs-run's own argv never
  contains a bare `--` for fhs-internal to trip over in the first
  place. The script has to live *inside*
  `~/.local/share/guix-sandbox-home` (the same directory nonguix
  bind-mounts *at* `$HOME` inside the sandbox), not the real `$HOME` —
  anything written under the real, unsandboxed home isn't visible to
  the sandboxed process at all. If you're on an old copy of the
  channel, regenerate `client.prefs` (re-run `faf-client-setup`) after
  updating.

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
