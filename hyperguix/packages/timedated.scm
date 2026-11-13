;;; hyperguix --- systemd's timedated without systemd
;;;
;;; COSMIC Settings (Date & Time) and other desktops read the time zone and
;;; the list of zones from the org.freedesktop.timedate1 D-Bus service.
;;; Guix ships localed the same way -- one daemon built out of the systemd
;;; tree -- so this package reuses that recipe for timedated.
;;;
;;; On Guix System the time zone is declared in the operating-system: a zone
;;; set from the desktop is written to /etc/localtime and lasts until the
;;; next reconfigure or reboot.  There's no timesyncd, so the NTP switch
;;; reports itself as unavailable.

(define-module (hyperguix packages timedated)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages freedesktop))

(define-public timedated
  (package
    (inherit localed)
    (name "timedated")
    (arguments
     (substitute-keyword-arguments (package-arguments localed)
       ((#:configure-flags flags)
        ;; localed's flags turn every component off except localed; turn
        ;; localed off too and timedated on.
        #~(cons* "-Dlocaled=false" "-Dtimedated=true"
                 (delete "-Dtimedated=false" #$flags)))
       ((#:phases phases)
        #~(modify-phases #$phases
            (delete 'set-xkeyboard-config-file-name)
            (add-after 'unpack 'use-store-zoneinfo
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((zoneinfo (search-input-directory inputs
                                                        "share/zoneinfo")))
                  (substitute* '("src/basic/time-util.c"
                                 "src/timedate/timedated.c")
                    (("\\.\\./usr/share/zoneinfo") zoneinfo)
                    (("/usr/share/zoneinfo") zoneinfo))
                  ;; /etc/localtime points into whichever tzdata the system
                  ;; was built with, which need not be this one: accept any
                  ;; `.../zoneinfo/ZONE' link target.
                  (substitute* "src/basic/time-util.c"
                    (("PATH_STARTSWITH_SET\\(t, \"[^\"]*\", \"[^\"]*\"\\)")
                     "(strstr(t, \"/zoneinfo/\") ? \
strstr(t, \"/zoneinfo/\") + strlen(\"/zoneinfo/\") : NULL)")))))
            (replace 'install
              (lambda _
                ;; Install 'timedated', the D-Bus and polkit files, and
                ;; 'timedatectl'.
                (let* ((out #$output)
                       (libexec (string-append out "/libexec/timedated"))
                       (bin     (string-append out "/bin"))
                       (lib     (string-append out "/lib"))
                       (dbus    (string-append out
                                               "/share/dbus-1/system-services"))
                       (conf    (string-append out "/etc/dbus-1/system.d/"))
                       (polkit  (string-append out
                                               "/share/polkit-1/actions")))
                  (define (source-file regexp)
                    (car (find-files ".." regexp)))

                  (mkdir-p libexec)
                  (copy-file "systemd-timedated"
                             (string-append libexec "/timedated"))
                  (install-file "timedatectl" bin)
                  (let ((service-file
                         (source-file "\\.timedate1\\.service$")))
                    (substitute* service-file
                      (("^Exec=.*$")
                       (string-append "Exec=" libexec "/timedated\n"))
                      ;; There's no systemd to hand the service over to.
                      (("^SystemdService=.*$") ""))
                    (install-file service-file dbus))
                  (install-file (source-file "\\.timedate1\\.policy$") polkit)
                  (install-file (source-file "\\.timedate1\\.conf$") conf)
                  (for-each (lambda (file)
                              (install-file file lib))
                            (find-files "src/shared"
                                        "libsystemd-shared.*\\.so")))))))))
    (inputs
     (modify-inputs (package-inputs localed)
       (delete "kbd" "xkeyboard-config")
       (prepend tzdata)))
    (home-page "https://www.freedesktop.org/software/systemd/man/latest/systemd-timedated.service.html")
    (synopsis "Query and change the system time zone over D-Bus")
    (description
     "Timedated is a tiny daemon that provides the
@code{org.freedesktop.timedate1} D-Bus interface, through which desktop
settings panels read and change the system time zone.  The
@command{timedatectl} command-line tool talks to it.  This package is
extracted from the broader systemd package.")
    (license license:lgpl2.1+)))
