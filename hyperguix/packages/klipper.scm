;;; hyperguix --- Klipper, Moonraker and Fluidd: a 3D-printer host
;;;
;;; Klipper's host half (klippy), the Moonraker API server and the Fluidd
;;; web interface, packaged so that a printer host needs no git checkout,
;;; no virtualenv and no compiler: upstream's own install scripts (and
;;; KIAUH) assume apt and systemd, and klippy compiles its C helper on first
;;; start.  Here the helper is compiled at build time, and every Python
;;; dependency comes from Guix.
;;;
;;; Pinned by hand, on purpose not in contrib/updates.toml: the MCU firmware
;;; flashed on the printer's board is built from Klipper's source, and a new
;;; klippy can refuse to talk to older firmware.  Move %klipper-commit only
;;; when you are ready to reflash.
;;;
;;; The MCU firmware itself is not packaged: it is configured per board
;;; (`make menuconfig') in a writable checkout.  See the README.

(define-module (hyperguix packages klipper)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system pyproject)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages messaging)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages serialization))

;; Dependencies Guix doesn't have.

;; smart-open without its cloud back ends (boto3, Azure, paramiko...):
;; streaming-form-data only needs the core, and those are ~150 MB.
(define python-smart-open-minimal
  (package/inherit python-smart-open
    (name "python-smart-open-minimal")
    (arguments (list #:tests? #f))      ;the tests need the back ends
    (propagated-inputs (list python-wrapt))))

(define-public python-streaming-form-data
  (package
    (name "python-streaming-form-data")
    (version "2.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "streaming_form_data" version))
       (sha256
        (base32 "0nvwx9hh9ygi26afkzryp8gvksc7kyaxmiiv10rs27j5kky82p1c"))))
    (build-system pyproject-build-system)
    ;; The tests need moto, requests-toolbelt and an S3 mock.
    (arguments (list #:tests? #f))
    (native-inputs (list python-setuptools))
    (propagated-inputs (list python-aiofiles python-smart-open-minimal))
    (home-page "https://github.com/siddhantgoel/streaming-form-data")
    (synopsis "Streaming parser for multipart/form-data")
    (description "A parser for @code{multipart/form-data} request bodies
that hands each part to a target (a file, a value, a hash) as it arrives,
written in Cython.  Moonraker uses it for uploads.")
    (license license:expat)))

(define-public python-periphery
  (package
    (name "python-periphery")
    (version "2.4.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "python-periphery" version))
       (sha256
        (base32 "12p881zc96iqv406c261x3i530d622mj11w7drv6yalq6vbn3m31"))))
    (build-system pyproject-build-system)
    ;; The tests drive real GPIO, SPI, I2C... hardware.
    (arguments (list #:tests? #f))
    (native-inputs (list python-setuptools))
    (home-page "https://github.com/vsergeev/python-periphery")
    (synopsis "Peripheral I/O (GPIO, LED, PWM, SPI, I2C, MMIO, serial) in Python")
    (description "A pure Python library for GPIO, LED, PWM, SPI, I2C, MMIO
and serial peripheral I/O from user space on Linux.")
    (license license:expat)))

;; Writes BIN, a shell script that runs PYTHON on SCRIPT, then wraps it
;; with the GUIX_PYTHONPATH of the build: every Python input, propagated
;; ones included.
(define (python-launcher-phase bin script)
  #~(lambda* (#:key inputs #:allow-other-keys)
      (let ((bin (string-append #$output "/bin/" #$bin)))
        (mkdir-p (dirname bin))
        (call-with-output-file bin
          (lambda (port)
            (format port "#!~a~%exec ~a ~a \"$@\"~%"
                    (search-input-file inputs "bin/bash")
                    (search-input-file inputs "bin/python3")
                    (string-append #$output "/" #$script))))
        (chmod bin #o755)
        (wrap-program bin
          `("GUIX_PYTHONPATH" prefix ,(list (getenv "GUIX_PYTHONPATH")))))))

