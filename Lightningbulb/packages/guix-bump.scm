;;; Lightningbulb channel --- `guix bump' and `guix nightly'
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

(define-module (Lightningbulb packages guix-bump)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages version-control))

(define-public guix-bump
  (package
    (name "guix-bump")
    (version "1.1")
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
