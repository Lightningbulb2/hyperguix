# faforever — a Guix channel for Forged Alliance Forever

## Fixes from real build/run feedback

Two bugs reported after an actual attempt to build and run this:

1. **`faf-client` couldn't log in: `faf-uid` wasn't executable.**
   `faf-uid`'s own upstream README explicitly warns the execute bit
   isn't reliably preserved once the binary is downloaded/extracted
   (they call this out for macOS specifically, needing a manual `chmod
   +x`). I'd assumed the release tarball's own permission bit would
   survive Guix's unpack + copy-build-system's copy step; that
   assumption was wrong, or at least not something to rely on. Fixed by
   explicitly `chmod`-ing `natives/faf-uid` to `#o755` right after
   unpack, in `faforever.scm`. (I also checked: FAForever's `uid` repo
   bakes an RSA public key into the binary at compile time, matching
   their server's private key — so building `faf-uid` from source
   myself, rather than reusing their official binary, would need their
   exact build-time key configuration to work at all. Reusing the
   official binary was the right call; it just needed this one fix.)

2. **`faf-client-src` failed with a Guile syntax error** in
   `wrap-native-library-path`'s `let*`. This was a real bug in what I
   delivered: a paren-counting mistake in `faforever/source.scm` left
   the whole `arguments` field one closing parenthesis short, which
   doesn't show up as a bare "unbalanced parens" error but instead makes
   `modify-phases` see a malformed clause once Guile tries to expand it
   — exactly the "failed to match any pattern" error you hit. I'd
   actually caught and fixed this myself while validating the file
   before it was ever sent to you, using an automated paren-balance
   check — but the fix never made it into what got delivered. That's on
   me. This revision has been re-verified three independent ways (a
   paren-balance count, a per-top-level-form boundary check, and a full
   labeled open/close stack trace confirming every field — `arguments`,
   `native-inputs`, `inputs`, etc. — sits at the correct nesting depth).
   I still don't have a Guix daemon to build against directly, so you're
   genuinely the first real test of whether it builds at all past this
   point — more issues may well surface further in, since the CA/proxy/
   Gradle-build logic itself is still unexecuted-by-me infrastructure
   (see "What's tested and what isn't" below).

3. **`faf-client` still couldn't log in after fix #1 —
   `Exec failed, error: 2 (No such file or directory)` for `faf-uid`.**
   Fix #1 (chmod before the install step's copy) was based on a wrong
   theory. The real signature — `ENOENT`, not `EACCES` — meant the
   *installed* binary in `$out` wasn't executable, i.e. the copy step
   doesn't preserve the permission bit the way I assumed. I also
   double-checked with `readelf -l`/`ldd` that this really is a fully
   static ELF with no `PT_INTERP`, ruling out the other classic Guix
   gotcha — a binary expecting a dynamic linker path that doesn't exist
   on a non-FHS system. Fixed properly this time: the `chmod` now runs
   in a new phase *after* install, directly on the file's final path in
   `$out`, so it no longer depends on what the copy step preserves.

4. **Fix #3's `chmod` itself failed: `ENOENT` on the exact same path.**
   Not a permissions problem after all — the file was never actually
   landing at `share/faf-client/natives/faf-uid` in the first place,
   regardless of its permission bit. Two ENOENT errors in a row against
   the identical computed path (first from `execve`, then from `chmod`)
   means I had the wrong theory twice: `copy-build-system`'s
   install-plan simply wasn't putting `natives/faf-uid` where I assumed
   it would. Rather than guess a third time at its exact directory-copy
   semantics, `faforever.scm` now copies `faf-uid` and
   `faf-ice-adapter.jar` explicitly itself (`copy-file` + `chmod`, from
   the still-current unpacked source tree to a `$out` path I fully
   control) instead of routing them through the install-plan at all.
   This removes the guesswork entirely rather than trading one
   assumption for another.

---

A **personal/third-party Guix channel**. Two packages:

- **`faf-client`** — repackages FAForever's own official prebuilt Linux
  release. Simple, small, and I'm reasonably confident in it (it's just
  jars + a launcher script).
- **`faf-client-src`** — builds the same client **from source** via
  Gradle, using `mitm-cache` (a real Guix package) to satisfy Gradle's
  dependency downloads from a pre-recorded cache instead of live network
  access mid-build. This is genuinely new, substantial infrastructure
  that **I have not been able to test against a real Guix daemon** — see
  "What's tested and what isn't" below before relying on it.

