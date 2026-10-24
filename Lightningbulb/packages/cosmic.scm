;;; Lightningbulb channel --- the COSMIC desktop environment (System76)
;;;
;;; One package per component, pinned to the commits the cosmic-epoch
;;; meta-repository points at (currently its epoch-1.11.0 tag).  Every
;;; component is a Rust workspace built with its own justfile (just
;;; build-release / just install), against the crates in cosmic-crates.scm;
;;; crates COSMIC takes from git (libcosmic and its iced fork, smithay,
;;; cosmic-protocols, ...) are vendored by the helper in cargo-git.scm.
;;;
;;; `cosmic' at the bottom is the meta package: put it in your system's
;;; packages and pick "COSMIC" in your display manager's session menu.

(define-module (Lightningbulb packages cosmic)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages regex)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages window-management)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages cargo-git)
  #:use-module (Lightningbulb packages cosmic-crates)
  #:use-module (Lightningbulb packages xwayland))

(define %cosmic-version "1.11.0")

(define* (cosmic-source name commit hash #:key lfs?)
  "Return the source of pop-os/NAME at COMMIT.  When LFS? is true, also fetch
the files the repository keeps in Git LFS; a plain checkout only has small
text pointers in their place."
  (origin
    (method (if lfs? git-fetch/lfs git-fetch))
    (uri (git-reference
          (url (string-append "https://github.com/pop-os/" name))
          (commit commit)))
    (file-name (git-file-name name (string-take commit 7)))
    (sha256 (base32 hash))))

;; Linked by most components (smithay-client-toolkit, libcosmic, zbus...).
(define %cosmic-common-inputs
  (list dbus eudev fontconfig freetype glib libdrm libinput
        libxkbcommon mesa openssl pixman vulkan-loader wayland
        (list zstd "lib")))

;; dlopen()ed at run time by wgpu/winit/wayland-rs; added to RUNPATH.  The X11
;; libraries are what winit's X11 back end opens when an application runs
;; outside a Wayland session (e.g. under Plasma X11); without them it panics
;; with "libXi.so.6: cannot open shared object file".
(define %cosmic-dlopen-libraries
  (list libx11 libxcb libxi libxkbcommon mesa vulkan-loader wayland))

;; The images are stored with Git LFS, hence git-fetch/lfs.  Defined up here
;; because cosmic-bg and xdg-desktop-portal-cosmic refer to it for their
;; default background.
(define-public cosmic-wallpapers
  (package
    (name "cosmic-wallpapers")
    (version (git-version %cosmic-version "0"
                          "da595bba495cb8fc57f26505621fc25000218349"))
    (source
     (origin
       (method git-fetch/lfs)
       (uri (git-reference
             (url "https://github.com/pop-os/cosmic-wallpapers")
             (commit "da595bba495cb8fc57f26505621fc25000218349")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0ds9p3sa9csd7vdpkw0mdl138m4b27v8wjjy64fk4cx5r64y33cv"))))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f
           #:make-flags #~(list (string-append "prefix=" #$output))
           #:phases #~(modify-phases %standard-phases
                        (delete 'configure))))
    (home-page "https://github.com/pop-os/cosmic-wallpapers")
    (synopsis "Wallpapers of the COSMIC desktop")
    (description "Default background images of the COSMIC desktop.")
    (license license:cc-by-sa4.0)))

(define %cosmic-default-backgrounds
  (file-append cosmic-wallpapers "/share/backgrounds/cosmic/"))

(define (use-store-backgrounds files)
  "Return a phase pointing the /usr/share/backgrounds/cosmic/ paths in FILES
at cosmic-wallpapers."
  #~(add-after 'unpack 'use-store-backgrounds
      (lambda _
        (substitute* '#$files
          (("/usr/share/backgrounds/cosmic/") #$%cosmic-default-backgrounds)))))

(define* (cosmic-component name commit hash
                           #:key
                           (repository name)
                           lfs?
                           (version %cosmic-version)
                           cargo-inputs git-crates
                           (extra-inputs '())
                           (extra-native-inputs '())
                           (build-env '())
                           (just-vars #f)
                           (build-recipe "build-release")
                           (build-args '())
                           (install-recipes '("install"))
                           (extra-phases '())
                           (license license:gpl3)
                           synopsis description)
  (package
    (name name)
    (version (git-version version "0" commit))
    (source (cosmic-source repository commit hash #:lfs? lfs?))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.95
      #:install-source? #f
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          #$@(vendor-git-crates-phases git-crates)
          (add-after 'unpack 'patch-justfile-shebangs
            ;; Recipes like `install-plugins' run through `#!/usr/bin/env
            ;; sh'; the build sandbox has no /usr/bin/env.  (Guix's
            ;; shebang patching only looks at the first line of a file.)
            (lambda _
              (for-each
               (lambda (file)
                 (substitute* file
                   (("#!/usr/bin/env (sh|bash)" _ shell)
                    (string-append "#!" (which shell)))))
               (find-files "." "^(justfile|Justfile|.*\\.just)$"))))
          (add-after 'unpack 'log-to-stderr-without-journald
            ;; tracing_journald::layer() succeeds without a journal (it only
            ;; opens a socket), so the components that prefer journald
            ;; (session, greeter, panel, launcher, notifications, portal...)
            ;; logged nowhere.  Log to stderr, which the session or the
            ;; display manager saves, unless journald is really there.
            (lambda _
              (substitute*
                  (find-files "." (lambda (file stat)
                                    (and (string-suffix? ".rs" file)
                                         (not (string-prefix? "./guix-vendor/"
                                                              file)))))
                (("if let Ok\\(([a-z_]+)\\) = tracing_journald::layer\\(\\)"
                  _ name)
                 (string-append
                  "if let Some(" name ") = std::path::Path::new("
                  "\"/run/systemd/journal/socket\").exists()"
                  ".then(tracing_journald::layer).and_then(Result::ok)")))))
          (add-after 'unpack-rust-crates 'patch-vendored-crates
            (lambda _
              (define (crate-files crate file)
                (find-files "guix-vendor"
                            (lambda (f stat)
                              (and (string-contains
                                    f (string-append "/rust-" crate "-"))
                                   (string-suffix? file f)))))
              ;; xkb-data reads the keyboard layout lists from
              ;; /usr/share/X11/xkb; without them the keyboard pages of
              ;; Settings and the initial setup were empty.
              (substitute* (crate-files "xkb-data" "/src/lib.rs")
                (("/usr/share/X11/xkb/")
                 #$(file-append xkeyboard-config "/share/X11/xkb/")))
              ;; Windows are matched to desktop entries by app ID; the last
              ;; resort compares it with the Exec command, which on Guix is
              ;; an absolute store file name (Exec=/gnu/store/...-vscodium-
              ;; .../bin/codium for the app ID "codium").  Compare its base
              ;; name as well, so the dock and app list find such entries
              ;; and their icons.
              (substitute* (crate-files "freedesktop-desktop-entry"
                                        "/src/lib.rs")
                (("^( *)\\.is_some_and\\(\\|exec\\| exec == app_id\\)\n"
                  _ indent)
                 (string-append
                  indent ".is_some_and(|exec| exec == app_id\n"
                  indent "    || std::path::Path::new(exec).file_name()\n"
                  indent "        .and_then(|name| name.to_str())\n"
                  indent "        .is_some_and(|name| name == app_id))\n")))))
          (add-after 'unpack 'set-build-environment
            (lambda _
              (for-each (lambda (pair) (setenv (car pair) (cdr pair)))
                        '#$build-env)
              ;; The justfiles call plain `cargo build'; not every recipe
              ;; takes extra arguments, so go offline this way.
              (setenv "CARGO_NET_OFFLINE" "true")))
          (replace 'build
            (lambda _
              (apply invoke "just" #$build-recipe '#$build-args)))
          (replace 'install
            (lambda _
              (apply invoke "just"
                     (append
                      (let ((vars #$(or just-vars
                                        #~(list "prefix" #$output
                                                "rootdir" ""))))
                        (let loop ((vars vars) (acc '()))
                          (if (null? vars)
                              (reverse acc)
                              (loop (cddr vars)
                                    (cons* (cadr vars) (car vars) "--set"
                                           acc)))))
                      '#$install-recipes))))
          (add-after 'install 'add-dlopen-runpath
            (lambda _
              (let ((runpath
                     (string-join
                      (list #$@(map (lambda (lib) (file-append lib "/lib"))
                                    %cosmic-dlopen-libraries))
                      ":")))
                (for-each
                 (lambda (file)
                   (when (and (elf-file? file)
                              (not (symbolic-link? file)))
                     (invoke "patchelf" "--add-rpath" runpath file)))
                 (append (find-files (string-append #$output "/bin"))
                         (if (file-exists? (string-append #$output "/libexec"))
                             (find-files (string-append #$output "/libexec"))
                             '()))))))
          #$@extra-phases)))
    (native-inputs
     ;; util-linux: install recipes pipe through `rev'; without it they
     ;; silently install nothing (no panel/applet defaults, no icons).
     (append (list gettext-minimal just patchelf pkg-config python util-linux)
             extra-native-inputs))
    (inputs
     (append %cosmic-common-inputs extra-inputs cargo-inputs))
    (supported-systems '("x86_64-linux" "aarch64-linux"))
    (home-page (string-append "https://github.com/pop-os/" repository))
    (synopsis synopsis)
    (description description)
    (license license)))


;;;
;;; Core session.
;;;

(define-public cosmic-comp
  (cosmic-component "cosmic-comp" "8cb1802caada438bb5cc7670dfabdaca5fad0502"
                    "0b4gqfaj3hpanbsil1ywi9xv3i0z3rj4wqj4l6xy6lnjvwqjxr6n"
                    #:version "1.0.0"
                    #:cargo-inputs cosmic-comp-cargo-inputs
                    #:build-env '(("GIT_HASH"
                                   . "8cb1802caada438bb5cc7670dfabdaca5fad0502"))
                    #:git-crates cosmic-comp-git-crates
                    #:extra-inputs (list libdisplay-info
                                         libseat ;Guix's seatd drops lib/ and include/
                                         ;; Rootless Xwayland with MIT-SCREEN-SAVER
                                         ;; (Steam's idle detection).
                                         xwayland-with-idle-time
                                         xrdb)
                    #:extra-phases
                    ;; Xwayland and xrdb are otherwise looked up in PATH, which
                    ;; need not contain them; X11 applications (Steam, ...)
                    ;; would then fail to start.
                    (list
                     #~(add-after 'unpack 'patch-xrdb-path
                         (lambda* (#:key inputs #:allow-other-keys)
                           (substitute* "src/xwayland.rs"
                             (("Command::new\\(\"xrdb\"\\)")
                              (format #f "Command::new(~s)"
                                      (search-input-file inputs "bin/xrdb"))))))
                     ;; Input devices are tracked by name, but one mouse can
                     ;; show up as several devices with the same name (a
                     ;; Razer DeathAdder is three).  Only the last one added
                     ;; was kept, so settings changed at run time (pointer
                     ;; speed, ...) skipped the actual pointer.  Key them by
                     ;; their unique kernel name (eventN) instead.
                     ;; Opt-in NVIDIA "dithering mode" per connector, from
                     ;; COSMIC_DRM_DITHERING[_<CONNECTOR>] (see the patch).
                     #~(add-after 'unpack 'apply-dithering-patch
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-comp-dithering-env.patch"))))
                     ;; Don't show override-redirect X11 windows whose
                     ;; _NET_WM_WINDOW_OPACITY is 0, as KWin doesn't:
                     ;; xembedsniproxy's tray icon containers, black squares
                     ;; at Xwayland's (0,0) otherwise (see the patch).
                     #~(add-after 'unpack 'apply-xwayland-opacity-patch
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-comp-xwayland-opacity.patch"))))
                     ;; New windows open on the output their app was last
                     ;; closed on, and fullscreen X11 windows (games) on the
                     ;; output they placed themselves on, instead of on the
                     ;; output the pointer is on (see the patch).
                     #~(add-after 'unpack 'apply-window-outputs-patch
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-comp-window-outputs.patch"))))
                     #~(add-after 'unpack 'track-input-devices-by-sysname
                         (lambda _
                           (substitute* "src/backend/kms/mod.rs"
                             (("\\.insert\\(device\\.name\\(\\)\\.into\\(\\)")
                              ".insert(device.sysname().into()")
                             (("\\.remove\\(&\\*device\\.name\\(\\)\\)")
                              ".remove(device.sysname())"))))
                     #~(add-after 'vendor-git-crates 'patch-xwayland-path
                         (lambda* (#:key inputs #:allow-other-keys)
                           (let ((files (filter (lambda (f)
                                                  (string-contains f "/smithay-"))
                                                (find-files "guix-vendor"
                                                            "^xserver\\.rs$"))))
                             (when (null? files)
                               (error "smithay's xwayland/xserver.rs not found"))
                             (substitute* files
                               (("Command::new\\(\"Xwayland\"\\)")
                                (format #f "Command::new(~s)"
                                        (search-input-file inputs
                                                           "bin/Xwayland")))))))
                     ;; Wayland->X11 clipboard transfers of 64 KiB or more
                     ;; (images) use INCR, which stalled for requestors
                     ;; whose window is InputOnly, as Chromium/Electron's
                     ;; (Steam, Discord): nothing pasted, or a freeze.
                     #~(add-after 'vendor-git-crates 'patch-xwm-incr
                         (lambda _
                           (let ((files (filter (lambda (f)
                                                  (string-contains
                                                   f "/src/xwayland/xwm/"))
                                                (find-files "guix-vendor"
                                                            "^selection\\.rs$"))))
                             (when (null? files)
                               (error "smithay's xwayland/xwm not found"))
                             (with-directory-excursion
                                 (dirname (dirname (dirname (dirname (car files)))))
                               (invoke "patch" "-p1" "--input"
                                       #$(local-file
                                          "aux-files/smithay-xwm-incr-property-change.patch")))))))
                    #:synopsis "Wayland compositor of the COSMIC desktop"
                    #:description
                    "cosmic-comp is the Smithay-based Wayland compositor at the
