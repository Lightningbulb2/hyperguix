;;; Lightningbulb channel --- Strata, local inference for large language models
;;;
;;; The `strata' command (Python) and its C++/CUDA engine, built for compute
;;; capability 8.6 like llama-cpp-cuda.  Upstream's desktop app (Tauri) and
;;; the picture reader (strata-vision) are not built.
;;;
;;; The engine is installed as a Strata "component": a folder whose manifest
;;; records the hash of every file, so the files must not change after
;;; packaging, hence no stripping here.  Grafts still rewrite it, so the
;;; launcher copies the engine into $XDG_DATA_HOME/strata/components and
;;; recomputes its manifest there (aux-files/strata-seed-components.py).
;;; Models and settings stay in the user's own XDG folders.

(define-module (Lightningbulb packages strata)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages check)
  #:use-module (gnu packages time)
  #:use-module (Lightningbulb packages cuda))

;; LLAMA_CPP_COMMIT in setup.py: Strata builds ggml from this checkout.
(define %strata-llama-cpp
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/ggml-org/llama.cpp")
          (commit "3cf03257f219afbe7334045ff7c6a06ac68c627d")))
    (file-name "strata-llama-cpp-3cf0325-checkout")
    (sha256
     (base32 "10hr8pkszphsylrg3j055pb0s4v2qpaip6kp0x12005qmxfsh4a9"))))

(define-public strata
  (let ((commit "146df3c468739147f520ac3816de806f71232571")
        (revision "0")
        (engine-version "0.1.58"))
    (package
      (name "strata")
      (version (git-version "0.2.12" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Niko1221/Strata")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0nhik4qi9mp496jmk9shahwsk1c8g00yacgdxj75pnpbd93cdj48"))))
      (build-system cmake-build-system)
      (arguments
       (list
        #:tests? #f
        #:strip-binaries? #f            ;see above
        #:validate-runpath? #f          ;libcuda.so.1 is the driver's
        #:generator "Ninja"
        #:build-type "Release"
        #:configure-flags
        #~(list "-DSTRATA_ENABLE_CUDA=ON"
                "-DSTRATA_BUILD_TESTS=OFF"
                "-DSTRATA_NATIVE_EXPERTS=ON"
                "-DSTRATA_PORTABLE=ON"  ;no -march=native
                "-DSTRATA_Q6K_EXPERTS=ON"
                "-DSTRATA_MMQ_KQUANTS=ON"
                "-DCMAKE_CUDA_ARCHITECTURES=86-real;86-virtual"
                (string-append "-DCUDAToolkit_ROOT="
                               #$(this-package-input "cuda-toolkit"))
                (string-append "-DSTRATA_GGML_DIR=" (getcwd)
                               "/source/third_party/llama.cpp"))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'unpack-llama-cpp
              (lambda _
                (copy-recursively #$%strata-llama-cpp
                                  "third_party/llama.cpp")))
            (replace 'build
              (lambda* (#:key parallel-build? #:allow-other-keys)
                (invoke "cmake" "--build" "." "--target" "strata" "strata_kq"
                        "-j" (if parallel-build?
                                 (number->string (parallel-job-count))
                                 "1"))))
            (replace 'install
              (lambda* (#:key inputs #:allow-other-keys)
                (let* ((lib (string-append #$output "/lib/strata"))
                       (source "../source")
                       (stage "engine-stage")
                       (runpath
                        (string-append
                         #$output "/lib/strata:"
                         #$(this-package-input "cuda-toolkit") "/lib:"
                         "/run/current-system/profile/lib:"
                         (dirname (search-input-file inputs
                                                     "lib/libstdc++.so")))))
                  (mkdir-p stage)
                  (for-each (lambda (file) (install-file file stage))
                            (cons "strata" (find-files "." "^libstrata_kq.*\\.so")))
                  (for-each (lambda (file)
                              (invoke "patchelf" "--set-rpath" runpath file))
                            (find-files stage))
                  (call-with-output-file (string-append stage "/BUILD.json")
                    (lambda (port)
                      (format port "{\"version\": ~s, \"source\": \"guix\", \
\"archs\": \"86\", \"portable\": true}\n" #$engine-version)))
                  ;; The Python programs.
                  (mkdir-p lib)
                  (for-each
                   (lambda (item)
                     (let ((from (string-append source "/" item))
                           (to (string-append lib "/" item)))
                       (if (file-is-directory? from)
                           (copy-recursively from to)
                           (install-file from lib))))
                   '("strata.py" "setup.py" "strata_control" "strata_cli"
                     "serve" "tools" "data" "docs"))
                  ;; The engine, as a component of the expected layout.
                  (invoke "python3"
                          (string-append source "/packaging/package_engine.py")
                          "--src" stage
                          "--backend" "cuda"
                          "--version" #$engine-version
                          "--out" (string-append lib "/components/engine")
                          "--arch" "sm_86" "--arch" "compute_86"
                          "--min-driver" "nvidia=580.65"
                          "--variant" "cuda13"
                          "--platform" "linux-x86_64"
                          "--build-id" #$(string-append "guix-" commit)
                          "--allow-lib" "libcuda.so.1"
                          "--allow-lib" "libcublas.so.13"
                          "--allow-lib" "libcublasLt.so.13"
                          "--allow-lib" "libcudart.so.13"
                          "--include" "libstrata_kq*"))))
            (add-after 'install 'install-launcher
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((bin (string-append #$output "/bin/strata"))
                      (lib (string-append #$output "/lib/strata")))
                  (copy-file #$(local-file
                                "aux-files/strata-seed-components.py")
                             (string-append lib "/strata-seed-components.py"))
                  (mkdir-p (dirname bin))
                  ;; Everything Strata writes stays in the XDG folders:
                  ;; components and the install folder (and, by default,
                  ;; models) under $XDG_DATA_HOME/strata, settings under
                  ;; $XDG_CONFIG_HOME/strata.  The packaged engine is copied
                  ;; into the user's components folder, see
                  ;; strata-seed-components.py for why.
                  (call-with-output-file bin
                    (lambda (port)
                      (format port "#!~a
data=\"${XDG_DATA_HOME:-$HOME/.local/share}/strata\"
: \"${STRATA_INSTALL_DIR:=$data/install}\"
: \"${STRATA_COMPONENTS_DIR:=$data/components}\"
export STRATA_INSTALL_DIR STRATA_COMPONENTS_DIR
mkdir -p \"$STRATA_INSTALL_DIR\" \"$STRATA_COMPONENTS_DIR\"
~a -I ~a/strata-seed-components.py ~a/components \"$STRATA_COMPONENTS_DIR\"
exec ~a ~a/strata.py \"$@\"~%"
                              (search-input-file inputs "bin/bash")
                              (search-input-file inputs "bin/python3")
                              lib lib
                              (search-input-file inputs "bin/python3")
                              lib)))
                  (chmod bin #o755)
                  (wrap-program bin
                    `("GUIX_PYTHONPATH" ":" prefix (,(getenv "GUIX_PYTHONPATH"))))))))))
      (native-inputs (list ninja patchelf))
      (inputs
       (list `(,gcc "lib")
             bash-minimal
             cuda-toolkit
             python
             python-jinja2
             python-numpy
             python-pillow
             python-psutil
             python-pyyaml
             python-regex
             python-requests
             python-rich                ;the launch screens and monitor
             python-textual
             python-tqdm))
      (supported-systems '("x86_64-linux"))
      (home-page "https://github.com/Niko1221/Strata")
      (synopsis "Run large language models locally on NVIDIA GPUs")
      (description
       "Strata serves large language models from your own computer, with an
OpenAI- and Anthropic-compatible API and a web page.  This package has the
@command{strata} command and the CUDA engine for compute capability 8.6 GPUs,
without the desktop application.")
      (license license:expat))))

;; Kept apart from `strata' so that adding a menu entry does not rebuild the
;; CUDA engine.
(define-public strata-desktop
  (package
    (name "strata-desktop")
    (version "1")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:builder
      (with-imported-modules '((guix build utils))
        #~(begin
            (use-modules (guix build utils))
            (let ((dir (string-append #$output "/share/applications")))
              (mkdir-p dir)
              (call-with-output-file (string-append dir "/strata.desktop")
                (lambda (port)
                  (display "[Desktop Entry]
Type=Application
Name=Strata
GenericName=Local LLM Server
Comment=Set up, serve and monitor local language models
Exec=strata launch
Icon=utilities-terminal
Terminal=true
Categories=Development;Science;
Keywords=llm;ai;model;server;
" port))))))))
    (home-page "https://github.com/Niko1221/Strata")
    (synopsis "Application menu entry for Strata")
    (description
     "This adds Strata to the desktop's application list.  The entry opens a
terminal running @command{strata launch}, Strata's guided setup, serving and
monitoring screens.  Install it next to the @code{strata} package.")
    (license license:expat)))
