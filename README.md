# Lightningbulb channel additions

Drop the `Lightningbulb/` directory into the root of your channel (next to your
existing `Lightningbulb/packages/*.scm`). Modules are named
`(Lightningbulb packages <file>)`, so the directory name must match exactly.

| Module | Package(s) | Command(s) |
| --- | --- | --- |
| `scrcpy.scm` | `scrcpy` 5.0.1 | `scrcpy` |
| `scrcpy-gui.scm` | `scrcpy-gui` 4.1.0 | `scrcpy-gui` (`scrcpy-gui-v3`) |
| `faforever.scm` | `faforever-client` 0.9.1 (Rust/Tauri client) | `faforever-client` |
| `pandora-launcher.scm` | `pandora-launcher` 5.3.1 | `pandora-launcher` |
| `radmin-vpn.scm` | `radmin-vpn-linux` 1.1.0 | `radmin-vpn`, `radmin-vpn-health-check`, `radmin-vpn-vps`, `radmin-vpn-datacenter` |
| `craft.scm` | `photocraft` 0.10.0, `effectcraft` 0.12.0, `filmcraft` 0.9.0 | `photocraft`, `effectcraft`, `filmcraft` (+ `*-cli`) |
| `cosmic.scm` | `cosmic` (meta) + 26 components incl. `xdg-desktop-portal-cosmic`, `pop-launcher`, `cosmic-icons`, `cosmic-sound-theme`, `cosmic-wallpapers` | log in to the "COSMIC" session |

Support modules (no packages of their own):

- `rust-crates.scm` *(generated)*: one origin per crate in the scrcpy-gui and
  FAForever `Cargo.lock` files. Hashes are the lockfile checksums.
- `node-deps.scm` *(generated)*: one origin per npm tarball in their
  `package-lock.json` / `pnpm-lock.yaml` (plus pnpm itself).
- `craft-crates.scm`, `cosmic-crates.scm` *(generated)*: crates.io origins plus
  pinned git checkouts for crates the lockfiles take from git.
- `cargo-git.scm` + `aux-files/vendor-git-crates.py`: vendors those git
  crates offline (what `cargo vendor` would do) so cargo can build without
  network.
- `js-offline.scm`: serves those tarballs from a throw-away HTTP registry on
  127.0.0.1 during the build, so `npm ci` / `pnpm install --frozen-lockfile`
  run unmodified with no network.

```sh
guix build -L /path/to/channel scrcpy scrcpy-gui faforever-client \
                               pandora-launcher radmin-vpn-linux
```

## Updating

Each package pins an upstream commit and its `git-fetch` hash (computed from
the exact snapshots you gave me). To move to a newer commit, change `commit`
and `version`, then set the hash to `guix hash -x -r <checkout>`.

For scrcpy-gui and the FAForever client, also regenerate the dependency
modules from checkouts of the new commits:

```sh
python3 contrib/update-lockfile-deps.py Lightningbulb/packages \
        ~/src/scrcpy-gui ~/src/FAForeverRustClient
```

(Python 3.11+, PyYAML, and curl. Crate hashes are read straight from
`Cargo.lock`. Npm tarballs are downloaded once, checked against the
lockfile's sha512, and recorded by sha256.)

For the Craft apps and COSMIC (anything with git dependencies), use the
general generator, which also fetches and hashes the git checkouts:

```sh
python3 contrib/cargo-lock-to-guix.py "Lightningbulb packages craft-crates" \
        Lightningbulb/packages/craft-crates.scm \
        photocraft=~/src/photocraft/Cargo.lock effectcraft=... filmcraft=...
```

For scrcpy, update `%scrcpy-version` and the server hash from
`install_release.sh` (`PREBUILT_SERVER_SHA256`, convert with
`guix hash`/nix-base32). For the FAForever natives, copy the digests from
`scripts/ensure-*.mjs` the same way.

## Runtime notes

- **scrcpy**: uses the `adb` on your `PATH` first, otherwise Guix's. You need
  the usual udev rule or `adbusers` group for USB access.
- **scrcpy-gui**: its built-in "update scrcpy" download can't write to the
  store. It uses the packaged `scrcpy`/`adb` instead.
- **faforever-client**: Java ICE adapter runs on Guix's `openjdk`. Override
  any helper with the env vars from upstream's README (`FAF_JAVA_PATH`,
  `FAF_UID_PATH`, `FAF_ICE_ADAPTER_JAR`, ...). The game itself (Forged
  Alliance via Steam/Proton or Wine) is set up inside the client.
- **pandora-launcher**: launches Minecraft with Guix JDKs 8/16/17/21/25 through
  upstream's `FORCE_EXTERNAL_JAVA`. Mojang's own runtimes are glibc-FHS
  builds and won't start on Guix. Set your own `FORCE_EXTERNAL_JAVA` to
  prepend other JDKs. The per-instance "Java binary" setting still overrides
  everything.
- **radmin-vpn-linux**: needs Wine ≥ 11 (Guix's `wine64` is 11.0), the `tun`
  module and `sudo` (the setuid one from your system config). The first run
  downloads Radmin VPN itself into `~/.local/share/radmin-vpn-linux`.
- **Craft apps** (`photocraft`, `effectcraft`, `filmcraft`): built with
  Guix's `rust-1.95`, which may compile locally once if there's no substitute.
- **COSMIC**: add `cosmic` to your *system* packages (so SDDM/GDM sees the
  `cosmic.desktop` session and `start-cosmic` finds the components on PATH),
  reconfigure, and pick "COSMIC" at login. It needs elogind (part of
  `%desktop-services`) for seat access. COSMIC's own greeter
  (`cosmic-greeter`) is packaged but requires a greetd service you configure
  yourself. `cosmic-wallpapers` has a placeholder hash (Git LFS): build it
  once, paste the reported hash, and add it to your packages if you want the
  stock wallpapers.