Both install `faf-client` and `faf-client-setup` (the latter detects your
existing Steam+Proton or plain-Wine setup for Supreme Commander: Forged
Alliance, which you must already own — see the previous revision of this
README, preserved below, for why the client and the Wine/game side are
one package with two commands rather than two packages).

5. **`faf-client-setup` couldn't find Steam, and manually typing the
   path also failed with "Invalid game path!".** Two separate bugs:

   - The manual path entry was failing on a path that was actually
     correct, just wrapped in literal quote marks (`"..."`) — almost
     certainly carried over from copy-pasting via a file manager's
     "copy path" feature, which adds quotes for shell-safety that
     `input()` has no reason to strip on its own. Fixed: all path
     prompts now go through a `read_path()` helper that strips
     surrounding whitespace and one layer of matching quotes.
   - Auto-detection failed because Steam was installed via **nonguix's
     `steam` package**, which runs Steam inside an isolated FHS
     container with its own sandboxed `$HOME` — confirmed by the user's
     own manually-typed path containing `.local/share/guix-sandbox-
     home/...`. `faf-client-setup`'s own (unsandboxed) view of `$HOME`
     never had a reason to look there. I couldn't get to nonguix's
     actual source from here to confirm the exact convention, but the
     user's own working path was direct enough evidence — Steam
     detection now also checks inside `~/.local/share/guix-sandbox-
     home` if it exists, alongside the normal candidate locations.
     Verified both fixes with a simulated sandboxed-home test tree
     before redelivering, not just by reading the diff.

6. **Game launch failed: `Cannot run program "steam-run": Exec failed,
   error: 2 (No such file or directory)`**, even though `steam-run`
   (from nonguix's Steam package) genuinely exists and works fine from
   an interactive shell. The bug: `faf-client-setup` was writing the
   bare command name `"steam-run"` into `client.prefs`, relying on the
   FAF *client's* own process to find it via its own `PATH` later — but
   that's a separate process (launched via a desktop entry, a different
   shell, or a different Guix profile) with no guarantee of sharing this
   script's environment. Fixed: a `resolve_command()` helper now resolves
   `steam-run`/`wine` to an absolute path (via `shutil.which`, in the
   environment `faf-client-setup` itself runs in, which is known to have
   it on `PATH`) at configuration time, and bakes that absolute path
   into `client.prefs` instead of the bare name. Falls back to the bare
   name with a clear warning if it can't find it even there.

7. **`steam-run` genuinely doesn't exist for nonguix's Steam.** You
   shared the actual `nonguix/multiarch-container.scm` source, which
   settled this properly instead of more guessing: nonguix's `steam`
   package is architecturally single-purpose — `fhs-internal` always
   execs one hardcoded target (Steam itself), with no general "run
   arbitrary command X inside this FHS sandbox" mechanism the way
   nixpkgs' `steam-run` provides. My whole reaper/wrapper/runtime/Proton
   reconstruction approach (ported from nix-gaming, built for NixOS)
   was fighting nonguix's design rather than working with it.

   Added a new path that works *with* it instead: when `steam-run` isn't
   found but a plain `steam` is, `faf-client-setup` now offers to set
   `executableDecorator` to `steam -applaunch 9420 "%s"` — delegating
   the entire launch to Steam itself (which already knows how to enter
   its own FHS container correctly, since that's the one thing nonguix
   built it to do), rather than trying to reconstruct that environment
   externally. This needs Proton enabled for the game once in Steam's
   own Properties → Compatibility dialog first. I verified the branch's
   control flow produces the right command string, but **not** whether
   `-applaunch`'s trailing-argument forwarding actually reaches the game
   binary correctly for this specific title/Proton combination — that
   needs a real test.

