;;; hyperguix --- scrcpy
;;;
;;; scrcpy is two pieces: the desktop client (C, built here with Meson) and
;;; "scrcpy-server", a dex/jar that is pushed to and run *on the phone*.
;;; Building the server needs the Android SDK (android.jar, d8, aidl), which
;;; Guix does not have, so -- like Debian, Nix and Arch -- we use upstream's
;;; prebuilt server for the exact same version.  The client refuses to talk to
;;; a server whose version string differs, so keep the two in lockstep.

(define-module (hyperguix packages scrcpy)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages android)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xdisorg))

(define %scrcpy-version "5.0.1")

;; Upstream pins this digest in install_release.sh.
(define scrcpy-server-prebuilt
  (origin
    (method url-fetch)
    (uri (string-append "https://github.com/Genymobile/scrcpy/releases/download/v"
                        %scrcpy-version "/scrcpy-server-v" %scrcpy-version))
    (file-name (string-append "scrcpy-server-" %scrcpy-version))
    (sha256
     (base32 "0dn57gjn5dizpzbrgf31g969ka9bi0h12d6zx4gj3m8ik3vvckkn"))))

(define-public scrcpy
  (let ((commit "a60891aea193d92e7e5c3942700eca63f9d19a5f"))
    (package
      (name "scrcpy")
      (version %scrcpy-version)
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Genymobile/scrcpy")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "062fnhm5pj39cxygs276zqw780blfw6rf850r442iw587a63fsyf"))))
      (build-system meson-build-system)
      (arguments
       (list
        #:configure-flags
        #~(list (string-append "-Dprebuilt_server=" #$scrcpy-server-prebuilt))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-desktop-files
              ;; The launchers go through "$SHELL -i" so that a PATH/ADB set
              ;; in .bashrc is honoured.  Our wrapper already provides adb.
              (lambda _
                (substitute* '("app/data/scrcpy.desktop"
                               "app/data/scrcpy-console.desktop")
                  (("^Exec=.*-c 'scrcpy ([^']*)'\"" _ args)
                   (string-append "Exec=" #$output "/bin/scrcpy " args))
                  (("^Exec=.*-c scrcpy\"")
                   (string-append "Exec=" #$output "/bin/scrcpy")))
                ;; Matches SDL_APP_ID below, so docks associate the window
                ;; with this launcher (and its icon).
                (substitute* "app/data/scrcpy.desktop"
                  (("^StartupNotify=.*" all)
                   (string-append all "StartupWMClass=scrcpy\n")))))
            (add-after 'install 'wrap-program
              ;; scrcpy shells out to adb.  Append rather than prepend so a
              ;; user-installed adb (or $ADB) still wins.
              (lambda* (#:key inputs #:allow-other-keys)
                (wrap-program (string-append #$output "/bin/scrcpy")
                  `("PATH" suffix
                    (,(dirname (search-input-file inputs "bin/adb"))))
                  ;; Without this SDL names the window (Wayland app_id, X11
                  ;; WM_CLASS) after the executable, i.e. ".scrcpy-real".
                  `("SDL_APP_ID" = ("scrcpy"))
                  ;; SDL 3 prefers X11 (Xwayland) on compositors without the
                  ;; fifo-v1 protocol, such as COSMIC.  Under Xwayland GL may
                  ;; be Mesa's software renderer, which cannot import the
                  ;; VA-API (DMA-BUF) frames scrcpy decodes by default: the
                  ;; window stays black, logging "could not import DMA-BUF as
                  ;; EGLImage".  Natively on Wayland, EGL is the GPU driver's
                  ;; and this works.  Appended, so a driver list the user set
                  ;; still comes first; SDL skips drivers that fail to start.
                  `("SDL_VIDEO_DRIVER" "," suffix ("wayland" "x11"))))))))
      (native-inputs (list pkg-config))
      (inputs (list adb bash-minimal ffmpeg libdrm libusb libva sdl3))
      (home-page "https://github.com/Genymobile/scrcpy")
      (synopsis "Display and control Android devices over USB or TCP/IP")
      (description
       "scrcpy mirrors the screen (and audio, on Android 11+) of an Android
device connected over USB or TCP/IP, and lets you control it with the
computer's keyboard and mouse.  It needs no root access and installs nothing
permanent on the device.  It can also use the device camera as a webcam source
(through V4L2), record to a file, and act as a HID keyboard/mouse/gamepad
(OTG mode).")
      (license license:asl2.0))))
