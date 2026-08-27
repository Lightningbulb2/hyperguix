;;; faforever/source.scm --- faf-client built from source via Gradle,
;;; using mitm-cache to satisfy Gradle's dependency downloads from a
;;; pre-fetched, hash-verified cache instead of live network access.
;;;
;;; UNTESTED END TO END. I don't have a Guix daemon available where I'm
;;; running, so I could not actually run `guix build' on this. What IS
;;; tested (see faforever/lockfile.scm and README.md): the lockfile
;;; decompression algorithm and the SRI-hash conversion, both run for
;;; real with `guile' against the actual 995-entry lockfile and
;;; cross-checked against an independent Python implementation. What is
;;; NOT tested: everything in this file -- the CA generation, the
;;; mitm-cache-replay-as-background-proxy step, Gradle's proxy/truststore
;;; wiring, and the Gradle invocation itself. That said, none of it is
;;; guesswork either: the CA generation and the exact proxy/truststore
;;; JVM flags below are transcribed directly from nixpkgs' own, real,
;;; currently-used scripts --
;;; pkgs/by-name/mi/mitm-cache/setup-hook.sh and
;;; pkgs/development/tools/build-managers/gradle/setup-hook.sh -- not
;;; reverse-engineered from scratch. The main risk left is Guix-specific
;;; plumbing (does the Guix build container's network namespace permit
;;; loopback traffic the way Nix's does? I believe so, but haven't
;;; confirmed it) and whatever subtle differences exist between how
;;; Guix's `gnu-build-system' phases work versus Nix's hook arrays.
;;;
;;; KNOWN REGRESSION vs. the binary-repackaged `faf-client': this build
;;; needs install4j-gradle (a Gradle plugin) and install4j-runtime (a
;;; compile-time dependency) at BUILD time -- both nonfree, fetched from
;;; ej-technologies' own Maven repo -- because build.gradle declares
;;; them unconditionally and nix-gaming's patches don't remove that. The
;;; binary-repackage approach never touches install4j at all. This
;;; from-source approach trades that away for being mostly-from-source
;;; everywhere else. See README.md.

(define-module (faforever source)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (faforever lockfile)
  #:export (faf-client-src))

(define (spec name) (specification->package name))

(define (host-dirname path)
  (let loop ((i (- (string-length path) 1)))
    (cond ((< i 0) ".")
          ((char=? (string-ref path i) #\/) (substring path 0 i))
          (else (loop (- i 1))))))

;; Gradle itself, like nixpkgs, is used as its own official prebuilt
;; binary distribution rather than built from source -- Gradle's build
;; is itself a large bootstrapping problem, and nixpkgs doesn't build it
;; from source either (checked: pkgs/development/tools/build-managers/
;; gradle/default.nix literally does `fetchurl
;; https://services.gradle.org/distributions/gradle-9.5.1-bin.zip').
;; Version/hash below match nixpkgs' own `gradle_9' exactly, since that's
;; the version nix-gaming's build needs for this client version.
(define gradle-version "9.5.1")
(define gradle-bin-origin
  (origin
    (method url-fetch)
    (uri (string-append "https://services.gradle.org/distributions/gradle-"
                         gradle-version "-bin.zip"))
    (sha256
     (base32
      ;; Converted from nixpkgs' own recorded hash for this exact
      ;; version (sha256-uvwUG2Ga1jUP2XX8kDFW3VwVGZjMiwWOjBBEq197Ax8=),
      ;; not independently verified against a fresh download -- if it
      ;; doesn't match, trust `guix download' over this.
      "07q3gdgsni0hij70b2yck0ciap6xaqqr1z3mv47kbmlsc4di9z5s"))))