8. **You correctly pointed out `-applaunch` doesn't actually work for
   FAF.** Steam's `-applaunch <appid>` launches *Steam's own configured
   executable* for that App ID, appending arguments to it — it can't
   substitute a different, patched executable path. But FAF's
   `executableDecorator` + `"%s"` mechanism needs full control over
   exactly what gets executed, since FAF plays from its own patched game
   files, not simply the vanilla Steam install. So fix #7 was addressing
   the wrong problem.

   The real fix, once you shared the actual `nongnu/packages/
   game-client.scm` (not just the generic container framework): nonguix's
   `steam` package config shows `run` is just a path string combined with
   `wrap-package` via `file-append` — meaning a general-purpose "run
   arbitrary command in this FHS sandbox" tool is buildable using
   nonguix's own machinery, just pointed at `env` instead of Steam's
   launcher (`env PROGRAM ARGS...` execs whatever it's given). This
   channel now includes **`fhs-run`** (`faforever/fhs-run.scm`) — reusing
   nonguix's own `steam-container-libs` list directly via `(@@ ...)`
   (an unexported binding, accessed the same way nonguix's own code
   reaches into `(gnu packages base)` for `glibc-for-fhs`) rather than
   retyping ~40 package references by hand. `faf-client-setup` now tries
   `fhs-run` first, falls back to a literal `steam-run` if that happens
   to exist, and only offers the known-broken `-applaunch` command as an
   explicit, strongly-discouraged last resort (default answer: no).

   This is new infrastructure I can't build or run myself, transcribed
   directly from real source rather than guessed at, but genuinely
   untested. Build it with `guix build -L /path/to/this/directory
   fhs-run`, install it, then re-run `faf-client-setup`.

## How `faf-client-src` came to exist

You pointed out that Guix already has `mitm-cache`
(packages.guix.gnu.org/packages/mitm-cache/0.1.2/) — the same tool
nixpkgs uses for `gradle.fetchDeps`. That was a real correction to my
earlier claim that "Guix has no equivalent tool." You then asked to go
all-in on a from-source package in one pass. Here's exactly what that
took, and what's solid versus what isn't.

**The lockfile format is more sophisticated than mitm-cache's own bundled
example `fetch.nix` shows.** nixpkgs' actual, current implementation
(`pkgs/development/tools/build-managers/gradle/fetch-deps.nix`) uses a
*compressed* encoding — shared Maven group/artifact/version prefixes
factored out, and `maven-metadata.xml` files synthesized on the fly
(rather than hash-pinned, since those mutate server-side) from whichever
jar/pom versions were actually recorded. I fetched that real file
directly from NixOS/nixpkgs on GitHub rather than trust the simpler
bundled example, and ported its exact decompression algorithm.

**I have real Guile available where I'm running, so I actually tested
the hard part.** I installed `guile` + `guile-json` and ran the ported
decompression algorithm, the SRI-base64-to-Guix-base32 hash conversion,
and the maven-metadata.xml synthesis against nix-gaming's real,
already-published 995-entry lockfile for this exact client version
(`deps-stable.json`, bundled in this channel, MIT-licensed, credit:
nix-gaming/chayleaf) — not synthetic test data. All three:

- decompressed all 995 entries to well-formed Maven-repository URLs
  (spot-checked against known JitPack/Maven Central URL conventions),
- matched an independent Python re-implementation of the same algorithm
  exactly,
- and the one hash conversion I could cross-check against a real
  recorded value (and separately against the hash of the actual
  `faf_unix_2026.7.0.tar.gz` I'd downloaded earlier) matched exactly
  both times.

That logic now lives in `faforever/lockfile.scm`.

**What I could not test: turning that into an actual Guix
`origin`/`computed-file` tree, and the whole CA-generation /
mitm-cache-replay-as-background-proxy / Gradle-proxy-trust build phase.**
I don't have a Guix daemon available in my execution environment, so
none of `faforever/source.scm` has been run through `guix build`. I
didn't reverse-engineer this part from scratch, though — I fetched
nixpkgs' *actual, current* orchestration scripts
(`pkgs/by-name/mi/mitm-cache/setup-hook.sh` and
`pkgs/development/tools/build-managers/gradle/setup-hook.sh`) and
transcribed their CA-generation commands and Gradle proxy/truststore JVM
flags directly, rather than guessing. The Guix-specific risk that's left
is mostly: whether Guix's build sandbox permits loopback networking the
way Nix's does (I believe so — Nix's own Darwin sandbox needed an
explicit `__darwinAllowLocalNetworking = true` escape hatch that its
Linux sandbox does not, suggesting Linux network namespaces permit
loopback by default in both tools' sandboxing models — but I haven't
confirmed this for Guix specifically), and ordinary first-draft bugs in
code I couldn't run.

**Gradle itself doesn't need to be a Guix package at all.** I initially
worried about this — Guix's own Java packaging conventions (in the
mirror I could inspect) actively *avoid* using Gradle, deleting bundled
Gradle wrappers from other projects' source trees rather than using
them. But nixpkgs doesn't build Gradle from source either: its own
`gradle_9` package just fetches Gradle's official prebuilt binary
distribution (`https://services.gradle.org/distributions/gradle-9.5.1-
bin.zip`) directly. `faf-client-src` does the same thing itself as a
plain `origin`, sidestepping the question of Guix's own Gradle support
entirely.

## Before attempting to build `faf-client-src`

