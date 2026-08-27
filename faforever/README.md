# faforever — a Guix channel for Forged Alliance Forever

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
