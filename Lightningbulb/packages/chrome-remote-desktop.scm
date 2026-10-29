;;; Lightningbulb channel --- chrome-remote-desktop
;;;
;;; Google's Chrome Remote Desktop *host* for Linux, repackaged from the
;;; official .deb the way nonguix packages other binary software, plus a
;;; system service that replaces the Debian package's systemd unit
;;; (chrome-remote-desktop@USER.service).  Non-free.
;;;
;;; What works on Guix: the classic "virtual desktop" host.  The host runs
;;; its own X server (Xorg with the dummy driver, or Xvfb) and starts an X11
;;; desktop in it; you connect to that desktop, not to the session on the
;;; physical monitor.  COSMIC cannot run there (cosmic-comp needs DRM/KMS),
;;; and Guix's Plasma 6 has no kwin_x11 (only kwin_wayland), so the service
;;; starts Xfce by default.  CRD's other modes
;;; do not apply: its Wayland mode only starts GNOME or Plasma Wayland
;;; sessions through systemd --user, and the multi-process host
;;; (chrome-remote-desktop.service) only works with GDM.
;;;
;;; Updating: the version and file name are in
;;; https://dl.google.com/linux/chrome-remote-desktop/deb/dists/stable/main/binary-amd64/Packages
;;; (the pool drops old versions, so update when the download 404s).

(define-module (Lightningbulb packages chrome-remote-desktop)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix profiles)
  #:use-module (guix download)
  #:use-module (guix records)
  #:use-module (ice-9 match)
  #:use-module (nonguix build-system binary)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system pam)
  #:export (chrome-remote-desktop-configuration
            chrome-remote-desktop-configuration?
            chrome-remote-desktop-service-type))

