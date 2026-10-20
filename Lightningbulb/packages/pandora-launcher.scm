;;; Lightningbulb channel --- Pandora Launcher (Minecraft launcher, GPUI)
;;;
;;; Upstream commits every crate it depends on (including the git ones: zed's
;;; gpui, gpui-component, ...) under vendor/, with a .cargo/config.toml that
;;; redirects all sources there.  So the git checkout alone is enough to build
;;; offline; we just have to keep Guix's cargo-build-system from replacing
;;; that setup with its own (empty) vendor directory.
;;;
;;; Guix-specific adjustments:
;;;   * FORCE_EXTERNAL_JAVA (an upstream knob) makes it use Guix's JDKs
;;;     instead of downloading Mojang's runtimes, which are built for FHS
;;;     distributions and cannot run here.
;;;   * The "Auto" GLFW/OpenAL library override also looks in Guix's glfw and
;;;     openal, and the wrapper exposes the graphics/audio libraries that
;;;     Minecraft's LWJGL dlopen()s.
;;;   * Self-update is off (no PANDORA_UPDATE_PUBKEY is compiled in).

(define-module (Lightningbulb packages pandora-launcher)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages java)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg))

(define-public pandora-launcher
  (let ((commit "2d83d6f22c43e804d9b544e8dc98d49d4874e3af")
        (revision "0"))
    (package
      (name "pandora-launcher")
      (version (git-version "5.3.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Moulberry/PandoraLauncher")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0nsyaj3iiqj110w0c50glhjcc2xwisjf47jy5fmwbghvijpc183x"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:install-source? #f
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'use-guix-libraries
              (lambda* (#:key inputs #:allow-other-keys)
                ;; "Auto" GLFW/OpenAL only probes FHS directories.
                (substitute* "crates/schema/src/instance.rs"
                  (("^( *)\"/lib/\"," all indent)
                   (string-append
                    indent "\"" #$(this-package-input "glfw") "/lib/\",\n"
                    indent "\"" #$(this-package-input "openal") "/lib/\",\n"
                    all)))))
            (add-after 'unpack 'allow-rust-1.93
              ;; Zed's gpui uses two std APIs stabilised in Rust 1.95; Guix
              ;; ships 1.93.  Both have exact older equivalents:
              ;;  * std::hint::cold_path() is only an optimisation hint;
              ;;  * Atomic*::try_update is the renamed fetch_update.
              (lambda _
                (substitute* (find-files "vendor/gpui/src" "\\.rs$")
                  (("std::hint::cold_path\\(\\);") "();"))
                (substitute* "vendor/gpui-base/src/text_selection.rs"
                  (("\\.try_update\\(") ".fetch_update("))
                #t))
            (add-before 'configure 'save-upstream-cargo-setup
              (lambda _
                (copy-file "Cargo.lock" "Cargo.lock.upstream")
                (copy-file ".cargo/config.toml" "cargo-config.upstream")))
            (add-after 'configure 'restore-upstream-cargo-setup
              ;; configure points crates.io at an (empty) guix-vendor
              ;; directory and may drop Cargo.lock; put back upstream's
              ;; vendor/ redirection (which also covers the git crates) and
              ;; lockfile, so the build is exactly upstream's `--frozen' one.
              (lambda _
                (for-each (lambda (f) (when (file-exists? f) (delete-file f)))
                          '(".cargo/config" ".cargo/config.toml" "Cargo.lock"))
                (rename-file "cargo-config.upstream" ".cargo/config.toml")
                (rename-file "Cargo.lock.upstream" "Cargo.lock")))
            ;; The vendored checksums already match Cargo.lock; Guix's
            ;; checksum rewriting would only break that.
            (delete 'patch-cargo-checksums)
            (add-before 'build 'relax-vendor-checksums
              ;; Guix's shebang patching (and the edits above) touch files
              ;; under vendor/, which cargo verifies file by file.  Drop the
              ;; per-file lists but keep each crate's "package" checksum, so
              ;; the tarball contents are still tied to Cargo.lock.
              (lambda _
                (substitute* (find-files "vendor" "^\\.cargo-checksum\\.json$")
                  (("\"files\":\\{[^}]*\\}") "\"files\":{}"))))
            (replace 'build
              (lambda _
                (setenv "PANDORA_RELEASE_VERSION" #$(package-version this-package))
                (setenv "PANDORA_DISTRIBUTION" "Guix (lightningbulb channel)")
                (invoke "cargo" "build" "--release" "--frozen"
                        "--package" "pandora_launcher")))
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
                (let ((bin (string-append #$output "/bin"))
                      (icons (string-append #$output "/share/icons/hicolor"))
                      (apps (string-append #$output "/share/applications"))
                      (metainfo (string-append #$output "/share/metainfo")))
                  (mkdir-p bin)
                  (copy-file (cargo-output "pandora_launcher")
                             (string-append bin "/pandora-launcher"))
                  (for-each
                   (lambda (size)
                     (let ((dir (string-append icons "/" size "x" size "/apps")))
                       (mkdir-p dir)
                       (copy-file (string-append "package/windows_icons/icon_"
                                                 size "x" size ".png")
                                  (string-append
                                   dir "/com.moulberry.PandoraLauncher.png"))))
                   '("16" "32" "48" "256"))
                  (install-file "package/flatpak/com.moulberry.PandoraLauncher.metainfo.xml"
                                metainfo)
                  ;; Not named com.moulberry.PandoraLauncher.desktop: that ID
                  ;; belongs to the Flatpak, and with both installed the menu
                  ;; would show only one of them -- often the Flatpak.
                  (mkdir-p apps)
                  (copy-file "package/flatpak/com.moulberry.PandoraLauncher.desktop"
                             (string-append apps "/pandora-launcher.desktop"))
                  (substitute* (string-append apps "/pandora-launcher.desktop")
                    (("^Name=.*") "Name=Pandora Launcher (Guix)\n")
                    (("^Exec=.*")
                     (string-append "Exec=" bin "/pandora-launcher\n"))
                    (("^X-Flatpak=.*") "")))))
            (add-after 'install 'wrap-program
              (lambda* (#:key inputs #:allow-other-keys)
                (define (lib name)
                  (dirname (search-input-file inputs (string-append "lib/" name))))
                (wrap-program (string-append #$output "/bin/pandora-launcher")
                  ;; Java homes, matched by exact major version per Minecraft
                  ;; release.  Appended, so your own FORCE_EXTERNAL_JAVA wins.
                  `("FORCE_EXTERNAL_JAVA" suffix
                    ;; (Referenced directly: every OpenJDK package is
                    ;; named "openjdk", so input labels can't tell them apart.)
                    (#$icedtea                ;8:  MC <= 1.16
                     #$openjdk16              ;16: MC 1.17
                     #$openjdk17              ;17: MC 1.18 - 1.20.4
                     #$openjdk21              ;21: MC 1.20.5 - 1.21.x
                     #$openjdk))              ;25: MC 26.x
                  ;; dlopen()ed by GPUI (wgpu/Vulkan, Wayland) and, through
                  ;; the inherited environment, by Minecraft's LWJGL.
                  `("LD_LIBRARY_PATH" suffix
                    ,(map lib '("libvulkan.so.1" "libwayland-client.so.0"
                                "libxkbcommon.so.0" "libGL.so.1" "libEGL.so.1"
                                "libX11.so.6" "libXcursor.so.1" "libXrandr.so.2"
                                "libXi.so.6" "libXxf86vm.so.1" "libXext.so.6"
                                "libglfw.so" "libopenal.so" "libpulse.so.0"
                                "libasound.so.2" "libudev.so.1")))
                  ;; LWJGL 2 (old Minecraft) shells out to xrandr; GPUI's file
                  ;; pickers go through the XDG portal, falling back to zenity.
                  `("PATH" suffix
                    (,(dirname (search-input-file inputs "bin/xrandr"))
                     ,(dirname (search-input-file inputs "bin/zenity"))))))))))
      (native-inputs (list cmake-minimal pkg-config))
      (inputs
       (list alsa-lib
             bash-minimal
             dbus
             eudev
             fontconfig
             freetype
             glfw
             libseccomp
             libx11
             libxcb
             libxcursor
             libxext
             libxi
             libxkbcommon
             libxrandr
             libxxf86vm
             mesa
             openal
             openssl
             pulseaudio
             sqlite
             vulkan-loader
             wayland
             xrandr
             zenity
             `(,zstd "lib")))
      (supported-systems '("x86_64-linux"))
      (home-page "https://github.com/Moulberry/PandoraLauncher")
      (synopsis "Native Minecraft launcher with sandboxing and modpack tools")
      (description
       "Pandora Launcher is a Minecraft launcher with a native (GPUI) user
interface.  It can optionally sandbox the game (seccomp/namespaces) so mods
cannot harm the system, syncs options and saves across instances, deduplicates
mods with reflinks or hard links, keeps account credentials in the platform
keyring, browses Modrinth and CurseForge, manages modpacks, and streams the
full game log live with access tokens redacted.")
      (license license:expat))))
