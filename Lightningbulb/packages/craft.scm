;;; Lightningbulb channel --- the ArtCraft "Craft" creative suite
;;;
;;;   photocraft   image editor   (a clean-room take on Photoshop)
;;;   effectcraft  motion/VFX     (... on After Effects)
;;;   filmcraft    video editor   (... on Premiere)
;;;
;;; All three are Rust workspaces built on egui/wgpu and need Rust 1.95,
;;; which Guix provides as `rust-1.95' (the default `rust' is older).  Their
;;; crates.io dependencies come from craft-crates.scm; crates they take from
;;; git (craft-libs, winprint.rs, filmcraft's codec crates) are vendored with
;;; the helper in cargo-git.scm.

(define-module (Lightningbulb packages craft)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages cargo-git)
  #:use-module (Lightningbulb packages craft-crates))

;; Libraries winit, wgpu and friends dlopen() at run time.
(define %craft-runtime-libraries
  (list libx11 libxcursor libxi libxrandr libxkbcommon mesa vulkan-loader
        wayland))

(define* (craft-app name version commit hash
                    #:key cargo-inputs git-crates (features '())
                    (extra-inputs '()) (extra-native-inputs '())
                    synopsis description)
  (package
    (name name)
    (version (git-version version "0" commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append "https://github.com/storytold/" name))
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256 (base32 hash))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.95
      #:install-source? #f
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          #$@(vendor-git-crates-phases git-crates)
          (replace 'build
            (lambda _
              (apply invoke "cargo" "build" "--offline" "--release"
                     "--package" #$name
                     "--package" #$(string-append name "-cli")
                     (if (null? '#$features)
                         '()
                         (list "--features" (string-join '#$features ","))))))
          (replace 'install
            (lambda _
              (let* ((app-id #$(string-append "ai.storyteller." name))
                     (bin (string-append #$output "/bin"))
                     (share (string-append #$output "/share"))
                     (pkg "packaging/linux/"))
                (for-each
                 (lambda (program)
                   (install-file
                    (car (filter (lambda (f)
                                   (string-suffix?
                                    (string-append "/release/" program) f))
                                 (find-files "target"
                                             (string-append "^" program "$"))))
                    bin))
                 (list #$name #$(string-append name "-cli")))
                (install-file (string-append pkg app-id ".desktop")
                              (string-append share "/applications"))
                (mkdir-p (string-append share "/mime/packages"))
                (copy-file (string-append pkg app-id ".mime.xml")
                           (string-append share "/mime/packages/"
                                          app-id ".xml"))
                (mkdir-p (string-append share "/metainfo"))
                (copy-file (string-append pkg app-id ".metainfo.xml.in")
                           (string-append share "/metainfo/"
                                          app-id ".metainfo.xml"))
                (substitute* (string-append share "/metainfo/"
                                            app-id ".metainfo.xml")
                  (("@VERSION@") #$version)
                  (("@DATE@") "1970-01-01"))
                (copy-recursively "assets/app-icon/hicolor"
                                  (string-append share "/icons/hicolor")))))
          (add-after 'install 'wrap-program
            (lambda _
              (for-each
               (lambda (program)
                 (wrap-program (string-append #$output "/bin/" program)
                   `("LD_LIBRARY_PATH" suffix
                     ,(list #$@(map (lambda (lib) (file-append lib "/lib"))
                                    %craft-runtime-libraries)))))
               (list #$name #$(string-append name "-cli"))))))))
    (native-inputs
     (append (list pkg-config python) extra-native-inputs))
    (inputs
     (append (list alsa-lib bash-minimal)
             %craft-runtime-libraries
             extra-inputs
             cargo-inputs))
    (supported-systems '("x86_64-linux" "aarch64-linux"))
    (home-page (string-append "https://github.com/storytold/" name))
    (synopsis synopsis)
    (description description)
    (license (list license:expat license:asl2.0))))

(define-public photocraft
  (craft-app "photocraft" "0.10.0" "03d0c7e3b39cfb401cdbba590431141ee4c6c8fa"
             "0hwhqzzh8nw2av9vhw538v1i4h3b6xzj65gpha354dnx02vyxqnw"
             #:cargo-inputs photocraft-cargo-inputs
             #:git-crates photocraft-git-crates
             ;; As in upstream's release builds: open HEIC/HEIF photos.
             #:features '("heif")
             ;; xcap (screenshots): PipeWire via bindgen, GBM/DRM;
             ;; aws-lc-sys (TLS for signature checks) wants cmake.
             #:extra-native-inputs (list clang cmake-minimal)
             #:extra-inputs (list libdrm openssl pipewire)
             #:synopsis "Layer-based image editor with PSD support"
             #:description
             "PhotoCraft is an image editor written in Rust, modelled on Adobe
Photoshop: layers, masks, adjustment layers, layer styles, type and vector
layers, brushes, and reading and writing PSD files, as well as common image
formats including HEIC/HEIF.  It also ships @command{photocraft-cli} for
batch processing."))

(define-public effectcraft
  (craft-app "effectcraft" "0.12.0" "ef74d82902ba486891b02afa87e42963cc9b84cc"
             "08rf1kgfcx8c0bzv8hj0wlirqnldyl7igcyqswr8amb0igb6fp0c"
             #:cargo-inputs effectcraft-cargo-inputs
             #:git-crates effectcraft-git-crates
             #:synopsis "Motion graphics and visual effects compositor"
             #:description
             "EffectCraft is a compositor for motion graphics and visual
effects written in Rust, in the spirit of Adobe After Effects: compositions,
layers and keyframes, some 300 effects, layer styles, expressions, 3D cameras
and lights, and a render queue.  @command{effectcraft-cli} renders projects
from the command line."))

(define-public filmcraft
  (craft-app "filmcraft" "0.9.0" "fb4cbda47a134eedabd89fe02cd59ebc69462737"
             "1j18bdmj0wj56zszxcsg6c8w3l56d0khg6sxjzw992rhv31p59pw"
             #:cargo-inputs filmcraft-cargo-inputs
             #:git-crates filmcraft-git-crates
             ;; GTK 3 for native file dialogs.
             #:extra-inputs (list gtk+)
             #:synopsis "Non-linear video editor with color and audio tools"
             #:description
             "FilmCraft is a non-linear video editor written in Rust: a
multi-track timeline, color correction and grading, audio mixing, titles and
transitions, with its own codecs for common formats (H.264, HEVC, AV1, VP9,
ProRes, DNx, AAC, Opus) and containers.  @command{filmcraft-cli} renders and
converts projects from the command line."))
