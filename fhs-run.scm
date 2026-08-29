;;; faforever/fhs-run.scm --- a genuine steam-run equivalent for nonguix
;;;
;;; nonguix's own `steam' package (nongnu/packages/game-client.scm) is
;;; architecturally single-purpose: its `nonguix-container' is built
;;; with `(run "/bin/steam")', and `fhs-internal' (the script that
;;; actually sets up the FHS symlinks inside the container) always execs
;;; that one hardcoded target. There is no general "run arbitrary
;;; command X inside this same sandbox" mechanism exposed, unlike
;;; nixpkgs' `steam-run'.
;;;
;;; This recreates that missing general-purpose tool using nonguix's own
;;; `nonguix-container' machinery directly: same FHS union of libraries
;;; Steam itself uses (literally the same `steam-container-libs' list,
;;; reused via `(@@ ...)' since it's a private binding in
;;; game-client.scm -- not copied/reconstructed by hand, to avoid
;;; getting a large, easy-to-typo library list subtly wrong), but with
;;; `run' pointed at plain `env' instead of Steam's launcher. Since
;;; `env PROGRAM ARGS...' just execs PROGRAM with ARGS, invoking the
;;; resulting `fhs-run' command as
;;;
;;;   fhs-run /path/to/some/binary --some-arg --another-arg
;;;
;;; runs that exact command inside the same FHS-configured container
;;; Steam uses, with full control over the executable and every
;;; argument -- which is what FAF's `executableDecorator' + "%s"
;;; substitution actually needs (unlike `steam -applaunch', which only
;;; ever launches Steam's own configured executable for an App ID and
;;; can't substitute a different one).
;;;
;;; UNTESTED: I don't have nonguix's `steam' package (or a Guix daemon)
;;; available where I'm running, so this hasn't been built or run. The
;;; mechanism is transcribed directly from real, current nonguix source
;;; (both multiarch-container.scm and game-client.scm, both shared
;;; directly rather than guessed at), so this should be structurally
;;; sound, but "should be" is not "confirmed."

(define-module (faforever fhs-run)
  #:use-module (nonguix multiarch-container)
  #:use-module (gnu packages base)     ; coreutils
  #:export (fhs-run))

(define (steam-container-libs*)
  ;; `steam-container-libs' is a plain (define ...), not (define-public
  ;; ...), in (nongnu packages game-client) -- not exported. `(@@ ...)'
  ;; is the standard, precedented way to reach an unexported binding in
  ;; another module when you specifically want it (nonguix's own
  ;; multiarch-container.scm does exactly this for `glibc-for-fhs' in
  ;; (gnu packages base)). Reusing this list directly, rather than
  ;; retyping ~40 package references across a dozen gnu/packages/*.scm
  ;; modules by hand, avoids exactly the kind of module-path/typo risk
  ;; that's bitten this channel before.
  (@@ (nongnu packages game-client) steam-container-libs))

(define fhs-run-container
  (nonguix-container
   (name "fhs-run")
   (wrap-package coreutils)
   (run "bin/env")
   (packages (steam-container-libs*))
   (link-files '())
   (home-page "https://gitlab.com/nonguix/nonguix")
   (synopsis "Run an arbitrary command inside Steam's FHS sandbox")
   (description
    "This provides a single command, @command{fhs-run}, that runs
whatever program and arguments you give it inside the same FHS-
compatible Guix container nonguix's own @code{steam} package uses --
same bundled libraries, same @file{$HOME/.local/share/guix-sandbox-home}
convention -- but without Steam itself in the loop. Useful for anything
that needs to run inside that same sandbox with a specific, externally-
controlled command line (for example, a game launcher like the
Forged Alliance Forever client that constructs its own precise launch
command rather than just wanting extra arguments appended to whatever
Steam already knows how to launch).")))

(define-public fhs-run (nonguix-container->package fhs-run-container))
