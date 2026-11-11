;;; Lightningbulb channel --- building Rust projects whose Cargo.lock pins
;;; crates to git repositories.
;;;
;;; Guix's cargo-build-system vendors crates.io crates from origins, but has
;;; no offline answer for `git = "..."' dependencies short of packaging every
;;; such repository separately.  Here each pinned repository is fetched as an
;;; ordinary git checkout, and a build-time script (aux-files/vendor-git-
;;; crates.py) copies the locked crates out of it into the vendor directory,
;;; normalizing their manifests the way `cargo vendor' does, and redirects the
;;; git sources there.  Cargo only accepts vendored git sources alongside a
;;; Cargo.lock, so the lockfile that cargo-build-system's configure phase
;;; deletes is put back.
;;;
;;; Usage, in a cargo-build-system package:
;;;
;;;   (native-inputs (list python ...))
;;;   (arguments
;;;    (list #:phases
;;;          #~(modify-phases %standard-phases
;;;              #$@(vendor-git-crates-phases foo-git-crates))))

(define-module (Lightningbulb packages cargo-git)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (srfi srfi-1)
  #:export (crate
            crate-table
            crate-selection
            git-checkout
            git-crate
            git-crate-selection
            vendor-git-crates-phases
            fast-cargo-release-phases))

(define (crate name version hash)
  "Origin of crates.io crate NAME at VERSION (HASH is its Cargo.lock
checksum in nix-base32)."
  (origin
    (method url-fetch)
    (uri (crate-uri name version))
    (file-name (string-append "rust-" name "-" version ".tar.gz"))
    (sha256 (base32 hash))))

;; The generated *-crates modules hold their crates as quoted data rather
;; than one `define' per crate: Guile compiles a quoted list almost
;; instantly, while thousands of top-level definitions and calls took
;; minutes (cosmic-crates: ~2.4 min, craft-crates: ~1.2 min) on every
;; `guix pull'.  The origins built are the same, so no package changes.

(define (crate-table specs)
  "Return a vector of crate origins, one per (NAME VERSION HASH) in SPECS."
  (list->vector (map (lambda (spec) (apply crate spec)) specs)))

(define (crate-selection table indices)
  "Return the crates of TABLE (from `crate-table') at INDICES, in order."
  (map (lambda (i) (vector-ref table i)) indices))

(define (git-crate-selection checkouts entries)
  "Return `git-crate' entries for ENTRIES, each (NAME VERSION SOURCE INDEX
SUBDIR) where INDEX picks the checkout origin from the vector CHECKOUTS."
  (map (lambda (entry)
         (apply (lambda (name version source index subdir)
                  (git-crate name version source
                             (vector-ref checkouts index) subdir))
                entry))
       entries))

(define* (git-checkout name url commit hash #:optional recursive?)
  (origin
    (method git-fetch)
    (uri (git-reference
          (url url)
          (commit commit)
          (recursive? recursive?)))
    (file-name (git-file-name name (string-take commit 7)))
    (sha256 (base32 hash))))

(define (git-crate name version source checkout subdir)
  "A crate locked to the git SOURCE (the Cargo.lock source string), found in
CHECKOUT (an origin) under SUBDIR."
  (list name version source checkout subdir))

(define %vendor-git-crates-script
  (local-file "aux-files/vendor-git-crates.py"))

(define (vendor-git-crates-phases crates)
  "Return modify-phases clauses vendoring CRATES (built with `git-crate').
Needs python (3.11 or later) among the native inputs."
  (if (null? crates)
      '()
      (list
       #~(add-before 'configure 'save-cargo-lock
           (lambda _
             (copy-file "Cargo.lock" ".guix-Cargo.lock")))
       #~(add-after 'patch-cargo-checksums 'vendor-git-crates
           (lambda _
             (rename-file ".guix-Cargo.lock" "Cargo.lock")
             (call-with-output-file ".guix-git-crates.tsv"
               (lambda (port)
                 (for-each
                  (lambda (entry)
                    (format port "~{~a~^\t~}~%" entry))
                  (list #$@(map (lambda (c)
                                  (apply (lambda (name version source
                                                  checkout subdir)
                                           #~(list #$name #$version #$source
                                                   #$checkout #$subdir))
                                         c))
                                crates)))))
             (invoke "python3" #$%vendor-git-crates-script
                     ".guix-git-crates.tsv" "guix-vendor"
                     (if (file-exists? ".cargo/config")
                         ".cargo/config"
                         ".cargo/config.toml")
                     "Cargo.lock"))))))

(define (fast-cargo-release-phases)
  "Return modify-phases clauses that make release builds faster to compile.

Upstream release profiles often ask for `codegen-units = 1' and LTO (the
Craft apps: thin LTO with one codegen unit; cosmic-comp: fat LTO).  That
squeezes out a few percent of speed but compiles the biggest crates on one
core, which is why the Craft apps took 16-26 minutes each.  Cargo's own
release defaults (16 units, no cross-crate LTO) are used instead.  Also
drops Guix's scan for bundled binaries, which only prints warnings and took
up to a minute per package."
  (list
   #~(delete 'check-for-pregenerated-files)
   #~(add-before 'build 'fast-release-profile
       (lambda _
         ;; Environment variables override Cargo.toml's [profile.release].
         (setenv "CARGO_PROFILE_RELEASE_LTO" "false")
         (setenv "CARGO_PROFILE_RELEASE_CODEGEN_UNITS" "16")))))
