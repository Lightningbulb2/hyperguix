;;; Lightningbulb channel --- the Ladybird web browser.
;;;
;;; Upstream builds its dependencies with vcpkg (see vcpkg.json and
;;; Meta/CMake/vcpkg/overlay-ports in the source).  Here Guix packages are
;;; used instead.  Where Guix lacks a dependency or carries an incompatible
;;; version, a private package below builds the version vcpkg.json pins, using
;;; the build recipes and patches from Ladybird's own tree (the vcpkg overlay
;;; ports and the Flatpak manifest under Meta/CMake/flatpak) so they stay in
;;; sync with the pinned commit.

(define-module (Lightningbulb packages ladybird)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages c)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libedit)
  #:use-module (gnu packages libidn)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages ladybird-crates)
  #:use-module (srfi srfi-1)
  #:export (skia-for-ladybird
            angle-for-ladybird))

(define %ladybird-commit "bf3e277c50a73b5200522d3531e11f401b121870")

(define %ladybird-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/LadybirdBrowser/ladybird")
          (commit %ladybird-commit)))
    (file-name (git-file-name "ladybird" (string-take %ladybird-commit 7)))
    (sha256
     (base32 "0w49gyf278bjmcxq57lq07j42shdz4n4ad0sbfgj91v35sag28k9"))))

