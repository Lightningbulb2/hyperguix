;;; Lightningbulb channel --- the COSMIC desktop environment (System76)
;;;
;;; One package per component, pinned to the commits the cosmic-epoch
;;; meta-repository points at.  Every component is a Rust workspace built
;;; with its own justfile (just build-release / just install), against the
;;; crates in cosmic-crates.scm; crates COSMIC takes from git (libcosmic and
;;; its iced fork, smithay, cosmic-protocols, ...) are vendored by the helper
;;; in cargo-git.scm.
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
  #:use-module (gnu packages bash)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
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
  #:use-module (Lightningbulb packages cosmic-crates))

(define %cosmic-version "1.10.0")

(define (cosmic-source name commit hash)
  (origin
    (method git-fetch)
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
    (source (cosmic-source repository commit hash))
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
  (cosmic-component "cosmic-comp" "41497b42d9744d9963c4c6d17e8add49489b45ee"
                    "15p0kjrp2ib7cbhkm4niah6j8m1pkfc3kllf5wlk6p2mbgzhyj0y"
                    #:version "1.0.0"
                    #:cargo-inputs cosmic-comp-cargo-inputs
                    #:build-env '(("GIT_HASH"
                                   . "41497b42d9744d9963c4c6d17e8add49489b45ee"))
                    #:git-crates cosmic-comp-git-crates
                    #:extra-inputs (list libdisplay-info
                                         libseat ;Guix's seatd drops lib/ and include/
                                         xorg-server-xwayland
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
                                                           "bin/Xwayland"))))))))
                    #:synopsis "Wayland compositor of the COSMIC desktop"
                    #:description
                    "cosmic-comp is the Smithay-based Wayland compositor at the
heart of the COSMIC desktop: window management with optional auto-tiling,
workspaces, multi-monitor and multi-GPU support, and XWayland."))

