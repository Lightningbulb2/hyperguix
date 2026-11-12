;;; Lightningbulb channel --- Isocast, a screen recorder that records every
;;; source as its own file
;;;
;;; A Rust workspace: the engine (isocastd), its media helper, the CLI, the
;;; Slint app (isocast-ui) and the WebKitGTK helper for browser sources, the
;;; same five programs as upstream's Arch PKGBUILD.  Its crates.io
;;; dependencies come from isocast-crates.scm.
;;;
;;; Slint draws with Skia through rust-skia (skia-bindings), which normally
;;; downloads a prebuilt Skia.  Here it builds rust-skia's own Skia fork
;;; (the tag skia-bindings names in its Cargo.toml) offline, against Guix's
;;; libraries (SKIA_USE_SYSTEM_LIBRARIES), with Guix's gn and ninja.
;;;
;;; At run time OpenH264 (libopenh264.so.8, the app's software decoder),
;;; PipeWire (upstream's pipewire-sys resolves it with dlopen()) and the
;;; windowing and GPU libraries are dlopen()ed, so they are added to RUNPATH;
;;; GStreamer finds its plugins through the wrapper.

(define-module (Lightningbulb packages isocast)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages cargo-git)
  #:use-module (Lightningbulb packages isocast-crates))

;; skia-bindings 0.153.3: [package.metadata] skia = "m153-0.101.2".
(define %isocast-skia
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/rust-skia/skia")
          (commit "61e7ca4e99062cdd0ab69445d5963fb3365778f6")))
    (file-name "rust-skia-m153-0.101.2-checkout")
    (sha256
     (base32 "0spgffglblrv1q41b4bq8j8gl92dn4scymd7pi5wj00k1ays9864"))))

;; Skia's DEPS: third_party/externals/vulkanmemoryallocator.  Guix's
;; vulkan-memory-allocator (3.3.0) lacks members Skia uses (minAlignment).
;; Header-only.
(define %isocast-skia-vma
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator")
          (commit "eb744ea7a2b17040121b4bbb4d6f9e8a77e3cae7")))
    (file-name "skia-vulkanmemoryallocator-eb744ea-checkout")
    (sha256
     (base32 "1wyh7wym8dyr42wpxsxj04kh150hjmbm2afw2ydbj6xvi5r4j5ic"))))

;; Libraries dlopen()ed at run time; added to RUNPATH.
(define %isocast-runtime-libraries
  (list libx11 libxcb libxcursor libxi libxrandr libxkbcommon mesa
        openh264 pipewire vulkan-loader wayland))