1. **JDK version**, same as `faf-client`: needs Java ≥ 25 — check `guix
   search openjdk`. nixpkgs needs `jdk25` for this same client version,
   which is at least a signal it's a solved problem somewhere nearby,
   not a guarantee Guix has it.
2. **The `faf-client-source` origin's hash is a placeholder.** I hashed
   the prebuilt *release* tarball myself (reused in both packages, and
   in `faf-client-src` for the two small native helpers, faf-uid and
   faf-ice-adapter.jar) but never downloaded the plain *source* tarball
   from the `v2026.7.0` tag, so `faforever/source.scm`'s
   `faf-client-source` origin has an all-zero placeholder hash. Run
   `guix download` on the URL in that file before building.
3. **The Gradle zip's hash was converted from nixpkgs' recorded value,
   not independently verified against a fresh download.** Cross-check
   with `guix download` too.

## Known regression: install4j re-enters the build (but not the output)

`build.gradle` declares `install4j-gradle` (a build plugin) and
`install4j-runtime` (a compile-time dependency) unconditionally, and
nix-gaming's patches — which `faf-client-src` reuses verbatim — don't
remove them. So a from-source build genuinely fetches and briefly uses
this nonfree software during compilation, via `mitm-cache`, from
ej-technologies' own Maven repo (present in the lockfile as
`https://maven.ej-technologies.com`). That's a real step *backwards* from
`faf-client`, which never touches install4j in any form. The trade
you're making with `faf-client-src` is "install4j touches the build" in
exchange for "almost everything else is compiled from source instead of
reused as a binary blob." Neither package is FSDG-clean — see below —
but they're not clean in different ways, and it's worth knowing which
one you're getting.

## Scope decisions in `faf-client-src`, stated plainly

- **faf-uid and faf-ice-adapter.jar are still reused from the official
  prebuilt release**, not built from source. nix-gaming has working
  from-source recipes for both (`uid.nix`, `ice-adapter.nix` in their
  repo) — porting those is a reasonable next step, but wasn't done here,
  to keep this pass focused on the part you actually asked about (the
  ~195-jar Gradle build).
- **The mitm-cache replay port listens on a fixed port (18935)** rather
  than dynamically reserving a free one (nixpkgs uses
  `ephemeral-port-reserve` for this). Each Guix build gets its own
  network namespace, so a fixed port should be safe — but this is
  simpler than nixpkgs' approach, not a faithful port of it.

## Why neither package is upstream Guix material

`faf-client` is binary repackaging — reusing FAForever's own already-
built release rather than compiling from source, which Guix's own
package collection doesn't accept regardless of licensing.

`faf-client-src` gets much closer to actually being from-source, but (a)
still touches nonfree install4j at build time as described above, (b)
still reuses two small prebuilt binaries, and (c) is untested
infrastructure I can't personally vouch for the way I can for something
I've actually built. Even if all of that were resolved, this is the kind
of build-time-networked, mitm-proxy-based approach that would need real
discussion with Guix's own Java packaging maintainers before landing in
guix.git — it's a genuinely new pattern for Guix, not a small tweak to
an existing one.

## Using this channel

```scheme
(cons (channel
        (name 'faforever)
        (url "file:///path/to/this/directory"))
      %default-channels)
```

then `guix pull`, then `guix install faf-client` (safe default) or
`guix install faf-client-src` (experimental — see above). For local
iteration without the channel/pull step:

```sh
guix build -L /path/to/this/directory faf-client
guix build -L /path/to/this/directory faf-client-src
```

## Known risk areas carried over from `faf-client`

- **JavaFX's bundled native libraries** need `LD_LIBRARY_PATH` help
  (confirmed via `readelf -d`: no RPATH/RUNPATH on the bundled `.so`
  files). The 10-package list matches nix-gaming's own working list.
- **`specification->package` lookups** everywhere instead of guessed
  module imports, so a renamed/missing package produces a clear error
  naming it rather than a confusing module-import failure.
- **`faf-client-setup`'s untested paths** — VDF parser verified against
  a synthetic file; the rest ported faithfully from nix-gaming but not
  run against a real Steam library.
- **32-bit Vulkan**, only relevant if you go the plain-Wine (not
  Steam/Proton) route.

## Actually playing

1. `guix install faf-client` (or `faf-client-src` if you want to help
   shake out the from-source path — check the caveats above first).
2. Own Supreme Commander: Forged Alliance on Steam already, and have
   launched it at least once so Steam's set up its own Proton prefix for
   it (or have a plain Wine prefix ready).
3. Run `faf-client-setup` and follow the prompts.
4. Run `faf-client` to log in and play.
