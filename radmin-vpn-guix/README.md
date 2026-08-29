# radmin-vpn-linux on Guix

A Guix package for [radmin-vpn-linux](https://github.com/baptisterajaut/radmin-vpn-linux),
built from the same source the project's own [NixOS flake](https://github.com/baptisterajaut/radmin-vpn-linux/blob/main/flake.nix)
packages. It builds the GPL-3.0 Wine shim only; the proprietary Radmin VPN
client itself is downloaded and sha256-verified by `run.sh` on first launch,
same as upstream — nothing proprietary is built, bundled, or distributed
by this package.

## Status

The first draft of this had two bugs, both from package names I recalled
instead of checked: `iproute2` (should be `iproute` — the *package* is
still named "iproute2", but the Scheme variable bound to it is `iproute`)
and a wholesale wrong guess at how Guix does mingw cross-compilation
(there's no single `mingw-w64-x86_64-toolchain` package like nixpkgs'
`pkgsCross.mingwW64` — see below).

Both are fixed now, checked against an actual clone of Guix's
`gnu/packages/*.scm` rather than memory. A third issue turned up after
that, in `guix.scm` itself rather than the package: `add-to-load-path`
immediately followed by `use-modules` left the package variable unbound
even though nothing errored along the way, because `guix build -f`
auto-compiles the file (macro-expanding the whole thing as one unit
before any of it runs), so `use-modules` was resolving against the load
path as it stood *before* `add-to-load-path` executed. Fixed by loading
the module with `load` (a plain runtime call, not a macro) and referring
to the package with a fully-qualified `@` instead — see the comment in
`guix.scm`.

A fourth issue showed up on an actual build attempt, past module loading:
the `find-ddk-headers` phase crashed because `(assoc-ref inputs
"mingw-w64-x86_64")` returned `#f` — the exact input label I'd confirmed
by reading the source didn't match what showed up in a real build (likely
a version difference between the Guix checkout I read and the Guix
actually running). Rather than guess at another exact label, that lookup
now searches every input whose label merely *contains* "mingw" for a
`ddk` directory, and `wrap-and-link-scripts` got a build-time check added
that fails loudly (naming the missing binary) if any core runtime tool
isn't found on the assembled PATH, instead of silently shipping a broken
wrapper the way it would have before.

**One placeholder is still outstanding**, and needs a working `guix` to
resolve — the source hash:

```bash
guix build -f guix.scm
```

This will fail on a hash mismatch and print the real
`sha256 (base32 "...")` to paste into `radmin-vpn/packages/vpn.scm`.
Rebuild after fixing it. That should be the only thing left before this
actually builds — but I don't have a working `guix` in my own environment
either, so if something else breaks, see "If something still doesn't
build" below.

## What was wrong, and how it was found

- **`iproute2: unbound variable`** — Guix's package for it is bound to
  the Scheme variable `iproute`, not `iproute2` (its `(name ...)` field,
  and therefore its *input label* inside build phases, is still the
  string `"iproute2"` — only the variable you write in `(inputs (list
  ...))` was wrong). Fixed.
- **`radmin-vpn-linux: unknown package`** — this is just `guix build
  radmin-vpn-linux` (by name) instead of `guix build -f guix.scm` (by
  file) — expected until you've added this repo as a channel and run
  `guix pull` (see "Using it" below). Not a bug, just two different
  ways to invoke a package that aren't interchangeable until the channel
  is registered.
- **The mingw cross-toolchain input was wrong in a way that wouldn't
  have surfaced until later.** I'd written `mingw-w64-i686-toolchain` /
  `mingw-w64-x86_64-toolchain`, modeled on nixpkgs'
  `pkgsCross.mingwW64.buildPackages.gcc`. Guix has no equivalent
  single-package toolchain. Its `(gnu packages mingw)` module only
  provides `mingw-w64-i686` / `mingw-w64-x86_64` (headers + import
  libs), and expects you to separately pull in `cross-gcc` /
  `cross-binutils` from `(gnu packages cross-base)` for the actual
  compiler — which is exactly how Guix's own `mingw-w64-x86_64` package
  bootstraps itself, so `vpn.scm` now does the same thing. This still
  produces binaries under the names the upstream Makefile already
  expects (`x86_64-w64-mingw32-gcc`, `x86_64-w64-mingw32-strip`, etc.),
  so no Makefile changes were needed once the inputs were right.

To find and confirm both fixes (and check everything else in this
package), I cloned Guix's actual source (`gnu/packages/*.scm`) rather
than continuing to go on memory. Genuinely uncertain items that I
couldn't resolve that way are called out explicitly below instead of
guessed at.

## What's confirmed vs. what's still open

Confirmed by reading the actual package definitions:

