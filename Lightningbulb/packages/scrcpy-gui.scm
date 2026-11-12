;;; Lightningbulb channel --- ScrcpyGUI (Tauri 2 + React front end for scrcpy)
;;;
;;; Built entirely from source:
;;;   * the React/Vite front end with `npm ci' against an offline mirror of
;;;     the exact tarballs in package-lock.json (see js-offline.scm);
;;;   * the Rust/Tauri shell with cargo against the crates in Cargo.lock
;;;     (see rust-crates.scm), with `tauri/custom-protocol' so the front end
;;;     is embedded in the binary instead of loaded from a dev server.
;;;
;;; The upstream app can also download its own scrcpy into a "scrcpy-bin"
;;; folder next to the executable; on Guix that folder is read-only, so it
;;; falls back to the scrcpy and adb put on its PATH by the wrapper.

(define-module (Lightningbulb packages scrcpy-gui)
  #:use-module (Lightningbulb packages cargo-git)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages android)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages node)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (Lightningbulb packages js-offline)
  #:use-module (Lightningbulb packages node-deps)
  #:use-module (Lightningbulb packages rust-crates)
  #:use-module (Lightningbulb packages scrcpy))

(define-public scrcpy-gui
  (let ((commit "7fbeee9224288739f2cdb01bad8f5cf852c257a1")
        (revision "0"))
    (package
      (name "scrcpy-gui")
      (version (git-version "4.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/kil0bit-kb/scrcpy-gui")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0rzvi8qnbbpams3sgjq0j2l92m6r6l7h71h3l71hj5nzrjzflzd0"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:install-source? #f
        #:tests? #f                     ;the UI tests need a display
        #:imported-modules `(,@%cargo-build-system-modules
                             ,@%glib-or-gtk-build-system-modules)
        #:modules '((guix build cargo-build-system)
                    ((guix build glib-or-gtk-build-system) #:prefix gtk:)
                    (guix build utils))
        #:phases
        #~(modify-phases %standard-phases
            #$@(fast-cargo-release-phases)
            (add-after 'unpack 'build-frontend
              (lambda _
                (setenv "HOME" (string-append (getcwd) "/.home"))
                (setenv "npm_config_cache" (string-append (getcwd) "/.npm-cache"))
                (let ((registry #$(start-offline-npm-registry
                                   (offline-npm-registry
                                    "scrcpy-gui" scrcpy-gui-npm-tarballs))))
                  (invoke "npm" "ci" "--ignore-scripts")
                  (kill registry SIGTERM))
                ;; package.json "build" is "tsc && vite build" (-> ./dist).
                ;; Call the tools through node: their #!/usr/bin/env shebangs
                ;; do not resolve inside the build container.
                (invoke "node" "node_modules/typescript/bin/tsc")
                (invoke "node" "node_modules/vite/bin/vite.js" "build")))
            (add-after 'unpack 'keep-webkit-compositing
              ;; Upstream forces WEBKIT_DISABLE_COMPOSITING_MODE=1 against a
              ;; blank window on NVIDIA, which is really the DMA-BUF
              ;; renderer's doing.  Without compositing, WebKitGTK draws every
              ;; frame in software on the main thread, so there is no
              ;; asynchronous or kinetic scrolling and scrolling stutters.
              ;; Leave the choice to the user's environment.
              (lambda _
                (substitute* "src-tauri/src/lib.rs"
                  (("std::env::set_var\\(\"WEBKIT_DISABLE_COMPOSITING_MODE\", \"1\"\\);")
                   ""))))
            (add-after 'build-frontend 'enter-tauri-dir
              (lambda _ (chdir "src-tauri")))
            (replace 'build
              (lambda _
                (invoke "cargo" "build" "--offline" "--release"
                        ;; Embed ../dist instead of pointing at a dev server.
                        "--features" "tauri/custom-protocol")))
            (replace 'install
              (lambda _
                (define (cargo-output name)
                  ;; target/release/NAME, or target/<triplet>/release/NAME
                  ;; when the build system sets CARGO_BUILD_TARGET.
                  (let ((hits (filter (lambda (f)
                                        (string-suffix?
                                         (string-append "/release/" name) f))
                                      (find-files "target"
                                                  (string-append "^" name "$")))))
                    (if (null? hits)
                        (error "cannot find cargo output" name)
                        (car hits))))
                (let ((bin   (string-append #$output "/bin"))
                      (icons (string-append #$output "/share/icons/hicolor"))
                      (apps  (string-append #$output "/share/applications")))
                  (install-file (cargo-output "scrcpy-gui-v3") bin)
                  (for-each
                   (lambda (pair)
                     (let ((dir (string-append icons "/" (cdr pair) "/apps")))
                       (mkdir-p dir)
                       (copy-file (string-append "icons/" (car pair))
                                  (string-append dir "/scrcpy-gui.png"))))
                   '(("32x32.png" . "32x32")
                     ("64x64.png" . "64x64")
                     ("128x128.png" . "128x128")
                     ("128x128@2x.png" . "256x256")
                     ("icon.png" . "512x512")))
                  (mkdir-p apps)
                  (call-with-output-file (string-append apps "/scrcpy-gui.desktop")
                    (lambda (port)
                      (format port "[Desktop Entry]
Type=Application
Name=ScrcpyGUI
GenericName=Android Remote Control
Comment=A modern GUI for scrcpy
Exec=~a/scrcpy-gui
Icon=scrcpy-gui
Terminal=false
Categories=Utility;Development;
Keywords=adb;android;scrcpy;mirror;
StartupWMClass=scrcpy-gui
" bin))))))
            (add-after 'install 'glib-or-gtk-wrap
              (assoc-ref gtk:%standard-phases 'glib-or-gtk-wrap))
            (add-after 'glib-or-gtk-wrap 'wrap-program
              (lambda* (#:key inputs #:allow-other-keys)
                (wrap-program (string-append #$output "/bin/scrcpy-gui-v3")
                  ;; No WEBKIT_DISABLE_DMABUF_RENDERER: that renderer is
                  ;; WebKitGTK's only GPU path, and it works with NVIDIA's
                  ;; 615 driver.  Set it (or WEBKIT_DISABLE_COMPOSITING_MODE)
                  ;; yourself if the window stays blank.
                  ;;
                  ;; scrcpy, adb, xdotool (window recentring on X11) and
                  ;; pkill are all looked up on PATH.
                  `("PATH" suffix
                    ,(map (lambda (cmd)
                            (dirname (search-input-file inputs
                                                        (string-append "bin/" cmd))))
                          '("scrcpy" "adb" "xdotool" "pkill"))))))
            (add-after 'wrap-program 'add-short-name
              ;; Tauri does not set a GTK application ID here, so GTK names
              ;; the window (Wayland app_id) after argv[0]: the .desktop file
              ;; starts this name and declares it as StartupWMClass.
              (lambda _
                (symlink "scrcpy-gui-v3"
                         (string-append #$output "/bin/scrcpy-gui")))))))
      (native-inputs (list node pkg-config))
      (inputs
       (append
        (list adb
              bash-minimal
              glib-networking
              gsettings-desktop-schemas
              gtk+
              librsvg
              openssl
              procps
              scrcpy
              webkitgtk-for-gtk3
              xdotool
              ;; Guix makes zstd-sys link the system libzstd.
              `(,zstd "lib"))
        scrcpy-gui-cargo-inputs))
      (supported-systems '("x86_64-linux"))  ;npm native bindings are pinned
      (home-page "https://github.com/kil0bit-kb/scrcpy-gui")
      (synopsis "Graphical front end for scrcpy")
      (description
       "ScrcpyGUI is a desktop front end for @command{scrcpy}, written with
Tauri, React and Rust.  It manages USB and wireless (Android 11+ pairing)
connections, exposes scrcpy's options -- HID/OTG keyboard and mouse, renderer
selection, camera (webcam) mode with lens and zoom selection, virtual display
\"desktop mode\" -- through a themed interface, and installs APKs or pushes
files by drag and drop.")
      (license license:expat))))
