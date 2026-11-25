# hyperguix

A Guix channel of packages Guix doesn't have (or doesn't have in
a usable form) -- the COSMIC desktop, the Craft apps, launchers, drivers and
`guix bump`. Modules are named `(hyperguix packages <file>)`.

```scheme
(channel
  (name 'hyperguix)
  (url "https://github.com/Lightningbulb2/hyperguix.git")
  (branch "main")
  (commit "..."))        ;pin it; `guix bump hyperguix` moves the pin
```

Changes only count once committed and pushed; then `guix bump hyperguix -H`
moves the pin in the config (`~/config.scm`), pulls and installs. To try
uncommitted changes: `guix build -L . PACKAGE` from a checkout.

The channel depends on nonguix (`.guix-channel`): several packages use its
`linux` kernel, NVIDIA driver, Electron, fonts or binary build systems.

## Packages

| Module | Package(s) | Notes |
| --- | --- | --- |
| `cosmic.scm` | `cosmic` (meta) and all its components, `cosmic-greeter`, `pop-launcher`, `cosmic-icons`, `pop-icon-theme`, `cosmic-sound-theme`, `cosmic-wallpapers` (COSMIC epoch 1.12.0) | see *COSMIC* below |
| `xwayland.scm` | `xwayland-with-idle-time`, `xwayland-activity-relay` | Xwayland used by cosmic-comp, and the helper that keeps Steam from going Away; see *COSMIC* |
| `timedated.scm` | `timedated` | systemd's timedated built alone (org.freedesktop.timedate1), for COSMIC Settings |
| `ask.scm` | `ask` | `ask QUESTION` recommends installed commands for a question, answered locally (llama.cpp, an index of the man pages, `guix` sub-commands and `--help`); `ask models --fetch` once, then `ask index` |
| `guix-bump.scm` | `guix-bump`, `guix-manager` | `guix bump` (move the channel pins in the config to the latest commits, pull, optionally reconfigure; `--check` lists apps with a newer version, `guix bump APP` updates one; `--search`, `--install`, `--remove` and `--installed` manage a list of package names in the config; `--undo`, a warning before compiling slow packages, commits the config to its git repository), `guix nightly` (bump all, pull, system + home, clean up, power off, with a log; the screens are off while it runs, `--screen-on` keeps them on) and Guix Manager (`guix-manager`), a window with Updates, Install and Installed pages that runs those commands in a terminal pane |
| `craft.scm` | `photocraft`, `effectcraft`, `filmcraft`, `pdfcraft`, `lightcraft`, `vectorcraft`, `gridcraft`, `wordcraft`, `soundcraft`, `cadcraft`, `figcraft`, `designcraft`, `deckcraft`, `texturecraft`, `materialcraft`, `anicraft`, `craft-anything`, `craft-launcher` | the storytold "Craft" suite, each with its `*-cli` |
| `solidcraft.scm` | `solidcraft` 0.49.1 (with `solidcraft-cli`) | Tangency Labs' parametric 3D CAD; crates in `solidcraft-crates.scm` |
| `ladybird.scm` | `ladybird` (git master), plus private Skia 148, ANGLE, ffmpeg 9, LLVM libc headers, curl+OpenSSL | Qt 6 UI; its sandbox needs Landlock (`lsm=landlock,...` kernel argument) |
| `scrcpy.scm`, `scrcpy-gui.scm` | `scrcpy` 5.0.1, `scrcpy-gui` 4.1.0 | Android mirroring |
| `faforever.scm` | `faforever-client` 1.0.2 | Rust/Tauri FAF client |
| `pandora-launcher.scm` | `pandora-launcher` 6.0.0 | Minecraft launcher on Guix JDKs |
| `r2modman.scm` | `r2modman` 3.2.21 | built from source, runs on nonguix's Electron 38 |
| `radmin-vpn.scm` | `radmin-vpn-linux`, `wine64-wow64`, `wine64-wow64/prefix-update` | Radmin VPN under Wine; the Wine variants are also used by `bfme.scm` |
| `bfme.scm` | `bfme-aio-launcher` | BFME All In One Launcher under Wine (nonfree; upstream's own builds) |
| `gamescope.scm` | `gamescope` 3.17.0, `heroic-nvidia-new-feature-gamescope` | Heroic with gamescope inside its FHS container |
| `claude-desktop.scm` | `claude-desktop` | Anthropic's official Linux beta, repackaged (nonfree) |
| `chrome-remote-desktop.scm` | `chrome-remote-desktop`, `chrome-remote-desktop-service-type` | Google's host, virtual Xfce desktop (nonfree; currently disabled in the config) |
| `openrazer.scm` | `openrazer-kernel-modules`, `%openrazer-keyboard-services` | `razerkbd` only, patched to put the BlackWidow (1532:011a) in driver mode so M1–M5 send F13–F17 |
| `gpu-unlock.scm` | `gpu-unlock`, `gpu-unlock-firmware`, `%gpu-unlock-services` | full-rate FP16/BF16/TF32 tensor cores on GeForce RTX 20/30/40 (kernel module; firmware from NVIDIA 610.43.03 is nonfree); see *Others* |
| `strata.scm` | `strata` 0.2.12 | the `strata` command and its CUDA engine (compute capability 8.6, built with CUDA 13.4); no desktop app or picture reader, and `strata update` can't replace the engine |
| `codecanvas.scm` | `codecanvas`, `codecanvas-vscode`, `codecanvas-zed-bridge` | infinite code canvas: the app, the VS Code extension and the Zed bridge are `rust/`, `vscode/` and `zed/` of github.com/Lightningbulb2/CodeCanvas at one pinned commit (`%codecanvas-commit`) |
| `llama-cpp.scm` | `llama-cpp/latest` (Vulkan, OpenBLAS), `llama-cpp-cuda` (also CUDA, compute capability 8.6) | llama.cpp 1.0.0 with its bundled ggml; Guix has 0.7.0 |
| `cuda.scm` | `cuda-toolkit` | NVIDIA CUDA 13.4: nvcc, cudart, cuBLAS (from NVIDIA's redist archives; nonfree); `libcuda` comes from the driver |
| `klipper.scm` | `klipper` (0.13.0+827), `klipper-e3v3se` (jpcurti's Ender-3 V3 SE fork, 0.13.0+919), `moonraker` (0.11.0+4), `fluidd` 1.38.0, `python-streaming-form-data`, `python-periphery` | 3D-printer host: klippy with its C helper prebuilt, Moonraker, and Fluidd's release build; see *Klipper* below |
| `reboot-to-bios.scm` | `reboot-to-bios` | |
| `grub-usb-keyboard.scm` | `grub-efi-usb-keyboard-bootloader`, `uefi-shell` (EDK2 shell 2.2, pbatard's 26H2 build) | GRUB with a USB keyboard under the firmware's Ultra Fast boot; see *Others* |

Maintaining the channel (layout, updating packages, pitfalls, conventions)
is covered in [AGENTS.md](AGENTS.md).

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
  left monitor until round 20.  Until round 21 a size-only configure
  request before mapping -- Wine sends one for its virtual desktops --
  also reset that position to 0,0 for the same reason.)
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

### Craft apps

Each Craft app is an ordinary package: installing one builds that one.
Several Craft apps share most of their libraries (egui, wgpu, image
codecs), so a config that installs more than one should build them
together, which compiles those libraries once instead of once per app.
Wrap the home environment (or the operating system) in `with-craft-suite`
from `(hyperguix packages craft)`, as with nonguix's NVIDIA transformation:

```scheme
(with-craft-suite
 (home-environment
   (packages (list photocraft filmcraft ...))))
```

Only the Craft apps listed go into that build. Changing any of them
rebuilds that build. (`craft-suite` is all of them at once.)

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

### Klipper

`klipper`, `moonraker` and `fluidd` are what upstream's install scripts
(and KIAUH) set up with git checkouts, a virtualenv and systemd units.  Here
they are ordinary packages: `klippy` and `moonraker` are commands, and the
services, nginx and the `printer_data` layout are written in the system
config (the owner's is `latitude.scm` in MyGuixConfig).

- `klippy PRINTER.CFG -l LOG -a SOCKET` and `moonraker -d PRINTER_DATA`,
  as upstream's service files run them.  The services need the `dialout`
  group (shepherd starts a service with no supplementary groups unless they
  are listed).
- Moonraker without systemd: `[machine] provider: none`.  Its update
  manager doesn't apply; Guix updates these.  Object processing is off
  (preprocess-cancellation isn't packaged), and so is `[zeroconf]` (Guix's
  python-zeroconf is too old).
- Fluidd is static files in `share/fluidd`, served by nginx with `/websocket`,
  the API paths and `/webcam/` proxied (upstream's nginx layout).
- **MCU firmware** is built from a writable checkout at the same commit as
  the package (`git checkout` the commit in `klipper.scm`), on any Guix
  machine.  `--pure` matters: `gcc-toolchain` in the same shell puts the
  host's glibc headers in front of avr-gcc's.

  ```sh
  # AVR boards (ATmega: older Creality, Prusa Einsy):
  guix shell --pure bash make python coreutils grep sed gawk findutils \
      which binutils gcc-cross-avr-toolchain -- make menuconfig   # then: make
  # ARM boards (STM32, ...): the nano toolchain (Klipper links newlib-nano),
  # and the toolchain's preprocessor for the linker script (no host cpp here):
  guix shell --pure bash make python coreutils grep sed gawk findutils \
      which binutils \
      -e '((@ (gnu packages embedded) make-arm-none-eabi-nano-toolchain-12.3.rel1))' \
      -- make menuconfig            # then: make CPP=arm-none-eabi-cpp
  # (no substitute: the first use compiles the cross GCC, newlib-nano and
  # libstdc++, about an hour)
  ```

  The result is `out/klipper.bin` (copy to the board's SD card) or
  `out/klipper.elf.hex` (`avrdude`); `make flash FLASH_DEVICE=...` works on
  the printer host, which has avrdude and dfu-util.
- **`klipper-e3v3se`** is [jpcurti's fork](https://github.com/jpcurti/ender3-v3-se-klipper-with-display)
  for the Creality Ender-3 V3 SE: it drives the printer's own screen
  (`[e3v3se_display]`, which needs Creality's display firmware 1.0.6) and the
  load-cell Z offset probe (`[prtouch]`).  Its MCU firmware comes from a
  checkout of the fork at the package's commit, with the fork's
  `test/configs/displayv3se.config` (STM32F103, 28KiB bootloader, USART1,
  serial bridge on USART2): `cp test/configs/displayv3se.config .config`,
  then `make olddefconfig` and `make CPP=arm-none-eabi-cpp` in the ARM shell
  above.

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
  for as long as the game runs. The self-updater is disabled, and so is
  0.9.5's own Linux runtime (GE-Proton in Valve's Steam Linux Runtime,
  downloaded on first start): it needs an FHS host and would bypass
  wine64-wow64's fixes, so the default launch command counts as your own.
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
- **grub-efi-usb-keyboard-bootloader**: use it in place of
  `grub-efi-bootloader` (same configuration) when the firmware's Ultra Fast
  boot leaves GRUB without a keyboard: GRUB has no xHCI driver and borrows
  the firmware's, which Ultra Fast never connects.  Each reconfigure installs
  GRUB as usual, then `\EFI\usbgrub\` (the UEFI shell and a `startup.nsh`
  that runs `connect -r` and then `\EFI\Guix\grubx64.efi`) and a firmware
  boot entry "GRUB (USB keyboard)" put first in BootOrder (grub-install moves
  "Guix" first every time).  If the shell can't start GRUB it exits and the
  firmware boots "Guix" directly.  Needs Secure Boot off (the shell isn't
  signed, but neither is Guix's GRUB).  To go back, switch to
  `grub-efi-bootloader`, reconfigure, and delete the entry
  (`efibootmgr -b NNNN -B`).
- **openrazer-kernel-modules**: in driver mode the keyboard's own backlight
  and macro-recording keys stop working; turn it off with the kernel
  argument `razerkbd.driver_mode=0`.
