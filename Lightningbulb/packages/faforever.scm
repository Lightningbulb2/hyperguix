;;; Lightningbulb channel --- FAForever client (Rust + Tauri rewrite)
;;;
;;; The client is built from source: the React front end with pnpm against an
;;; offline mirror of pnpm-lock.yaml (see js-offline.scm), the Rust/Tauri
;;; shell with cargo against the crates in Cargo.lock (rust-crates.scm).
;;;
;;; Its "natives" are a different matter.  Upstream's `pnpm tauri' downloads
;;; them, checksum-verified, at build time; we fetch the very same files with
;;; the very same SHA-256 digests (copied from scripts/ensure-*.mjs):
;;;
;;;   faf-uid          FAF's official machine-id helper.  It embeds a secret
;;;                    key, so a self-built copy is rejected by the lobby;
;;;                    the prebuilt binary is the only one that works.
;;;   faf-pioneer      Go ICE adapter (experimental, selectable in Settings).
;;;   faf-ice-adapter  Java ICE adapter (the default) + GodFuper's WebRTC
;;;                    build as the "experimental" choice.
;;;   libsteam_api.so  Valve Steamworks, for Steam "now playing" status; it
;;;                    lives in the client's own repository.
;;;
;;; Instead of upstream's bundled Temurin JRE, the adapters run on Guix's
;;; OpenJDK.  The game itself (Forged Alliance) still has to come from your
;;; own Steam/Wine setup and is configured inside the client.

(define-module (Lightningbulb packages faforever)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages java)
  #:use-module (gnu packages node)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages webkit)
  #:use-module (Lightningbulb packages js-offline)
  #:use-module (Lightningbulb packages node-deps)
  #:use-module (Lightningbulb packages rust-crates))

(define (github-release-asset owner repo tag asset hash)
  (origin
    (method url-fetch)
    (uri (string-append "https://github.com/" owner "/" repo
                        "/releases/download/" tag "/" asset))
    (file-name asset)
    (sha256 (base32 hash))))

(define faf-uid-binary
  ;; scripts/ensure-faf-uid.mjs, v4.0.7
  (github-release-asset "FAForever" "uid" "v4.0.7" "faf-uid"
                        "1nk1mk6bj7rsga5dkzfpcfzr1rmsqkd3y13mscm6hqbyrphx0dhi"))

(define faf-pioneer-binary
  ;; scripts/ensure-faf-pioneer.mjs, 0.2.2
  (github-release-asset "FAForever" "faf-pioneer" "0.2.2"
                        "faf-pioneer-0.2.2-linux-amd64"
                        "0azm1zx76p9rl6vni9gscklzsdf2nmzkhklfagrq80cwq32mv7wl"))

(define faf-java-ice-adapter
  ;; scripts/ensure-java-ice-adapter.mjs, 3.3.14
  (github-release-asset "FAForever" "java-ice-adapter" "3.3.14"
                        "faf-ice-adapter-3.3.14-linux.jar"
                        "0mnn0x8zy10yhpc4dcq184704xc3mz7kk0zlxkdlska2d74c6mnp"))

(define faf-exp-java-ice-adapter
  ;; scripts/ensure-exp-java-ice-adapter.mjs, 4.0.1
  (github-release-asset "GodFuper" "java-ice-adapter" "4.0.1"
                        "faf-ice-adapter-4.0.1-linux.jar"
                        "0yzxnd053bhm4jxqn92dy4xil9gpn9fm1zby7w8gvjzkh5s8wm7d"))

