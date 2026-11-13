;;; guix nightly --- update everything, then power off
;;;
;;; Bump every channel pin, pull, reconfigure the system and the home
;;; environment, clean up old generations, and power off, with a log.  If a step fails the computer stays on with
;;; the error on screen.

(define-module (guix extensions nightly)
  #:use-module (guix scripts)
  #:use-module (guix extensions bump)
  #:export (guix-nightly))

(define-command (guix-nightly . args)
  (category extension)
  (synopsis "bump every channel, pull, reconfigure system and home, power off")
  (if (or (member "-h" args) (member "--help" args))
      (begin
        (display "Usage: guix nightly [-- BUILD-OPTION...]
Short for: guix bump all --system --home --yes --gc --log --shutdown

Asks for the sudo password once at the start.  Everything is also written to
a log in ~/.local/state/guix-bump.  If any step fails, the computer stays on
and the error stays on screen.  Add --dry-run to see which pins would move.
")
        (exit 0))
      (apply guix-bump "all" "--system" "--home" "--yes" "--gc" "--log"
             "--shutdown" args)))
