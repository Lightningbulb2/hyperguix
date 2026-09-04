;;; zed-monorepo-crates.scm --- Packages for the 18 zed-industries/zed
;;; monorepo crates PandoraLauncher's gpui dependency chain needs on Linux.
;;;
;;; Generated against zed-industries/zed @ 184e124bba43220e1e39f73ff63f563fc8f27c76.
;;; External (crates.io) dep versions match Pandora's own Cargo.lock exactly.
;;;
;;; REVISION 3: cargo regenerates Cargo.lock per-WORKSPACE, not per-crate,
;;; so building any one of these with all 18 still listed as `members`
;;; drags in whatever optional/test-only deps any *sibling* declares (this
;;; is how `async-process`, never in Pandora's real Cargo.lock, showed up
;;; on a `rust-gpui-util` build that has nothing to do with it). Fix: each
;;; package now re-prunes `members` a second time, at build time, down to
;;; just its own transitive closure within our 18 -- computed for real via
;;; a dependency-graph walk, not guessed.
;;;
;;; REVISION 2: #:cargo-inputs / #:cargo-development-inputs are deprecated
;;; -- crate-source origins go in plain (inputs (list ...)) instead.
;;;
;;; NOTE on external references: individual rust-<name>-<version> bindings
;;; in (gnu packages rust-crates) are NOT exported (only lookup-cargo-inputs
;;; is, and it returns an unfiltered, unscoped list -- not useful here). We
;;; reach the private bindings via Guile's (@@ module binding) syntax,
;;; which steps around that module's declared public interface.
;;;
;;; TODO before this builds:
;;;   1. Replace the placeholder sha256 -- run `guix build`, paste in the
;;;      real hash it reports on mismatch.
;;;   2. zlog, ztracing, ztracing_macro are GPL-3.0-or-later; the rest here
;;;      are Apache-2.0 (gpui_shared_string/gpui_util have no license field
;;;      upstream at all -- defaulted to Apache-2.0, unverified).

(define-module (Lightningbulb packages zed-monorepo-crates)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages rust-crates))

(define zed-checkout
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/zed-industries/zed")
          (commit "184e124bba43220e1e39f73ff63f563fc8f27c76")))
    (file-name (git-file-name "zed-checkout" "184e124"))
    ;; Placeholder -- see TODO #1 above.
    (sha256 (base32 "1bhxwmlw3k50nvym5yf7ri2fnv5a55q63gjbnf8ak57wjbaa2wx0"))
    (modules '((ice-9 rdelim) (srfi srfi-13)))
    ;; Outer bound: prune from the full ~500-crate editor down to our 18.
    ;; Each package prunes further, to just its own closure, at build time.
    (snippet
     '(let ((keep (list "crates/gpui_util" "crates/collections" "crates/refineable/derive_refineable" "crates/gpui_macros" "crates/gpui_shared_string" "crates/http_client" "crates/refineable" "crates/scheduler" "crates/zlog" "crates/ztracing_macro" "crates/ztracing" "crates/sum_tree" "tooling/perf" "crates/util_macros" "crates/gpui" "crates/gpui_wgpu" "crates/gpui_linux" "crates/gpui_platform")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml")))))

;;; --- gpui_util 0.1.0  (crates/gpui_util)  closure: ['gpui_util'] ---
(define-public rust-gpui-util
  (package
    (name "rust-gpui-util")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/gpui_util")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui_util"))))))
    (inputs
     (list (@@ (gnu packages rust-crates) rust-anyhow-1.0.102)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal gpui_util crate from the zed-industries/zed monorepo, used by")
    (description "Internal gpui_util crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:asl2.0)))

;;; --- collections 0.1.0  (crates/collections)  closure: ['collections', 'gpui_util'] ---
(define-public rust-collections
  (package
    (name "rust-collections")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/gpui_util")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/collections"))))))
    (inputs
     (list rust-gpui-util
           (@@ (gnu packages rust-crates) rust-indexmap-2.14.0)
           (@@ (gnu packages rust-crates) rust-rustc-hash-2.1.1)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Standard collection types used by Zed and GPUI")
    (description "Standard collection types used by Zed and GPUI")
    (license license:asl2.0)))