(define-public faforever-client
  (let ((commit "e5533b3c8c096797bc4169d43cf7564b628932d1")
        (revision "0"))
    (package
      (name "faforever-client")
      (version (git-version "0.9.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/FAForeverRustClient/FAForeverRustClient")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "18wil8wnx4c8d3w3r3i3vj2lhgs3cg1r1533xm1sj9p0d1q2wnwz"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:install-source? #f
        #:tests? #f                     ;several suites need network/display
        #:imported-modules `(,@%cargo-build-system-modules
                             ,@%glib-or-gtk-build-system-modules)
        #:modules '((guix build cargo-build-system)
                    ((guix build glib-or-gtk-build-system) #:prefix gtk:)
                    (guix build utils))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'build-frontend
              (lambda _
                (let ((top (getcwd)))
                  (setenv "HOME" (string-append top "/.home"))
                  (setenv "XDG_DATA_HOME" (string-append top "/.home/share"))
                  (setenv "XDG_CACHE_HOME" (string-append top "/.home/cache"))
                  (setenv "XDG_CONFIG_HOME" (string-append top "/.home/config"))
                  (mkdir-p ".pnpm")
                  (invoke "tar" "xf" #$faforever-client-pnpm-tarball "-C" ".pnpm")
                  ;; Upstream refuses packages younger than a day; checking
                  ;; that needs registry metadata we don't have (and the
                  ;; lockfile already pins everything by hash).
                  (substitute* ".npmrc"
                    (("^minimum-release-age=.*") ""))
                  (let ((port (open-file "pnpm-workspace.yaml" "a")))
                    (display "\nminimumReleaseAge: 0\n" port)
                    (close-port port))
                  (let ((registry #$(start-offline-npm-registry
                                     (offline-npm-registry
                                      "faforever-client"
                                      faforever-client-npm-tarballs))))
                    (invoke "node" ".pnpm/package/bin/pnpm.mjs" "install"
                            "--frozen-lockfile" "--ignore-scripts"
                            "--reporter=append-only"
                            (string-append "--registry="
                                           (getenv "npm_config_registry"))
                            (string-append "--store-dir=" top "/.pnpm-store"))
                    (kill registry SIGTERM))
                  ;; "pnpm build" minus its pnpm-only guard script -> ui/dist
                  (invoke "node" "node_modules/vite/bin/vite.js" "build"))))
            (add-after 'unpack 'find-nonguix-steam
              ;; Also auto-detect Forged Alliance under the sandbox home of
              ;; nonguix's `steam' package, next to the native and Flatpak
              ;; Steam folders upstream already checks.
              (lambda _
                (substitute* "crates/faf-app/src/infra/game_updater/install.rs"
                  (("^( *)roots\\.push\\(home\\.join\\(\"\\.var/app/com\\.valvesoftware\\.Steam/\\.local/share/Steam\"\\)\\);"
                    all indent)
                   (string-append
                    all "\n" indent
                    "roots.push(home.join(\".local/share/guix-sandbox-home/.local/share/Steam\"));")))))
            (replace 'build
              (lambda _
                (invoke "cargo" "build" "--offline" "--release"
                        "--package" "faforever-rust-client"
                        "--features" "tauri/custom-protocol")))
            (replace 'install
              (lambda* (#:key inputs #:allow-other-keys)
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
                (let* ((libdir  (string-append #$output "/lib/faforever-client"))
                       (natives (string-append libdir "/natives"))
                       (bin     (string-append #$output "/bin"))
                       (real    (string-append libdir "/faforever-rust-client"))
                       (ld.so   (search-input-file inputs
                                                   "lib/ld-linux-x86-64.so.2"))
                       ;; gcc:lib is referenced here rather than listed as an
                       ;; input: an input labelled "gcc" would replace the
                       ;; compiler cargo-build-system exports as $CC.
                       (rpath   (string-append (ungexp gcc "lib") "/lib"
                                               ":" (dirname ld.so))))
                  (define (install-native source target)
                    (mkdir-p (dirname target))
                    (copy-file source target)
                    (chmod target #o755))
                  (define (patch-prebuilt file)
                    ;; Make the prebuilt ELF files usable on Guix: point the
                    ;; dynamic ones at Guix's loader and libraries.  Static
                    ;; ones have no interpreter and are left alone.
                    (when (false-if-exception
                           (invoke "patchelf" "--print-interpreter" file))
                      (invoke "patchelf" "--set-interpreter" ld.so file))
                    (when (false-if-exception
                           (invoke "patchelf" "--print-needed" file))
                      (invoke "patchelf" "--set-rpath" rpath file)))
                  ;; The client resolves its helpers relative to its own
                  ;; executable, so it lives next to natives/ in libdir.
                  (install-file (cargo-output "faforever-rust-client") libdir)
                  (install-native #$faf-uid-binary
                                  (string-append natives "/faf-uid"))
                  (install-native #$faf-pioneer-binary
                                  (string-append natives "/faf-pioneer"))
                  (install-native #$faf-java-ice-adapter
                                  (string-append natives
                                                 "/java-ice-adapter/faf-ice-adapter.jar"))
                  (install-native #$faf-exp-java-ice-adapter
                                  (string-append natives
                                                 "/exp-java-ice-adapter/faf-ice-adapter.jar"))
                  (install-native "vendor/steamworks/linux64/libsteam_api.so"
                                  (string-append natives "/steam/libsteam_api.so"))
                  (for-each patch-prebuilt
                            (map (lambda (f) (string-append natives f))
                                 '("/faf-uid" "/faf-pioneer"
                                   "/steam/libsteam_api.so")))
                  ;; Launcher.  Every default can be overridden from the
                  ;; environment, as documented in upstream's README.
                  (mkdir-p bin)
                  (call-with-output-file (string-append bin "/faforever-client")
                    (lambda (port)
                      (format port "#!~a
export FAF_JAVA_PATH=\"${FAF_JAVA_PATH:-~a}\"
export FAF_UID_PATH=\"${FAF_UID_PATH:-~a/faf-uid}\"
export FAF_ICE_ADAPTER_JAR=\"${FAF_ICE_ADAPTER_JAR:-~a/java-ice-adapter/faf-ice-adapter.jar}\"
export FAF_EXP_JAVA_ICE_ADAPTER_JAR=\"${FAF_EXP_JAVA_ICE_ADAPTER_JAR:-~a/exp-java-ice-adapter/faf-ice-adapter.jar}\"
export FAF_ICE_ADAPTER_PATH=\"${FAF_ICE_ADAPTER_PATH:-~a/faf-pioneer}\"
export FAF_STEAM_API_PATH=\"${FAF_STEAM_API_PATH:-~a/steam/libsteam_api.so}\"
exec -a \"$0\" ~a \"$@\"~%"
                              (search-input-file inputs "bin/bash")
                              (search-input-file inputs "bin/java")
                              natives natives natives natives natives
                              real)))
                  (chmod (string-append bin "/faforever-client") #o755)
                  ;; Desktop integration (incl. the replay file types the
                  ;; Tauri bundle would register).
                  (for-each
                   (lambda (pair)
                     (let ((dir (string-append #$output "/share/icons/hicolor/"
                                               (cdr pair) "/apps")))
                       (mkdir-p dir)
                       (copy-file (string-append "src-tauri/icons/" (car pair))
                                  (string-append dir "/faforever-client.png"))))
                   '(("32x32.png" . "32x32")
                     ("64x64.png" . "64x64")
                     ("128x128.png" . "128x128")
                     ("128x128@2x.png" . "256x256")
                     ("icon.png" . "512x512")))
                  (let ((apps (string-append #$output "/share/applications"))
                        (mime (string-append #$output "/share/mime/packages")))
                    (mkdir-p apps)
                    (mkdir-p mime)
                    (call-with-output-file (string-append apps "/faforever-client.desktop")
                      (lambda (port)
                        (format port "[Desktop Entry]
Type=Application
Name=FAForever Client
Comment=Forged Alliance Forever client
Exec=~a/faforever-client %f
Icon=faforever-client
Terminal=false
Categories=Game;StrategyGame;
MimeType=application/x-fafreplay;application/x-scfareplay;
StartupWMClass=faforever-rust-client
" bin)))
                    (call-with-output-file (string-append mime "/faforever-client.xml")
                      (lambda (port)
                        (display "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mime-info xmlns=\"http://www.freedesktop.org/standards/shared-mime-info\">
  <mime-type type=\"application/x-fafreplay\">
    <comment>Forged Alliance Forever replay</comment>
    <glob pattern=\"*.fafreplay\"/>
  </mime-type>
  <mime-type type=\"application/x-scfareplay\">
    <comment>Supreme Commander replay</comment>
    <glob pattern=\"*.scfareplay\"/>
  </mime-type>
</mime-info>
" port)))))))
            ;; Prebuilt natives: don't strip them, and don't fail the build
            ;; over libraries they may dlopen from the game environment.
            (delete 'strip)
            (delete 'validate-runpath)
            (add-after 'install 'glib-or-gtk-wrap
              (assoc-ref gtk:%standard-phases 'glib-or-gtk-wrap))
            (add-after 'glib-or-gtk-wrap 'wrap-program
              (lambda* (#:key inputs #:allow-other-keys)
                (wrap-program (string-append #$output "/bin/faforever-client")
                  ;; The tray icon dlopen()s libappindicator3.
                  `("LD_LIBRARY_PATH" suffix
                    (,#$(file-append (this-package-input "libappindicator")
                                     "/lib")))
                  ;; "Open in browser" etc. go through xdg-open.
                  `("PATH" suffix
                    (,(dirname (search-input-file inputs "bin/xdg-open"))))
                  `("WEBKIT_DISABLE_DMABUF_RENDERER" = ("1"))))))))
      (native-inputs (list node patchelf pkg-config))
      (inputs
       (append
        (list bash-minimal
              dbus                    ;libdbus-sys
              glib-networking
              gsettings-desktop-schemas
              gtk+
              libappindicator
              librsvg
              openjdk
              openssl
              webkitgtk-for-gtk3
              xdg-utils
              ;; Guix makes zstd-sys link the system libzstd.
              `(,zstd "lib"))
        faforever-client-cargo-inputs))
      (supported-systems '("x86_64-linux"))
      (home-page "https://github.com/FAForeverRustClient/FAForeverRustClient")
      (synopsis "Client for Forged Alliance Forever, written in Rust and Tauri")
      (description
       "This is a modular client for FAForever, the community-run online
platform for Supreme Commander: Forged Alliance.  It covers logging in
(OAuth), custom games and matchmaking (parties, map pool vetoes, co-op,
Galactic War), lobby chat, the map/mod/replay vault with live spectating and
the Neroxis map generator, tournaments, leaderboards and clans.  It needs a
separately installed copy of Forged Alliance (e.g. Steam with Proton/Wine) to
actually play.")
      (license license:expat))))
