;;; hyperguix --- ask: which installed command does this?
;;;
;;; https://github.com/Lightningbulb2/AskBash, at the head of its main
;;; branch.  Python with no dependencies; the programs it runs are wired in:
;;; llama-server (this channel's llama.cpp, which the newer models need),
;;; man, and bubblewrap for the sandbox in which it reads --help.  The model
;;; files are not packaged: `ask models --fetch' downloads them to
;;; ~/.local/share/ask/models, and `ask index' builds the per-user index.

(define-module (hyperguix packages ask)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages man)
  #:use-module (gnu packages python)
  #:use-module (gnu packages virtualization)
  #:use-module (hyperguix packages llama-cpp))

(define %ask-commit "4d7cc10e626d821bc6317fce7a9f1f27cc1d5fc5")

(define-public ask
  (package
    (name "ask")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Lightningbulb2/AskBash")
             (commit %ask-commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0zcbqvcib99vydswvd6a1gfjksz3hv5yaziyyccv6g411yayjqn1"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("ask" "share/ask/ask")
          ("README.md" "share/doc/ask/")
          ("ARCHITECTURE.md" "share/doc/ask/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'refer-to-programs
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((llama-server (search-input-file inputs "bin/llama-server"))
                    (man (search-input-file inputs "bin/man"))
                    (bwrap (search-input-file inputs "bin/bwrap")))
                (substitute* "ask/config.py"
                  (("or \"llama-server\"")
                   (string-append "or \"" llama-server "\"")))
                (substitute* "ask/sources.py"
                  (("\\[\"man\", ")
                   (string-append "[\"" man "\", "))
                  (("shutil\\.which\\(\"bwrap\"\\)")
                   (string-append "shutil.which(\"bwrap\") or \"" bwrap "\"")))
                ;; A pattern that matches nothing is not an error, so check.
                (for-each
                 (lambda (file+program)
                   (unless (zero? (system* "grep" "-q" "-F"
                                           (cdr file+program)
                                           (car file+program)))
                     (error "program not wired in" file+program)))
                 (list (cons "ask/config.py" llama-server)
                       (cons "ask/sources.py" man)
                       (cons "ask/sources.py" bwrap))))))
          (add-after 'install 'install-command
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/ask")
                  (lambda (port)
                    (format port "#!~a
import sys
sys.path.insert(0, ~s)
from ask.cli import main
sys.exit(main())
"
                            (search-input-file inputs "bin/python3")
                            (string-append #$output "/share/ask"))))
                (chmod (string-append bin "/ask") #o755)))))))
    (inputs (list python llama-cpp/latest man-db bubblewrap))
    (home-page "https://github.com/Lightningbulb2/AskBash")
    (synopsis "Ask which installed command does something, answered locally")
    (description "@command{ask QUESTION} recommends a few commands that are
installed on this machine and answer the question, each with a one-line
description.  @command{ask index} builds a search index of the executables
on @env{PATH}, their manual pages, the @command{guix} sub-commands and, in a
sandbox, the @option{--help} of the rest.  Questions are answered by small
language models run locally with llama.cpp; nothing is sent over the
network and the recommended commands are never run.  The models are
downloaded once with @command{ask models --fetch}.")
    (license license:gpl3+)))
