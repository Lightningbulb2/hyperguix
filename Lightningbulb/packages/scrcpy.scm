(define-module (Lightningbulb packages scrcpy)
    #:use-module (gnu packages)
    #:use-module (gnu packages video)
    #:use-module (guix packages)
    #:use-module (guix git-download)
    #:use-module (guix build-system meson)
    #:use-module (guix gexp)
    #:use-module ((guix licenses) #:prefix license:)

    #:use-module (gnu packages android)
    #:use-module (gnu packages libusb)
    #:use-module (gnu packages pkg-config)
    #:use-module (gnu packages sdl)
    #:use-module (gnu packages version-control)
    #:use-module (gnu packages gcc)
    #:use-module (gnu packages java)
    #:use-module (gnu packages gstreamer)
    #:use-module (guix search-paths)
    )

(define-public scrcpy
    (package
        (name "scrcpy")
        (version "4.1")
        (source (origin
                (method git-fetch)
                (uri (git-reference
                     (url "https://github.com/genymobile/scrcpy")
                     (commit (string-append "v" version))))
                (sha256
                 (base32
                 "1gm1jz428lkfw96fs1gxsa8fy3lrwi7v02v67s17b2vm2hvh5cn7"))))
    (build-system meson-build-system)
    (arguments
        (list #:phases
              #~(modify-phases %standard-phases
                  (add-before 'configure 'set-java-home
                      (lambda* (#:key inputs #:allow-other-keys)
                          (setenv "JAVA_HOME"
                              (dirname (dirname (search-input-file inputs "bin/java")))))))))
    (outputs `("out" "debug"))
    (native-inputs (list pkg-config
                     gcc
                     git
                     ffms2
                     openjdk17
                     gst-libav))
    (inputs (list ffmpeg
              sdl3
              adb
              libusb))
    (synopsis "android screen viewing tool")
    (description "scrcpy or screen copy, is a tool to show a connected android device's screen in a desktop window")
    (home-page "https://github.com/genymobile/scrcpy")
    (license license:asl2.0)))
