;;; faforever.scm --- Guix packages for Forged Alliance Forever
;;;
;;; IMPORTANT — read README.md before using this channel. Short version:
;;;
;;;   * Two packages, both in this one file (in dependency order:
;;;     `fhs-run' first, since `faf-client' propagates it as a
;;;     dependency -- see below -- and needs it defined first):
;;;
;;;     - `fhs-run': a genuine general-purpose "run an arbitrary
;;;       command inside Steam's FHS sandbox" tool, needed because
;;;       nonguix's own `steam' package doesn't expose one (confirmed
;;;       from its actual source: it always execs one hardcoded target,
;;;       Steam itself, with no equivalent of nixpkgs' `steam-run').
;;;       Built from nonguix's own `nonguix-container' machinery,
;;;       reusing its exact `steam-container-libs' list.
;;;
;;;     - `faf-client': repackages FAForever's own official prebuilt
;;;       Linux release of https://github.com/FAForever/downlords-faf-client
;;;       (a Gradle/JavaFX app) rather than building it from source,
;;;       which is why this lives in a personal channel and not
;;;       upstream Guix. Installs two commands: `faf-client' itself,
;;;       and `faf-client-setup' (a detect-and-configure script for
;;;       Supreme Commander: Forged Alliance, which you must already
;;;       own and have installed via Steam, or already have set up
;;;       under plain Wine). `faf-client-setup.py' is a separate FILE
;;;       purely for readability (600+ lines of Python is unwieldy as
;;;       an escaped Scheme string) -- it is NOT a separate package;
;;;       it's built directly into `faf-client's own output. `faf-client'
;;;       also `propagated-inputs's `fhs-run', so `guix install
;;;       faf-client' alone gets you both.
;;;
;;;   * An earlier revision of this channel also had an experimental,
;;;     from-source `faf-client-src' (via a Gradle+mitm-cache build) in
;;;     two extra files, plus a from-scratch attempt at reimplementing
;;;     https://github.com/FAForever/faf-linux's Proton/DXVK-downloading
;;;     approach as a *third* package before that. Both were dropped:
;;;     neither was needed to actually get FAF running, and "so many
;;;     files/packages" was a fair complaint on its own. See README.md
;;;     if you want the full history/reasoning, or want that from-source
;;;     build back.
;;;
;;; Not appropriate for upstreaming into Guix proper.

(define-module (Lightningbulb packages faforever)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)              ; for `specification->package'
  #:use-module (gnu packages bash)         ; bash-minimal
  #:use-module (gnu packages base)         ; coreutils, for fhs-run
)

