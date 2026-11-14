;;; hyperguix --- `guix bump' and `guix nightly'
;;;
;;; Two Guix extensions (commands that Guix finds under
;;; share/guix/extensions of any installed profile):
;;;
;;;   guix bump [CHANNEL...|all] [--home] [--system] [--undo] ...
;;;       move the (commit "...") pins in the config file to the latest
;;;       commit of each channel, pull, and optionally apply
;;;   guix nightly
;;;       guix bump all --system --home --yes --gc --log --shutdown
;;;
;;; The config file is $GUIX_BUMP_CONFIG, or ~/config.scm.

(define-module (hyperguix packages guix-bump)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages python)
  #:use-module (gnu packages version-control))

(define-public guix-bump
  (package
    (name "guix-bump")
    (version "1.5")
    (source (local-file "aux-files/guix-bump" "guix-bump-source"
                        #:recursive? #t))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      ;; ".in": `guix pull' compiles every .scm file of a channel.
      #~'(("bump.scm.in" "share/guix/extensions/guix/extensions/bump.scm")
          ("nightly.scm.in"
           "share/guix/extensions/guix/extensions/nightly.scm"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'set-git
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "bump.scm.in"
                (("@GIT@") (search-input-file inputs "bin/git"))
                (("@BASH@") (search-input-file inputs "bin/bash"))))))))
    (inputs (list bash-minimal git-minimal))
    ;; So a profile holding this package exports GUIX_EXTENSIONS_PATH even
    ;; when `guix' itself comes from `guix pull' and isn't in the profile.
    (native-search-paths
     (list (search-path-specification
            (variable "GUIX_EXTENSIONS_PATH")
            (files '("share/guix/extensions")))))
    (home-page "https://guix.gnu.org")
    (synopsis "Move channel pins in a Guix config, pull and apply")
    (description
     "@command{guix bump} rewrites the pinned channel commits in a Guix
configuration file to the latest ones, runs @command{guix pull} to them and
can then reconfigure the home environment or the system.  @command{guix
nightly} does all of it and powers the computer off.")
    (license license:gpl3+)))

(define-public guix-manager
  (package
    (name "guix-manager")
    (version "0.2")
    (source (local-file "aux-files/guix-bump" "guix-bump-source"
                        #:recursive? #t))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("manager.py.in" "bin/guix-manager"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'set-python
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "manager.py.in"
                (("@PYTHON@") (search-input-file inputs "bin/python3")))))
          (add-after 'install 'install-desktop-file
            (lambda _
              (chmod (string-append #$output "/bin/guix-manager") #o755)
              (let ((dir (string-append #$output "/share/applications")))
                (mkdir-p dir)
                (call-with-output-file
                    (string-append
                     dir "/io.github.lightningbulb2.GuixManager.desktop")
                  (lambda (port)
                    (format port "[Desktop Entry]
Type=Application
Name=Guix Manager
Comment=Update, install and remove apps; every change goes into the config
Exec=~a/bin/guix-manager
Icon=system-software-update
Terminal=false
Categories=System;Settings;GTK;
Keywords=update;upgrade;install;remove;uninstall;software;packages;guix;bump;
StartupNotify=true
" #$output))))))
          (add-after 'install-desktop-file 'wrap
            (lambda _
              (wrap-program (string-append #$output "/bin/guix-manager")
                `("GI_TYPELIB_PATH" ":" prefix (,(getenv "GI_TYPELIB_PATH")))
                `("GUIX_PYTHONPATH" ":" prefix (,(getenv "GUIX_PYTHONPATH")))
                ;; The commands it runs, whatever the profile exports.
                `("GUIX_EXTENSIONS_PATH" ":" prefix
                  (,(string-append #$(this-package-input "guix-bump")
                                   "/share/guix/extensions")))
                ;; Symbolic icons, on desktops without the Adwaita theme.
                `("XDG_DATA_DIRS" ":" suffix
                  (,(string-append #$(this-package-input "adwaita-icon-theme")
                                   "/share")))))))))
    (inputs
     (list adwaita-icon-theme
           bash-minimal
           gobject-introspection
           gtk
           guix-bump
           libadwaita
           python
           python-pygobject
           vte))
    (home-page "https://github.com/Lightningbulb2/hyperguix")
    (synopsis "Update, install and remove apps through the Guix config")
    (description
     "Guix Manager shows which installed apps have a newer version and
updates them, searches for packages and installs them, and removes apps or
chooses their version.  It is a front end to @command{guix bump}: every
button runs a @command{guix bump} command in a terminal pane of the window,
and every change is written into the configuration file, which stays the
only description of the machine.")
    (license license:gpl3+)))
