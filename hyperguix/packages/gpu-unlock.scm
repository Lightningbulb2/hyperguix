;;; gpu-unlock: lifts GeForce RTX 20/30/40 cards' half-rate cap on FP16,
;;; BF16 and TF32 tensor math (with FP32 accumulation) at boot, before the
;;; stock NVIDIA driver binds the card.  https://github.com/Zagitta/gpu-unlock
;;;
;;; Two packages, as upstream ships them:
;;;   gpu-unlock           the gpu_unlock kernel module (GPL 2);
;;;   gpu-unlock-firmware  NVIDIA 610.43.03 firmware it uploads to the card,
;;;                        extracted unchanged from NVIDIA's driver installer
;;;                        and open kernel module source (nonfree).
;;;
;;; System config:
;;;   %gpu-unlock-services  -- add to the OS `services' list;
;;;   "gpu_unlock.targets=0000:05:00.0" (or "=all") -- add to the
;;;   `kernel-arguments'.  Without it the module does nothing.
;;; Like %openrazer-keyboard-services it is a plain list of service values,
;;; so config.scm can use it although it loads this module only at run time.
;;;
;;; Upstream loads gpu_unlock from the initramfs.  Guix's initrd can only
;;; hold modules of the kernel package itself, and nvidia isn't in it
;;; anyway: on Guix nvidia is loaded by udev, from its PCI modalias, during
;;; the coldplug.  So a udev rule loads gpu_unlock for the same device event
;;; first (60-*.rules run before the modalias load in 80-drivers.rules), and
;;; its init, which unlocks the cards synchronously, is done before nvidia
;;; loads.  Its firmware is then on the root file system, where the kernel
;;; finds it through the OS `firmware' (firmware_class.path).

(define-module (hyperguix packages gpu-unlock)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system linux-module)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((nonguix licenses) #:prefix nonguix-license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages python)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services linux)
  #:use-module (nongnu packages linux)
  #:export (gpu-unlock
            gpu-unlock-firmware
            %gpu-unlock-services))

(define gpu-unlock-version "2.0.0")
(define gpu-unlock-commit "7eb51bccae0a0b7e599e084d971170e9a1e82d0c")

;; The NVIDIA driver the firmware comes from; the module asks for
;; gpu-unlock/610.43.03/*.bin.  Only the firmware is used, whatever driver
;; the system runs.
(define gpu-unlock-nvidia-version "610.43.03")

(define gpu-unlock-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/Zagitta/gpu-unlock")
          (commit gpu-unlock-commit)))
    (file-name (git-file-name "gpu-unlock" gpu-unlock-version))
    (sha256
     (base32 "1m84a37xk2qha65pj8g6zvds6yqm11x0vrv3prb2b46dzbhg62bq"))))

(define gpu-unlock
  (package
    (name "gpu-unlock")
    (version gpu-unlock-version)
    (source gpu-unlock-source)
    (build-system linux-module-build-system)
    (arguments
     (list
      ;; Must be the same kernel package as the OS `kernel' field, or the
      ;; module's vermagic won't match and it refuses to load.
      #:linux linux
      #:tests? #f                       ;tests/ builds in Docker containers
      #:source-directory "kernel/gpu_unlock"))
    (home-page "https://github.com/Zagitta/gpu-unlock")
    (synopsis "Full-rate FP16/BF16/TF32 tensor cores on GeForce RTX cards")
    (description
     "The gpu_unlock kernel module removes the half-rate limit NVIDIA puts on
GeForce RTX 20, 30 and 40 series tensor cores for FP16, BF16 and TF32 math
with FP32 accumulation.  It runs at boot, before the stock NVIDIA driver binds
the card, and again after suspend.  It does nothing unless the kernel command
line names the cards, as @code{gpu_unlock.targets=all} or a comma-separated
list of PCI addresses.  It needs @code{gpu-unlock-firmware}.")
    (license license:gpl2)))

