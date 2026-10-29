;;; Lightningbulb channel --- SolidCraft, a parametric 3D CAD application
;;;
;;; A Rust workspace built on egui/wgpu with its own geometry kernel (a fork
;;; of truck, kept in the source's vendor/ directory and wired in with
;;; [patch.crates-io]).  Needs Rust 1.95.  Its crates.io dependencies come
;;; from solidcraft-crates.scm; it takes none from git.

(define-module (Lightningbulb packages solidcraft)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages solidcraft-crates))

;; Libraries winit, wgpu and friends dlopen() at run time; added to RUNPATH.
(define %solidcraft-runtime-libraries
  (list libx11 libxcb libxcursor libxi libxrandr libxkbcommon mesa
        vulkan-loader wayland))

(define-public solidcraft
  (let ((commit "9454afe13a87ea31330b7cb413fb3d440bd46f5c")
        (revision "0")
        (binaries '("solidcraft" "solidcraft-cli")))
    (package
      (name "solidcraft")
      (version (git-version "0.26.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/tangency-labs/solidcraft")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0xs0n7q6kmalij8j06ikjzny9injv4jf0pj6i9rpnqxgl9ark7f5"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:rust rust-1.95
        #:install-source? #f
        ;; The test suites need a GPU and a display, and would build the
        ;; whole workspace a second time.
        #:tests? #f
        #:cargo-build-flags
        `'("--release" "--package" "solidcraft" "--package" "solidcraft-cli")
        #:phases
        #~(modify-phases %standard-phases
            (replace 'install
              (lambda _
                (let* ((app-id "io.tangencylabs.solidcraft")
                       (bin (string-append #$output "/bin"))
                       (share (string-append #$output "/share"))
                       (doc (string-append share "/doc/solidcraft-"
                                           #$(package-version this-package)))
                       (platform "assets/platforms/linux/")
                       (icons "assets/icons/app/linux/exports/hicolor")
                       (metainfo (string-append share "/metainfo/"
                                                app-id ".metainfo.xml")))
                  ;; As packaging/linux/package.sh does.
                  (for-each (lambda (program)
                              (install-file
                               (string-append "target/release/" program)
                               bin))
                            '#$binaries)
                  (install-file (string-append platform app-id ".desktop")
                                (string-append share "/applications"))
                  (mkdir-p (string-append share "/mime/packages"))
                  (copy-file (string-append platform app-id ".mime.xml")
                             (string-append share "/mime/packages/"
                                            app-id ".xml"))
                  (mkdir-p (dirname metainfo))
                  (copy-file (string-append platform app-id
                                            ".metainfo.xml.in")
                             metainfo)
                  (substitute* metainfo
                    (("@VERSION@") "0.26.1")
                    ;; No meaningful release date for a git snapshot.
                    ((" date=\"@DATE@\"") ""))
                  (for-each
                   (lambda (size)
                     (install-file
                      (string-append icons "/" size "/apps/" app-id ".png")
                      (string-append share "/icons/hicolor/" size "/apps")))
                   '("16x16" "24x24" "32x32" "48x48" "64x64" "128x128"
                     "256x256" "512x512"))
                  (for-each (lambda (file)
                              (install-file file doc))
                            '("README.md" "LICENSE-MIT" "LICENSE-APACHE"
                              "NOTICE" "THIRD-PARTY-LICENSES.txt")))))
            (add-after 'install 'add-dlopen-runpath
              (lambda _
                (let ((runpath
                       (string-join
                        (list #$@(map (lambda (lib) (file-append lib "/lib"))
                                      %solidcraft-runtime-libraries))
                        ":")))
                  (for-each
                   (lambda (program)
                     (invoke "patchelf" "--add-rpath" runpath
                             (string-append #$output "/bin/" program)))
                   '#$binaries)))))))
      (native-inputs (list patchelf pkg-config))
      (inputs
       ;; dbus: libdbus-sys (the Secret Service keychain for the agent
       ;; chat's API keys).
       (append (list dbus)
               %solidcraft-runtime-libraries
               solidcraft-cargo-inputs))
      (supported-systems '("x86_64-linux" "aarch64-linux"))
      (home-page "https://solidcraft.io")
      (synopsis "Parametric 3D CAD application")
      (description
       "SolidCraft is a parametric 3D CAD application: sketches solved with
constraints and parameter-driven dimensions, and features (extrude, revolve,
sweep, loft, fillet, chamfer, shell, holes, threads, patterns and more) on an
editable timeline that rebuilds when a dimension changes.  It has assemblies
with joints and mass properties, sheet metal, and reads and writes STEP,
IGES, 3MF, STL, OBJ and glTF.  @command{solidcraft-cli} runs command scripts
and exports headless, and includes an MCP server for AI agents.")
      ;; MIT OR Apache-2.0; the vendored truck crates are Apache-2.0, and the
      ;; UI fonts egui embeds are under the SIL Open Font License.
      (license (list license:expat license:asl2.0 license:silofl1.1)))))