;; NumPy 2.4 requires x86-64-v2 (SSE4.2, POPCNT) by default and refuses to
;; import without it, which leaves out Core 2-era printer hosts (a Core 2
;; Duo P8700 has SSE4.1 at most): SHAPER_CALIBRATE and MEASURE_AXES_NOISE
;; then shut Klipper down.  Without a CPU baseline it imports anywhere, and
;; still picks its SSE4.2/AVX code at run time where the CPU has it.
(define python-numpy/no-cpu-baseline
  (package
    (inherit python-numpy)
    (arguments
     (substitute-keyword-arguments (package-arguments python-numpy)
       ((#:configure-flags _ #f)
        ''(("setup-args" . #("-Dcpu-baseline=none"))))))))

(define %klipper-commit "29d4ec2d6d840ee839333306003a400da186d41d")
(define %klipper-base-version "0.13.0")
(define %klipper-revision "827")      ;commits since the tag (git describe)

(define-public klipper
  (package
    (name "klipper")
    (version (git-version %klipper-base-version %klipper-revision
                          %klipper-commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Klipper3d/klipper")
             (commit %klipper-commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1wrmnrqlwmshxmrgsjwkjiwln7n8jw9jrign69a8kdxd1h07f85i"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("klippy" "lib/klipper/klippy")
          ("scripts" "lib/klipper/scripts")
          ;; Moonraker serves these two to the web interface (example
          ;; configurations, documentation), from next to klippy.
          ("config" "lib/klipper/config")
          ("docs" "lib/klipper/docs")
          ("COPYING" "share/doc/klipper/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'write-version
            ;; klippy asks git for its version, and reads this file when
            ;; there is no git checkout.
            (lambda _
              (call-with-output-file "klippy/.version"
                (lambda (port)
                  (format port "v~a-~a-g~a~%" #$%klipper-base-version
                          #$%klipper-revision
                          #$(string-take %klipper-commit 8))))))
          (add-after 'write-version 'build-c-helper
            ;; Exactly what klippy does on its first start, which would fail
            ;; in the store.  Store files all have the same mtime, so klippy
            ;; then finds the library up to date and never runs gcc.
            (lambda _
              (invoke "python3" "-c"
                      "import sys; sys.path.insert(0, 'klippy')
import chelper; chelper.get_ffi()")
              (unless (file-exists? "klippy/chelper/c_helper.so")
                (error "klippy's C helper was not built"))))
          (add-after 'install 'byte-compile
            ;; klippy can't write __pycache__ in the store: without this
            ;; every start recompiles all of it, slow on an old host.
            (lambda _
              ;; Only klippy: a few of the helper scripts are Python 2.
              (invoke "python3" "-m" "compileall" "-q"
                      (string-append #$output "/lib/klipper/klippy"))))
          (add-after 'byte-compile 'install-launcher
            #$(python-launcher-phase "klippy" "lib/klipper/klippy/klippy.py")))))
    (inputs
     (list bash-minimal
           python
           python-cffi
           python-greenlet
           python-jinja2
           python-markupsafe
           python-pyserial
           python-can
           python-msgspec
           ;; Input shaping: SHAPER_CALIBRATE, MEASURE_AXES_NOISE.
           python-numpy/no-cpu-baseline))
    (home-page "https://www.klipper3d.org/")
    (synopsis "3D-printer firmware: the host half (klippy)")
    (description "Klipper is 3D-printer firmware that runs its motion
planning on a general-purpose computer, which drives the printer's
micro-controllers over USB, serial or CAN.  This is that host program,
@command{klippy}, with its C helper prebuilt, and the example printer
configurations in @file{lib/klipper/config}.  The micro-controller
firmware is built separately from Klipper's source.")
    (license license:gpl3)))

;; The Creality Ender-3 V3 SE: jpcurti's fork (itself a fork of 0xD34D's),
;; which drives the printer's own screen through a serial bridge in the
;; MCU firmware (`e3v3se_display') and adds the load-cell Z offset probe
;; (`prtouch').  It needs the screen on Creality's display firmware 1.0.6,
;; and MCU firmware built from this same commit with the serial bridge on
;; USART2.  Pinned by hand, like klipper.
(define %klipper-e3v3se-commit "d74d36bb69bd8c561a169fd99e8c83e254318562")
(define %klipper-e3v3se-base-version "0.13.0")
(define %klipper-e3v3se-revision "919")   ;commits since upstream's v0.13.0

(define-public klipper-e3v3se
  (package
    (inherit klipper)
    (name "klipper-e3v3se")
    (version (git-version %klipper-e3v3se-base-version
                          %klipper-e3v3se-revision
                          %klipper-e3v3se-commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jpcurti/ender3-v3-se-klipper-with-display")
             (commit %klipper-e3v3se-commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "02ifcjw3a5b5xddx4yysd18ghi6bfklyk7lz9lrm3ha95x4mfg09"))))
    (arguments
     (substitute-keyword-arguments (package-arguments klipper)
       ((#:phases phases)
        #~(modify-phases #$phases
            (replace 'write-version
              (lambda _
                (call-with-output-file "klippy/.version"
                  (lambda (port)
                    (format port "v~a-~a-g~a~%"
                            #$%klipper-e3v3se-base-version
                            #$%klipper-e3v3se-revision
                            #$(string-take %klipper-e3v3se-commit 8))))))))))
    (home-page "https://github.com/jpcurti/ender3-v3-se-klipper-with-display")
    (synopsis "Klipper host for the Ender-3 V3 SE, with its screen")
    (description "This is Klipper's host program, @command{klippy}, from a
fork for the Creality Ender-3 V3 SE: it drives the printer's own screen
(@code{[e3v3se_display]}) through a serial bridge in the micro-controller
firmware, and adds the printer's load-cell Z offset probe
(@code{[prtouch]}).  The screen must run Creality's display firmware 1.0.6.")))

(define %moonraker-commit "b559b9a81161f958a43c2f527b6ad96f73310d5d")
(define %moonraker-base-version "0.11.0")
(define %moonraker-revision "4")

(define-public moonraker
  (package
    (name "moonraker")
    (version (git-version %moonraker-base-version %moonraker-revision
                          %moonraker-commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Arksine/moonraker")
             (commit %moonraker-commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0ba0h5id2p14zmc9dqv2371j3djlv40k6cklnyw5nr8ab1hzzqjz"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("moonraker" "lib/moonraker/moonraker")
          ("docs" "share/doc/moonraker/"
           #:include-regexp ("\\.md$"))
          ("LICENSE" "share/doc/moonraker/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'write-version
            ;; Read when the source is not a git checkout.
            (lambda _
              (call-with-output-file "moonraker/.version"
                (lambda (port)
                  (format port "v~a-~a-g~a~%" #$%moonraker-base-version
                          #$%moonraker-revision
                          #$(string-take %moonraker-commit 7))))))
          (add-after 'install 'byte-compile
            (lambda _
              (invoke "python3" "-m" "compileall" "-q"
                      (string-append #$output "/lib/moonraker"))))
          (add-after 'byte-compile 'install-launcher
            #$(python-launcher-phase "moonraker"
                                     "lib/moonraker/moonraker/moonraker.py"))
          (add-after 'install-launcher 'check-imports
            ;; Everything the core components import at load time.  The
            ;; optional ones (zeroconf, ldap, ...) load only when configured.
            (lambda _
              (invoke (string-append #$output "/bin/moonraker")
                      "--help")
              (setenv "GUIX_PYTHONPATH"
                      (string-append #$output "/lib/moonraker:"
                                     (getenv "GUIX_PYTHONPATH")))
              (invoke "python3" "-c"
                      "import moonraker.server
for c in moonraker.server.CORE_COMPONENTS + ['application', 'websockets',
          'notifier', 'mqtt', 'gpio', 'template']:
    __import__('moonraker.components.' + c)"))))))
    (inputs
     (list bash-minimal
           python
           python-tornado
           python-pyserial
           python-pillow
           python-streaming-form-data
           python-distro
           python-inotify-simple
           python-libnacl
           python-paho-mqtt
           python-jinja2
           python-dbus-fast
           python-importlib-metadata
           python-apprise           ;[notifier]
           python-periphery         ;[power] and [button] GPIO devices
           python-lmdb              ;migrating an old database
           python-msgspec))         ;faster JSON
    (home-page "https://github.com/Arksine/moonraker")
    (synopsis "Web API server for Klipper")
    (description "Moonraker connects Klipper's host program to web
interfaces such as Fluidd and Mainsail: it serves the HTTP and websocket
API, manages G-code files, print history and the job queue, and controls
power devices and notifications.  Its update manager does not apply here:
Guix updates it.")
    (license license:gpl3)))

(define-public fluidd
  (package
    (name "fluidd")
    (version "1.38.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/fluidd-core/fluidd/releases"
                           "/download/v" version "/fluidd.zip"))
       (file-name (string-append name "-" version ".zip"))
       (sha256
        (base32 "15yxayzv970vh959q79x2vm7394lsiza2l32l195l64xqlh97cki"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan #~'(("." "share/fluidd"))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            ;; The zip has no top directory: the standard phase would step
            ;; into its first subdirectory (assets/) and install only that.
            (lambda* (#:key source #:allow-other-keys)
              (mkdir "fluidd")
              (chdir "fluidd")
              (invoke "unzip" "-q" source)
              (unless (file-exists? "index.html")
                (error "no index.html in" source)))))))
    (native-inputs (list unzip))
    (home-page "https://docs.fluidd.xyz/")
    (synopsis "Web interface for Klipper")
    (description "Fluidd is a browser interface for Klipper printers that
talks to Moonraker.  This is upstream's release build: static files to be
served by a web server, in @file{share/fluidd}.")
    (license license:gpl3+)))
