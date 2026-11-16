;;; hyperguix --- `guix bump', `guix nightly' and Guix Manager
;;;
;;; https://github.com/Lightningbulb2/GuixManager, at the head of its main
;;; branch: two Guix extensions (commands that Guix finds under
;;; share/guix/extensions of any installed profile) and a window on them.
;;;
;;;   guix bump ...     move the (commit "...") pins in the config file,
;;;                     pull, apply; check for, install and remove apps
;;;   guix nightly      guix bump all --system --home --yes --gc --log
;;;                     --shutdown
;;;   guix-manager      the window "Guix Manager"

(define-module (hyperguix packages guix-bump)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages python)
  #:use-module (gnu packages version-control))

(define %guix-manager-commit "1105e172cd132b362184c8f3b369fa145a8a8bc9")
(define %guix-manager-version "2.4")

(define %guix-manager-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/Lightningbulb2/GuixManager")
          (commit %guix-manager-commit)))
    (file-name (git-file-name "guix-manager" %guix-manager-version))
    (sha256
     (base32 "0drvpzxhdqiz3kfzc4jfr9sg0jv5vf6nk0cg6g8gz91klhsk34gl"))))

(define-public guix-bump
  (package
    (name "guix-bump")
    (version %guix-manager-version)
    (source %guix-manager-source)
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("extensions" "share/guix/extensions")
          ("README.md" "share/doc/guix-bump/")
          ("ARCHITECTURE.md" "share/doc/guix-bump/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'refer-to-programs
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((file "extensions/guix/extensions/bump.scm"))
                (substitute* file
                  (("@GIT@") (search-input-file inputs "bin/git"))
                  (("@BASH@") (search-input-file inputs "bin/bash")))
                ;; A pattern that matches nothing is not an error, so check.
                (unless (zero? (system* "grep" "-q" "/bin/git\"" file))
                  (error "bump.scm: @GIT@ was not replaced"))))))))
    (inputs (list bash-minimal git-minimal))
    ;; So a profile holding this package exports GUIX_EXTENSIONS_PATH even
    ;; when `guix' itself comes from `guix pull' and isn't in the profile.
    (native-search-paths
     (list (search-path-specification
            (variable "GUIX_EXTENSIONS_PATH")
            (files '("share/guix/extensions")))))
    (home-page "https://github.com/Lightningbulb2/GuixManager")
    (synopsis "Update, install and remove apps through a Guix config file")
    (description
     "@command{guix bump} rewrites the pinned channel commits in a Guix
configuration file to the latest ones, runs @command{guix pull} to them and
can then reconfigure the home environment or the system.  It also lists the
installed apps that have a newer version, updates one by name, and installs
or removes apps by editing a list of package names in the configuration
file.  @command{guix nightly} updates everything and powers the computer
off.")
    (license license:gpl3+)))

(define-public guix-manager
  (package
    (name "guix-manager")
    (version %guix-manager-version)
    (source %guix-manager-source)
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("guix-manager" "bin/")
          ("data/io.github.lightningbulb2.GuixManager.desktop"
           "share/applications/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'absolute-exec
            (lambda _
              (substitute* (string-append
                            #$output "/share/applications/"
                            "io.github.lightningbulb2.GuixManager.desktop")
                (("^Exec=guix-manager")
                 (string-append "Exec=" #$output "/bin/guix-manager")))))
          (add-after 'patch-shebangs 'wrap
            (lambda _
              (wrap-program (string-append #$output "/bin/guix-manager")
                `("GI_TYPELIB_PATH" ":" prefix (,(getenv "GI_TYPELIB_PATH")))
                `("GUIX_PYTHONPATH" ":" prefix (,(getenv "GUIX_PYTHONPATH")))
                ;; The commands it runs, whatever the profile exports.
                `("GUIX_EXTENSIONS_PATH" ":" prefix
                  (,(string-append #$(this-package-input "guix-bump")
                                   "/share/guix/extensions")))
                ;; setsid, which Cancel uses to stop a background query and
                ;; everything it started.
                `("PATH" ":" suffix
                  (,(string-append #$(this-package-input "util-linux")
                                   "/bin")))
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
           util-linux
           vte))
    (home-page "https://github.com/Lightningbulb2/GuixManager")
    (synopsis "Update, install and remove apps through the Guix config")
    (description
     "Guix Manager shows which installed apps have a newer version and
updates them, searches for packages and installs them, and removes apps or
chooses their version.  It is a front end to @command{guix bump}: every
button runs a @command{guix bump} command in a terminal pane of the window,
and every change is written into the configuration file, which stays the
only description of the machine.")
    (license license:gpl3+)))
