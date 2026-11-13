;;; OpenRazer kernel driver for the Razer BlackWidow Ultimate (1532:011a),
;;; so its M1-M5 macro keys send F13-F17.
;;;
;;; Only razerkbd is built.  razermouse, razerkraken and razeraccessory
;;; are left out on purpose: razermouse would grab the DeathAdder
;;; (1532:0098), which works fine with hid-generic.
;;;
;;; Upstream razerkbd only *reads* M1-M5 when the keyboard is in "driver
;;; mode" (mode 0x03); it puts the keyboard into normal mode on probe and
;;; leaves switching to the OpenRazer daemon.  The patch below makes the
;;; driver switch the BlackWidow Ultimate 2013 to driver mode itself (on
;;; probe and after resume), so no daemon is needed.  Disable with the
;;; kernel argument "razerkbd.driver_mode=0".
;;;
;;; System config:
;;;   %openrazer-keyboard-services  -- add to the OS `services' list.
;;; It is a plain list of service values (no record macros), so config.scm
;;; can use it although it loads this module only at run time.

(define-module (hyperguix packages openrazer)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system linux-module)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu services)
  #:use-module (gnu services linux)
  #:use-module (nongnu packages linux)
  #:export (openrazer-kernel-modules
            %openrazer-keyboard-services))

(define openrazer-version "3.12.4")

(define openrazer-kernel-modules
  (package
    (name "openrazer-kernel-modules")
    (version openrazer-version)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/openrazer/openrazer")
             (commit (string-append "v" version))))
       (file-name (git-file-name "openrazer" version))
       (sha256
        (base32 "1f5q8fhhvsi66f2rx3gvkdnln4ajykm7wbzwbyjkb7x18yrxh02s"))
       (patches
        (list (local-file "aux-files/openrazer-kbd-driver-mode.patch")))))
    (build-system linux-module-build-system)
    (arguments
     (list
      ;; Must be the same kernel package as the OS `kernel' field, or the
      ;; module's vermagic won't match and it refuses to load.
      #:linux linux
      #:tests? #f                       ;no test suite for the driver
      #:source-directory "driver"
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'only-razerkbd
            (lambda _
              (substitute* "driver/Makefile"
                (("^obj-m :=.*")
                 "obj-m := razerkbd.o\n")))))))
    (home-page "https://openrazer.github.io/")
    (synopsis "OpenRazer keyboard kernel driver (razerkbd)")
    (description
     "The razerkbd kernel module from OpenRazer.  It drives Razer keyboards;
this build also switches the BlackWidow Ultimate 2013 into driver mode by
itself, so its M1-M5 macro keys emit F13-F17 without the OpenRazer daemon.")
    (license license:gpl2+)))

(define %openrazer-keyboard-services
  ;; Add the module to the kernel profile (/run/booted-system/kernel), so
  ;; udev autoloads it via its modalias, and load it explicitly at boot too.
  (list (simple-service 'openrazer-kernel-modules
                        linux-loadable-module-service-type
                        (list openrazer-kernel-modules))
        (simple-service 'openrazer-load-razerkbd
                        kernel-module-loader-service-type
                        '("razerkbd"))))