(define-public chrome-remote-desktop
  (package
    (name "chrome-remote-desktop")
    (version "157.0.8103.19")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://dl.google.com/linux/chrome-remote-desktop/deb/pool/main/"
             "c/chrome-remote-desktop/chrome-remote-desktop_" version
             "_amd64.deb"))
       (sha256
        (base32 "0qfvscz8661223xn8161x0zybb2gz3wh6lzpl6jmbx5ygzn86f6b"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
     (list
      #:substitutable? #f
      #:modules '((nonguix build binary-build-system)
                  (guix build utils)
                  (srfi srfi-1))
      #:validate-runpath? #t
      #:install-plan
      #~'(("opt/google/chrome-remote-desktop/" "lib/chrome-remote-desktop/")
          ;; Firefox (nonguix) reads system-wide native-messaging manifests
          ;; from $ICECAT_SYSTEM_DIR/native-messaging-hosts, a search path
          ;; for lib/icecat in the profile Firefox is installed in.
          ("usr/lib/mozilla/native-messaging-hosts/"
           "lib/icecat/native-messaging-hosts/")
          ;; Google Chrome: installed as /etc/opt/chrome/... by the service.
          ("etc/opt/chrome/native-messaging-hosts/"
           "etc/opt/chrome/native-messaging-hosts/")
          ;; WirePlumber >= 0.5 profile used for the session's audio.
          ("usr/share/wireplumber/" "share/wireplumber/")
          ("usr/share/applications/" "share/applications/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'binary-unpack 'patch-scripts
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((dir "opt/google/chrome-remote-desktop")
                     (crd (string-append dir "/chrome-remote-desktop"))
                     (python (search-input-file inputs "bin/python3"))
                     (site-dirs
                      (map (lambda (name)
                             (car (find-files (assoc-ref inputs name)
                                              "^site-packages$"
                                              #:directories? #t)))
                           '("python-dbus" "python-psutil" "python-pyxdg"
                             "python-packaging")))
                     (tool-dirs
                      (map (lambda (name)
                             (string-append (assoc-ref inputs name) "/bin"))
                           '("xorg-server" "xdpyinfo" "xrandr" "setxkbmap"
                             "xauth" "util-linux" "coreutils" "pipewire"
                             "wireplumber" "dbus")))
                     (xorg (assoc-ref inputs "xorg-server"))
                     (dummy (assoc-ref inputs "xf86-video-dummy")))
                (for-each
                 (lambda (script)
                   (substitute* script
                     (("^#!/usr/bin/python3") (string-append "#!" python))))
                 (list crd
                       (string-append dir "/setup-session-environment")
                       (string-append dir "/configure-url-forwarder")))
                (substitute* crd
                  ;; Python modules and the X/audio tools the script runs
                  ;; through $PATH (Xvfb, Xorg, xdpyinfo, xrandr, setxkbmap,
                  ;; xauth, mcookie, nproc, pipewire, wireplumber).  The
                  ;; script's own share/ goes on XDG_DATA_DIRS so WirePlumber
                  ;; finds the "chrome-remote-desktop" profile.
                  (("^import sys\n")
                   (string-append
                    "import sys\n"
                    "sys.path[:0] = ["
                    (string-join (map (lambda (d) (string-append "'" d "'"))
                                      site-dirs)
                                 ", ")
                    "]"
                    "  # Guix\n"
                    "import os as _guix_os\n"
                    "_guix_os.environ['PATH'] = '"
                    (string-join tool-dirs ":")
                    ":' + _guix_os.environ.get('PATH', '')\n"
                    "_guix_os.environ['XDG_DATA_DIRS'] = '" #$output "/share:'"
                    " + (_guix_os.environ.get('XDG_DATA_DIRS')"
                    " or '/usr/local/share:/usr/share')\n"))
                  ;; Xorg + dummy driver.
                  (("ModulePath \"/usr/lib/xorg/modules\"")
                   (string-append "ModulePath \"" dummy "/lib/xorg/modules,"
                                  xorg "/lib/xorg/modules\""))
                  (("\"/usr/lib/xorg/Xorg\"")
                   (string-append "\"" xorg "/bin/Xorg\""))
                  ;; The script asks dpkg whether xserver-xorg-video-dummy
                  ;; is new enough; ours always is.
                  (("^      video_dummy_info = subprocess.check_output\\(" all)
                   (string-append "      return False  # Guix\n" all))
                  ;; The web page / native host asks --get-status whether this
                  ;; system is supported; upstream says yes when Debian's
                  ;; /etc/X11/Xsession exists.  Point it at our replacement.
                  (("DEBIAN_XSESSION_PATH = \"/etc/X11/Xsession\"")
                   (string-append "DEBIAN_XSESSION_PATH = \"" #$output
                                  "/lib/chrome-remote-desktop/Xsession\""))
                  ;; Starting the host: systemctl -> the Shepherd service.
                  (("\\[\"systemctl\", \"enable\", \"--now\",")
                   "[\"/run/current-system/profile/bin/herd\", \"start\",")
                  (("\\[\"systemctl\", \"start\",")
                   "[\"/run/current-system/profile/bin/herd\", \"start\",")
                  (("\"chrome-remote-desktop@\" \\+ (user|getpass.getuser\\(\\))"
                    _ who)
                   "\"chrome-remote-desktop\"")
                  (("/usr/bin/pkexec") "/run/privileged/bin/pkexec")
                  (("/usr/bin/sudo") "/run/privileged/bin/sudo")
                  ;; No systemd --user: ignore the "systemctl --user" calls
                  ;; (only cleanup on exit and the GNOME/KDE Wayland mode).
                  (("subprocess\\.call\\(\\[\"systemctl\", \"--user\""
                    all)
                   (string-append "shutil.which(\"systemctl\") and " all)))
                ;; Session chooser helper: run the chosen session command.
                (call-with-output-file (string-append dir "/Xsession")
                  (lambda (port)
                    (format port "#!/bin/sh
# Guix replacement for Debian's /etc/X11/Xsession, used by the Chrome Remote
# Desktop session chooser: run the selected session with its own D-Bus bus.
exec ~a/bin/dbus-run-session -- /bin/sh -c \"$*\"~%"
                            (assoc-ref inputs "dbus"))))
                ;; Deprecated wrapper; keep it pointing at the right file.
                (substitute* (string-append dir "/is-remoting-session")
                  (("^#!/bin/bash") "#!/bin/sh")))))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((lib (string-append #$output "/lib/chrome-remote-desktop"))
                     (ld.so (search-input-file inputs "lib/ld-linux-x86-64.so.2"))
                     (needed
                      '("libglib-2.0.so.0" "libxkbcommon.so.0" "libnspr4.so"
                        "libnss3.so" "libpam.so.0" "libexpat.so.1"
                        "libatk-1.0.so.0" "libcairo.so.2" "libgtk-3.so.0"
                        "libpango-1.0.so.0" "libX11.so.6" "libXdamage.so.1"
                        "libXext.so.6" "libXfixes.so.3" "libXrandr.so.2"
                        "libXtst.so.6" "libgbm.so.1" "libxcb.so.1"
                        "libdbus-1.so.3" "libelogind.so.0" "libgcc_s.so.1"
                        "libc.so.6"))
                     (rpath
                      (string-join
                       (delete-duplicates
                        (map (lambda (so)
                               (dirname
                                (or (false-if-exception
                                     (search-input-file inputs
                                                        (string-append "lib/" so)))
                                    (search-input-file
                                     inputs (string-append "lib/nss/" so)))))
                             needed))
                       ":"))
                     (rpath (string-append rpath ":" (dirname ld.so))))
                ;; elogind provides the sd-bus/sd-login API (same symbol
                ;; versions) under its own soname.
                (invoke "patchelf" "--replace-needed" "libsystemd.so.0"
                        "libelogind.so.0"
                        (string-append lib "/libremoting_core.so"))
                (invoke "patchelf" "--set-rpath" rpath
                        (string-append lib "/libremoting_core.so"))
                (for-each
                 (lambda (exe)
                   (let ((file (string-append lib "/" exe)))
                     (invoke "patchelf" "--set-interpreter" ld.so file)
                     ;; Since 157 the crashpad tools link GLib and D-Bus
                     ;; too, so every program gets the full RUNPATH.
                     (invoke "patchelf" "--set-rpath"
                             (string-append lib ":" rpath) file)))
                 '("chrome-remote-desktop-host" "native-messaging-host"
                   "start-host" "remote-assistance-host" "remote-open-url"
                   "remote-session-info" "remote-webauthn" "migrate-host"
                   "crashpad-handler" "crashpad-db")))))
          (add-after 'patch-elf 'finish-install
            (lambda _
              (let ((lib (string-append #$output "/lib/chrome-remote-desktop"))
                    (bin (string-append #$output "/bin")))
                (chmod (string-append lib "/Xsession") #o755)
                ;; Native-messaging manifests and the .desktop file -> store.
                (substitute*
                    (append
                     (find-files (string-append #$output "/lib/icecat") "\\.json$")
                     (find-files (string-append #$output "/etc") "\\.json$")
                     (find-files (string-append #$output "/share/applications")))
                  (("/opt/google/chrome-remote-desktop") lib))
                (mkdir-p bin)
                (for-each
                 (lambda (name)
                   (symlink (string-append lib "/" name)
                            (string-append bin "/" name)))
                 '("chrome-remote-desktop" "start-host"
                   "remote-session-info")))))
          (add-after 'finish-install 'use-single-process-host
            (lambda* (#:key inputs #:allow-other-keys)
              ;; start-host and the native-messaging host first ask
              ;; "systemctl is-active chrome-remote-desktop.service" whether
              ;; the GDM-only multi-process host is in use, and log an error
              ;; when there is no systemctl.  Give them a stand-in that says
              ;; "inactive" so they always take the single-process (virtual
              ;; X11 desktop) path, which the Shepherd service runs.
              (let* ((lib (string-append #$output "/lib/chrome-remote-desktop"))
                     (stub-dir (string-append #$output
                                              "/libexec/chrome-remote-desktop"))
                     (stub (string-append stub-dir "/systemctl"))
                     (sh (search-input-file inputs "bin/bash")))
                (mkdir-p stub-dir)
                (call-with-output-file stub
                  (lambda (port)
                    (format port "#!~a
# Guix stand-in for systemctl, used only by Chrome Remote Desktop's setup
# tools: the multi-process host (chrome-remote-desktop.service) does not exist.
case \"$1\" in
  is-active) echo inactive; exit 3 ;;
  disable|stop|is-enabled) exit 0 ;;
  *) echo \"chrome-remote-desktop: systemctl $* is not available on Guix;\" \\
          \"use 'herd start chrome-remote-desktop'\" >&2
     exit 1 ;;
esac~%" sh)))
                (chmod stub #o755)
                (for-each
                 (lambda (exe)
                   (wrap-program (string-append lib "/" exe)
                     #:sh sh
                     `("PATH" prefix (,stub-dir))))
                 '("start-host" "native-messaging-host"
                   "remote-assistance-host"))))))))
    (inputs
     (list at-spi2-core
           bash-minimal
           cairo
           coreutils
           dbus
           elogind
           expat
           `(,gcc "lib")
           glib
           glibc
           gtk+
           libx11
           libxcb
           libxdamage
           libxext
           libxfixes
           libxkbcommon
           libxrandr
           libxtst
           linux-pam
           mesa
           nspr
           nss
           pango
           pipewire
           python
           python-dbus
           python-packaging
           python-psutil
           python-pyxdg
           setxkbmap
           util-linux
           wireplumber
           xauth
           xdpyinfo
           xf86-video-dummy
           xorg-server
           xrandr))
    (home-page "https://remotedesktop.google.com/")
    (synopsis "Chrome Remote Desktop host (virtual X11 desktop)")
    (description
     "Chrome Remote Desktop lets you reach this computer from a browser at
@url{https://remotedesktop.google.com}.  This package is Google's Linux host,
repackaged from the official Debian package.  It serves a separate virtual
X11 desktop (Xorg with the dummy driver, or Xvfb), not the session on the
physical screen.  Use it with @code{chrome-remote-desktop-service-type}, which
provides the service, the PAM entry and the paths the host expects.  Install
the package in the same profile as Firefox so its native-messaging host is
found by the Chrome Remote Desktop add-on.")
    (license (license:nonfree
              "https://chromium.googlesource.com/chromium/src/+/main/LICENSE"))))


;;;
;;; Service.
;;;

(define-record-type* <chrome-remote-desktop-configuration>
  chrome-remote-desktop-configuration make-chrome-remote-desktop-configuration
  chrome-remote-desktop-configuration?
  (package        chrome-remote-desktop-configuration-package
                  (default chrome-remote-desktop))
  ;; Account whose host this is (the one that ran start-host).
  (user           chrome-remote-desktop-configuration-user)
  ;; Resolutions the virtual display offers (it follows the client window
  ;; when "resize desktop to fit" is on, within the largest of these).
  (desktop-sizes  chrome-remote-desktop-configuration-desktop-sizes
                  (default "1920x1080,2560x1440,3840x2160"))
  ;; #t: Xvfb instead of Xorg + dummy driver.
  (use-xvfb?      chrome-remote-desktop-configuration-use-xvfb?
                  (default #f))
  ;; Shell command starting the X11 desktop in the virtual display, run
  ;; with its own D-Bus session bus.  ~/.chrome-remote-desktop-session, if
  ;; it exists, takes precedence.
  (session-command chrome-remote-desktop-configuration-session-command
                   (default "startxfce4"))
  ;; Packages providing that desktop.  They get a profile of their own that
  ;; only the remote session sees, so they don't show up in the local
  ;; desktop's menus (Thunar & co. in COSMIC).
  (desktop-packages chrome-remote-desktop-configuration-desktop-packages
                    (default (list xfce))))

(define (chrome-remote-desktop-desktop-profile config)
  (profile
    (name "chrome-remote-desktop-desktop")
    (content (packages->manifest
              (chrome-remote-desktop-configuration-desktop-packages config)))))

(define (chrome-remote-desktop-session-file config)
  (let ((desktop (chrome-remote-desktop-desktop-profile config)))
    (mixed-text-file "chrome-remote-desktop-session"
                     "#!/bin/sh
# Desktop started inside the Chrome Remote Desktop virtual X display.
# (COSMIC can't run here: cosmic-comp needs a real GPU/DRM device.)
unset WAYLAND_DISPLAY
export XDG_SESSION_TYPE=x11
export PATH=\"" desktop "/bin:$PATH\"
export XDG_DATA_DIRS=\"" desktop "/share:${XDG_DATA_DIRS:-/run/current-system/profile/share}\"
export XDG_CONFIG_DIRS=\"" desktop "/etc/xdg:${XDG_CONFIG_DIRS:-/etc/xdg}\"
exec " dbus "/bin/dbus-run-session -- "
                     (chrome-remote-desktop-configuration-session-command config)
                     "\n")))

(define (chrome-remote-desktop-shepherd-service config)
  (match-record config <chrome-remote-desktop-configuration>
    (package user desktop-sizes use-xvfb?)
    (let ((command
           (string-append
            "exec env CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES="
            desktop-sizes
            (if use-xvfb? " CHROME_REMOTE_DESKTOP_USE_XVFB=1" "")
            " /opt/google/chrome-remote-desktop/chrome-remote-desktop"
            " --start --new-session")))
      (define host-config?
        ;; Whether start-host / the web page has registered a host yet.
        #~(lambda ()
            (let ((dir (string-append (passwd:dir (getpwnam #$user))
                                      "/.config/chrome-remote-desktop")))
              (pair? (or (scandir dir
                                  (lambda (f)
                                    (and (string-prefix? "host#" f)
                                         (string-suffix? ".json" f))))
                         '())))))
      (define log-file "/var/log/chrome-remote-desktop.log")
      (list
       (shepherd-service
        (provision '(chrome-remote-desktop))
        (requirement '(user-processes networking))
        (documentation
         "Chrome Remote Desktop host (virtual X11 desktop) for one user.")
        (modules `((ice-9 ftw) (srfi srfi-1) ,@%default-modules))
        (start
         #~(lambda _
             (if (#$host-config?)
                 ;; su opens a PAM session (elogind session, runtime dir)
                 ;; the way systemd's PAMName= does for upstream's unit.
                 (fork+exec-command
                  (list #$(file-append shadow "/bin/su") "-l" #$user
                        "-c" #$command)
                  #:log-file #$log-file)
                 (begin
                   ;; Only in the log file, never on the console.
                   (let ((port (open-file #$log-file "a")))
                     (format port "chrome-remote-desktop: no host \
configuration in ~~~a/.config/chrome-remote-desktop yet; set the host up \
with start-host first.~%" #$user)
                     (close-port port))
                   #f))))
        (stop #~(make-kill-destructor))
        ;; The script exits with 41 to be restarted after the remote user
        ;; logs out of the virtual desktop.
        (respawn? #t)
        (respawn-delay 5)
        ;; Started at boot by chrome-remote-desktop-autostart (only once a
        ;; host is registered), and by start-host / the web page through
        ;; "herd start chrome-remote-desktop".
        (auto-start? #f))
       (shepherd-service
        (provision '(chrome-remote-desktop-autostart))
        (requirement '(user-processes networking))
        (documentation
         "Start chrome-remote-desktop at boot if a host is registered.")
        (modules `((ice-9 ftw) (srfi srfi-1) ,@%default-modules))
        (one-shot? #t)
        (start
         #~(lambda _
             (when (#$host-config?)
               (false-if-exception
                (start-service (lookup-service 'chrome-remote-desktop))))
             #t)))))))

(define (chrome-remote-desktop-activation config)
  (let ((package (chrome-remote-desktop-configuration-package config)))
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          ;; The native-messaging host and start-host run the script at this
          ;; fixed path (compiled into libremoting_core.so).
          (mkdir-p "/opt/google")
          (switch-symlinks "/opt/google/chrome-remote-desktop"
                           #$(file-append package
                                          "/lib/chrome-remote-desktop"))))))

(define (chrome-remote-desktop-etc-files config)
  (let ((package (chrome-remote-desktop-configuration-package config)))
    `(("chrome-remote-desktop-session"
       ,(chrome-remote-desktop-session-file config))
      ;; Google Chrome's system-wide native-messaging manifests.
      ("opt/chrome/native-messaging-hosts"
       ,(file-append package "/etc/opt/chrome/native-messaging-hosts")))))

(define chrome-remote-desktop-service-type
  (service-type
   (name 'chrome-remote-desktop)
   (extensions
    (list (service-extension shepherd-root-service-type
                             chrome-remote-desktop-shepherd-service)
          (service-extension activation-service-type
                             chrome-remote-desktop-activation)
          (service-extension etc-service-type
                             chrome-remote-desktop-etc-files)
          ;; The host checks the account with PAM service
          ;; "chrome-remote-desktop"; without it PAM falls back to "other",
          ;; which denies everything on Guix.
          (service-extension pam-root-service-type
                             (const (list (unix-pam-service
                                           "chrome-remote-desktop"))))
          (service-extension profile-service-type
                             (compose list
                                      chrome-remote-desktop-configuration-package))))
   (description
    "Run the Chrome Remote Desktop host for one user, serving a virtual X11
desktop.")))