| Guix binding | Confirmed as |
|---|---|
| `wine64` | Has 32-bit/WoW64 support built in (copies wine's 32-bit binaries+libs at build time) — covers the 32-bit `adapter_hook.dll`/`rvpn_launcher.exe` too, no separate `wine`/`wine32` input needed |
| `gtk` | **Is** GTK4 (version 4.6.1 in this checkout) in Guix's naming — `gtk+`/`gtk+-2` are GTK3/GTK2. Not `gtk4`. |
| `iproute` | Package name/input label `"iproute2"`, Scheme variable `iproute` |
| `websockify` | Lives in `(gnu packages web)`, plain `websockify` — not `python-websockify` |
| `cross-gcc` / `cross-binutils` | From `(gnu packages cross-base)`; `(cross-gcc "x86_64-w64-mingw32")` etc. produces the toolchain, mingw is an explicitly-handled target in both |
| everything else in `%radmin-core-runtime-inputs` | `coreutils`, `findutils`, `grep`, `sed`, `gawk`, `procps`, `glibc`, `curl`, `wget`, `openssl`, `nftables`, `iptables`, `net-tools`, `desktop-file-utils`, `pkg-config` — all confirmed present under exactly these names |

Confirmed **absent** — checked, not just unfound by a narrow grep:

- **`x11vnc` and `novnc` do not exist as Guix packages**, under any
  name, in any module. `radmin-vpn-datacenter` (the optional
  browser-GUI-over-VNC mode) is installed and wrapped, but won't
  actually work until you get an x11vnc binary and noVNC's web assets
  onto your profile's `PATH` some other way — write a small local
  package for them, use nonguix or another third-party channel if one
  has them, or run them from a container. Because the wrapper uses
  `PATH` *prefix* (not replacement), anything you add to your own
  profile's `PATH` is still picked up automatically — no changes to
  `vpn.scm` needed once they exist somewhere.
- `radmin-vpn-linux`, `radmin-vpn-vps`, and `radmin-vpn-health-check`
  don't depend on any of this and should work standalone.

## If something still doesn't build

I don't have a working `guix` to test the full build end-to-end (no
substitutes access in the environment I drafted this in), so it's
possible something downstream of the fixes above — the `find-ddk-headers`
phase's assumption that a directory literally named `ddk` exists
somewhere under the `mingw-w64-x86_64` input, for instance — doesn't
survive contact with a real build. If `guix build -f guix.scm` fails:

1. Read the error — Guix's build errors are usually specific about which
   phase and which file.
2. If it's an unbound-variable / module-loading error, it's another
   wrong package name; `guix search <keyword>` or grep a local Guix
   checkout's `gnu/packages/*.scm` for `define-public` the way this
   README's fixes were found.
3. If it's the `find-ddk-headers` phase failing to find a `ddk`
   directory, run `guix build mingw-w64-x86_64` then
   `find /gnu/store/*-mingw-w64-x86_64-*/ -type d -name ddk` to see
   where it actually landed, and sanity-check against what the phase is
   doing.

## What gets installed

| Command | Wraps upstream's | What it's for |
|---|---|---|
| `radmin-vpn-linux` | `run.sh` | Normal desktop use |
| `radmin-vpn-vps` | `run_vps.sh` | Headless, fixed adapter GUID, no GUI |
| `radmin-vpn-health-check` | `health_check.sh` | Pre-flight / diagnostics |
| `radmin-vpn-datacenter` | `run_datacenter.sh` | Headless with the real GUI over VNC/noVNC in a browser — **needs x11vnc + noVNC on `PATH` from elsewhere, see above** |

All four share one Wine prefix at
`~/.local/share/radmin-vpn-linux/wineprefix` (set via `WINEPREFIX` in the
wrapper, since upstream's own default — relative to its own install
location — would otherwise land inside the read-only store).

`contrib/run-in-netns.sh` (network-namespace isolation) is installed for
reference under `share/radmin-vpn-linux/contrib/` but has no `bin/`
wrapper — it takes an AppImage path as its argument, which doesn't apply
to a from-source Guix build, and it needs to run as root directly. Run it
manually from the store path if you want it; see its header for usage.

## Runtime prerequisites this package can't provide

- **`sudo`**, configured for your user, for TAP device creation and
  routing. Deliberately *not* a package input — a Guix store item can't
  usefully carry a setuid bit, and if you're running Guix System you
  already have `sudo` configured some other way (e.g. the
  `sudo-service-type`).
- **TUN/TAP kernel support.** Almost certainly already on: check with
  `sudo modprobe tun` and `ls /dev/net/tun`.
- **Network access on first run**, to fetch the pinned Radmin VPN
  installer from `download.radmin-vpn.com` (verified against the sha256
  in upstream's `lib.sh` before Wine ever touches it).

## Using it

### One-off, no channel

```bash
git clone <this-repo>
cd radmin-vpn-guix
guix build -f guix.scm        # after fixing the hash — see "Status" above
guix shell -f guix.scm -- radmin-vpn-linux
```

### Installed into your profile

```bash
guix package -f guix.scm -i
radmin-vpn-linux
```

### As a channel (so `radmin-vpn-linux` shows up in `guix search` /
`guix install` / your `operating-system` config)

Add to `~/.config/guix/channels.scm`:

```scheme
(cons (channel
        (name 'radmin-vpn)
        (url "file:///path/to/radmin-vpn-guix")   ; or a git URL you push this to
        (branch "main"))
      %default-channels)
```

Then:

```bash
guix pull
guix install radmin-vpn-linux
```

### Declaratively, in a Guix System config

Unlike Nix, there's no separate "overlay" step — a channel package is
just a normal package once `guix pull` has picked it up:

```scheme
(use-modules (radmin-vpn packages vpn))

(operating-system
  ;; ...
  (packages (cons radmin-vpn-linux %base-packages))
  ;; make sure something provides sudo for your user, e.g.:
  ;; (services (cons (service sudo-service-type) %base-services))
  )
```

```bash
sudo guix system reconfigure /path/to/config.scm
```

## A note if you ever want to upstream this into Guix proper

Guix's default channel follows the Free System Distribution Guidelines,
the same reasoning that already lets `wine` itself in: the package here
builds and ships only GPL-3.0 code, and treats the proprietary Radmin VPN
client exactly the way Wine treats arbitrary Windows software — fetched
by the user, never bundled. That's a defensible position (it's the same
one the upstream Nix flake takes), but it's ultimately a judgment call
for Guix's own reviewers on `guix-patches@gnu.org`, not something this
README can settle. Worth reading their guidelines before submitting.

## Files in this directory

```
.guix-channel                    # marks this repo as a pullable channel
guix.scm                         # standalone entry point (no channel needed)
radmin-vpn/packages/vpn.scm      # the actual package definition
README.md                        # this file
```
