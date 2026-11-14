;;; hyperguix --- llama.cpp, newer than Guix's
;;;
;;; Guix's llama-cpp (0.7.0) is built against its separate ggml package, which
;;; would have to move in step with every llama.cpp release.  This one builds
;;; the ggml that llama.cpp carries in its own tree instead, with the backends
;;; Guix's ggml enables: Vulkan (NVIDIA, AMD and Intel GPUs through the
;;; driver's Vulkan ICD) and OpenBLAS on the CPU.  The backends are loaded at
;;; run time (GGML_BACKEND_DL) from lib/backends.
;;;
;;; Updating: change `version' (a vX.Y.Z tag), set the source hash to zeros
;;; and build once; `llama-cpp-ui-build' is the number in that release's
;;; nightly-tag.txt asset (https://github.com/ggml-org/llama.cpp/releases),
;;; whose prebuilt web UI the server embeds.

(define-module (hyperguix packages llama-cpp)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages machine-learning)
  #:use-module (gnu packages tls)
  #:use-module (hyperguix packages cuda))

(define llama-cpp-ui-build "12359")

(define llama-cpp-ui
  (origin
    (method url-fetch)
    (uri (string-append "https://github.com/ggml-org/llama.cpp/releases/download/b"
                        llama-cpp-ui-build "/llama-b" llama-cpp-ui-build
                        "-ui.tar.gz"))
    (file-name "ui.tar.gz")
    (sha256
     (base32 "10w6syfsg2fwqx9xvn0qbgmnscdc3amijfsnfy8l3nq8db4d0wp4"))))

(define-public llama-cpp/latest
  (package
    (inherit llama-cpp)
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ggml-org/llama.cpp")
             (commit (string-append "v" version))))
       (file-name (git-file-name "llama-cpp" version))
       (sha256
        (base32 "0c641dk1mhn0s6h5vl2fh2rhc4rnq3514h4anbxrixfaik0y5339"))))
    (arguments
     (substitute-keyword-arguments (package-arguments llama-cpp)
       ((#:configure-flags _)
        #~(list "-DBUILD_SHARED_LIBS=ON"
                "-DLLAMA_USE_SYSTEM_GGML=OFF"
                #$(string-append "-DLLAMA_BUILD_NUMBER=" llama-cpp-ui-build)
                "-DGGML_BACKEND_DL=ON"
                (string-append "-DGGML_BACKEND_DIR=" #$output "/lib/backends")
                "-DGGML_VULKAN=ON"
                "-DGGML_NATIVE=OFF"     ;no '-march=native'
                "-DGGML_CPU_ALL_VARIANTS=ON"
                "-DGGML_BLAS=ON"
                "-DGGML_BLAS_VENDOR=OpenBLAS"))
       ((#:phases phases)
        #~(modify-phases #$phases
            (replace 'get-ui
              (lambda _
                (with-directory-excursion "tools/ui"
                  (invoke "tar" "xf" #$(this-package-input "ui.tar.gz"))
                  (rename-file #$(string-append "llama-b" llama-cpp-ui-build)
                               "dist"))))))))
    (inputs
     (modify-inputs (package-inputs ggml)
       (append openssl llama-cpp-ui)))
    (native-inputs (package-native-inputs ggml))
    (synopsis "LLM inference in C/C++ (llama.cpp), with GPU support")
    (description "llama.cpp runs large language models in the GGUF format:
@command{llama-cli} for chat, @command{llama-server} for an OpenAI-compatible
HTTP API with a web UI, and tools to quantize, benchmark and convert models.
This build includes the Vulkan backend (GPU) and OpenBLAS (CPU).")))

;;; With the CUDA backend too (NVIDIA GPUs), built for compute capability 8.6
;;; (RTX 30 series: the 3060 Ti); for other cards change
;;; CMAKE_CUDA_ARCHITECTURES (8.9 for RTX 40, 12.0 for RTX 50; a list such as
;;; "86;89" builds for several, at a cost in build time).  At run time the
;;; backend takes libcuda from the NVIDIA driver in the system profile.
(define-public llama-cpp-cuda
  (package
    (inherit llama-cpp/latest)
    (name "llama-cpp-cuda")
    (arguments
     (substitute-keyword-arguments (package-arguments llama-cpp/latest)
       ((#:configure-flags flags)
        #~(append #$flags
                  (list "-DGGML_CUDA=ON"
                        "-DCMAKE_CUDA_ARCHITECTURES=86"
                        (string-append "-DCUDAToolkit_ROOT="
                                       #$(this-package-input "cuda-toolkit")))))
       ;; libcuda.so.1 is the driver's, outside the store.
       ((#:validate-runpath? _ #f) #f)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'install 'find-cuda-libraries
              (lambda _
                (for-each
                 (lambda (library)
                   (invoke "patchelf" "--add-rpath"
                           (string-append #$(this-package-input "cuda-toolkit")
                                          "/lib:/run/current-system/profile/lib")
                           library))
                 (find-files (string-append #$output "/lib/backends")
                             "libggml-cuda.*\\.so$"))))))))
    (inputs
     (modify-inputs (package-inputs llama-cpp/latest)
       (append cuda-toolkit)))
    (native-inputs
     (modify-inputs (package-native-inputs llama-cpp/latest)
       (append patchelf)))
    (synopsis "LLM inference in C/C++ (llama.cpp), with CUDA and Vulkan")
    (description "llama.cpp runs large language models in the GGUF format:
@command{llama-cli} for chat, @command{llama-server} for an OpenAI-compatible
HTTP API with a web UI, and tools to quantize, benchmark and convert models.
This build includes the CUDA backend (NVIDIA GPUs, built for compute
capability 8.6), Vulkan and OpenBLAS.")))