heart of the COSMIC desktop: window management with optional auto-tiling,
workspaces, multi-monitor and multi-GPU support, and XWayland."))

(define-public cosmic-session
  (cosmic-component
   "cosmic-session" "4b0a0a24e98b9e755b6a7146e4cb29539cacda0a"
   "10bk51psw8jsbwqsnn0cafzkq62qbjgb76d9z0pbkxyxajawy5qx"
   #:cargo-inputs cosmic-session-cargo-inputs
   #:git-crates cosmic-session-git-crates
   #:extra-inputs (list bash-minimal)
   ;; Without systemd, cosmic-session itself must start the XDG autostart
   ;; entries (~/.config/autostart, /etc/xdg/autostart); that code is behind
   ;; a non-default feature.
   #:build-args '("--features" "autostart")
   #:just-vars #~(list "prefix" #$output "rootdir" ""
                       ;; Screen reader started by the session (optional).
                       "orca" "orca")
   #:extra-phases
   (list
    ;; (The session's log goes to stderr, which the display manager saves:
    ;; see log-to-stderr-without-journald in cosmic-component.)
    #~(add-after 'install 'fix-session-paths
        (lambda* (#:key inputs #:allow-other-keys)
          (let ((dbus-run-session (search-input-file inputs "bin/dbus-run-session")))
            (substitute* (string-append #$output "/bin/start-cosmic")
              (("^#!/bin/sh")
               (string-append "#!" (search-input-file inputs "bin/sh")))
              (("/usr/bin/dbus-run-session") dbus-run-session)
              (("/usr/bin/cosmic-session")
               (string-append #$output "/bin/cosmic-session"))
              ;; The CuteCosmic probe used QT_PLUGIN_PATH as its loop
              ;; variable, leaving it set to "/usr/lib/*/qt6/plugins" and
              ;; hiding the profiles' Qt plugins (Wayland platform, image
              ;; formats, themes) from every Qt application.
              (("for QT_PLUGIN_PATH in .*; do")
               "for qt_plugin_dir in $(IFS=:; echo ${QT_PLUGIN_PATH}); do")
              (("\\$\\{QT_PLUGIN_PATH\\}/platformthemes")
               "${qt_plugin_dir}/platformthemes")
              ;; Without XCURSOR_THEME the compositor (and Xwayland, which
              ;; it hands the theme to) looks for a theme called "default";
              ;; there is none on Guix, so every pointer shape -- links,
              ;; text, resize edges -- fell back to the same built-in
              ;; arrow.  Use COSMIC's own cursor theme (pop-icon-theme).
              (("^export DCONF_PROFILE=.*" all)
               ;; (ALL ends with the newline.)
               (string-append all
                              "export XCURSOR_THEME=\"${XCURSOR_THEME:-Pop}\"\n"
                              "export XCURSOR_SIZE=\"${XCURSOR_SIZE:-24}\"\n"))
              ;; greetd hands the session its VT as stdout/stderr, so the
              ;; whole session's log (compositor and components included)
              ;; scrolled by on an invisible console.  Keep it in a file, the
              ;; previous session's next to it.
              (("^export XDG_CURRENT_DESKTOP=.*" all)
               (string-append
                "if [ -t 2 ]; then\n"
                "    log_dir=\"${XDG_STATE_HOME:-$HOME/.local/state}/cosmic\"\n"
                "    mkdir -p \"$log_dir\"\n"
                "    [ -f \"$log_dir/session.log\" ] && "
                "mv -f \"$log_dir/session.log\" \"$log_dir/session.log.old\"\n"
                "    exec >>\"$log_dir/session.log\" 2>&1\n"
                "fi\n"
                all)))
            (substitute* (string-append #$output
                                        "/share/wayland-sessions/cosmic.desktop")
              (("^Exec=.*")
               (string-append "Exec=" #$output "/bin/start-cosmic\n")))))))
   #:synopsis "Session manager of the COSMIC desktop"
   #:description
   "cosmic-session starts and supervises the components of a COSMIC session
(compositor, panels, settings daemon, notifications, ...).  It installs the
@command{start-cosmic} entry point and the @file{cosmic.desktop} Wayland
session file display managers list."))

(define-public cosmic-settings-daemon
  (cosmic-component "cosmic-settings-daemon"
                    "655b14fb9572dd7f7231ec6c343c63984e99741a"
                    "0v56l3m0mjg445pmsdq1qd33nqvdljw51xjg4j6v4nrxrchwdi49"
                    #:cargo-inputs cosmic-settings-daemon-cargo-inputs
                    #:git-crates cosmic-settings-daemon-git-crates
                    #:extra-inputs (list pipewire)
                    #:extra-native-inputs (list clang)
                    #:extra-phases
                    ;; Sound themes (event sounds) and the adw-gtk3 themes
                    ;; it switches GTK 3 to are looked up under /usr/share.
                    (list
                     #~(add-after 'unpack 'use-system-profile-data
                         (lambda _
                           (substitute* '("src/pipewire.rs" "src/battery.rs"
                                          "src/theme.rs")
                             (("/usr/share/(sounds|themes)/" _ dir)
                              (string-append "/run/current-system/profile/share/"
                                             dir "/")))))
                     ;; The default Suspend action (also what cosmic-idle
                     ;; runs after the idle timeout) is `systemctl suspend';
                     ;; without systemd that does nothing.  elogind's
                     ;; loginctl does the same through logind.
                     #~(add-after 'unpack 'suspend-with-loginctl
                         (lambda _
                           (substitute* "data/system_actions.ron"
                             (("\"systemctl suspend\"")
                              "\"loginctl suspend\"")))))
                    #:license license:gpl3+
                    #:synopsis "Settings daemon of the COSMIC desktop"
                    #:description
                    "cosmic-settings-daemon applies COSMIC settings at run time:
themes and appearance, brightness and volume keys, input devices, and other
system integration."))

(define-public cosmic-panel
  (cosmic-component "cosmic-panel" "ca20ce3185b3b4404f429d59d429c40b58a2ddef"
                    "0sjpzhf2589gd2y6l6d3i5cdqvf39d0ahp95pl6ljlapf1y21034"
                    #:cargo-inputs cosmic-panel-cargo-inputs
                    #:git-crates cosmic-panel-git-crates
                    #:synopsis "Panel and dock of the COSMIC desktop"
                    #:description
                    "cosmic-panel draws the COSMIC top panel and dock and hosts
the applets shown in them."))

(define-public cosmic-applets
  (cosmic-component "cosmic-applets" "328d142faac17c9cc3e00d434d05060411c007ea"
                    "05xk984jhhxzral08l36x6krcbhsm2a4qm5k55fdv0wk0n25qif0"
                    #:cargo-inputs cosmic-applets-cargo-inputs
                    #:git-crates cosmic-applets-git-crates
                    #:extra-phases
                    ;; Status area: right-clicking an item without a DBusMenu
                    ;; opened an empty popup.  Call the item's ContextMenu
                    ;; instead, as other hosts do, so that the XEmbed icons
                    ;; xembedsniproxy proxies (Wine programs...) show their
                    ;; own menu (see the patch).
                    ;; Its watcher also kept those icons after their program
                    ;; ended: it only dropped an item when the connection
                    ;; that registered it went away, and xembedsniproxy
                    ;; registers them from another connection than the one
                    ;; it serves them on (see the patch).
                    (list
                     #~(add-after 'unpack 'apply-status-area-context-menu-patch
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-applets-status-area-context-menu.patch"))))
                     #~(add-after 'apply-status-area-context-menu-patch
                           'apply-status-area-watcher-unregister-patch
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-applets-status-area-watcher-unregister.patch"))))
                     ;; Dock: the focused window's icon minimizes it from
                     ;; every output's dock (see the patch).
                     #~(add-after 'unpack 'apply-app-list-focus-patch
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-applets-app-list-focus-any-output.patch")))))
                    #:synopsis "Panel applets of the COSMIC desktop"
                    #:description
                    "The standard COSMIC panel applets: app list, audio,
battery, Bluetooth, network, notifications, power, status area (tray),
tiling, time, workspaces, input sources and accessibility."))

(define-public cosmic-bg
  (cosmic-component "cosmic-bg" "9520e16758693bc2f6845d52680f236d548edda2"
                    "1vx7aamb3kl91ygxqxzs1mq6hddnzrbkxp5mdnp41q5n4ajvfknv"
                    #:cargo-inputs cosmic-bg-cargo-inputs
                    #:git-crates cosmic-bg-git-crates
                    #:extra-inputs (list dav1d)
                    #:extra-phases
                    (list (use-store-backgrounds '("config/src/lib.rs"
                                                   "data/v1/all")))
                    #:license license:mpl2.0
                    #:synopsis "Wallpaper service of the COSMIC desktop"
                    #:description
                    "cosmic-bg draws the COSMIC desktop background on every
output, from images, colors or gradients."))

(define-public cosmic-idle
  (cosmic-component "cosmic-idle" "6d6f07af60bb307882cdcbd0bda0a6fc76bd0df3"
                    "0chm03yrzcbnwy1v4kw1kqpkjaccmqabk1666cw3ng4yz5ha8m4g"
                    #:cargo-inputs cosmic-idle-cargo-inputs
                    #:git-crates cosmic-idle-git-crates
                    #:extra-phases
                    ;; Its fallback when no Suspend action is configured;
                    ;; see cosmic-settings-daemon.
                    (list
                     #~(add-after 'unpack 'suspend-with-loginctl
                         (lambda _
                           (substitute* "src/main.rs"
                             (("\"systemctl suspend\"")
                              "\"loginctl suspend\""))))
                     ;; org.freedesktop.ScreenSaver.GetSessionIdleTime, which
                     ;; Steam polls for its Away status (KDE provides it).
                     #~(add-after 'unpack 'add-session-idle-time
                         (lambda _
                           (invoke "patch" "-p1" "--input"
                                   #$(local-file
                                      "aux-files/cosmic-idle-session-idle-time.patch")))))
                    #:synopsis "Idle daemon of the COSMIC desktop"
                    #:description
                    "cosmic-idle blanks the screen and suspends the system after
the configured idle time."))

(define-public cosmic-osd
  (cosmic-component "cosmic-osd" "4f96e98981712f02b98f704a6f19c4c6a58b378b"
                    "1yqv4a4v0p5lv6ynpwbpx0c1kd2rvq012bdfz0sxpj4dvmcbpxcw"
                    #:cargo-inputs cosmic-osd-cargo-inputs
                    #:git-crates cosmic-osd-git-crates
                    ;; Guix's polkit service installs the setuid helper here.
                    #:build-env '(("POLKIT_AGENT_HELPER_1"
                                   . "/run/setuid-programs/polkit-agent-helper-1"))
                    #:license license:gpl3+
                    #:synopsis "On-screen displays and polkit agent for COSMIC"
                    #:description
                    "cosmic-osd shows COSMIC's on-screen displays (volume,
brightness, ...) and acts as its polkit authentication agent."))

(define-public cosmic-notifications
  (cosmic-component "cosmic-notifications"
                    "382927dc48964f3b098429ad6b836cc4b7e7ecf2"
                    "0js0k0l52r957awrx117h95kacg7k9ydxy6mvyhnr8mw6rslh0x0"
                    #:cargo-inputs cosmic-notifications-cargo-inputs
                    #:git-crates cosmic-notifications-git-crates
                    #:synopsis "Notification daemon of the COSMIC desktop"
                    #:description
                    "cosmic-notifications implements the freedesktop.org
notification service for the COSMIC desktop."))

(define-public cosmic-launcher
  (cosmic-component "cosmic-launcher" "b6c2ed7d1224a94568b083162ea6b79409ef111b"
                    "1cjnki0jrb0qsa2bvynbd5wxs2bnn87sql6jzg7d082ddh0b69ql"
                    #:cargo-inputs cosmic-launcher-cargo-inputs
                    #:git-crates cosmic-launcher-git-crates
                    #:synopsis "Application launcher of the COSMIC desktop"
                    #:description
                    "cosmic-launcher is the COSMIC launcher overlay, a front end
to pop-launcher's search plugins."))

(define-public cosmic-app-library
  (cosmic-component "cosmic-app-library"
                    "3651caff79bcf36f7c16ba5ed4f41de530c7b1a7"
                    "0mfkdc2zmdlq2ssdradzdxlqing1bxf8g2kqc99v65kcflp2v6jw"
                    #:cargo-inputs cosmic-app-library-cargo-inputs
                    #:git-crates cosmic-app-library-git-crates
                    #:synopsis "Application library of the COSMIC desktop"
                    #:description
                    "cosmic-app-library is COSMIC's grid of installed
applications, with user-defined folders."))

(define-public cosmic-workspaces
  (cosmic-component "cosmic-workspaces"
                    "cb953ea0e6fb45ac8f62f9c52f1347c971388e03"
                    "1lff84w1nvw0m0x1zdfvx8018vbw056y3zqqwk6v5mbw097yw4sl"
                    #:repository "cosmic-workspaces-epoch"
                    #:version "1.0.12"
                    #:cargo-inputs cosmic-workspaces-epoch-cargo-inputs
                    #:git-crates cosmic-workspaces-epoch-git-crates
                    ;; The one component with a Makefile instead of a justfile.
                    #:extra-phases
                    (list
                     #~(replace 'build
                         (lambda _ (invoke "make")))
                     #~(replace 'install
                         (lambda _
                           (invoke "make" "install"
                                   (string-append "prefix=" #$output)))))
                    #:synopsis "Workspace overview of the COSMIC desktop"
                    #:description
                    "cosmic-workspaces shows all workspaces and their windows,
and lets you move windows between them."))

(define-public cosmic-randr
  (cosmic-component "cosmic-randr" "f1a97655c97e8799bf4a37a8f5103a8ab5e5068d"
                    "02sk9s270hypszdsq9icwvyhk2mhx9j140fp1imc3y2s9aidzvzx"
                    #:cargo-inputs cosmic-randr-cargo-inputs
                    #:git-crates cosmic-randr-git-crates
                    #:license license:mpl2.0
                    #:synopsis "Display configuration tool for COSMIC"
                    #:description
                    "cosmic-randr lists and configures outputs (resolution,
refresh rate, position, scale) of the COSMIC compositor."))

(define-public cosmic-screenshot
  (cosmic-component "cosmic-screenshot" "45549f7e940d495ecee9268f58824668814e970c"
                    "084j0sl4abfnz7bd2fsdkav48xd32b19wy42gnn8qqsdxa7r5cid"
                    #:cargo-inputs cosmic-screenshot-cargo-inputs
                    #:git-crates cosmic-screenshot-git-crates
                    #:synopsis "Screenshot tool of the COSMIC desktop"
                    #:description
                    "cosmic-screenshot takes screenshots through the desktop
portal."))

(define-public cosmic-osk
  (cosmic-component "cosmic-osk" "6b146a2b0a23d88ae84223ad06c6813bda5a9386"
                    "0dv3d5d3a3kqc6v01ihcq0d3ccgxmciis4rz1bkcrr1b30rh23xg"
                    #:cargo-inputs cosmic-osk-cargo-inputs
                    #:git-crates cosmic-osk-git-crates
                    #:synopsis "On-screen keyboard of the COSMIC desktop"
                    #:description
                    "cosmic-osk is COSMIC's on-screen keyboard."))

(define-public cosmic-settings
  (cosmic-component "cosmic-settings" "f1d00fc06e18203e880771617657067c10c43321"
                    "0jxvzn66jxkk0dk876h9b3kc7xchr1x84kqa2l7ragavlhmjlxgr"
                    #:cargo-inputs cosmic-settings-cargo-inputs
                    #:git-crates cosmic-settings-git-crates
                    #:extra-inputs (list dav1d)
                    #:extra-phases
                    ;; The v2 default themes lack `list_button', which v1 has
                    ;; and libcosmic reads: every program without a theme of
                    ;; its own -- the greeter's compositor at boot -- logged
                    ;; "error loading system dark theme".  The files are v1's
                    ;; values in v2's notation, as COSMIC Settings writes them.
                    (list
                     #~(add-after 'unpack 'add-v2-theme-list-button
                         (lambda _
                           (for-each
                            (lambda (variant)
                              (copy-file
                               (string-append
                                #$(local-file "aux-files/cosmic-theme-v2"
                                              #:recursive? #t)
                                "/" variant "-list_button")
                               (string-append
                                "resources/default_schema/com.system76.CosmicTheme."
                                variant "/v2/list_button")))
                            '("Dark" "Light")))))
                    #:synopsis "Settings application of the COSMIC desktop"
                    #:description
                    "cosmic-settings configures the COSMIC desktop: appearance,
panel and dock, displays, input, sound, networking, users, and more."))

(define-public cosmic-initial-setup
  (cosmic-component "cosmic-initial-setup"
                    "653a4db1841e70ef8e36d3c6f0a14b7fce335697"
                    "1a2bi8scl1gapzlqsb5nilyi94zya0m3krn2gidpl2wcirhjz84f"
                    ;; Theme previews (built-in and extra) are in Git LFS.
                    #:lfs? #t
                    #:cargo-inputs cosmic-initial-setup-cargo-inputs
                    #:git-crates cosmic-initial-setup-git-crates
                    #:extra-native-inputs (list cmake-minimal)
                    ;; Its autostart entry goes under ROOTDIR/etc.
                    #:just-vars #~(list "rootdir" #$output "prefix" "")
                    #:extra-phases
                    (list
                     #~(add-after 'unpack 'adapt-to-guix-system
                         (lambda _
                           ;; The language page sets the locale through
                           ;; systemd-localed and the location page the time
                           ;; zone through timedatectl; Guix has neither, and
                           ;; both are declared in the operating-system
                           ;; instead.  Drop the pages, as the `nixos' feature
                           ;; does (its other changes are NixOS paths).
                           (substitute* "src/page/mod.rs"
                             (("#\\[cfg\\(not\\(feature = \"nixos\"\\)\\)\\]")
                              "#[cfg(any())]"))
                           ;; Extra themes and panel layouts are installed
                           ;; with the program, not under /usr/share.
                           (substitute* "src/page/appearance.rs"
                             (("/usr/share/cosmic-themes/")
                              (string-append #$output "/share/cosmic-themes/")))
                           (substitute* "src/page/layout.rs"
                             (("/usr/share/cosmic-layouts/")
                              (string-append #$output
                                             "/share/cosmic-layouts/"))))))
                    #:synopsis "First-run setup assistant of COSMIC"
                    #:description
                    "cosmic-initial-setup walks a new user through
accessibility, keyboard, appearance and panel layout choices on the first
COSMIC login.  On Guix System the language and time zone pages are left out:
both are set in the operating-system declaration."))

(define-public xdg-desktop-portal-cosmic
  (cosmic-component "xdg-desktop-portal-cosmic"
                    "f448ddfb296bf7bb23517b24b2f532559a334a1c"
                    "1ww3pvax94y0rf5bka1194k5x9a1i89ss4s9y0h0mvq9nm8xynji"
                    #:cargo-inputs xdg-desktop-portal-cosmic-cargo-inputs
                    #:git-crates xdg-desktop-portal-cosmic-git-crates
                    #:extra-inputs (list gstreamer pipewire)
                    #:extra-native-inputs (list clang)
                    #:build-recipe "build"
                    #:extra-phases
                    (list (use-store-backgrounds '("src/screenshot.rs"
                                                   "src/widget/screenshot.rs")))
                    #:license license:gpl3+
                    #:synopsis "XDG desktop portal back end for COSMIC"
                    #:description
                    "xdg-desktop-portal-cosmic implements the freedesktop.org
desktop portals for COSMIC: screenshots and screen casting (through PipeWire),
file chooser, access requests and settings, used by sandboxed applications and
by browsers for screen sharing."))


;;;
;;; Applications.
;;;

(define-public cosmic-files
  (cosmic-component "cosmic-files" "3cc4b8003e8d08349c7ced8a9cdd10cdfa45d38c"
                    "109sh2nnzrfpxcw3x48nnhl6vj7xsdyrddrpv1r9ra8fb5l8xy4h"
                    #:cargo-inputs cosmic-files-cargo-inputs
                    #:git-crates cosmic-files-git-crates
                    #:synopsis "File manager of the COSMIC desktop"
                    #:description
                    "COSMIC Files is a file manager with tabs, split views,
search, network and trash locations, and desktop-icon support."))

(define-public cosmic-edit
  (cosmic-component "cosmic-edit" "4ac1cc84f784d4f89327f3d3459af2633ceb4f12"
                    "0j95s73647p8wlrqixxpgba1h9cr43954svl0iplnz1zzn6bbnfg"
                    #:cargo-inputs cosmic-edit-cargo-inputs
                    #:git-crates cosmic-edit-git-crates
                    ;; Guix's cargo-build-system sets RUSTONIG_SYSTEM_LIBONIG,
                    ;; so onig_sys (syntax highlighting) links the system copy.
                    #:extra-inputs (list oniguruma)
                    #:synopsis "Text editor of the COSMIC desktop"
                    #:description
                    "COSMIC Text Editor is a tabbed text editor with syntax
highlighting, project folders, search and replace, and Git status."))

(define-public cosmic-term
  (cosmic-component "cosmic-term" "699ac42384b917029082d45a01a9261a4ba75c45"
                    "1qm3lan6aw23cj80znphkhls0imp8ckyzvl308g39a31hzzdnlzw"
                    #:cargo-inputs cosmic-term-cargo-inputs
                    #:git-crates cosmic-term-git-crates
                    #:synopsis "Terminal emulator of the COSMIC desktop"
                    #:description
                    "COSMIC Terminal is a GPU-rendered terminal emulator based on
alacritty_terminal, with tabs, split panes and themes."))

(define-public cosmic-store
  (cosmic-component "cosmic-store" "16b1667e43c634318a99995c8eb77c23603ae560"
                    "1p3hnk6bq16a33awfh5fc9d9k0p04cazy6qy4zxrvnv9ycx8qb3w"
                    #:cargo-inputs cosmic-store-cargo-inputs
                    #:git-crates cosmic-store-git-crates
                    #:extra-inputs (list flatpak)
                    #:extra-native-inputs (list cmake-minimal)
                    #:synopsis "Application store of the COSMIC desktop"
                    #:description
                    "COSMIC Store browses and installs applications from Flatpak
remotes."))

(define-public cosmic-player
  (cosmic-component
   "cosmic-player" "34a41f247a37eb681dd5c27c832e2d1f3c1dc1e4"
   "07jvqslkn6rcqcsn7bccl8w22yjpp2zzr1kr9yjakv38snyz34qi"
   #:cargo-inputs cosmic-player-cargo-inputs
   ;; No .git in the checkout for vergen to read.
   #:build-env '(("VERGEN_GIT_SHA" . "34a41f247a37eb681dd5c27c832e2d1f3c1dc1e4"))
   #:git-crates cosmic-player-git-crates
   #:extra-inputs (list bash-minimal gstreamer gst-plugins-base gst-plugins-good
                        gst-plugins-bad gst-libav)
   #:extra-phases
   (list
    #~(add-after 'add-dlopen-runpath 'wrap-gstreamer
        (lambda _
          (wrap-program (string-append #$output "/bin/cosmic-player")
            `("GST_PLUGIN_SYSTEM_PATH" suffix
              (,(getenv "GST_PLUGIN_SYSTEM_PATH")))))))
   #:synopsis "Media player of the COSMIC desktop"
   #:description
   "COSMIC Media Player plays audio and video files through GStreamer."))

(define-public cosmic-viewer
  (cosmic-component "cosmic-viewer" "300210f1c7d86ba14a43602e40dd5fe1deb16703"
                    "1sj8h9gjvc1vhsgw9isq89wrbxjh39wdbn7q9xfv0v0i7x0wc7qx"
                    #:cargo-inputs cosmic-viewer-cargo-inputs
                    #:git-crates cosmic-viewer-git-crates
                    #:extra-inputs (list libheif libjpeg-turbo-3) ;turbojpeg-sys wants >= 3.0
                    ;; Both -sys crates default to compiling bundled copies
                    ;; with CMake (libheif with a dozen codecs); link
                    ;; Guix's libheif and libjpeg-turbo through pkg-config.
                    #:build-env '(("TURBOJPEG_SOURCE" . "pkg-config"))
                    #:extra-phases
                    (list
                     #~(add-after 'unpack 'use-system-libheif
                         (lambda _
                           (substitute* "Cargo.toml"
                             (("\"embedded-libheif\",") "")))))
                    #:synopsis "Image viewer of the COSMIC desktop"
                    #:description
                    "COSMIC Image Viewer displays images, including HEIF and
camera formats, with a gallery of the surrounding folder."))

(define-public cosmic-monitor
  (cosmic-component "cosmic-monitor" "d79ff440dfa899ea6e9a3019dcfd9f9e8a44448d"
                    "153n3hh98ravbb535x9kmwvmxf5dzfp5f1qwwpbgz9qknxznbwy2"
                    #:cargo-inputs cosmic-monitor-cargo-inputs
                    #:git-crates cosmic-monitor-git-crates
                    #:synopsis "System monitor of the COSMIC desktop"
                    #:description
                    "COSMIC System Monitor shows processes and CPU, memory,
disk, network and GPU usage."))

(define-public cosmic-greeter
  (cosmic-component "cosmic-greeter" "80e8a104b75a01ab8df52bca7b8bde6dbcdb8133"
                    "167cyaa52n2w16mjdqvab5f4clnf71rw7ga9fdsdqbkgg0zn18fb"
                    ;; Its built-in login background is in Git LFS.
                    #:lfs? #t
                    #:cargo-inputs cosmic-greeter-cargo-inputs
                    ;; build.rs only skips git (absent in Guix checkouts)
                    ;; when both of these are set.
                    #:build-env '(("VERGEN_GIT_SHA"
                                   . "80e8a104b75a01ab8df52bca7b8bde6dbcdb8133")
                                  ("VERGEN_GIT_COMMIT_DATE" . "2026-10-20"))
                    #:git-crates cosmic-greeter-git-crates
                    #:extra-inputs (list bash-minimal coreutils dav1d linux-pam)
                    #:extra-native-inputs (list clang)
                    ;; "install" adds systemd sysusers/tmpfiles snippets.
                    #:install-recipes '("install-debian")
                    #:extra-phases
                    (list
                     #~(add-after 'unpack 'patch-session-commands
                         (lambda* (#:key inputs #:allow-other-keys)
                           ;; Sessions are started through /usr/bin/env (to
                           ;; set XDG_SESSION_TYPE and friends), and the
                           ;; screen reader from /usr/bin.
                           (substitute* "src/greeter.rs"
                             (("\"/usr/bin/env\"")
                              (format #f "~s" (search-input-file inputs
                                                                 "bin/env")))
                             (("\"/usr/bin/orca\"") "\"orca\""))))
                     #~(add-after 'install 'adapt-to-guix-system
                         (lambda* (#:key inputs #:allow-other-keys)
                           ;; greetd runs this as the cosmic-greeter user.
                           ;; It sources /etc/profile first (source_profile),
                           ;; but don't count on it for what the greeter
                           ;; needs: the session files and programs of the
                           ;; system profile, a cursor theme, and a runtime
                           ;; directory (elogind normally provides one).
                           ;; Unlike upstream's, keep the compositor's
                           ;; output: it ends up in greetd's log.
                           (call-with-output-file
                               (string-append #$output "/bin/cosmic-greeter-start")
                             (lambda (port)
                               (format port "#!~a
export PATH=\"${PATH:+$PATH:}/run/current-system/profile/bin\"
export XDG_DATA_DIRS=\"${XDG_DATA_DIRS:-/run/current-system/profile/share}\"
export XCURSOR_PATH=\"${XCURSOR_PATH:-/run/current-system/profile/share/icons}\"
export XCURSOR_THEME=\"${XCURSOR_THEME:-Pop}\"
if [ -z \"$XDG_RUNTIME_DIR\" ] || [ ! -w \"$XDG_RUNTIME_DIR\" ]; then
    export XDG_RUNTIME_DIR=/run/cosmic-greeter/runtime
    ~a -p -m 0700 \"$XDG_RUNTIME_DIR\"
fi
~a -rf /run/cosmic-greeter/cosmic/com.system76.CosmicSettingsDaemon/v1/*
exec cosmic-comp ~a/bin/cosmic-greeter~%"
                                       (search-input-file inputs "bin/sh")
                                       (search-input-file inputs "bin/mkdir")
                                       (search-input-file inputs "bin/rm")
                                       #$output)))
                           (chmod (string-append #$output
                                                 "/bin/cosmic-greeter-start")
                                  #o555)
                           ;; Let D-Bus start the daemon (it runs as root
                           ;; and serves user names, avatars and
                           ;; backgrounds to the greeter) on first use; the
                           ;; bus policy is installed by install-debian.
                           (let ((dir (string-append
                                       #$output "/share/dbus-1/system-services")))
                             (mkdir-p dir)
                             (call-with-output-file
                                 (string-append
                                  dir "/com.system76.CosmicGreeter.service")
                               (lambda (port)
                                 (format port "[D-BUS Service]
Name=com.system76.CosmicGreeter
Exec=~a/bin/cosmic-greeter-daemon
User=root~%"
                                         #$output)))))))
                    #:synopsis "Login greeter and screen locker of the COSMIC desktop"
                    #:description
                    "cosmic-greeter is COSMIC's login screen, a greeter for the
greetd display manager, started by @command{cosmic-greeter-start} as the
@code{cosmic-greeter} user.  It offers the sessions of the system profile's
@file{share/wayland-sessions} and @file{share/xsessions} (the latter through
@command{startx}), and talks to @command{cosmic-greeter-daemon}, which D-Bus
starts on the system bus.  Run inside a user session, the same program is the
COSMIC screen locker, which cosmic-session starts.  It authenticates through
the @code{cosmic-greeter} PAM service, which must exist on the system (on Guix
System, for instance @code{(unix-pam-service \"cosmic-greeter\")}): without
it, PAM denies every unlock attempt.  This is why it is not part of the
@code{cosmic} meta package."))


;;;
;;; Launcher back end and data.
;;;

(define-public pop-launcher
  (cosmic-component
   "pop-launcher" "86c2639ba82f4d846c801abe84fcea8ae8e7d716"
   "02grp90fa75zrzmmikmknlmyjvr6bnhs5xqdgfz45p02z5l3ys1b"
   #:repository "launcher"
   #:version "1.2.7"
   #:cargo-inputs pop-launcher-cargo-inputs
   #:git-crates pop-launcher-git-crates
   #:license license:mpl2.0
   ;; Its justfile installs below ROOTDIR/usr.
   #:just-vars #~(list "rootdir" #$output)
   #:extra-phases
   (list
    #~(add-after 'unpack 'use-store-plugin-directory
        (lambda _
          (substitute* '("src/lib.rs" "plugins/src/scripts/mod.rs")
            (("/usr/lib/pop-launcher")
             (string-append #$output "/lib/pop-launcher")))))
    #~(add-after 'install 'move-out-of-usr
        (lambda _
          (with-directory-excursion #$output
            (for-each (lambda (dir)
                        (when (file-exists? (string-append "usr/" dir))
                          (rename-file (string-append "usr/" dir) dir)))
                      '("bin" "lib" "share"))
            (delete-file-recursively "usr")))))
   #:synopsis "Modular search and launch service"
   #:description
   "pop-launcher is the search back end of the COSMIC launcher: a service
that queries plugins (applications, files, calculator, web search, windows,
scripts, ...) over a JSON protocol on standard input and output."))

(define-public cosmic-icons
  (package
    (name "cosmic-icons")
    (version (git-version %cosmic-version "0"
                          "f1a282a0822aed1f0083dd2ab2e6c65bd5b401eb"))
    (source (cosmic-source "cosmic-icons"
                           "f1a282a0822aed1f0083dd2ab2e6c65bd5b401eb"
                           "1nc3bnxkxg3zb9s4zk8bcnnbg6sya4xfr2v3npks8ab35snc7bc0"))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'install
            (lambda _
              (invoke "just" "--set" "prefix" #$output "--set" "rootdir" ""
                      "install"))))))
    (native-inputs (list just))
    (propagated-inputs (list hicolor-icon-theme))
    (home-page "https://github.com/pop-os/cosmic-icons")
    (synopsis "Icon theme of the COSMIC desktop")
    (description "The Cosmic icon theme, COSMIC's default icons.")
    (license license:cc-by-sa4.0)))

(define-public pop-icon-theme
  (package
    (name "pop-icon-theme")
    (version "3.5.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/pop-os/icon-theme")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0fqh6w2dnzn8ncaas2x6w3znsfa2r4g4gnzj719jdm924gxazm86"))))
    (build-system meson-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'skip-icon-cache
            ;; The post-install script runs gtk-update-icon-cache; Guix
            ;; builds the icon caches of profiles itself.
            (lambda _
              (substitute* "meson.build"
                (("^meson\\.add_install_script.*") "")))))))
    (propagated-inputs (list hicolor-icon-theme))
    (home-page "https://github.com/pop-os/icon-theme")
    (synopsis "Icon and cursor theme of Pop!_OS and COSMIC")
    (description
     "The Pop icon theme, based on Paper, and the Pop cursor theme.  COSMIC's
own icon theme falls back to it, and its cursors are COSMIC's default pointer
theme.")
    (license license:cc-by-sa4.0)))

(define-public cosmic-sound-theme
  (package
    (name "cosmic-sound-theme")
    (version (git-version %cosmic-version "0"
                          "bf5335fe1af0cb3bee83e1ad2371410ee434658d"))
    (source (cosmic-source "cosmic-sound-theme"
                           "bf5335fe1af0cb3bee83e1ad2371410ee434658d"
                           "1f057ifmdbdjmaw6yd8dbbiqybx2qn644pz7z3szgb36f4d7wl2d"))
    (build-system meson-build-system)
    (home-page "https://github.com/pop-os/cosmic-sound-theme")
    (synopsis "Sound theme of the COSMIC desktop")
    (description "The freedesktop.org sound theme used by COSMIC.")
    (license license:cc-by-sa4.0)))


;;;
;;; Meta package.
;;;

(define-public cosmic
  (package
    (name "cosmic")
    (version %cosmic-version)
    (source #f)
    (build-system (@ (guix build-system trivial) trivial-build-system))
    (arguments
     (list #:builder #~(mkdir #$output)))
    (propagated-inputs
     (list cosmic-comp cosmic-session cosmic-settings-daemon cosmic-panel
           cosmic-applets cosmic-bg cosmic-idle cosmic-osd cosmic-notifications
           cosmic-launcher pop-launcher cosmic-app-library cosmic-workspaces
           cosmic-randr cosmic-screenshot cosmic-osk cosmic-settings
           cosmic-initial-setup cosmic-icons pop-icon-theme cosmic-sound-theme
           cosmic-wallpapers
           cosmic-files cosmic-edit cosmic-term cosmic-store cosmic-player
           cosmic-viewer cosmic-monitor
           ;; Keeps Steam from going Away while Wayland programs are used.
           xwayland-activity-relay
           xdg-desktop-portal xdg-desktop-portal-cosmic
           ;; cosmic-portals.conf falls back to GTK's portal.
           xdg-desktop-portal-gtk
           ;; COSMIC's default interface and monospace fonts: Open Sans and
           ;; Noto Sans Mono (which Guix ships only in font-google-noto).
           font-open-sans font-google-noto
           ;; GIO back ends: network shares, phones (MTP), cameras and
           ;; other mounts in COSMIC Files.
           gvfs))
    (home-page "https://system76.com/cosmic")
    (synopsis "COSMIC desktop environment")
    (description
     "COSMIC is a Wayland desktop environment written in Rust by System76.
This meta package pulls in the compositor, session, panel and applets,
settings, launcher, notifications and the standard COSMIC applications.  Add
it to your system's packages and choose the \"COSMIC\" session in your display
manager.")
    (license license:gpl3)))
