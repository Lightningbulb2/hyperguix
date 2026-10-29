# Lightningbulb's Guix channel

Packages Guix doesn't have (or doesn't have in a usable form), used by the
`thekitchen` system config (`~/config_cosmic.scm`). Modules are named
`(Lightningbulb packages <file>)`.

```scheme
(channel
  (name 'local-channel)
  (url "file:///home/Lightningbulb/local-channel")
  (branch "master"))
```

Changes only count once committed; then `guix pull -C ~/config_cosmic.scm
--unsafe-channel-evaluation --allow-downgrades` and `sudo guix system
reconfigure ~/config_cosmic.scm`. To try uncommitted changes:
`guix build -L ~/local-channel PACKAGE`.

The channel depends on nonguix (`.guix-channel`): several packages use its
`linux` kernel, NVIDIA driver, Electron, fonts or binary build systems.

## Packages

| Module | Package(s) | Notes |
| --- | --- | --- |
| `cosmic.scm` | `cosmic` (meta) and all its components, `cosmic-greeter`, `pop-launcher`, `cosmic-icons`, `pop-icon-theme`, `cosmic-sound-theme`, `cosmic-wallpapers` (COSMIC epoch 1.11.0) | see *COSMIC* below |
| `xwayland.scm` | `xwayland-with-idle-time`, `xwayland-activity-relay` | Xwayland used by cosmic-comp, and the helper that keeps Steam from going Away; see *COSMIC* |
| `timedated.scm` | `timedated` | systemd's timedated built alone (org.freedesktop.timedate1), for COSMIC Settings |
| `craft.scm` | `photocraft`, `effectcraft`, `filmcraft`, `pdfcraft`, `lightcraft`, `vectorcraft`, `gridcraft`, `wordcraft`, `soundcraft`, `cadcraft`, `figcraft`, `designcraft`, `deckcraft`, `craft-launcher` | the storytold "Craft" suite, each with its `*-cli` |
| `ladybird.scm` | `ladybird` (git master, Qt 6.10 calls guarded for Guix's Qt 6.9), plus private Skia 148, ANGLE, ffmpeg 9, curl+OpenSSL | Qt 6 UI; its sandbox needs Landlock (`lsm=landlock,...` kernel argument) |
| `scrcpy.scm`, `scrcpy-gui.scm` | `scrcpy` 5.0.1, `scrcpy-gui` 4.1.0 | Android mirroring |
| `faforever.scm` | `faforever-client` 0.9.2 | Rust/Tauri FAF client |
| `pandora-launcher.scm` | `pandora-launcher` 6.0.0 | Minecraft launcher on Guix JDKs |
| `r2modman.scm` | `r2modman` 3.2.20 | built from source, runs on nonguix's Electron 38 |
| `radmin-vpn.scm` | `radmin-vpn-linux`, `wine64-wow64`, `wine64-wow64/prefix-update` | Radmin VPN under Wine; the Wine variants are also used by `bfme.scm` |
| `bfme.scm` | `bfme-aio-launcher` | BFME All In One Launcher under Wine (nonfree; upstream's own builds) |
| `gamescope.scm` | `gamescope` 3.17.0, `heroic-nvidia-new-feature-gamescope` | Heroic with gamescope inside its FHS container |
| `claude-desktop.scm` | `claude-desktop` | Anthropic's official Linux beta, repackaged (nonfree) |
| `chrome-remote-desktop.scm` | `chrome-remote-desktop`, `chrome-remote-desktop-service-type` | Google's host, virtual Xfce desktop (nonfree; currently disabled in the config) |
| `openrazer.scm` | `openrazer-kernel-modules`, `%openrazer-keyboard-services` | `razerkbd` only, patched to put the BlackWidow (1532:011a) in driver mode so M1–M5 send F13–F17 |
| `gpu-unlock.scm` | `gpu-unlock`, `gpu-unlock-firmware`, `%gpu-unlock-services` | full-rate FP16/BF16/TF32 tensor cores on GeForce RTX 20/30/40 (kernel module; firmware from NVIDIA 610.43.03 is nonfree); see *Others* |
| `llama-cpp.scm` | `llama-cpp/latest` (Vulkan, OpenBLAS), `llama-cpp-cuda` (also CUDA, compute capability 8.6) | llama.cpp 0.8.0 with its bundled ggml; Guix has 0.5.0 |
| `cuda.scm` | `cuda-toolkit` | NVIDIA CUDA 13.4: nvcc, cudart, cuBLAS (from NVIDIA's redist archives; nonfree); `libcuda` comes from the driver |
| `reboot-to-bios.scm` | `reboot-to-bios` | |

Support modules:

- **Generated** (never edit by hand): `cosmic-crates.scm`, `craft-crates.scm`,
  `ladybird-crates.scm`, `rust-crates.scm`, `node-deps.scm`,
  `r2modman-deps.scm`.
- `cargo-git.scm` with `aux-files/vendor-git-crates.py` vendors crates that
  lockfiles take from git, as `cargo vendor` would, so cargo builds offline.
  It drops `[dev-dependencies]` and the feature entries that name them, and
  `contrib/cargo-lock-to-guix.py` also vendors `[[patch.unused]]` git crates.
- `js-offline.scm` serves pinned npm tarballs from a throw-away 127.0.0.1
  registry during a build, so `npm ci` / `pnpm install --frozen-lockfile` run
  unmodified.
- `aux-files/` holds patches and launcher scripts the packages install.

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

The config pins `guix` and `nonguix` to commits; `guix-discord` and this
channel follow their branches. A `guix` commit pins *every* package Guix
provides, so bumping it updates (and may rebuild) everything at once.

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
  and `nonguix` together with it. `guix describe -f channels > lock.scm`
  records the exact current state; `guix time-machine -C lock.scm -- system
  reconfigure ...` rebuilds it later.

## Runtime notes

### COSMIC

- `cosmic` goes in the system `packages`; the config logs in through
  `cosmic-greeter` under greetd, which lists COSMIC and Plasma.
- Fixes made for Guix (search `cosmic.scm` for the comments):
  - Xwayland and xrdb by store path;
  - input devices tracked by kernel name: a mouse that shows up as several
    same-named devices (Razer) otherwise ignored speed changes;
  - logs go to `~/.local/state/cosmic/session.log` instead of a missing
    journald;
  - XKB data, sound themes and themes looked up in the store or the system
    profile instead of `/usr/share`;
  - `loginctl suspend` instead of `systemctl suspend`;
  - default cursor theme (Pop);
  - `QT_PLUGIN_PATH` no longer clobbered by `start-cosmic`;
  - the initial setup's language and timezone pages are dropped (Guix sets
    those in the OS config);
  - `COSMIC_DRM_DITHERING[_<CONNECTOR>]` turns NVIDIA's dithering on or off
    per monitor (opt-in);
  - cosmic-idle answers `org.freedesktop.ScreenSaver.GetSessionIdleTime`
    (milliseconds, as KDE does);
  - `xwayland-activity-relay` (in the `cosmic` meta package, started
    through XDG autostart) resets the X11 screen saver every 20 s while the
    session is in use, which `xwayland-with-idle-time` counts as activity:
    the X11 idle time follows the whole session.  (Steam's Away status
    doesn't: on Linux it only counts input to Steam's own windows.)
  - the status area (tray) drops XEmbed icons (Wine, Java) when their
    program ends: xembedsniproxy registers them from another D-Bus
    connection than the one it serves them on, and the watcher only
    watched the registering one;
  - smithay's X11 clipboard bridge subscribes to property changes on the
    requestor window, so INCR transfers (anything over 64 KiB, i.e. images)
    to Chromium/Electron apps (Steam, Discord) no longer stall.
- The v2 default themes lack `list_button` upstream; cosmic-settings adds
  it, so the greeter no longer logs "error loading system dark theme".
- Window placement: new windows open where they were last closed -- the
  output, and for floating windows the position and size -- remembered per
  window by app id and title (Steam's library, friends list and chats are
  told apart) and per app from its last window to close, in
  `~/.local/state/cosmic-comp/window-outputs` across reboots; else on the
  primary output (Xwayland primary);
  fullscreen X11 windows (Wine games) on the output they placed themselves
  on, which ended black screens and mouse offsets on the other monitor.
  (That position is smithay's `last_configure()`: `geometry()` is
  window-relative, always at 0,0, which put every such window on the
  left monitor until round 20.)
- Dock: clicking the focused window's icon minimizes it from either
  monitor's dock; clicking the panel or dock doesn't take the keyboard
  focus.
- cosmic-settings-daemon syncs the theme to GTK (`gsettings`, by store
  path; it wasn't on the PATH) and adw-gtk3 is installed, so GTK and
  Electron apps (Claude) start in the current light/dark theme.
- `xwayland-with-idle-time` finds the NVIDIA EGL/GBM back ends, which
  cosmic-comp's sparse environment otherwise hid, leaving X11 apps on
  llvmpipe.  It also keeps MIT-SCREEN-SAVER for X11 idle queries, and keeps track of
  the pointer leaving X11 windows after one was destroyed under it: mouse
  buttons forwarded for push to talk (COSMIC Settings, *X11 compatibility*,
  i.e. `xwayland_eavesdropping.pointer`) used to go to a stale X11 window
  instead of reaching Discord.
- COSMIC Settings needs the systemd D-Bus services `locale1`, `timedate1` and
  `hostname1`: the config provides localed, `timedated` and gardenhostd.

### Wine packages (`radmin-vpn-linux`, `bfme-aio-launcher`)

- Guix's `wine64` has ELF builtins and old-style WoW64, which breaks both
  programs. `wine64-wow64` is the same Wine 11.0 built with mingw PE builtins
  and the new WoW64 mode.
- Every store file has mtime 1, so Wine's own "prefix needs updating" check
  never fires after a Wine change. `wine64-wow64/prefix-update` records the
  Wine build in `$WINEPREFIX/.guix-wine` and runs `wineboot -u` when it
  changes.
- Prefixes live under `$XDG_DATA_HOME` (`radmin-vpn-linux/wineprefix`,
  `bfme-aio-launcher/prefix`), with winemenubuilder disabled. BFME's games
  go to drive `D:` (`$XDG_DATA_HOME/bfme-aio-launcher/games`).
- A named virtual desktop's window is named (WM_CLASS) after the desktop,
  lowercased (`faf`, `bfme`), not `explorer.exe`, so docks show each game
  with its own name and icon.  It is created at the X11 primary monitor's
  position (COSMIC's Xwayland primary, DP-1 here), and cosmic-comp shows a
  fullscreen X11 window on the output it is on.  Radmin's prefix is
  `RADMIN_WINEPREFIX`, so a global `WINEPREFIX` doesn't move it.

### Others

- **faforever-client**: finds Steam inside nonguix's container home
  (`$GUIX_SANDBOX_HOME`, default `~/.local/share/guix-sandbox-home`); its own
  data is in `$XDG_DATA_HOME/faforever`. With an empty "Launch command" the
  game runs through the bundled `faf-wine` (wine64-wow64 + DXVK, prefix
  `$XDG_DATA_HOME/faforever/wine`); `faforever-client --quit` quits a running
  client.  The game runs in a Wine virtual desktop as big as the primary monitor
  and on it (`FAF_VIRTUAL_DESKTOP=auto`, the default; `off` for its own
  fullscreen window; `WIDTHxHEIGHT`); BFME: `BFME_VIRTUAL_DESKTOP`, same
  values and default.  Its default 1024x768 fullscreen resolution is replaced by the
  primary monitor's: switching display modes under Xwayland made it
  flicker.  The game's window gets
  the game's own icon (taken from ForgedAlliance.exe).  Prefix:
  `FAF_WINEPREFIX`; replays in `$XDG_DATA_HOME/faforever/replays`; DXVK's
  log in `$XDG_CACHE_HOME/faforever/dxvk`.  Steam status ("playing
  Forged Alliance", Settings -> Game): the client's helper can't reach
  nonguix's containerized Steam from the host, so `faf-steam-presence`
  (`FAF_STEAM_PRESENCE_COMMAND`) runs a small helper inside the running
  Steam container (`nsenter` into its user, mount, PID and IPC namespaces)
  for as long as the game runs. The self-updater is disabled.
- **r2modman**: also finds that sandboxed Steam library and launches games
  with `steam -applaunch`; mods need its profile directory shared into the
  Steam container (`GUIX_SANDBOX_EXTRA_SHARES`, set by the config).
- **scrcpy**: runs as a native Wayland client (`SDL_VIDEO_DRIVER=wayland,x11`).
- **pandora-launcher**: uses Guix JDKs through upstream's
  `FORCE_EXTERNAL_JAVA`; Mojang's runtimes don't run on Guix.
- **gamescope**: in Heroic, enable it per game under Settings > Other.
- **gpu-unlock**: `%gpu-unlock-services` installs the `gpu_unlock` module,
  its firmware and a udev rule (`60-gpu-unlock.rules`) that loads it for
  NVIDIA display controllers before `80-drivers.rules` loads `nvidia` from
  the same device event; its init unlocks the cards synchronously.  (Upstream
  uses the initramfs, which on Guix can only hold the kernel package's own
  modules.)  It acts only on the cards named by the kernel argument
  `gpu_unlock.targets=` (`0000:05:00.0` in the config).  Check with
  `sudo dmesg | grep gpu_unlock`; remove the argument, or delete it in GRUB's
  edit screen for one boot, to turn it off.
- **ladybird**: Skia, ANGLE, FFmpeg and pdf.js take their vcpkg overlay
  patches from a separately pinned Ladybird tree (`%ladybird-ports-commit`),
  so moving `%ladybird-commit` doesn't rebuild them; move it too when
  `git diff OLD NEW -- Meta/CMake/vcpkg` isn't empty.
  libpng-apng (1.6.50) is forced on executables *and* shared libraries
  (`-L`, `-rpath-link`, `--no-as-needed`); otherwise ld finds Qt's plain
  1.6.39, which lacks `png_set_cICP`.
- **openrazer-kernel-modules**: in driver mode the keyboard's own backlight
  and macro-recording keys stop working; turn it off with the kernel
  argument `razerkbd.driver_mode=0`.