;;; --- derive_refineable 0.1.0  (crates/refineable/derive_refineable)  closure: ['derive_refineable'] ---
(define-public rust-derive-refineable
  (package
    (name "rust-derive-refineable")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/refineable/derive_refineable")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/refineable/derive_refineable"))))))
    (inputs
     (list (@@ (gnu packages rust-crates) rust-proc-macro2-1.0.101)
           (@@ (gnu packages rust-crates) rust-quote-1.0.41)
           (@@ (gnu packages rust-crates) rust-syn-2.0.117)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "A derive macro for creating refinement types in Rust")
    (description "A derive macro for creating refinement types in Rust")
    (license license:asl2.0)))

;;; --- gpui_macros 0.1.0  (crates/gpui_macros)  closure: ['gpui_macros'] ---
(define-public rust-gpui-macros
  (package
    (name "rust-gpui-macros")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/gpui_macros")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui_macros"))))))
    (inputs
     (list (@@ (gnu packages rust-crates) rust-heck-0.5.0)
           (@@ (gnu packages rust-crates) rust-proc-macro2-1.0.101)
           (@@ (gnu packages rust-crates) rust-quote-1.0.41)
           (@@ (gnu packages rust-crates) rust-syn-2.0.117)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Macros used by gpui")
    (description "Macros used by gpui")
    (license license:asl2.0)))

;;; --- gpui_shared_string 0.1.0  (crates/gpui_shared_string)  closure: ['gpui_shared_string'] ---
(define-public rust-gpui-shared-string
  (package
    (name "rust-gpui-shared-string")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/gpui_shared_string")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui_shared_string"))))))
    (inputs
     (list (@@ (gnu packages rust-crates) rust-schemars-1.0.4)
           (@@ (gnu packages rust-crates) rust-serde-1.0.228)
           (@@ (gnu packages rust-crates) rust-smol-str-0.3.6)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal gpui_shared_string crate from the zed-industries/zed monorepo")
    (description "Internal gpui_shared_string crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:asl2.0)))

;;; --- http_client 0.1.0  (crates/http_client)  closure: ['http_client'] ---
(define-public rust-http-client
  (package
    (name "rust-http-client")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/http_client")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/http_client"))))))
    (inputs
     (list (@@ (gnu packages rust-crates) rust-anyhow-1.0.102)
           (@@ (gnu packages rust-crates) rust-async-compression-0.4.32)
           (@@ (gnu packages rust-crates) rust-bytes-1.11.1)
           (@@ (gnu packages rust-crates) rust-derive-more-2.1.1)
           (@@ (gnu packages rust-crates) rust-futures-0.3.32)
           (@@ (gnu packages rust-crates) rust-http-1.3.1)
           (@@ (gnu packages rust-crates) rust-http-body-1.0.1)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)
           (@@ (gnu packages rust-crates) rust-parking-lot-0.12.5)
           (@@ (gnu packages rust-crates) rust-serde-1.0.228)
           (@@ (gnu packages rust-crates) rust-serde-json-1.0.145)
           (@@ (gnu packages rust-crates) rust-serde-urlencoded-0.7.1)
           (@@ (gnu packages rust-crates) rust-url-2.5.7)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "A HTTP client library for Zed and GPUI")
    (description "A HTTP client library for Zed and GPUI")
    (license license:asl2.0)))

;;; --- refineable 0.1.0  (crates/refineable)  closure: ['derive_refineable', 'refineable'] ---
(define-public rust-refineable
  (package
    (name "rust-refineable")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/refineable/derive_refineable" "crates/refineable")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/refineable"))))))
    (inputs
     (list rust-derive-refineable))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "A macro for creating 'refinement' types that can be used to partially ")
    (description "A macro for creating 'refinement' types that can be used to partially initialize or mutate a complex struct")
    (license license:asl2.0)))