(define gpu-unlock-nvidia-source
  (origin
    (method url-fetch)
    (uri (string-append
          "https://download.nvidia.com/XFree86/"
          "NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-"
          gpu-unlock-nvidia-version ".tar.xz"))
    (sha256
     (base32 "1p61kzz2vb770cia95c6z6d4xq738qx2fqsd24vdqgm2qwiqj4by"))))

(define gpu-unlock-nvidia-installer
  (origin
    (method url-fetch)
    (uri (string-append
          "https://download.nvidia.com/XFree86/Linux-x86_64/"
          gpu-unlock-nvidia-version "/NVIDIA-Linux-x86_64-"
          gpu-unlock-nvidia-version "-no-compat32.run"))
    (sha256
     (base32 "141gzqc47s05a95xkxs5r7ikdln495bnakypsclxz9ihnwflb170"))))

(define gpu-unlock-firmware
  (package
    (name "gpu-unlock-firmware")
    (version gpu-unlock-version)
    (source gpu-unlock-source)
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (replace 'build
            ;; What upstream's `make firmware' does, from the pinned inputs
            ;; instead of a download cache.  Both scripts check the NVIDIA
            ;; version and copy the firmware bytes unchanged.
            (lambda _
              (let ((source #$gpu-unlock-nvidia-source))
                (mkdir "nvidia-source")
                (invoke "tar" "-xf" source "-C" "nvidia-source")
                (invoke "python3" "firmware/extract_gsp.py"
                        #$gpu-unlock-nvidia-installer
                        "assets")
                (invoke "python3" "firmware/extract_boot_assets.py"
                        (string-append "nvidia-source/NVIDIA-kernel-module-source-"
                                       #$gpu-unlock-nvidia-version)
                        "assets"))))
          (replace 'install
            (lambda _
              ;; NVIDIA's license and upstream's notice go next to the
              ;; licenses in licenses/, which the standard phase installs.
              (invoke "make" "install-firmware" "ASSETS=assets"
                      (string-append "FWDIR=" #$output "/lib/firmware/gpu-unlock/"
                                     #$gpu-unlock-nvidia-version)
                      (string-append "LICENSEDIR=" #$output "/share/doc"))
              (rename-file (string-append #$output "/share/doc/gpu-unlock-firmware")
                           (string-append #$output "/share/doc/gpu-unlock-firmware-"
                                          #$gpu-unlock-version))))
          ;; Firmware is copied unchanged; nothing to strip or patch.
          (delete 'strip)
          (delete 'validate-runpath))))
    (native-inputs (list python zstd))
    (home-page "https://github.com/Zagitta/gpu-unlock")
    (synopsis "NVIDIA firmware used by the gpu_unlock kernel module")
    (description
     "The NVIDIA 610.43.03 GSP firmware, SEC2 booter bundles, Falcon loader and
GSP boot images that @code{gpu-unlock} loads onto the card, extracted
byte-for-byte from NVIDIA's driver installer and open kernel module source.")
    (license
     (list (nonguix-license:nonfree
            "https://www.nvidia.com/en-us/drivers/nvidia-license/")
           license:gpl2))))

(define %gpu-unlock-services
  (list (simple-service 'gpu-unlock-module
                        linux-loadable-module-service-type
                        (list gpu-unlock))
        (simple-service 'gpu-unlock-firmware
                        firmware-service-type
                        (list gpu-unlock-firmware))
        ;; Before nvidia: see the top of this file.  Only display
        ;; controllers (class 0x03xx) of NVIDIA's; gpu_unlock itself skips
        ;; cards that aren't listed in gpu_unlock.targets or supported.
        (udev-rules-service
         'gpu-unlock
         (udev-rule "60-gpu-unlock.rules"
                    "\
ACTION==\"add\", SUBSYSTEM==\"pci\", ATTR{vendor}==\"0x10de\", \
ATTR{class}==\"0x03[0-9]*\", RUN{builtin}+=\"kmod load gpu_unlock\"
"))))