;; Packages are looked up by name via `specification->package' rather
;; than imported module-by-module, purely so a wrong guess at which
;; gnu/packages/*.scm file something lives in produces a clear runtime
;; error naming the package, instead of a module-import failure that's
;; harder to place.
(define (spec name)
  (specification->package name))

;; ---------------------------------------------------------------------
;; fhs-run
;; ---------------------------------------------------------------------
;;
;; nonguix's own `steam' package (nongnu/packages/game-client.scm) is
;; architecturally single-purpose: its `nonguix-container' is built with
;; `(run "/bin/steam")', and `fhs-internal' (the script that actually
;; sets up the FHS symlinks inside the container) always execs that one
;; hardcoded target. There is no general "run arbitrary command X inside
;; this same sandbox" mechanism exposed, unlike nixpkgs' `steam-run'.
;;
;; This recreates that missing general-purpose tool using nonguix's own
;; `nonguix-container' machinery directly: the same FHS union of
;; libraries Steam itself uses (literally the same `steam-container-libs'
;; list, reused via `(@@ ...)' since it's a private binding in
;; game-client.scm -- not copied/reconstructed by hand, to avoid getting
;; a large, easy-to-typo library list subtly wrong), but with `run'
;; pointed at plain `env' instead of Steam's launcher. Since
;; `env PROGRAM ARGS...' just execs PROGRAM with ARGS, invoking the
;; resulting `fhs-run' command as
;;
;;   fhs-run /path/to/some/binary --some-arg --another-arg
;;
;; runs that exact command inside the same FHS-configured container
;; Steam uses, with full control over the executable and every
;; argument -- which is what FAF's `executableDecorator' + "%s"
;; substitution actually needs (unlike `steam -applaunch', which only
;; ever launches Steam's own configured executable for an App ID and
;; can't substitute a different one).
;;
;; NOTE: `(run "/bin/env")' below MUST keep its leading slash.
;; `file-append' concatenates the package's own store path directly with
;; this string, with no separator inserted automatically -- omitting the
;; slash here previously produced a literal, broken path
;; ("...coreutils-9.1bin/env") and a real "No such file or directory"
;; failure at the exec step. Confirmed by matching against nonguix's own
;; `(run "/bin/steam")' convention in game-client.scm.
(define (steam-container-libs*)
  ;; `steam-container-libs' is a plain (define ...), not (define-public
  ;; ...), in (nongnu packages game-client) -- not exported. `(@@ ...)'
  ;; is the standard, precedented way to reach an unexported binding in
  ;; another module when you specifically want it (nonguix's own
  ;; multiarch-container.scm does exactly this for `glibc-for-fhs' in
  ;; (gnu packages base)).
  (@@ (nongnu packages game-client) steam-container-libs))

(define fhs-run-container
  (nonguix-container
   (name "fhs-run")
   (wrap-package coreutils)
   (run "/bin/env")
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
controlled command line (for example, a game launcher like the Forged
Alliance Forever client that constructs its own precise launch command
rather than just wanting extra arguments appended to whatever Steam
already knows how to launch).")))

(define-public fhs-run (nonguix-container->package fhs-run-container))

;; ---------------------------------------------------------------------
;; faf-client
;; ---------------------------------------------------------------------
;;
;; Upstream: https://github.com/FAForever/downlords-faf-client (MIT)
;;
;; Packaging approach and the native-library list below were checked
;; against, and the launcher script's JVM flags and classpath-building
;; trick were adapted from, nix-gaming's faf-client package
;; (https://github.com/fufexan/nix-gaming/blob/master/pkgs/faf-client/,
;; MIT, credit: chayleaf and contributors).
;;
;; This repackages FAForever's own prebuilt Linux release tarball
;; (named e.g. "faf_unix_2026_7_0.tar.gz", attached to GitHub release
;; v2026.7.0). Inside it:
;;
;;   - lib/*.jar        ~195 jars, incl. `faf-client-<ver>-plain.jar',
;;                       the actual application
;;                       (Main-Class: com.faforever.client.Main).
;;   - natives/          faf-uid (static ELF, no dynamic deps; also a
;;                       .exe/macOS build we don't need and drop),
;;                       faf-ice-adapter.jar.
;;   - .install4j/        install4j's proprietary runtime + a generated
;;                       launcher wrapper. Not needed to run the app —
;;                       `com.faforever.client.Main' can be started with
;;                       a plain classpath invocation instead (confirmed
;;                       from the jar's own manifest) — so we drop this
;;                       directory entirely and never touch it.
(define-public faf-client
  (package
    (name "faf-client")
    (version "2026.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/FAForever/downlords-faf-client/releases/"
             "download/v" version "/faf_unix_"
             (string-map (lambda (c) (if (char=? c #\.) #\_ c)) version)
             ".tar.gz"))
       (sha256
        (base32
         ;; Computed locally from the actual downloaded tarball
         ;; (sha256 hex: 28bcddcf6b5b5b0e0b1441229346507837aa586c2c16d518011f35f93adcbc46)
         ;; and converted to Guix's base32 by hand -- double-check this
         ;; against `guix download <url>' before relying on it.
         "0imwvhxgjd8z04cda5icdicaldvqa13968j12h5hwnsvdg7xvg18"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("lib" "share/faf-client/lib/")
          ("faf-client.vmoptions" "share/faf-client/")
          ("steam_appid.txt" "share/faf-client/"))
      #:modules '((guix build copy-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'drop-nonfree-install4j-bits
            (lambda _
              (when (file-exists? ".install4j")
                (delete-file-recursively ".install4j"))
              ;; Windows/macOS-only; drop rather than ship other-OS/arch
              ;; binaries in a Linux-only package.
              (for-each (lambda (f)
                          (when (file-exists? (string-append "natives/" f))
                            (delete-file (string-append "natives/" f))))
                        '("faf-uid.exe" "faf-uid-macos"))))
          (add-after 'install 'install-natives
            (lambda* (#:key outputs #:allow-other-keys)
              ;; Two ENOENT errors in a row (first from `execve', then
              ;; from `chmod', both against the exact same computed
              ;; path) indicated copy-build-system's install-plan simply
              ;; wasn't putting natives/faf-uid where assumed -- rather
              ;; than guess again at its exact directory-copy semantics,
              ;; this is done explicitly instead: copy straight from the
              ;; still-current unpacked source tree (phases don't change
              ;; the working directory, so "natives/..." below is still
              ;; valid here, after 'install) to a path fully controlled
              ;; here, and set the permission bit on that exact same
              ;; path -- no more guessing about what an intermediate
              ;; copy step does or doesn't preserve.
              (let* ((out     (assoc-ref outputs "out"))
                     (natives (string-append out "/share/faf-client/natives")))
                (mkdir-p natives)
                (copy-file "natives/faf-uid" (string-append natives "/faf-uid"))
                (chmod (string-append natives "/faf-uid") #o755)
                (copy-file "natives/faf-ice-adapter.jar"
                           (string-append natives "/faf-ice-adapter.jar")))))
          (add-after 'install-natives 'install-launcher
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out   (assoc-ref outputs "out"))
                     (share (string-append out "/share/faf-client"))
                     (bin   (string-append out "/bin"))
                     (java  (search-input-file inputs "bin/java")))
                (mkdir-p bin)
                ;; JVM flags and the "classpath = every jar except the
                ;; ice-adapter one" trick both follow nix-gaming's
                ;; start.sh, which has been shaking out real-world
                ;; problems (memory limits, GC pauses, javafx cache
                ;; location) for a while now.
                (call-with-output-file (string-append bin "/faf-client")
                  (lambda (port)
                    (format port
                            "#!~a
# Bypasses upstream's install4j launcher and starts the real application
# entry point directly; see the comment on the `faf-client' package in
# faforever.scm for why that's fine.
set -e
cd ~a
export LD_LIBRARY_PATH=\"~a${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"
export LOG_DIR=\"${LOG_DIR:-$HOME/.faforever/logs}\"
cp=\"$(find ~a/lib -type f -name '*.jar' \\
       ! -name 'faf-ice-adapter.jar' -printf '%p:' | sed 's/:$//')\"
exec ~a \\
     -Xmx712m -XX:ConcGCThreads=1 -XX:ParallelGCThreads=1 -XX:+UseG1GC \\
     -XX:+HeapDumpOnOutOfMemoryError \\
     -Djava.net.preferIPv4Stack=true \\
     \"-DnativeDir=~a/natives\" \\
     -Dprism.forceGPU=true \\
     \"-Djava.library.path=~a/lib\" \\
     --add-opens=java.base/java.lang=ALL-UNNAMED \\
     \"-Djavafx.cachedir=${XDG_CACHE_HOME:-$HOME/.cache}/openjfx\" \\
     -classpath \"$cp\" \\
     com.faforever.client.Main \"$@\"\n"
                            (search-input-file inputs "bin/bash")
                            share
                            "@LIB_PLACEHOLDER@"
                            share java share share)))
                (chmod (string-append bin "/faf-client") #o755)
                ;; The setup script has zero Guix-specific dependencies
                ;; (stdlib-only port of nix-gaming's faf-client-setup.py;
                ;; see README.md), so it's just copied in and chmod'd.
                (copy-file #$(local-file "faf-client-setup.py")
                           (string-append bin "/faf-client-setup"))
                (chmod (string-append bin "/faf-client-setup") #o755)
                ;; The script's own shebang says `#!/usr/bin/env python3',
                ;; which only works if python3 happens to be on the
                ;; invoking user's PATH already. `patch-shebang' rewrites
                ;; it to the absolute store path of the `python' input
                ;; instead, which is the standard Guix fix for exactly
                ;; this situation.
                (patch-shebang (string-append bin "/faf-client-setup")))))
          (add-after 'install-launcher 'wrap-native-library-path
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     ;; JavaFX on Linux ships its own native libraries
                     ;; (libglass.so, libprism_es2.so,
                     ;; libgstreamer-lite.so, libjfxwebkit.so, ...)
                     ;; *inside* the javafx-*-linux jars, extracted to a
                     ;; cache dir at runtime, carrying no RPATH/RUNPATH
                     ;; at all (checked with readelf), so on a non-FHS
                     ;; system they need LD_LIBRARY_PATH to find their
                     ;; deps. This exact 9-package list is what
                     ;; nix-gaming's working package uses for the same
                     ;; jars (mesa/libGL, libx11, libxxf86vm, libxtst,
                     ;; gtk+/gtk3, pango, glib, fontconfig, freetype,
                     ;; alsa-lib) — cairo/atk/gdk-pixbuf aren't listed
                     ;; separately because gtk+'s own RPATH already
                     ;; resolves those once LD_LIBRARY_PATH gets it that
                     ;; far, on both Nix and Guix.
                     (lib-inputs
                      '("mesa" "libx11" "libxxf86vm" "libxtst" "gtk+"
                        "pango" "glib" "fontconfig" "freetype" "alsa-lib"))
                     (path (let loop ((names lib-inputs) (acc ""))
                             (if (null? names)
                                 acc
                                 (let ((dir (string-append
                                             (assoc-ref inputs (car names))
                                             "/lib")))
                                   (loop (cdr names)
                                         (if (= (string-length acc) 0)
                                             dir
                                             (string-append acc ":" dir)))))))
                     (launcher (string-append out "/bin/faf-client")))
                (substitute* launcher
                  (("@LIB_PLACEHOLDER@") path))))))))
    (native-inputs '())
    (propagated-inputs (list fhs-run)) ; so `guix install faf-client'
                                        ; alone gets you `fhs-run' too --
                                        ; faf-client-setup needs it to
                                        ; build the actual game launch
                                        ; command
    (inputs
     (list bash-minimal
           (spec "openjdk")   ; MUST be >= 25 -- see README.md
           (spec "mesa")
           (spec "libx11")
           (spec "libxxf86vm")
           (spec "libxtst")
           (spec "gtk+")
           (spec "pango")
           (spec "glib")
           (spec "fontconfig")
           (spec "freetype")
           (spec "alsa-lib")
           (spec "python")))  ; runs faf-client-setup
    (home-page "https://faforever.com/")
    (synopsis "Client for the Forged Alliance Forever community game service")
    (description
     "This package repackages FAForever's own official prebuilt Linux
release of @code{downlords-faf-client}, the JavaFX-based lobby, patcher,
and matchmaking client for Supreme Commander: Forged Alliance, played
online via the Forged Alliance Forever (FAF) community project. It
provides two commands:

@table @command
@item faf-client
The lobby/matchmaking application itself.
@item faf-client-setup
A detect-and-configure script for the game launch command: it looks for
an existing Steam install of Supreme Commander: Forged Alliance (which
you must already own — this package cannot provide it) and its
Steam-managed Proton prefix, or asks you to point it at a plain Wine
prefix instead, and writes @file{~/.faforever/client.prefs} accordingly.
It does not install or download Wine, Proton, or DXVK itself.
@end table")
    (license license:expat)))