;;; --- scheduler 0.1.0  (crates/scheduler)  closure: ['scheduler'] ---
(define-public rust-scheduler
  (package
    (name "rust-scheduler")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/scheduler")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/scheduler"))))))
    (inputs
     (list (@@ (gnu packages rust-crates) rust-async-task-4.7.1)
           (@@ (gnu packages rust-crates) rust-backtrace-0.3.76)
           (@@ (gnu packages rust-crates) rust-chrono-0.4.42)
           (@@ (gnu packages rust-crates) rust-flume-0.12.0)
           (@@ (gnu packages rust-crates) rust-futures-0.3.32)
           (@@ (gnu packages rust-crates) rust-parking-lot-0.12.5)
           (@@ (gnu packages rust-crates) rust-rand-0.9.4)
           (@@ (gnu packages rust-crates) rust-web-time-1.1.0)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal scheduler crate from the zed-industries/zed monorepo, used by")
    (description "Internal scheduler crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:asl2.0)))

;;; --- zlog 0.1.0  (crates/zlog)  closure: ['collections', 'gpui_util', 'zlog'] ---
(define-public rust-zlog
  (package
    (name "rust-zlog")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/gpui_util" "crates/zlog")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/zlog"))))))
    (inputs
     (list rust-collections
           (@@ (gnu packages rust-crates) rust-anyhow-1.0.102)
           (@@ (gnu packages rust-crates) rust-chrono-0.4.42)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal zlog crate from the zed-industries/zed monorepo, used by gpui")
    (description "Internal zlog crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:gpl3+)))

;;; --- ztracing_macro 0.1.0  (crates/ztracing_macro)  closure: ['ztracing_macro'] ---
(define-public rust-ztracing-macro
  (package
    (name "rust-ztracing-macro")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/ztracing_macro"))))))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal ztracing_macro crate from the zed-industries/zed monorepo, us")
    (description "Internal ztracing_macro crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:gpl3+)))

;;; --- ztracing 0.1.0  (crates/ztracing)  closure: ['collections', 'gpui_util', 'zlog', 'ztracing', 'ztracing_macro'] ---
(define-public rust-ztracing
  (package
    (name "rust-ztracing")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/gpui_util" "crates/zlog" "crates/ztracing" "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/ztracing"))))))
    (inputs
     (list rust-zlog
           rust-ztracing-macro
           (@@ (gnu packages rust-crates) rust-tracing-0.1.43)
           (@@ (gnu packages rust-crates) rust-tracing-subscriber-0.3.22)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal ztracing crate from the zed-industries/zed monorepo, used by ")
    (description "Internal ztracing crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:gpl3+)))

;;; --- sum_tree 0.1.0  (crates/sum_tree)  closure: ['collections', 'gpui_util', 'sum_tree', 'zlog', 'ztracing', 'ztracing_macro'] ---
(define-public rust-sum-tree
  (package
    (name "rust-sum-tree")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/gpui_util" "crates/sum_tree" "crates/zlog" "crates/ztracing" "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/sum_tree"))))))
    (inputs
     (list rust-ztracing
           (@@ (gnu packages rust-crates) rust-heapless-0.9.2)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)
           (@@ (gnu packages rust-crates) rust-rayon-1.11.0)
           (@@ (gnu packages rust-crates) rust-tracing-0.1.43)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "A sum tree data structure, a concurrency-friendly B-tree")
    (description "A sum tree data structure, a concurrency-friendly B-tree")
    (license license:asl2.0)))

;;; --- perf 0.1.0  (tooling/perf)  closure: ['collections', 'gpui_util', 'perf'] ---
(define-public rust-perf
  (package
    (name "rust-perf")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/gpui_util" "tooling/perf")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "tooling/perf"))))))
    (inputs
     (list rust-collections
           (@@ (gnu packages rust-crates) rust-serde-1.0.228)
           (@@ (gnu packages rust-crates) rust-serde-json-1.0.145)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "A tool for measuring Zed test performance, with too many Clippy lints")
    (description "A tool for measuring Zed test performance, with too many Clippy lints")
    (license license:asl2.0)))

;;; --- util_macros 0.1.0  (crates/util_macros)  closure: ['collections', 'gpui_util', 'perf', 'util_macros'] ---
(define-public rust-util-macros
  (package
    (name "rust-util-macros")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/gpui_util" "tooling/perf" "crates/util_macros")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/util_macros"))))))
    (inputs
     (list rust-perf
           (@@ (gnu packages rust-crates) rust-quote-1.0.41)
           (@@ (gnu packages rust-crates) rust-syn-2.0.117)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Utility macros for Zed")
    (description "Utility macros for Zed")
    (license license:asl2.0)))

;;; --- gpui 0.2.2  (crates/gpui)  closure: ['collections', 'derive_refineable', 'gpui', 'gpui_macros', 'gpui_shared_string', 'gpui_util', 'http_client', 'perf', 'refineable', 'scheduler', 'sum_tree', 'util_macros', 'zlog', 'ztracing', 'ztracing_macro'] ---
(define-public rust-gpui
  (package
    (name "rust-gpui")
    (version "0.2.2")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/refineable/derive_refineable" "crates/gpui" "crates/gpui_macros" "crates/gpui_shared_string" "crates/gpui_util" "crates/http_client" "tooling/perf" "crates/refineable" "crates/scheduler" "crates/sum_tree" "crates/util_macros" "crates/zlog" "crates/ztracing" "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui"))))))
    (inputs
     (list rust-collections
           rust-gpui-macros
           rust-gpui-shared-string
           rust-gpui-util
           rust-http-client
           rust-refineable
           rust-scheduler
           rust-sum-tree
           rust-util-macros
           (@@ (gnu packages rust-crates) rust-accesskit-0.24.1)
           (@@ (gnu packages rust-crates) rust-anyhow-1.0.102)
           (@@ (gnu packages rust-crates) rust-async-channel-2.5.0)
           (@@ (gnu packages rust-crates) rust-async-task-4.7.1)
           (@@ (gnu packages rust-crates) rust-backtrace-0.3.76)
           (@@ (gnu packages rust-crates) rust-bitflags-2.13.1)
           (@@ (gnu packages rust-crates) rust-chrono-0.4.42)
           (@@ (gnu packages rust-crates) rust-ctor-1.0.6)
           (@@ (gnu packages rust-crates) rust-derive-more-2.1.1)
           (@@ (gnu packages rust-crates) rust-embed-resource-3.0.6)
           (@@ (gnu packages rust-crates) rust-etagere-0.2.15)
           (@@ (gnu packages rust-crates) rust-futures-0.3.32)
           (@@ (gnu packages rust-crates) rust-futures-concurrency-7.7.1)
           (@@ (gnu packages rust-crates) rust-heapless-0.9.2)
           (@@ (gnu packages rust-crates) rust-image-0.25.10)
           (@@ (gnu packages rust-crates) rust-inventory-0.3.21)
           (@@ (gnu packages rust-crates) rust-itertools-0.14.0)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)
           (@@ (gnu packages rust-crates) rust-lyon-1.0.16)
           (@@ (gnu packages rust-crates) rust-num-cpus-1.17.0)
           (@@ (gnu packages rust-crates) rust-parking-2.2.1)
           (@@ (gnu packages rust-crates) rust-parking-lot-0.12.5)
           (@@ (gnu packages rust-crates) rust-pin-project-1.1.10)
           (@@ (gnu packages rust-crates) rust-pollster-0.4.0)
           (@@ (gnu packages rust-crates) rust-postage-0.5.0)
           (@@ (gnu packages rust-crates) rust-profiling-1.0.17)
           (@@ (gnu packages rust-crates) rust-rand-0.9.4)
           (@@ (gnu packages rust-crates) rust-raw-window-handle-0.6.2)
           (@@ (gnu packages rust-crates) rust-regex-1.12.3)
           (@@ (gnu packages rust-crates) rust-resvg-0.46.0)
           (@@ (gnu packages rust-crates) rust-schemars-1.0.4)
           (@@ (gnu packages rust-crates) rust-seahash-4.1.0)
           (@@ (gnu packages rust-crates) rust-serde-1.0.228)
           (@@ (gnu packages rust-crates) rust-serde-json-1.0.145)
           (@@ (gnu packages rust-crates) rust-slotmap-1.0.7)
           (@@ (gnu packages rust-crates) rust-smallvec-1.15.1)
           (@@ (gnu packages rust-crates) rust-spin-0.9.8)
           (@@ (gnu packages rust-crates) rust-stacksafe-0.1.4)
           (@@ (gnu packages rust-crates) rust-strum-0.27.2)
           (@@ (gnu packages rust-crates) rust-taffy-0.12.2)
           (@@ (gnu packages rust-crates) rust-thiserror-2.0.17)
           (@@ (gnu packages rust-crates) rust-ttf-parser-0.25.1)
           (@@ (gnu packages rust-crates) rust-url-2.5.7)
           (@@ (gnu packages rust-crates) rust-usvg-0.46.0)
           (@@ (gnu packages rust-crates) rust-uuid-1.18.1)
           (@@ (gnu packages rust-crates) rust-waker-fn-1.2.0)
           (@@ (gnu packages rust-crates) rust-web-time-1.1.0)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Zed's GPU-accelerated UI framework")
    (description "Zed's GPU-accelerated UI framework")
    (license license:asl2.0)))

;;; --- gpui_wgpu 0.1.0  (crates/gpui_wgpu)  closure: ['collections', 'derive_refineable', 'gpui', 'gpui_macros', 'gpui_shared_string', 'gpui_util', 'gpui_wgpu', 'http_client', 'perf', 'refineable', 'scheduler', 'sum_tree', 'util_macros', 'zlog', 'ztracing', 'ztracing_macro'] ---
(define-public rust-gpui-wgpu
  (package
    (name "rust-gpui-wgpu")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/refineable/derive_refineable" "crates/gpui" "crates/gpui_macros" "crates/gpui_shared_string" "crates/gpui_util" "crates/gpui_wgpu" "crates/http_client" "tooling/perf" "crates/refineable" "crates/scheduler" "crates/sum_tree" "crates/util_macros" "crates/zlog" "crates/ztracing" "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui_wgpu"))))))
    (inputs
     (list rust-collections
           rust-gpui
           rust-gpui-util
           rust-zed-font-kit
           (@@ (gnu packages rust-crates) rust-anyhow-1.0.102)
           (@@ (gnu packages rust-crates) rust-bytemuck-1.24.0)
           (@@ (gnu packages rust-crates) rust-cosmic-text-0.19.0)
           (@@ (gnu packages rust-crates) rust-etagere-0.2.15)
           (@@ (gnu packages rust-crates) rust-itertools-0.14.0)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)
           (@@ (gnu packages rust-crates) rust-parking-lot-0.12.5)
           (@@ (gnu packages rust-crates) rust-profiling-1.0.17)
           (@@ (gnu packages rust-crates) rust-raw-window-handle-0.6.2)
           (@@ (gnu packages rust-crates) rust-smallvec-1.15.1)
           (@@ (gnu packages rust-crates) rust-swash-0.2.6)
           (@@ (gnu packages rust-crates) rust-unicode-bidi-0.3.18)
           (@@ (gnu packages rust-crates) rust-unicode-segmentation-1.12.0)
           (@@ (gnu packages rust-crates) rust-wgpu-29.0.4)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal gpui_wgpu crate from the zed-industries/zed monorepo, used by")
    (description "Internal gpui_wgpu crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:asl2.0)))

;;; --- gpui_linux 0.1.0  (crates/gpui_linux)  closure: ['collections', 'derive_refineable', 'gpui', 'gpui_linux', 'gpui_macros', 'gpui_shared_string', 'gpui_util', 'gpui_wgpu', 'http_client', 'perf', 'refineable', 'scheduler', 'sum_tree', 'util_macros', 'zlog', 'ztracing', 'ztracing_macro'] ---
(define-public rust-gpui-linux
  (package
    (name "rust-gpui-linux")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/refineable/derive_refineable" "crates/gpui" "crates/gpui_linux" "crates/gpui_macros" "crates/gpui_shared_string" "crates/gpui_util" "crates/gpui_wgpu" "crates/http_client" "tooling/perf" "crates/refineable" "crates/scheduler" "crates/sum_tree" "crates/util_macros" "crates/zlog" "crates/ztracing" "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui_linux"))))))
    (inputs
     (list rust-collections
           rust-gpui
           rust-gpui-util
           rust-gpui-wgpu
           rust-http-client
           rust-zed-scap
           rust-zed-xim
           (@@ (gnu packages rust-crates) rust-accesskit-0.24.1)
           (@@ (gnu packages rust-crates) rust-accesskit-unix-0.21.0)
           (@@ (gnu packages rust-crates) rust-anyhow-1.0.102)
           (@@ (gnu packages rust-crates) rust-as-raw-xcb-connection-1.0.1)
           (@@ (gnu packages rust-crates) rust-ashpd-0.13.2)
           (@@ (gnu packages rust-crates) rust-bitflags-2.13.1)
           (@@ (gnu packages rust-crates) rust-bytemuck-1.24.0)
           (@@ (gnu packages rust-crates) rust-calloop-0.14.4)
           (@@ (gnu packages rust-crates) rust-calloop-wayland-source-0.4.1)
           (@@ (gnu packages rust-crates) rust-filedescriptor-0.8.3)
           (@@ (gnu packages rust-crates) rust-futures-0.3.32)
           (@@ (gnu packages rust-crates) rust-image-0.25.10)
           (@@ (gnu packages rust-crates) rust-itertools-0.14.0)
           (@@ (gnu packages rust-crates) rust-libc-0.2.186)
           (@@ (gnu packages rust-crates) rust-log-0.4.29)
           (@@ (gnu packages rust-crates) rust-notify-rust-4.18.0)
           (@@ (gnu packages rust-crates) rust-oo7-0.6.0)
           (@@ (gnu packages rust-crates) rust-open-5.3.2)
           (@@ (gnu packages rust-crates) rust-parking-lot-0.12.5)
           (@@ (gnu packages rust-crates) rust-pathfinder-geometry-0.5.1)
           (@@ (gnu packages rust-crates) rust-pollster-0.4.0)
           (@@ (gnu packages rust-crates) rust-profiling-1.0.17)
           (@@ (gnu packages rust-crates) rust-raw-window-handle-0.6.2)
           (@@ (gnu packages rust-crates) rust-smallvec-1.15.1)
           (@@ (gnu packages rust-crates) rust-smol-2.0.2)
           (@@ (gnu packages rust-crates) rust-strum-0.27.2)
           (@@ (gnu packages rust-crates) rust-swash-0.2.6)
           (@@ (gnu packages rust-crates) rust-url-2.5.7)
           (@@ (gnu packages rust-crates) rust-uuid-1.18.1)
           (@@ (gnu packages rust-crates) rust-wayland-backend-0.3.15)
           (@@ (gnu packages rust-crates) rust-wayland-client-0.31.11)
           (@@ (gnu packages rust-crates) rust-wayland-cursor-0.31.11)
           (@@ (gnu packages rust-crates) rust-wayland-protocols-0.32.9)
           (@@ (gnu packages rust-crates) rust-wayland-protocols-plasma-0.3.9)
           (@@ (gnu packages rust-crates) rust-wayland-protocols-wlr-0.3.9)
           (@@ (gnu packages rust-crates) rust-x11-clipboard-0.9.3)
           (@@ (gnu packages rust-crates) rust-x11rb-0.13.2)
           (@@ (gnu packages rust-crates) rust-xkbcommon-0.8.0)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal gpui_linux crate from the zed-industries/zed monorepo, used b")
    (description "Internal gpui_linux crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:asl2.0)))

;;; --- gpui_platform 0.1.0  (crates/gpui_platform)  closure: ['collections', 'derive_refineable', 'gpui', 'gpui_linux', 'gpui_macros', 'gpui_platform', 'gpui_shared_string', 'gpui_util', 'gpui_wgpu', 'http_client', 'perf', 'refineable', 'scheduler', 'sum_tree', 'util_macros', 'zlog', 'ztracing', 'ztracing_macro'] ---
(define-public rust-gpui-platform
  (package
    (name "rust-gpui-platform")
    (version "0.1.0")
    (source zed-checkout)
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prune-workspace-members
            (lambda _ (let ((keep (list "crates/collections" "crates/refineable/derive_refineable" "crates/gpui" "crates/gpui_linux" "crates/gpui_macros" "crates/gpui_platform" "crates/gpui_shared_string" "crates/gpui_util" "crates/gpui_wgpu" "crates/http_client" "tooling/perf" "crates/refineable" "crates/scheduler" "crates/sum_tree" "crates/util_macros" "crates/zlog" "crates/ztracing" "crates/ztracing_macro")))
             (use-modules (ice-9 rdelim) (srfi srfi-13))
             (call-with-output-file "Cargo.toml.pruned"
               (lambda (out)
                 (call-with-input-file "Cargo.toml"
                   (lambda (in)
                     (let loop ((in-members? #f))
                       (let ((line (read-line in)))
                         (cond
                          ((eof-object? line) #t)
                          ((and (not in-members?)
                                (string-prefix? "members = [" line))
                           (display "members = [\n" out)
                           (for-each (lambda (p)
                                       (display "    \"" out)
                                       (display p out)
                                       (display "\",\n" out))
                                     keep)
                           (loop #t))
                          ((and in-members? (string=? line "]"))
                           (display "]\n" out)
                           (loop #f))
                          (in-members?
                           (loop #t))
                          (else
                           (display line out)
                           (newline out)
                           (loop #f)))))))))
             (rename-file "Cargo.toml.pruned" "Cargo.toml"))))
          (add-after 'prune-workspace-members 'chdir
            (lambda _ (chdir "crates/gpui_platform"))))))
    (inputs
     (list rust-gpui
           rust-gpui-linux))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "Internal gpui_platform crate from the zed-industries/zed monorepo, use")
    (description "Internal gpui_platform crate from the zed-industries/zed monorepo, used by gpui.")
    (license license:asl2.0)))
