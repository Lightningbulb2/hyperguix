;;; faforever.scm --- A Guix package for the Forged Alliance Forever client
;;;
;;; IMPORTANT — read README.md before using this channel. Short version:
;;;
;;;   * This is ONE package, `faf-client', not two. It repackages
;;;     FAForever's own official prebuilt Linux release tarball of
;;;     https://github.com/FAForever/downlords-faf-client (a Gradle/JavaFX
;;;     app) rather than building it from source, which is why this lives
;;;     in a personal channel and not upstream Guix.
;;;
;;;   * It installs two commands: `faf-client' (the lobby/matchmaking
;;;     app) and `faf-client-setup' (a detect-and-configure script for
;;;     Supreme Commander: Forged Alliance, which you must already own
;;;     and have installed via Steam, or already have set up under plain
;;;     Wine). Earlier drafts of this channel split these into two
;;;     packages and additionally tried to reimplement
;;;     https://github.com/FAForever/faf-linux's approach of downloading
;;;     Proton-GE/a Steam Runtime image/DXVK/DirectX at setup time. Both
;;;     of those decisions were wrong: see README.md for why, and for the
;;;     credit this design actually owes to nix-gaming.
;;;
;;; Not appropriate for upstreaming into Guix proper.

(define-module (faforever)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)          ; for `specification->package'
  #:use-module (gnu packages bash)     ; bash-minimal
  #:use-module (faforever source)      ; faf-client-src (experimental)
  #:use-module (faforever fhs-run)     ; fhs-run (nonguix FHS sandbox tool)
  #:re-export (faf-client-src
               fhs-run))

;; See the comment on this same helper in the previous revision of this
;; file: packages are looked up by name via `specification->package'
;; rather than imported module-by-module, purely so a wrong guess at
;; which gnu/packages/*.scm file something lives in produces a clear
;; runtime error naming the package, instead of a module-import failure
;; that's harder to place. Swap for direct #:use-module imports once
;; you've confirmed module paths against a real Guix checkout.
(define (spec name)
  (specification->package name))

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
;; MIT, credit: chayleaf and contributors) — a real, currently-maintained
;; package doing the same job for Nix. Notably, nix-gaming *builds from
;; source* using nixpkgs' `gradle.fetchDeps` (a mitm-proxy tool that
;; records every Maven/Gradle download once into a lockfile, then replays
;; it offline in the sandbox — nixpkgs' answer to "Gradle wants the
;; network mid-build"). Guix has no equivalent tool yet, which is the
;; concrete, specific gap blocking a from-source Guix package here (not
;; that the dependencies — Spring, Jackson, JavaFX, ~195 jars in total —
;; are individually unusual; they aren't). Building that tool, or
;; hand-writing ~195 Guix package definitions instead, is real work
;; that's out of scope for this channel; see README.md.
;;
;; So: this package instead repackages FAForever's own prebuilt Linux
;; release tarball (named e.g. "faf_unix_2026_7_0.tar.gz", attached to
;; GitHub release v2026.7.0). Inside it:
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
              ;; path) indicate copy-build-system's install-plan simply
              ;; wasn't putting natives/faf-uid where I assumed --
              ;; rather than guess again at its exact directory-copy
              ;; semantics, do this one explicitly myself: copy straight
              ;; from the still-current unpacked source tree (phases
              ;; don't change the working directory, so "natives/..."
              ;; below is still valid here, after 'install) to a path I
              ;; fully control, and set the permission bit on that exact
              ;; same path -- no more guessing about what an
              ;; intermediate copy step does or doesn't preserve.
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