(define-public cosmic-session
  (cosmic-component
   "cosmic-session" "8093b59bb1262b0612d814e6540ba936303f735a"
   "0byq559kir0dp2kshanf1nk8m66hn14hsp6nhrk4cxc1x0v0p6il"
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
    #~(add-after 'install 'fix-session-paths
        (lambda* (#:key inputs #:allow-other-keys)
          (let ((dbus-run-session (search-input-file inputs "bin/dbus-run-session")))
            (substitute* (string-append #$output "/bin/start-cosmic")
              (("^#!/bin/sh")
               (string-append "#!" (search-input-file inputs "bin/sh")))
              (("/usr/bin/dbus-run-session") dbus-run-session)
              (("/usr/bin/cosmic-session")
               (string-append #$output "/bin/cosmic-session")))
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
                    "9e4ae69fc175191f15789d35423806ea0f093c9d"
                    "0dgczy5yxqfgy783y42dh18y6fnwy0cj5j7cpgn7hrzbsij6k63q"
                    #:cargo-inputs cosmic-settings-daemon-cargo-inputs
                    #:git-crates cosmic-settings-daemon-git-crates
                    #:extra-inputs (list pipewire)
                    #:extra-native-inputs (list clang)
                    #:license license:gpl3+
                    #:synopsis "Settings daemon of the COSMIC desktop"
                    #:description
                    "cosmic-settings-daemon applies COSMIC settings at run time:
themes and appearance, brightness and volume keys, input devices, and other
system integration."))

(define-public cosmic-panel
  (cosmic-component "cosmic-panel" "3ce6ce1cec97669f91e809962d9446aaefe8a06e"
                    "16cvzwysb84p280gb4jd0lkjzpdjd7mx5sxxagpc6r86c2l9k1ay"
                    #:cargo-inputs cosmic-panel-cargo-inputs
                    #:git-crates cosmic-panel-git-crates
                    #:synopsis "Panel and dock of the COSMIC desktop"
                    #:description
                    "cosmic-panel draws the COSMIC top panel and dock and hosts
the applets shown in them."))

(define-public cosmic-applets
  (cosmic-component "cosmic-applets" "406d1b7d627138fdf4078f654268d3d8774e50f1"
                    "13pfbppzsg2fxf6jqz11zv203in6wm11lmm0m9lq56vk4zjh27pg"
                    #:cargo-inputs cosmic-applets-cargo-inputs
                    #:git-crates cosmic-applets-git-crates
                    #:synopsis "Panel applets of the COSMIC desktop"
                    #:description
                    "The standard COSMIC panel applets: app list, audio,
battery, Bluetooth, network, notifications, power, status area (tray),
tiling, time, workspaces, input sources and accessibility."))

(define-public cosmic-bg
  (cosmic-component "cosmic-bg" "91d525b7310f5a497c9fd09a25d2710eb9f8a6f7"
                    "03qf54xfpnhrcin9s962a6a8k6pac3g7xip7d7q5a7xr0d504xlx"
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
  (cosmic-component "cosmic-idle" "21e983c63e75640ab0055495e768a5c616742c19"
                    "1ix8a55rph6cihj1q4yiib23qlmjwp8fbacf4ax9cd75g19k2j7r"
                    #:cargo-inputs cosmic-idle-cargo-inputs
                    #:git-crates cosmic-idle-git-crates
                    #:synopsis "Idle daemon of the COSMIC desktop"
                    #:description
                    "cosmic-idle blanks the screen and suspends the system after
the configured idle time."))

(define-public cosmic-osd
  (cosmic-component "cosmic-osd" "9b14ee017fb8fdb7d03d73da597cf17b89d890f7"
                    "1fk05h00wbrkz3zk6pyl5y4wvxqlzn9m8r6bnyi4z5bky8yp7gks"
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
                    "1e4c1f11fdcae273d6954fd0bfc54749a6145267"
                    "0py0ij70lxzb5nxwsazng5hjj8xisvywpfkl4z9xymna0vzzhn2c"
                    #:cargo-inputs cosmic-notifications-cargo-inputs
                    #:git-crates cosmic-notifications-git-crates
                    #:synopsis "Notification daemon of the COSMIC desktop"
                    #:description
                    "cosmic-notifications implements the freedesktop.org
notification service for the COSMIC desktop."))

(define-public cosmic-launcher
  (cosmic-component "cosmic-launcher" "03195ddb097c6ad83c4072917d60d900b8bd944f"
                    "0ap3jhl8xiqlmmigd908szlhk6yny21n2ccjfq8c545s58928l22"
                    #:cargo-inputs cosmic-launcher-cargo-inputs
                    #:git-crates cosmic-launcher-git-crates
                    #:synopsis "Application launcher of the COSMIC desktop"
                    #:description
                    "cosmic-launcher is the COSMIC launcher overlay, a front end
to pop-launcher's search plugins."))

(define-public cosmic-app-library
  (cosmic-component "cosmic-app-library"
                    "1107375789e3f60e120b6dc5b81379771ecaa811"
                    "1lhqb4ci4lhybd35r4y5db1cflzmvpaxc43xv02pr7jgnksxz38r"
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
  (cosmic-component "cosmic-randr" "85efc7febb99876094cf90af6dbce0927ad8cca7"
                    "117fnwghcpavsi0pnx8qaf9z1q1g9a5qmwp8ydav33dvm86af0hy"
                    #:cargo-inputs cosmic-randr-cargo-inputs
                    #:git-crates cosmic-randr-git-crates
                    #:license license:mpl2.0
                    #:synopsis "Display configuration tool for COSMIC"
                    #:description
                    "cosmic-randr lists and configures outputs (resolution,
refresh rate, position, scale) of the COSMIC compositor."))

(define-public cosmic-screenshot
  (cosmic-component "cosmic-screenshot" "07e27587eb387ecf38cb4692ccbf25ad20760d22"
                    "1dmcm0gdgq0kjavvfrasg9fakwxxig3mwzvcz9qf8fs2g6z8slfv"
                    #:cargo-inputs cosmic-screenshot-cargo-inputs
                    #:git-crates cosmic-screenshot-git-crates
                    #:synopsis "Screenshot tool of the COSMIC desktop"
                    #:description
                    "cosmic-screenshot takes screenshots through the desktop
portal."))

(define-public cosmic-osk
  (cosmic-component "cosmic-osk" "1b7ec698b79d248d6a59ff426f453fc7ce3edc91"
                    "09cbwzzzxvajjhr2k023mam9nbr05ncc2cmz69b2fyd4c2w5s4h9"
                    #:cargo-inputs cosmic-osk-cargo-inputs
                    #:git-crates cosmic-osk-git-crates
                    #:synopsis "On-screen keyboard of the COSMIC desktop"
                    #:description
                    "cosmic-osk is COSMIC's on-screen keyboard."))

(define-public cosmic-settings
  (cosmic-component "cosmic-settings" "58aeb65244b8830880e8b6ced89dcd25663f20b1"
                    "07xivp1am8sbfk40sgy84sx59r0rc6125fz1brzfcfcr79dkffv6"
                    #:cargo-inputs cosmic-settings-cargo-inputs
                    #:git-crates cosmic-settings-git-crates
                    #:extra-inputs (list dav1d)
                    #:synopsis "Settings application of the COSMIC desktop"
                    #:description
                    "cosmic-settings configures the COSMIC desktop: appearance,
panel and dock, displays, input, sound, networking, users, and more."))

(define-public cosmic-initial-setup
  (cosmic-component "cosmic-initial-setup"
                    "8b025bc9eec4844d8c01fb238e5298b3db920b3f"
                    "0y4040jk3hpm9qk4cjy9kny8g1z50bsi02d8fi9x881ygz12m0mk"
                    #:cargo-inputs cosmic-initial-setup-cargo-inputs
                    #:git-crates cosmic-initial-setup-git-crates
                    #:extra-native-inputs (list cmake-minimal)
                    ;; Its autostart entry goes under ROOTDIR/etc.
                    #:just-vars #~(list "rootdir" #$output "prefix" "")
                    #:synopsis "First-run setup assistant of COSMIC"
                    #:description
                    "cosmic-initial-setup walks a new user through language,
appearance and layout choices on the first COSMIC login."))

(define-public xdg-desktop-portal-cosmic
  (cosmic-component "xdg-desktop-portal-cosmic"
                    "9d35e6300b69cf06da723a502a9a56604a022786"
                    "1zjmh0jn2bsmrz6rr83w5r9a677acc10zymd4zzc23klyg5r5rhs"
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
  (cosmic-component "cosmic-files" "ac5cef76fa60b5a329bfda3d30825489ec28af53"
                    "1aq9wwnsp10ddia58wwf8hl017j9xz9sv0lia5p9p1zkkcd4lzym"
                    #:cargo-inputs cosmic-files-cargo-inputs
                    #:git-crates cosmic-files-git-crates
                    #:synopsis "File manager of the COSMIC desktop"
                    #:description
                    "COSMIC Files is a file manager with tabs, split views,
search, network and trash locations, and desktop-icon support."))

(define-public cosmic-edit
  (cosmic-component "cosmic-edit" "5ddf5115995e02fd71851a42bf0e6a9c9b5a1ce5"
                    "1qsyrxfg5cl40hkb004807z8ywsh62k6la7152v4jv6p403ln7pg"
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
  (cosmic-component "cosmic-term" "3bfca1eb804de2f069e62d0709982beca908cb01"
                    "0jyfdp4hykhhcfx8csbrwxizmfnpxmwl97n9sf43ksfdw14j7v9k"
                    #:cargo-inputs cosmic-term-cargo-inputs
                    #:git-crates cosmic-term-git-crates
                    #:synopsis "Terminal emulator of the COSMIC desktop"
                    #:description
                    "COSMIC Terminal is a GPU-rendered terminal emulator based on
alacritty_terminal, with tabs, split panes and themes."))

(define-public cosmic-store
  (cosmic-component "cosmic-store" "c7b36a2fdccf1ce88944793af67c3664413ee560"
                    "147nrasvmbjlwc5swhjnr0ygafx3vz2scr83y6pcdh0wf6w3llxk"
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
   "cosmic-player" "900453787f999ec151b8d58683923e3110b727e1"
   "0fjcpca0v72i7hhj2xvvacbax7p0n2v06rzrr6j5lspqd1cvkp3v"
   #:cargo-inputs cosmic-player-cargo-inputs
   ;; No .git in the checkout for vergen to read.
   #:build-env '(("VERGEN_GIT_SHA" . "900453787f999ec151b8d58683923e3110b727e1"))
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
  (cosmic-component "cosmic-viewer" "77ba62deb7027217efab1999e90670f3c89c5a02"
                    "08rzvxxj0009k370c80vpqry4hilcr8v8hc3pg8scgqa9xa41kck"
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
  (cosmic-component "cosmic-monitor" "a79ce9e7d2259a82150d56978fb7a094bd4ec2f0"
                    "0wlyg6qnkzqjfliwv85c6p5p58ip2k2kwzsjijjzzmhk7c9afgdw"
                    #:cargo-inputs cosmic-monitor-cargo-inputs
                    #:git-crates cosmic-monitor-git-crates
                    #:synopsis "System monitor of the COSMIC desktop"
                    #:description
                    "COSMIC System Monitor shows processes and CPU, memory,
disk, network and GPU usage."))

(define-public cosmic-greeter
  (cosmic-component "cosmic-greeter" "98df07df93df1cb091c95451f7162dca1a2ae2dd"
                    "17sdkfjfg1dzrdgwazarm65w0aq2v7w546800ih8yvr2ilwq57c9"
                    #:cargo-inputs cosmic-greeter-cargo-inputs
                    ;; build.rs only skips git (absent in Guix checkouts)
                    ;; when both of these are set.
                    #:build-env '(("VERGEN_GIT_SHA"
                                   . "98df07df93df1cb091c95451f7162dca1a2ae2dd")
                                  ("VERGEN_GIT_COMMIT_DATE" . "2026-10-07"))
                    #:git-crates cosmic-greeter-git-crates
                    #:extra-inputs (list dav1d linux-pam)
                    #:extra-native-inputs (list clang)
                    ;; "install" adds systemd sysusers/tmpfiles snippets.
                    #:install-recipes '("install-debian")
                    #:synopsis "Login greeter and screen locker of the COSMIC desktop"
                    #:description
                    "cosmic-greeter is COSMIC's login screen, a greeter for the
greetd display manager.  Run inside a user session, the same program is the
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
   "pop-launcher" "8a09fa50a9fbbe66a97afe3865b5e61dd1d0432c"
   "1diwh41wiakwzgxd7wnm0pnldivq469jd9b7vsh0iq3ry2fv4fyf"
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
           cosmic-initial-setup cosmic-icons cosmic-sound-theme
           cosmic-wallpapers
           cosmic-files cosmic-edit cosmic-term cosmic-store cosmic-player
           cosmic-viewer cosmic-monitor
           xdg-desktop-portal xdg-desktop-portal-cosmic
           ;; cosmic-portals.conf falls back to GTK's portal.
           xdg-desktop-portal-gtk))
    (home-page "https://system76.com/cosmic")
    (synopsis "COSMIC desktop environment")
    (description
     "COSMIC is a Wayland desktop environment written in Rust by System76.
This meta package pulls in the compositor, session, panel and applets,
settings, launcher, notifications and the standard COSMIC applications.  Add
it to your system's packages and choose the \"COSMIC\" session in your display
manager.")
    (license license:gpl3)))
