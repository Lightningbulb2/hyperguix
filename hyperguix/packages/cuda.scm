;;; hyperguix --- NVIDIA CUDA toolkit (the parts llama.cpp needs)
;;;
;;; Neither Guix nor nonguix packages the CUDA toolkit.  NVIDIA publishes it
;;; as separate "redist" archives per component
;;; (https://developer.download.nvidia.com/compute/cuda/redist/, listed in
;;; redistrib_VERSION.json with their SHA-256); this is the compiler (nvcc,
;;; with crt, nvvm and the CCCL headers), the runtime (cudart) and cuBLAS,
;;; merged into one prefix laid out like /usr/local/cuda and patched to run on
;;; Guix.  The driver side (libcuda) comes from the NVIDIA driver, in the
;;; system profile.  Nonfree.
;;;
;;; Updating: change the versions and the hashes from the new
;;; redistrib_VERSION.json (sha256, hex -> nix base32).

(define-module (hyperguix packages cuda)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc))

(define (cuda-redist component version hash)
  (origin
    (method url-fetch)
    (uri (string-append "https://developer.download.nvidia.com/compute/cuda/redist/"
                        component "/linux-x86_64/" component "-linux-x86_64-"
                        version "-archive.tar.xz"))
    (sha256 (base32 hash))))

(define-public cuda-toolkit
  (package
    (name "cuda-toolkit")
    (version "13.4.3")
    (source #f)
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:strip-binaries? #f              ;NVIDIA's binaries, as shipped
      ;; The libraries dlopen() or need libcuda.so.1, which is the driver's,
      ;; outside the store at build time.
      #:validate-runpath? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'unpack)
          (delete 'configure)
          (delete 'build)
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              ;; Each archive holds one COMPONENT-...-archive directory with
              ;; bin/, include/, lib/... merged into the output.
              (for-each
               (lambda (archive)
                 (let ((dir (string-drop-right (strip-store-file-name archive)
                                               (string-length ".tar.xz"))))
                   (invoke "tar" "xf" archive)
                   (copy-recursively dir #$output)
                   (delete-file-recursively dir)))
               (filter (lambda (file)
                         (string-suffix? "-archive.tar.xz" file))
                       (map cdr inputs)))))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (search-input-file inputs "lib/ld-linux-x86-64.so.2"))
                     (rpath (string-join
                             (list (string-append #$output "/lib")
                                   (string-append #$output "/nvvm/lib64")
                                   (dirname (search-input-file
                                             inputs "lib/libstdc++.so.6"))
                                   (dirname ld.so))
                             ":")))
                (for-each
                 (lambda (file)
                   (when (and (elf-file? file)
                              (not (string-contains file "/stubs/")))
                     (when (false-if-exception
                            (invoke "patchelf" "--print-interpreter" file))
                       (invoke "patchelf" "--set-interpreter" ld.so file))
                     (when (false-if-exception
                            (invoke "patchelf" "--print-needed" file))
                       (invoke "patchelf" "--set-rpath" rpath file))))
                 (append (find-files (string-append #$output "/bin"))
                         (find-files (string-append #$output "/nvvm/bin"))
                         (find-files (string-append #$output "/lib") "\\.so")
                         (find-files (string-append #$output "/nvvm/lib64")
                                     "\\.so")))))))))
    (inputs (list `(,gcc "lib") glibc))
    (native-inputs
     (list patchelf
           (cuda-redist "cuda_nvcc" "13.4.92"
                                  "0g8rqz55vkr11b79i4skxz2zncw16b62svl459mq5xcxri08z6b0")
           (cuda-redist "cuda_crt" "13.4.92"
                                 "1aksbw11443n4xg3078yxblc0bk2y5kjirxc437z1nqjxlfycsf9")
           (cuda-redist "libnvvm" "13.4.92"
                                  "0xdxlfhxi992v22lmci9c7jrdhhzfslrqnb54s0pqzxjsprrqq8f")
           (cuda-redist "cuda_cudart" "13.4.92"
                                    "1dd82hz7pvv4ci5nbxpmx4g9wiabrq642fs9pj1rjknh732xpi8a")
           (cuda-redist "cccl" "13.3.4.3.1"
                                  "02c219z2xkjs9kzqzwfrrmbapig1r0c17hdrzv9hvy229w3icxbb")
           (cuda-redist "libcublas" "13.8.0.4"
                                    "1dh62xjvv90dvvgxgqniwx0jffagd6k190ljpdmdlwhnav7gqvxx")
           (cuda-redist "cuda_nvml_dev" "13.4.92"
                                  "1jmr7g6yv3s92rgla6lqgvw8c81fgmf0s2ivi1cscmhgh96dzx1y")
           (cuda-redist "cuda_culibos" "13.4.92"
                                     "0m8fiavfv03rw1yybfm3pbjh9kzcnn24w73q7gkkqqg0363n2714")))
    (supported-systems '("x86_64-linux"))
    (home-page "https://developer.nvidia.com/cuda-toolkit")
    (synopsis "NVIDIA CUDA compiler, runtime and cuBLAS")
    (description "This is the part of NVIDIA's CUDA toolkit needed to build
CUDA programs such as llama.cpp: the @command{nvcc} compiler (with NVVM, the
CRT headers and CCCL: Thrust, CUB, libcu++), the CUDA runtime and cuBLAS.
Running the programs takes the NVIDIA driver's @code{libcuda}.")
    (license (license:nonfree "https://docs.nvidia.com/cuda/eula/index.html"))))