;; The tree the dependencies below take their vcpkg overlay port patches
;; from.  It has its own pin so that moving %ladybird-commit doesn't rebuild
;; Skia, ANGLE, FFmpeg and pdf.js when those patches haven't changed; move it
;; when `git diff OLD NEW -- Meta/CMake/vcpkg' shows they have.
(define %ladybird-ports-commit "b60be2e29b721f4748998e598cda2361d05462f6")

(define %ladybird-ports-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/LadybirdBrowser/ladybird")
          (commit %ladybird-ports-commit)))
    (file-name (git-file-name "ladybird" (string-take %ladybird-ports-commit 7)))
    (sha256
     (base32 "1aqh7cwjvm5m1zv91gdpf9158x47kp3zy7526wvqk9mci94sv88v"))))

(define (ladybird-file file)
  "FILE from Ladybird's source tree (a vcpkg overlay port patch, say)."
  (file-append %ladybird-ports-source "/" file))


;;;
;;; Dependencies Guix lacks or has in an incompatible version.
;;;

;; vcpkg.json: "skia" 148.  Guix has 112.
(define skia-for-ladybird
  (let ((commit "e7c90ecca9444fe09598f1630ab7cee2c0ee027a") ;chrome/m148
        (revision "0"))
    (package
      (inherit skia)
      (name "skia-for-ladybird")
      (version (git-version "148" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://skia.googlesource.com/skia.git")
                      (commit commit)))
                (file-name (git-file-name "skia" version))
                (sha256
                 (base32
                  "0dls4zrz2czwzy04w2bcmy3jyk5a9iy66yd96xl2n18dm5dg3ryv"))))
      (build-system gnu-build-system)   ;actually GN + Ninja
      (arguments
       (list
        #:tests? #f                     ;tests need the bundled externals
        #:phases
        #~(modify-phases %standard-phases
            (replace 'configure
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "BUILD.gn"
                  ;; As in Guix's skia: the zlib third_party target fails
                  ;; even when the system zlib is used.
                  (("deps = \\[ \"//third_party/zlib\" ]")
                   "deps = []"))
                ;; The flags of Ladybird's Flatpak build
                ;; (Meta/CMake/flatpak/skia/skia-configure.sh).
                (invoke "gn" "gen" "out"
                        (string-append
                         "--args="
                         "cc=\"" #$(cc-for-target) "\" "
                         "cxx=\"" #$(cxx-for-target) "\" "
                         "is_official_build=true "
                         "is_component_build=true "
                         "is_debug=false "
                         "skia_use_dng_sdk=false "
                         "skia_use_wuffs=false "
                         "skia_use_zlib=true "
                         "skia_use_system_zlib=true "
                         "skia_use_harfbuzz=true "
                         "skia_use_vulkan=true "
                         "skia_vulkan_memory_allocator_dir=\""
                         (dirname (dirname (search-input-file
                                            inputs "include/vk_mem_alloc.h")))
                         "\" "
                         "skia_use_fontconfig=true "
                         "skia_use_icu=true "
                         "skia_use_system_icu=true "
                         (format #f "extra_cflags=[\"-I~a\",\"-I~a\",~
\"-DSK_USE_EXTERNAL_VULKAN_HEADERS\",\"-Wno-psabi\"] "
                                 (search-input-directory inputs
                                                         "include/harfbuzz")
                                 (search-input-directory inputs
                                                         "include/freetype2"))
                         "extra_cflags_cc=[\"-DSKCMS_DLL\","
                         "\"-USK_HIDE_PATH_EDIT_METHODS\"] "
                         "extra_ldflags=[\"-Wl,-rpath=" #$output "/lib\"]"))))
            (replace 'build
              (lambda* (#:key parallel-build? #:allow-other-keys)
                (invoke "ninja" "-j"
                        (if parallel-build?
                            (number->string (parallel-job-count))
                            "1")
                        "-C" "out" ":skia" ":modules")))
            (replace 'install
              ;; Like Meta/CMake/flatpak/skia/skia-install.sh: Ladybird
              ;; includes <core/SkCanvas.h>, Skia's own headers include
              ;; "include/core/...", so put both directories on the path.
              (lambda _
                (let ((inc (string-append #$output "/include/skia"))
                      (lib (string-append #$output "/lib")))
                  (for-each (lambda (h)
                              (install-file h (string-append
                                               inc "/" (dirname h))))
                            (append (find-files "include" "\\.h$")
                                    (find-files "modules" "\\.h$")
                                    (find-files "src" "\\.h$")))
                  (for-each (lambda (l) (install-file l lib))
                            (find-files "out" "^lib.*\\.(so|a)$"))
                  (mkdir-p (string-append lib "/pkgconfig"))
                  (call-with-output-file
                      (string-append lib "/pkgconfig/skia.pc")
                    (lambda (port)
                      (format port "prefix=~a
exec_prefix=${prefix}
libdir=${prefix}/lib
includedir=${prefix}/include/skia

Name: skia
Description: 2D graphic library for drawing text, geometries and images.
URL: https://skia.org/
Version: 148
Libs: -L${libdir} -lskia -lskcms
Cflags: -I${includedir} -I${includedir}/include~%" #$output)))))))))
      (native-inputs (list gn ninja pkg-config python-wrapper))
      (inputs (list expat fontconfig freetype harfbuzz icu4c-78 libjpeg-turbo
                    libpng-apng-next libwebp mesa vulkan-headers
                    vulkan-memory-allocator zlib))
      (synopsis "2D graphics library (version for Ladybird)"))))

;; Inputs for the CMake build of ANGLE that vcpkg uses
;; (Meta/CMake/vcpkg/overlay-ports/angle/portfile.cmake).
(define %webkit-angle-commit "0742522b24152262b04913242cb0b3c48de92ba0")

(define %webkit-gni-to-cmake
  (origin
    (method url-fetch)
    (uri (string-append "https://github.com/WebKit/WebKit/raw/"
                        %webkit-angle-commit
                        "/Source/ThirdParty/ANGLE/gni-to-cmake.py"))
    (file-name "webkit-angle-gni-to-cmake.py")
    (sha256
     (base32 "1gb8c7z7v0sciak5alx7d4qmpvwy3ipmwmg0jlc5cafayycp0zv8"))))

(define %webkit-angle-include-cmakelists
  (origin
    (method url-fetch)
    (uri (string-append "https://github.com/WebKit/WebKit/raw/"
                        %webkit-angle-commit
                        "/Source/ThirdParty/ANGLE/include/CMakeLists.txt"))
    (file-name "webkit-angle-include-CMakeLists.txt")
    (sha256
     (base32 "0xs4np5b9hrk7s71al66v0ghcq1dab8wf0g5ci9q0h44ai9mi1f7"))))

(define %chromium-zlib
  ;; Only google/compression_utils_portable.{h,cc} are used, against the
  ;; system zlib.
  (let ((commit "4028ebf8710ee39d2286cb0f847f9b95c59f84d8"))
    (origin
      (method git-fetch)
      (uri (git-reference
            (url "https://chromium.googlesource.com/chromium/src/third_party/zlib")
            (commit commit)))
      (file-name (git-file-name "chromium-zlib" (string-take commit 7)))
      (sha256
       (base32 "017v4h2698csjjg598wp2zw5gd1d9zwb0z7fdig01qj7p4i0hi9h")))))

;; vcpkg.json: "angle" chromium_7258.  Not in Guix.
(define angle-for-ladybird
  (let ((commit "d9fc4a372074b1079c193c422fc4a180e79b6636") ;chromium/7258
        (revision "0"))
    (package
      (name "angle-for-ladybird")
      (version (git-version "7258" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/google/angle")
                      (commit commit)))
                (file-name (git-file-name "angle" version))
                (sha256
                 (base32
                  "11zn62pvnfl4d0kd00a1npf2ff898d4dbd0y5plqnmnxvrhihgab"))))
      (build-system cmake-build-system)
      (arguments
       (list
        #:tests? #f
        #:build-type "Release"
        #:configure-flags
        #~(list "-DANGLE_IS_64_BIT_CPU=1"
                "-DPORT=Linux"
                "-DANGLE_USE_D3D11_COMPOSITOR_NATIVE_WINDOW=OFF"
                "-DVCPKG_TARGET_IS_WINDOWS=OFF"
                "-DUSE_METAL=OFF"
                "-DBUILD_SHARED_LIBS=ON"
                "-DCMAKE_CXX_FLAGS=-DUSE_SYSTEM_ZLIB"
                ;; ANGLE's GL backend dlopen()s libEGL.so.1 / libGL.so.1.
                (string-append "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath="
                               #$(this-package-input "mesa") "/lib"))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'add-cmake-buildsystem
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((port #$(ladybird-file
                               "Meta/CMake/vcpkg/overlay-ports/angle"))
                      (short #$(string-take commit 12)))
                  (for-each (lambda (patch)
                              (invoke "patch" "-p1" "-i"
                                      (string-append port "/" patch)))
                            '("001-fix-builder-error.patch"
                              "002-bsd-support.patch"))
                  (for-each
                   (lambda (dir)
                     (call-with-output-file
                         (string-append dir "angle_commit.h")
                       (lambda (p)
                         (format p "#define ANGLE_COMMIT_HASH ~s
#define ANGLE_COMMIT_HASH_SIZE 12
#define ANGLE_COMMIT_DATE \"invalid-date\"
#define ANGLE_REVISION 7258~%" short)))
                     (call-with-output-file
                         (string-append dir "ANGLEShaderProgramVersion.h")
                       (lambda (p)
                         (format p "#define ANGLE_PROGRAM_VERSION ~s
#define ANGLE_PROGRAM_VERSION_HASH_SIZE 12~%" short))))
                   '("" "src/common/"))
                  (copy-file (string-append port
                                            "/unofficial-angle-config.cmake")
                             "unofficial-angle-config.cmake")
                  ;; Generate CMake lists from the GN files.
                  (for-each
                   (lambda (args)
                     (apply invoke "python3" #$%webkit-gni-to-cmake args))
                   '(("src/compiler.gni" "Compiler.cmake")
                     ("src/libGLESv2.gni" "GLESv2.cmake")
                     ("src/libANGLE/renderer/d3d/BUILD.gn" "D3D.cmake"
                      "--prepend" "src/libANGLE/renderer/d3d/")
                     ("src/libANGLE/renderer/gl/BUILD.gn" "GL.cmake"
                      "--prepend" "src/libANGLE/renderer/gl/")
                     ("src/libANGLE/renderer/metal/BUILD.gn" "Metal.cmake"
                      "--prepend" "src/libANGLE/renderer/metal/")))
                  (copy-file #$%webkit-angle-include-cmakelists
                             "include/CMakeLists.txt")
                  (for-each (lambda (f)
                              (copy-file f (basename f)))
                            (find-files (string-append port
                                                       "/cmake-buildsystem")
                                        "(CMakeLists\\.txt|\\.cmake)$"
                                        #:directories? #f))
                  (mkdir-p "cmake")
                  (for-each (lambda (f)
                              (copy-file f (string-append "cmake/"
                                                          (basename f))))
                            (find-files (string-append
                                         port "/cmake-buildsystem/cmake")
                                        "\\.cmake$"))
                  ;; The cmake/ modules were copied to the top too; remove
                  ;; those strays.
                  (for-each (lambda (f)
                              (when (file-exists? f) (delete-file f)))
                            (map basename
                                 (find-files (string-append
                                              port "/cmake-buildsystem/cmake")
                                             "\\.cmake$")))
                  (mkdir-p "third_party/zlib/google")
                  (for-each
                   (lambda (f)
                     (copy-file
                      (string-append #$%chromium-zlib "/google/" f)
                      (string-append "third_party/zlib/google/" f)))
                   '("compression_utils_portable.h"
                     "compression_utils_portable.cc"))
                  ;; vcpkg takes the Khronos headers from the egl-registry
                  ;; and opengl-registry ports; install ANGLE's own copies.
                  (substitute* "CMakeLists.txt"
                    (("^ *PATTERN \"(EGL|GLES|GLES2|GLES3)/[a-z0-9]+\\.h\" EXCLUDE\n")
                     "")
                    (("^ *PATTERN \"KHR\" EXCLUDE\n") ""))))))))
      (native-inputs (list pkg-config python-wrapper python-ply))
      (inputs (list libdrm libx11 libxext mesa zlib))
      (home-page "https://chromium.googlesource.com/angle/angle")
      (synopsis "OpenGL ES implementation on top of desktop OpenGL")
      (description
       "ANGLE (Almost Native Graphics Layer Engine) implements OpenGL ES and
EGL on top of other graphics APIs.  This build, made with the CMake build
system Ladybird uses, provides the OpenGL backend only.")
      (license license:bsd-3))))

;; vcpkg.json: "ffmpeg" 9.0.2 with "ladybird-components": only the decoders
;; LibMedia uses, with a -ladybird library suffix and own symbol versions so
;; that a system FFmpeg can be loaded next to it.  Guix has 8.1.2.
(define ffmpeg-for-ladybird
  (package
    (name "ffmpeg-for-ladybird")
    (version "9.0.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://ffmpeg.org/releases/ffmpeg-"
                                  version ".tar.xz"))
              (sha256
               (base32
                "0bh0dslibv4vhjh83vq9gcs1ggp0a50a0y1090ka0pxj7ql50f4c"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f                       ;the FATE suite needs samples
      #:configure-flags
      #~(list "--enable-shared" "--disable-static" "--enable-pic"
              "--disable-doc" "--enable-runtime-cpudetect"
              "--disable-autodetect" "--build-suffix=-ladybird"
              "--disable-everything" "--disable-network"
              "--disable-programs"
              "--enable-avcodec" "--disable-avdevice" "--disable-avformat"
              "--disable-avfilter" "--enable-swresample" "--disable-swscale"
              "--enable-libdav1d" "--enable-zlib" "--enable-vulkan"
              "--enable-libdrm"
              (string-append "--enable-decoder=vp8,vp9,av1,libdav1d,theora,"
                             "vorbis,opus,flac,mp3float,pcm_u8,pcm_s16le,"
                             "pcm_s24le,pcm_s32le,pcm_f32le,pcm_alaw,"
                             "pcm_mulaw")
              "--enable-hwaccel=vp9_vulkan,av1_vulkan"
              "--enable-parser=vp8,vp9,av1,mpegaudio"
              (string-append "--extra-ldflags=-Wl,-rpath=" #$output "/lib"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'apply-ladybird-patch
            (lambda _
              (invoke "patch" "-p1" "-i"
                      #$(ladybird-file
                         "Meta/CMake/vcpkg/overlay-ports/ffmpeg/\
0100-ladybird-symbol-version-nodes.patch"))))
          (replace 'configure
            ;; FFmpeg's configure is not Autoconf's.
            (lambda* (#:key configure-flags #:allow-other-keys)
              (substitute* "configure"
                (("#! */bin/sh") (string-append "#!" (which "sh"))))
              (setenv "SHELL" (which "bash"))
              (setenv "CONFIG_SHELL" (which "bash"))
              (apply invoke "./configure"
                     (string-append "--prefix=" #$output)
                     configure-flags))))))
    (native-inputs (list nasm pkg-config))
    (inputs (list dav1d libdrm vulkan-headers vulkan-loader zlib))
    (home-page "https://ffmpeg.org/")
    (synopsis "Audio and video decoders of FFmpeg, for Ladybird")
    (description
     "This is a minimal build of FFmpeg's libavcodec, libavutil and
libswresample with only the decoders the Ladybird browser uses.  Its
libraries carry a @code{-ladybird} suffix.")
    (license license:lgpl2.1+)))

;; QUIC for curl's HTTP/3, with OpenSSL (3.5 has the QUIC API ngtcp2 needs);
;; Guix's ngtcp2 only has the GnuTLS crypto backend.
(define ngtcp2-for-ladybird
  (package
    (inherit ngtcp2)
    (name "ngtcp2-for-ladybird")
    (arguments
     (list #:configure-flags
           #~(list "--with-openssl" "--without-gnutls" "--disable-static")))
    (inputs (list openssl))
    (properties '((hidden? . #t)))))

;; vcpkg.json: "curl" with the "openssl", "http2", "http3", "brotli",
;; "zstd" and "websockets" features.  Guix's curl uses GnuTLS, which lacks
;; CURLOPT_SSL_CTX_FUNCTION (Ladybird configures OpenSSL through it) and has
;; no HTTP/3.
(define curl-for-ladybird
  (package
    (inherit curl)
    (name "curl-for-ladybird")
    (arguments
     (substitute-keyword-arguments (package-arguments curl)
       ((#:configure-flags _)
        #~(list "--with-openssl" "--with-ngtcp2" "--with-nghttp2"
                "--with-nghttp3" "--with-brotli" "--with-zstd"
                "--with-libpsl" "--without-gssapi" "--disable-static"))
       ;; The test suite takes long and is run for Guix's curl already.
       ((#:tests? _ #t) #f)))
    (inputs (list brotli libidn2 libpsl `(,nghttp2 "lib") nghttp3
                  ngtcp2-for-ladybird openssl zlib `(,zstd "lib")))
    (properties '((hidden? . #t)))))

;; vcpkg.json: "simdjson" 5.0.2.  Guix has 4.6.3.
(define simdjson-for-ladybird
  (package
    (inherit simdjson)
    (name "simdjson")
    (version "5.0.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/simdjson/simdjson")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0ckfj7p9a05r6lyz1hm71jv2g2prw676m2ahnhja1b1yz2a2absq"))))
    (properties '((hidden? . #t)))))

;; vcpkg.json: "mimalloc" 2.2.7.  Guix has 3.5.3, whose heap API differs.
(define mimalloc-for-ladybird
  (package
    (inherit mimalloc)
    (name "mimalloc")
    (version "2.2.7")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/microsoft/mimalloc")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0gdsf5n44kad22x53nkrm6p237s3kwqmr8chjmdl94866wwqrnng"))))
    (arguments
     ;; The options of Ladybird's Flatpak build.
     (list #:build-type "Release"
           #:configure-flags
           #~(list "-DMI_BUILD_OBJECT=OFF" "-DMI_BUILD_TESTS=OFF"
                   "-DMI_BUILD_STATIC=OFF" "-DMI_BUILD_SHARED=ON"
                   "-DMI_INSTALL_TOPLEVEL=ON" "-DMI_OVERRIDE=OFF"
                   "-DMI_SECURE=ON" "-DMI_USE_CXX=ON")
           #:tests? #f))
    (properties '((hidden? . #t)))))

;; vcpkg.json: "zmij" 1.2.  Not in Guix.
(define zmij
  (package
    (name "zmij")
    (version "1.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/vitaut/zmij")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1hdiaqpa5300i5iwch4sfszim83fp1gj9ilcwh9d5jwdwcm6knns"))))
    (build-system cmake-build-system)
    (arguments
     (list #:tests? #f
           #:configure-flags
           #~(list "-DBUILD_SHARED_LIBS=ON" "-DZMIJ_TEST=OFF"
                   "-DZMIJ_EXAMPLE=OFF")))
    (home-page "https://github.com/vitaut/zmij")
    (synopsis "Fast floating-point to string conversion")
    (description
     "Zmij is a C and C++ library that converts double-precision and
single-precision floating-point numbers to their shortest decimal string
representation.")
    (license license:expat)))

;; vcpkg.json: "wuffs" 0.3.5 (the single-file C release).  Guix has
;; 0.4.0-alpha, which does not ship wuffs-v0.3.c.
(define wuffs-0.3
  (package
    (name "wuffs")
    (version "0.3.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/google/wuffs-mirror-release-c")
                    (commit (string-append "v" version))))
              (file-name (git-file-name "wuffs-mirror-release-c" version))
              (sha256
               (base32
                "14w3wa1r7h4gsd9rhaina6p7hj292590fdd7g798j9fd4rl81jq0"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan
           #~'(("release/c/wuffs-v0.3.c" "include/wuffs/"))))
    (home-page "https://github.com/google/wuffs")
    (synopsis "Memory-safe file format decoders as a single C file")
    (description
     "Wuffs (Wrangling Untrusted File Formats Safely) is a collection of
image and data format decoders.  This is the single-file C release of its
0.3 series.")
    (license license:asl2.0)))

;; vcpkg.json: "pdfjs" 6.4.299.  This is Mozilla's release build (generated
;; JavaScript), patched for Ladybird as the vcpkg overlay port does.
(define pdfjs-for-ladybird
  (package
    (name "pdfjs-for-ladybird")
    (version "6.4.299")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/mozilla/pdf.js/"
                                  "releases/download/v" version
                                  "/pdfjs-" version "-dist.zip"))
              (sha256
               (base32
                "0vfqxf9pyc4fbpji6ih3bi7qf5gcpxvs2s755y3lqrrzxyvmw97j"))))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((share (string-append #$output "/share/pdfjs")))
            (setenv "PATH" (string-append #$(this-package-native-input "unzip")
                                          "/bin:"
                                          #$(this-package-native-input "patch")
                                          "/bin"))
            (mkdir "src")
            (chdir "src")
            (invoke "unzip" "-q" #$source)
            (invoke "patch" "-p1" "-i"
                    #$(ladybird-file "Meta/CMake/vcpkg/overlay-ports/pdfjs/\
0001-ladybird-embed.patch"))
            (for-each (lambda (f) (install-file f (string-append share "/build")))
                      (find-files "build" "\\.mjs$"))
            (for-each (lambda (f) (install-file f (string-append share "/web")))
                      '("web/viewer.html" "web/viewer.mjs" "web/viewer.css"))
            (copy-recursively "web/images" (string-append share "/web/images"))
            (install-file "web/locale/en-US/viewer.ftl"
                          (string-append share "/web/locale/en-US"))
            (call-with-output-file (string-append share "/web/locale/locale.json")
              (lambda (port)
                (display "{\"en-us\":\"en-US/viewer.ftl\"}" port)))))))
    (native-inputs (list patch unzip))
    (home-page "https://mozilla.github.io/pdf.js/")
    (synopsis "PDF viewer in JavaScript, as embedded by Ladybird")
    (description
     "PDF.js renders PDF documents with HTML5 and JavaScript.  This package
holds the viewer files Ladybird embeds.")
    (license license:asl2.0)))

;; HSTS preload list, otherwise downloaded at configure time (the Chromium
;; revision Ladybird's Flatpak manifest pins).
(define %hsts-preload-list
  (origin
    (method url-fetch)
    (uri (string-append "https://raw.githubusercontent.com/chromium/chromium/"
                        "aa04f175415addb04bb78936b0d8b973fbd8ea61"
                        "/net/http/transport_security_state_static.json"))
    (file-name "chromium-transport_security_state_static-aa04f17.json")
    (sha256
     (base32 "0qz11ra9f2cncmmydnzdzpwvi7vmgwsvsdy3dcj9i8bi2l2hz9sc"))))


;;;
;;; Ladybird.
;;;

(define-public ladybird
  (package
    (name "ladybird")
    (version (git-version "0.0.0" "0" %ladybird-commit))
    ;; Patched here, not in %ladybird-source: Skia and ANGLE take patches
    ;; from that tree and would be rebuilt.
    (source (origin
              (inherit %ladybird-source)
              (patches
               (list (local-file "aux-files/ladybird-qt-6.9-contrast.patch")))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f                       ;BUILD_TESTING=OFF
      #:build-type "Release"
      ;; Upstream builds with Ninja; with Make, code generators race
      ;; with the creation of their output directories.
      #:generator "Ninja"
      #:modules '((guix build cmake-build-system)
                  (guix build utils)
                  (ice-9 popen)
                  (ice-9 rdelim)
                  (srfi srfi-1))
      #:configure-flags
      #~(list "-DBUILD_TESTING=OFF"
              "-DENABLE_NETWORK_DOWNLOADS=OFF"
              "-DENABLE_LAGOM_CCACHE=OFF"
              "-DENABLE_LTO_FOR_RELEASE=OFF"
              "-DENABLE_INSTALL_HEADERS=OFF"
              "-DENABLE_INSTALL_FREEDESKTOP_FILES=ON"
              "-DCMAKE_SKIP_RPATH=OFF"
              (string-append "-DCMAKE_INSTALL_RPATH=" #$output "/lib")
              (string-append "-DICU_ROOT=" #$(this-package-input "icu4c"))
              ;; Load the APNG-enabled libpng before Qt's plain one: both
              ;; have the same soname, and only the first loaded is used.
              ;; Shared libraries need it too: otherwise ld resolves
              ;; liblagom-gfx's libpng16.so.16 through another library's
              ;; RUNPATH to the plain 1.6.39, which lacks png_set_cICP.
              #$@(let ((flags #~(string-append
                                 "-Wl,--no-as-needed -L"
                                 #$(this-package-input "libpng-apng")
                                 "/lib -Wl,-rpath-link,"
                                 #$(this-package-input "libpng-apng")
                                 "/lib -lpng16 -Wl,--as-needed")))
                   (list #~(string-append "-DCMAKE_EXE_LINKER_FLAGS=" #$flags)
                         #~(string-append "-DCMAKE_SHARED_LINKER_FLAGS="
                                          #$flags))))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-sources
            (lambda* (#:key inputs #:allow-other-keys)
              ;; Don't build for the CPU of the build machine.
              (substitute* "Meta/CMake/compile_options.cmake"
                (("add_cxx_compile_options\\(-march=native\\)") "")
                (("set\\(RUSTC_TARGET_CPU_FLAGS -Ctarget-cpu=native\\)") ""))
              ;; WebGLCommands.h includes the generated GLFunctions.h, but
              ;; nothing makes LibCompositing wait for it.
              (substitute* "Libraries/LibCompositing/CMakeLists.txt"
                (("^ladybird_lib\\(LibCompositing .*" all)
                 (string-append
                  all "add_dependencies(LibCompositing "
                  "generate_GLFunctions.cpp)\n")))
              ;; Guix has Qt 6.9; nothing used needs 6.10.
              (substitute* "UI/Qt/CMakeLists.txt"
                (("Qt6 6\\.10") "Qt6 6.9"))
              ;; The Landlock sandbox of the Compositor and the video decoder
              ;; allows the FHS library and data directories, plus the
              ;; directories of the libraries loaded so far and the files
              ;; that the GPU loader manifests name.  On Guix, drivers load
              ;; their own dependencies (libnvidia-glsi, LLVM, zstd...) and
              ;; read manifests, fontconfig files and fonts from other store
              ;; items, all reached through profile symlinks; without this
              ;; Vulkan instance creation fails and painting falls back to
              ;; the CPU.  The store is world-readable and immutable.
              (substitute* "Libraries/LibSandbox/GpuDriverPaths.cpp"
                (("^( *)TRY\\(add_landlock_path_if_exists\\(paths, \"/usr/local/lib\"sv, .*" all indent)
                 (string-append all indent
                                "TRY(add_landlock_path_if_exists(paths, \""
                                (%store-directory)
                                "\"sv, LandlockPath::Access::ReadOnly));\n")))
              ;; No .git in the checkout.
              (substitute* "Meta/Generators/generate-build-information.py"
                (("revision, state = git_revision\\(source\\)")
                 (string-append "revision, state = \""
                                #$%ladybird-commit "\", \"clean\"")))
              ;; Use the pdf.js viewer from its own package (vcpkg only).
              (substitute* "UI/cmake/ResourceFiles.cmake"
                (("if \\(NOT \"\\$\\{VCPKG_INSTALLED_DIR\\}\" STREQUAL \"\" .*")
                 "if (TRUE)\n")
                (("set\\(_pdfjs_vcpkg_dir .*")
                 (string-append "set(_pdfjs_vcpkg_dir \""
                                #$(this-package-input "pdfjs-for-ladybird")
                                "/share/pdfjs\")\n")))
              ;; Downloaded at configure time otherwise; this is the
              ;; default LADYBIRD_CACHE_DIR.
              (mkdir-p "Build/caches/HSTSPreload")
              (copy-file #$%hsts-preload-list
                         (string-append "Build/caches/HSTSPreload/"
                                        "transport_security_state_static.json"))))
          (add-after 'patch-sources 'vendor-rust-crates
            ;; Set up a vendored crate directory as `cargo vendor' would,
            ;; keeping Cargo.lock (CMake looks for it, and its checksums
            ;; must match the vendored crates').
            (lambda _
              (let ((vendor (string-append (getcwd) "/../guix-vendor")))
                (mkdir-p vendor)
                (for-each
                 (lambda (crate)
                   (let* ((base (strip-store-file-name crate))
                          (dir (string-append
                                vendor "/"
                                (string-drop-right
                                 (string-drop base (string-length "rust-"))
                                 (string-length ".tar.gz"))))
                          (sum (let* ((pipe (open-pipe* OPEN_READ
                                                        "sha256sum" crate))
                                      (line (read-line pipe)))
                                 (close-pipe pipe)
                                 (car (string-split line #\space)))))
                     (mkdir-p dir)
                     (invoke "tar" "xf" crate "-C" dir
                             "--strip-components" "1")
                     (call-with-output-file
                         (string-append dir "/.cargo-checksum.json")
                       (lambda (port)
                         (format port "{\"files\":{},\"package\":~s}" sum)))))
                 (list #$@ladybird-cargo-inputs))
                (setenv "CARGO_HOME" (string-append (getcwd) "/../cargo-home"))
                (mkdir-p (getenv "CARGO_HOME"))
                (call-with-output-file
                    (string-append (getenv "CARGO_HOME") "/config.toml")
                  (lambda (port)
                    (format port "[source.crates-io]
replace-with = 'vendored-sources'

[source.vendored-sources]
directory = '~a'

[net]
offline = true~%" vendor))))))
          (add-after 'set-paths 'hide-default-gcc
            ;; Use GCC 15's libstdc++ headers, not the default GCC's.
            ;; (Upstream's CI uses GCC 16, but Guix's gcc-16 has a libstdc++
            ;; configured without C99 math: _GLIBCXX11_USE_C99_MATH is
            ;; undefined, so <cmath> leaves the C 'signbit' etc. macros in
            ;; place and Ladybird fails to build.)
            (lambda _
              (setenv "CPLUS_INCLUDE_PATH"
                      (string-join
                       (remove (lambda (dir)
                                 (and (string-suffix? "/include/c++" dir)
                                      (not (string-prefix? #$gcc-15 dir))))
                               (string-split (getenv "CPLUS_INCLUDE_PATH")
                                             #\:))
                       ":"))))
          (add-after 'install 'remove-commit-file
            ;; Meant for upstream's release tarballs of the js and wasm tools.
            (lambda _
              (delete-file (string-append #$output "/COMMIT"))))
          (add-after 'install 'wrap-program
            (lambda _
              (wrap-program (string-append #$output "/bin/Ladybird")
                `("QT_PLUGIN_PATH" prefix
                  (,(string-append #$(this-package-input "qtwayland")
                                   "/lib/qt6/plugins")))))))))
    (native-inputs
     (list gcc-15
           `(,rust-1.96 "cargo")
           rust-1.96
           git-minimal
           glslang
           ninja
           pkg-config
           python-wrapper))
    (inputs
     (list angle-for-ladybird
           bash-minimal
           brotli
           cpptrace
           curl-for-ladybird
           dav1d
           fast-float
           ffmpeg-for-ladybird
           fontconfig
           freetype
           glib
           harfbuzz
           icu4c-78
           libavif
           libdrm
           libedit
           libjpeg-turbo
           libpng-apng-next
           libpsl
           libtommath
           libwebp
           libxml2
           mimalloc-for-ladybird
           openssl
           pdfjs-for-ladybird
           pulseaudio
           qtbase
           qtpositioning
           qtwayland
           sdl3
           simdjson-for-ladybird
           simdutf
           skia-for-ladybird
           sqlite-next
           vulkan-headers
           vulkan-loader
           vulkan-memory-allocator
           woff2
           wuffs-0.3
           xcb-util-wm
           zlib
           zmij
           `(,zstd "lib")))
    (home-page "https://ladybird.org")
    (synopsis "Independent web browser")
    (description
     "Ladybird is a web browser built on a new engine of its own, following
web standards rather than reusing code from other browsers.  It is in an
early stage of development (pre-alpha).  This package provides its Qt user
interface.")
    (license license:bsd-2)))