;; The official prebuilt release tarball is still used for exactly two
;; small pieces: faf-uid (a tiny native helper) and faf-ice-adapter.jar.
;; Building *those* from source too is a reasonable next step (they're
;; much smaller than the ~195-jar client and nix-gaming already has
;; working recipes for both, uid.nix and ice-adapter.nix) but is out of
;; scope for this pass -- see README.md for why.
(define faf-client-version "2026.7.0")
(define faf-client-release-origin
  (origin
    (method url-fetch)
    (uri (string-append
          "https://github.com/FAForever/downlords-faf-client/releases/"
          "download/v" faf-client-version "/faf_unix_"
          (string-map (lambda (c) (if (char=? c #\.) #\_ c)) faf-client-version)
          ".tar.gz"))
    (sha256
     (base32 "0imwvhxgjd8z04cda5icdicaldvqa13968j12h5hwnsvdg7xvg18"))))

(define faf-client-source
  (origin
    (method url-fetch)
    (uri (string-append
          "https://github.com/FAForever/downlords-faf-client/archive/refs/tags/v"
          faf-client-version ".tar.gz"))
    (sha256
     (base32
      ;; Placeholder -- this is the *source* tarball (not the prebuilt
      ;; release), which I never actually downloaded and hashed myself
      ;; (only the prebuilt binary release, used above and in the
      ;; binary-repackage package). Run `guix download' on the URL above
      ;; to fill this in for real before building.
      "0000000000000000000000000000000000000000000000000000"))))

(define %gradle-deps
  ;; The tested decompression logic, applied to nix-gaming's real,
  ;; already-recorded lockfile for this client version (bundled in this
  ;; channel as deps-stable.json, MIT-licensed, credit: nix-gaming /
  ;; chayleaf).
  (gradle-deps-tree "faf-client-gradle-deps"
                    (string-append (host-dirname (host-dirname (current-filename)))
                                   "/deps-stable.json")))

(define-public faf-client-src
  (package
    (name "faf-client-src")
    (version faf-client-version)
    (source faf-client-source)
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f  ; matches nix-gaming: "tests are somewhat unstable"
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 format))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)  ; nothing to configure; Gradle handles it
          (add-after 'unpack 'patch-build-gradle
            (lambda _
              ;; Transcribed verbatim from nix-gaming's postPatch, which
              ;; already solved these three build.gradle quirks for this
              ;; exact project:
              (substitute* "build.gradle"
                ;; 1. a `.outputs.files' reference that doesn't survive
                ;;    outside their exact Nix build environment
                (("^.*\\.outputs\\.files,?.*$") "")
                ;; 2. skip the task that downloads native deps over the
                ;;    network at build time -- we provide faf-uid/
                ;;    faf-ice-adapter.jar ourselves, from the official
                ;;    release, in the install phase below instead
                (("compileJava\\.dependsOn 'downloadNativeDependencies'") "")
                ;; 3. a JitPack version pin
                (("codacy-coverage-reporter:-SNAPSHOT")
                 "codacy-coverage-reporter:latest.integration"))))
          (add-after 'patch-build-gradle 'unpack-gradle
            (lambda* (#:key inputs #:allow-other-keys)
              (mkdir-p "gradle-dist")
              (invoke (search-input-file inputs "bin/unzip") "-q"
                      #$gradle-bin-origin "-d" "gradle-dist")))
          (add-after 'unpack-gradle 'start-mitm-proxy-and-build
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (define (local-dirname path)
                (let loop ((i (- (string-length path) 1)))
                  (cond ((< i 0) ".")
                        ((char=? (string-ref path i) #\/) (substring path 0 i))
                        (else (loop (- i 1))))))
              (let* ((openssl (search-input-file inputs "bin/openssl"))
                     (keytool (search-input-file inputs "bin/keytool"))
                     (mitm-cache-bin (search-input-file inputs "bin/mitm-cache"))
                     (java-home (car (find-files (assoc-ref inputs "openjdk")
                                                  "^java$" #:directories? #f)))
                     (jdk-dir (local-dirname (local-dirname java-home)))
                     (gradle-launcher
                      (car (find-files "gradle-dist" "^gradle$")))
                     (host "127.0.0.1")
                     (port "18935")  ; fixed: each build gets its own
                                     ; network namespace, so no risk of
                                     ; port collision between builds
                     (keystore (string-append (getcwd) "/mitm-keystore.jks"))
                     (keystore-pass "guixmitmcache"))
                (chmod gradle-launcher #o755)
                ;; --- CA generation: identical to nixpkgs'
                ;; mitmCacheConfigureHook (pkgs/by-name/mi/mitm-cache/
                ;; setup-hook.sh) ---
                (invoke openssl "genrsa" "-out" "ca.key" "2048")
                (invoke openssl "req" "-x509" "-new" "-nodes" "-key" "ca.key"
                        "-sha256" "-days" "1" "-out" "ca.cer"
                        "-subj" "/C=AL/ST=a/L=a/O=a/OU=a/CN=example.org")
                ;; --- Java truststore: identical to nixpkgs' gradle
                ;; gradleConfigureHook (.../gradle/setup-hook.sh) ---
                (invoke keytool "-importcert" "-noprompt" "-file" "ca.cer"
                        "-alias" "mitm-ca" "-keystore" keystore
                        "-storepass" keystore-pass)
                ;; --- launch mitm-cache in replay mode, in the
                ;; background, serving the pre-fetched dependency tree
                ;; over loopback only ---
                (system (string-append
                         mitm-cache-bin
                         " --listen " host ":" port
                         " --ca-key ca.key --ca-cert ca.cer"
                         " replay " #$%gradle-deps
                         " >mitm-cache.log 2>&1 & echo $! >mitm-cache.pid"))
                ;; give it a moment to start listening before Gradle
                ;; starts making requests
                (sleep 1)
                (setenv "JAVA_HOME" jdk-dir)
                (setenv "GRADLE_USER_HOME" (string-append (getcwd) "/.gradle-home"))
                (invoke gradle-launcher
                        "--no-daemon" "-Dorg.gradle.console=plain"
                        (string-append "-Dorg.gradle.java.home=" jdk-dir)
                        (string-append "-Phttp.proxyHost=" host)
                        (string-append "-Dhttp.proxyHost=" host)
                        (string-append "-Dhttp.proxyPort=" port)
                        (string-append "-Dhttps.proxyHost=" host)
                        (string-append "-Dhttps.proxyPort=" port)
                        (string-append "-Djavax.net.ssl.trustStore=" keystore)
                        (string-append "-Djavax.net.ssl.trustStorePassword=" keystore-pass)
                        "-Pversion=faf-client-src" "-PjavafxPlatform=linux"
                        "installDist")
                ;; stop the proxy; build's done with it either way
                (system "kill $(cat mitm-cache.pid) 2>/dev/null || true"))))
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (share (string-append out "/share/faf-client"))
                     (bin (string-append out "/bin")))
                (mkdir-p (string-append share "/lib"))
                (mkdir-p (string-append share "/natives"))
                (mkdir-p bin)
                ;; Gradle's `installDist' (application plugin) produces
                ;; build/install/<name>/lib/*.jar -- the exact project
                ;; name inside build.gradle determines the <name>
                ;; component, which for this project is "faf-client".
                (for-each (lambda (jar)
                            (copy-file jar (string-append share "/lib/" (basename jar))))
                          (find-files "build/install/faf-client/lib" "\\.jar$"))
                ;; faf-uid / faf-ice-adapter.jar: reused from the
                ;; official prebuilt release rather than also built from
                ;; source in this pass (see the file-level comment).
                (invoke (search-input-file inputs "bin/tar") "xf"
                        #$faf-client-release-origin "-C" "/tmp"
                        "--wildcards" "*/natives/faf-uid"
                        "*/natives/faf-ice-adapter.jar"
                        "--strip-components=2")
                (copy-file "/tmp/faf-uid" (string-append share "/natives/faf-uid"))
                (copy-file "/tmp/faf-ice-adapter.jar" (string-append share "/natives/faf-ice-adapter.jar"))
                (chmod (string-append share "/natives/faf-uid") #o755))))
          (add-after 'install 'install-launcher
            (lambda* (#:key inputs outputs #:allow-other-keys)
              ;; Identical launcher-script strategy to the
              ;; binary-repackaged `faf-client' package -- see
              ;; faforever.scm's comment on that package for why this
              ;; classpath-invocation approach is correct and how the
              ;; native-library LD_LIBRARY_PATH wrap works. Duplicated
              ;; here rather than factored out, to keep this
              ;; experimental package self-contained and independently
              ;; removable.
              (let* ((out (assoc-ref outputs "out"))
                     (share (string-append out "/share/faf-client"))
                     (bin (string-append out "/bin"))
                     (java (search-input-file inputs "bin/java")))
                (call-with-output-file (string-append bin "/faf-client")
                  (lambda (port)
                    (format port
                            "#!~a
set -e
cd ~a
export LD_LIBRARY_PATH=\"~a${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"
export LOG_DIR=\"${LOG_DIR:-$HOME/.faforever/logs}\"
cp=\"$(find ~a/lib -type f -name '*.jar' ! -name 'faf-ice-adapter.jar' -printf '%p:' | sed 's/:$//')\"
exec ~a -Xmx712m -XX:ConcGCThreads=1 -XX:ParallelGCThreads=1 -XX:+UseG1GC \\
     -XX:+HeapDumpOnOutOfMemoryError -Djava.net.preferIPv4Stack=true \\
     \"-DnativeDir=~a/natives\" -Dprism.forceGPU=true \"-Djava.library.path=~a/lib\" \\
     --add-opens=java.base/java.lang=ALL-UNNAMED \\
     \"-Djavafx.cachedir=${XDG_CACHE_HOME:-$HOME/.cache}/openjfx\" \\
     -classpath \"$cp\" com.faforever.client.Main \"$@\"\n"
                            (search-input-file inputs "bin/bash")
                            share "@LIB_PLACEHOLDER@" share java share share)))
                (chmod (string-append bin "/faf-client") #o755)
                (copy-file #$(local-file "faf-client-setup.py")
                           (string-append bin "/faf-client-setup"))
                (chmod (string-append bin "/faf-client-setup") #o755)
                (patch-shebang (string-append bin "/faf-client-setup")))))
          (add-after 'install-launcher 'wrap-native-library-path
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib-inputs '("mesa" "libx11" "libxxf86vm" "libxtst" "gtk+"
                                   "pango" "glib" "fontconfig" "freetype" "alsa-lib"))
                     (path (let loop ((names lib-inputs) (acc ""))
                             (if (null? names) acc
                                 (let ((dir (string-append (assoc-ref inputs (car names)) "/lib")))
                                   (loop (cdr names)
                                         (if (= (string-length acc) 0) dir (string-append acc ":" dir)))))))
                (substitute* (string-append out "/bin/faf-client")
                  (("@LIB_PLACEHOLDER@") path)))))))))
    (native-inputs
     (list unzip
           (spec "openssl")
           (spec "mitm-cache")))
    (inputs
     (list (spec "bash-minimal")
           (spec "openjdk")   ; MUST be >= 25 -- see README.md
           (spec "tar")
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
           (spec "python")))
    (home-page "https://faforever.com/")
    (synopsis "Forged Alliance Forever client, built from source (experimental)")
    (description
     "An experimental, from-source alternative to the @code{faf-client}
package (which repackages FAForever's official prebuilt release). This
one actually compiles @code{downlords-faf-client} from its own Gradle
build, using @code{mitm-cache} to satisfy Gradle's dependency downloads
from a pre-recorded, hash-verified cache instead of live network access
during the build. Untested end to end -- see README.md.")
    (license license:expat)))
