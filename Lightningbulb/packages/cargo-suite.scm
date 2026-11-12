;;; Lightningbulb channel --- building related Rust packages together
;;;
;;; The COSMIC components share most of their dependency tree (libcosmic,
;;; iced, wgpu, smithay-client-toolkit, zbus, ...), and so do the Craft apps
;;; (egui, wgpu, image codecs, ...).  Built as separate packages, every one
;;; of them compiles that tree again: COSMIC compiled 16,344 crates of which
;;; 1,870 are distinct, the Craft apps 10,457 of 1,582.
;;;
;;; `cargo-suite' builds several cargo-build-system packages in ONE
;;; derivation, one after another, each with its own unchanged phases,
;;; source, features and Cargo.lock, but in the same directory with the same
;;; vendor directory and the same Cargo target directory.  Cargo then reuses
;;; every dependency an earlier package already compiled with the same
;;; version, features and profile.  (It only does so when the vendored
;;; sources sit at the same absolute path, hence the shared directory.)
;;; Each package is installed to its own output of the suite, and
;;; `suite-member' turns that output back into an ordinary package under the
;;; original name, so configurations and other packages don't change.
;;;
;;; Each member is built in a child process, so the environment variables
;;; its phases set (build-env, CRAFT_FONTS_DIR, ...) don't leak into the next
;;; one, and with "out" set to its own output, which is what #$output in its
;;; phases reads.
;;;
;;; Requirements on members:
;;;   - same Rust (one suite per toolchain);
;;;   - they keep their Cargo.lock (the vendor-git-crates phases do): the
;;;     shared vendor directory holds every member's crates, and without a
;;;     lockfile cargo would pick the newest compatible ones among them;
;;;   - no member patches a vendored crate that another member also builds:
;;;     cargo doesn't notice changed sources of vendored crates, so the patch
;;;     would leak into, or be missing from, the other member's build;
;;;   - no member refers to another member (that would be a cycle).
;;;
;;; `suite-member' lists the suite as an input, so that input rewriting
;;; such as nonguix's NVIDIA transformation still reaches it.
;;;
;;; The cost: changing any member rebuilds the whole suite.  Members that
;;; share fewer dependencies, or that are updated on their own, are better
;;; left as separate packages.

(define-module (Lightningbulb packages cargo-suite)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system trivial)
  #:use-module (srfi srfi-1)
  #:export (cargo-suite
            suite-member))

(define (member-argument member keyword default)
  (let ((args (package-arguments member)))
    (match-keyword args keyword default)))

(define (match-keyword args keyword default)
  (let loop ((args args))
    (cond ((null? args) default)
          ((eq? (car args) keyword) (cadr args))
          (else (loop (cddr args))))))

(define (union-of proc members)
  "Inputs PROC returns for any of MEMBERS, each once."
  (delete-duplicates (append-map proc members)
                     (lambda (a b)
                       (and (equal? (car a) (car b))
                            (eq? (cadr a) (cadr b))
                            (equal? (cddr a) (cddr b))))))

(define* (cargo-suite name members #:key rust)
  "Return a package building MEMBERS (cargo-build-system packages using RUST)
in one derivation that shares their compiled dependencies, with one output
named after each member."
  (define (member-build member)
    (let ((phases (member-argument member #:phases '%standard-phases))
          (features (member-argument member #:features ''()))
          (flags (member-argument member #:cargo-build-flags ''("--release")))
          (tests? (member-argument member #:tests? #t))
          (install-source? (member-argument member #:install-source? #t)))
      #~(list #$(package-name member)
              (lambda (inputs outputs search-paths)
                (cargo-build
                 #:name #$(package-full-name member "-")
                 #:source #+(package-source member)
                 #:system #$(%current-system)
                 #:inputs inputs
                 #:outputs outputs
                 #:search-paths search-paths
                 #:vendor-dir "guix-vendor"
                 #:cargo-build-flags #$flags
                 #:features #$features
                 #:tests? #$tests?
                 #:install-source? #$install-source?
                 #:parallel-build? #t
                 #:phases
                 (modify-phases #$phases
                   ;; Bring in what the previous members left: the vendored
                   ;; crates and the compiled ones.
                   (add-after 'unpack 'take-shared-directories
                     (lambda _
                       (for-each (lambda (dir)
                                   (when (file-exists? (string-append "../../" dir))
                                     (rename-file (string-append "../../" dir)
                                                  dir)))
                                 '("guix-vendor" "target"))))))))))

  (package
    (name name)
    ;; Members keep their own versions; this only names the store item.
    (version "0")
    (source #f)
    (build-system cargo-build-system)
    (outputs (cons "out" (map package-name members)))
    (arguments
     (list
      #:rust rust
      #:modules '((guix build cargo-build-system)
                  (guix build utils)
                  (ice-9 ftw))
      #:phases
      #~(list
         (cons 'build-members
               (lambda* (#:key inputs outputs search-paths #:allow-other-keys)
                 (define top (getcwd))
                 (define (shared dir) (string-append top "/" dir))
                 (for-each
                  (lambda (entry)
                    (let* ((name (car entry))
                           (build (cadr entry))
                           (out (assoc-ref outputs name))
                           (dir (string-append top "/member")))
                      (format #t "~%~%=== suite member ~a ===~%~%" name)
                      (mkdir-p dir)
                      (let ((pid (primitive-fork)))
                        (if (zero? pid)
                            (begin
                              (chdir dir)
                              (setenv "out" out)
                              (primitive-exit
                               (with-exception-handler
                                   (lambda (e)
                                     (format (current-error-port)
                                             "suite member ~a failed: ~s~%"
                                             name e)
                                     1)
                                 (lambda ()
                                   (build inputs `(("out" . ,out))
                                          search-paths)
                                   (force-output (current-output-port))
                                   (force-output (current-error-port))
                                   0)
                                 #:unwind? #t)))
                            (let ((status (cdr (waitpid pid))))
                              (unless (zero? (status:exit-val status))
                                (error "suite member failed" name)))))
                      ;; Keep the vendored and compiled crates for the next
                      ;; member; drop this member's git crates, which the
                      ;; next one vendors anew from its own pins.
                      (with-directory-excursion (string-append dir "/source")
                        (for-each (lambda (d)
                                    (when (file-exists? d)
                                      (rename-file d (shared d))))
                                  '("guix-vendor" "target")))
                      (when (file-exists? (shared "guix-vendor"))
                        (for-each (lambda (d)
                                    (delete-file-recursively
                                     (string-append (shared "guix-vendor")
                                                    "/" d)))
                                  (scandir (shared "guix-vendor")
                                           (lambda (d)
                                             (string-suffix? "-git" d)))))
                      (delete-file-recursively dir)))
                  (list #$@(map member-build members)))
                 (mkdir-p #$output)
                 (call-with-output-file (string-append #$output "/members")
                   (lambda (port)
                     (for-each (lambda (m) (format port "~a~%" m))
                               '#$(map package-full-name members)))))))))
    (native-inputs (union-of package-native-inputs members))
    (inputs (union-of package-inputs members))
    (propagated-inputs (union-of package-propagated-inputs members))
    (home-page (package-home-page (first members)))
    (synopsis "Rust packages built together, sharing their dependencies")
    (description
     (string-append "This builds "
                    (string-join (map package-name members) ", ")
                    " in one go so that their common dependencies are only
compiled once."))
    (license (delete-duplicates
              (append-map (lambda (m)
                            (let ((l (package-license m)))
                              (if (list? l) l (list l))))
                          members)))))

(define (suite-member suite member)
  "Return MEMBER as built by SUITE: a package with MEMBER's name, version and
metadata whose contents link to SUITE's output for it."
  ;; SUITE is an input rather than only a reference in the builder, so that
  ;; input rewriting (such as nonguix's NVIDIA transformation, which
  ;; replaces mesa) reaches the suite and its inputs, as it reached MEMBER.
  (package
    (inherit member)
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build union))
      #:builder
      (with-imported-modules '((guix build union) (guix build utils))
        #~(begin
            (use-modules (guix build union))
            (union-build #$output
                         (list #$(gexp-input
                                  (this-package-input (package-name suite))
                                  (package-name member))))))))
    (native-inputs '())
    (inputs (list (list suite (package-name member))))))