(define-public isocast
  (let ((commit "dd2d1038f10ae90e07bd08582881ba21aaeaa0cc")
        (revision "0")
        (base-version "0.0.10")
        (binaries '("isocast" "isocastd" "isocast-ui" "isocast-browser"
                    "isocast-media")))
    (package
      (name "isocast")
      (version (git-version base-version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/anomalyco/isocast")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1ivi423aamilqzhw8mjsbk4gs1s7km3qa4wq8ab8lpsymlhsiqyw"))
         ;; Settings in $XDG_CONFIG_HOME, logs in $XDG_STATE_HOME.
         (patches
          (list (local-file "aux-files/isocast-xdg-folders.patch")))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:rust rust-1.97
        #:install-source? #f
        ;; The test suites need a GPU, a display and capture devices.
        #:tests? #f
        #:cargo-build-flags
        ''("--release"
           "--package" "isocast-media" "--package" "isocast-cli"
           "--package" "isocast-daemon" "--package" "isocast-ui"
           "--package" "isocast-browser")
        #:modules '((guix build cargo-build-system)
                    (guix build utils)
                    (ice-9 match))
        #:phases
        #~(modify-phases %standard-phases
            #$@(vendor-git-crates-phases isocast-git-crates)
            #$@(fast-cargo-release-phases)
            (add-after 'unpack 'use-system-opus
              (lambda _
                ;; The bundled libopus is built with cmake; link Guix's.
                (substitute* '("crates/isocast-daemon/Cargo.toml"
                               "crates/isocast-engine/Cargo.toml"
                               "crates/isocast-ui/Cargo.toml")
                  (("(opus2 = \\{ version = \"=0.4.0\"), features = \\[\"bundled\"\\]"
                    _ head)
                   head))))
            (add-before 'build 'configure-skia
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((skia (string-append (getcwd) "/../rust-skia")))
                  (copy-recursively #$%isocast-skia skia)
                  (for-each make-file-writable (find-files skia))
                  ;; As in Guix's skia: the zlib target is built even
                  ;; when the system zlib is used, and fails.
                  (substitute* (string-append skia "/BUILD.gn")
                    (("deps = \\[ \"//third_party/zlib\" ]")
                     "deps = []"))
                  (setenv "SKIA_SOURCE_DIR" skia)
                  (setenv "SKIA_USE_SYSTEM_LIBRARIES" "1")
                  (setenv "SKIA_GN_COMMAND" (which "gn"))
                  (setenv "SKIA_NINJA_COMMAND" (which "ninja"))
                  ;; skia-bindings passes clang options (--target).
                  (setenv "CLANGCC" (which "clang"))
                  (setenv "CLANGCXX" (which "clang++"))
                  (setenv "LIBCLANG_PATH"
                          (dirname (search-input-file inputs
                                                      "lib/libclang.so")))
                  (setenv "SKIA_GN_ARGS"
                          (string-append
                           "skia_use_wuffs=false "
                           "skia_vulkan_memory_allocator_dir=\""
                           #$%isocast-skia-vma
                           "\" "
                           (format #f "extra_cflags+=[\"-I~a\",\"-I~a\",~
\"-Wno-psabi\"]"
                                   (search-input-directory inputs
                                                           "include/harfbuzz")
                                   (search-input-directory
                                    inputs "include/freetype2")))))))
            (add-before 'build 'set-build-info
              (lambda _
                ;; Upstream's build scripts read these from .git, which a
                ;; Guix checkout lacks.
                (setenv "ISOCAST_GIT_SHA" #$commit)
                (setenv "VERGEN_GIT_SHA" #$commit)))
            (replace 'install
              (lambda _
                (let* ((bin (string-append #$output "/bin"))
                       (share (string-append #$output "/share"))
                       (doc (string-append share "/doc/isocast-"
                                           #$(package-version this-package))))
                  ;; As packaging/arch/PKGBUILD does.
                  (for-each (lambda (program)
                              (install-file
                               (string-append "target/release/" program)
                               bin))
                            '#$binaries)
                  (install-file "packaging/linux/dev.isocast.Isocast.desktop"
                                (string-append share "/applications"))
                  (copy-recursively "packaging/linux/icons/hicolor"
                                    (string-append share "/icons/hicolor"))
                  (for-each (lambda (file) (install-file file doc))
                            '("README.md" "LICENSE-MIT" "LICENSE-APACHE"
                              "THIRD_PARTY_NOTICES"
                              "packaging/linux/CISCO_H264_LICENSE.txt")))))
            (add-after 'install 'add-dlopen-runpath
              (lambda _
                (let ((runpath
                       (string-join
                        (list #$@(map (lambda (lib) (file-append lib "/lib"))
                                      %isocast-runtime-libraries))
                        ":")))
                  (for-each
                   (lambda (program)
                     (invoke "patchelf" "--add-rpath" runpath
                             (string-append #$output "/bin/" program)))
                   '#$binaries))))
            (add-after 'add-dlopen-runpath 'wrap-programs
              (lambda _
                ;; The programs find one another next to their own
                ;; executable, so the wrappers stay in bin/ beside them.
                (let ((gst (getenv "GST_PLUGIN_SYSTEM_PATH")))
                  (for-each
                   (lambda (program)
                     (wrap-program (string-append #$output "/bin/" program)
                       `("GST_PLUGIN_SYSTEM_PATH" ":" prefix (,gst))))
                   '#$binaries)))))))
      (native-inputs
       ;; cmake: libxaac-sys builds its bundled libxaac (not in Guix).
       (list clang cmake-minimal gn ninja patchelf pkg-config python))
      (inputs
       (append
        (list alsa-lib
              eudev
              expat
              fontconfig
              freetype
              gst-libav
              gst-plugins-bad            ;AV1 decoding (isocast doctor)
              gst-plugins-base
              gst-plugins-good
              gstreamer
              gtk
              harfbuzz
              icu4c
              libdrm
              libinput
              libjpeg-turbo
              libpng
              libseat
              libwebp
              openssl
              opus
              vulkan-headers
              webkitgtk
              zlib)
        %isocast-runtime-libraries
        isocast-cargo-inputs))
      (supported-systems '("x86_64-linux" "aarch64-linux"))
      (home-page "https://isocast.com")
      (synopsis "Screen recorder and streaming app that records every source")
      (description
       "Isocast records and streams like OBS Studio, with scenes, sources,
transitions and an audio mixer, and also saves each screen, window and camera
as its own full-quality file (ISO recording), all on one clock.  It imports
OBS scene collections, answers obs-websocket clients, streams to several
RTMP destinations at once and has a replay buffer and a virtual camera.  The
@command{isocast} command and an MCP server drive the same engine as the
app.")
      (license (list license:expat license:asl2.0)))))
