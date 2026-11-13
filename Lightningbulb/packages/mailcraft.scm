;;; Lightningbulb channel --- MailCraft, a mail, calendar, contacts and tasks app
;;;
;;; A Rust workspace in the Craft apps' mould (egui/wgpu, "everything is a
;;; command", a CLI with an MCP server).  Needs Rust 1.95.  Its crates.io
;;; dependencies come from mailcraft-crates.scm; winit (and its dpi crate)
;;; come from upstream's own winit fork on GitHub and are vendored with the
;;; helper in cargo-git.scm.
;;;
;;; Everything at run time is pure Rust: TLS through rustls/ring, the Secret
;;; Service (GNOME Keyring) through zbus, file dialogs through the XDG desktop
;;; portal.  Only the libraries winit and wgpu dlopen() are added to RUNPATH.
;;; Self-updating is only for AppImages, so this build only gives notices.

(define-module (Lightningbulb packages mailcraft)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages cargo-git)
  #:use-module (Lightningbulb packages mailcraft-crates))

;; Libraries winit, wgpu and friends dlopen() at run time; added to RUNPATH.
(define %mailcraft-runtime-libraries
  (list libx11 libxcb libxcursor libxi libxrandr libxkbcommon mesa
        vulkan-loader wayland))

(define-public mailcraft
  (let ((commit "92eb10c080d2da131bde71dd448bf37413a74d03")
        (revision "0")
        (base-version "0.12.0")
        (binaries '("mailcraft" "mailcraft-cli")))
    (package
      (name "mailcraft")
      (version (git-version base-version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/UCS-Care-Group/mailcraft")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "17whb7jrl1p93s2q2hidjzkq41w3dsiki1l3nz3m8k32qc3vk8c9"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:rust rust-1.95
        #:install-source? #f
        ;; The test suites need a GPU and a display, and would build the
        ;; whole workspace a second time.
        #:tests? #f
        #:cargo-build-flags
        `'("--release" "--package" "mailcraft" "--package" "mailcraft-cli")
        #:phases
        #~(modify-phases %standard-phases
            #$@(vendor-git-crates-phases mailcraft-git-crates)
            #$@(fast-cargo-release-phases)
            (add-before 'build 'set-build-sha
              (lambda _
                ;; Upstream reads it from .git, which a Guix checkout lacks.
                (setenv "MAILCRAFT_BUILD_SHA" #$commit)))
            (replace 'install
              (lambda _
                (let* ((app-id "io.github.billsecond.mailcraft")
                       (bin (string-append #$output "/bin"))
                       (share (string-append #$output "/share"))
                       (doc (string-append share "/doc/mailcraft-"
                                           #$(package-version this-package)))
                       (pkg "packaging/linux/")
                       (metainfo (string-append share "/metainfo/"
                                                app-id ".metainfo.xml")))
                  ;; As packaging/linux/package.sh does.
                  (for-each (lambda (program)
                              (install-file
                               (string-append "target/release/" program)
                               bin))
                            '#$binaries)
                  (install-file (string-append pkg app-id ".desktop")
                                (string-append share "/applications"))
                  (mkdir-p (string-append share "/mime/packages"))
                  (copy-file (string-append pkg app-id ".mime.xml")
                             (string-append share "/mime/packages/"
                                            app-id ".xml"))
                  (mkdir-p (dirname metainfo))
                  (copy-file (string-append pkg app-id ".metainfo.xml.in")
                             metainfo)
                  (substitute* metainfo
                    (("@VERSION@") #$base-version)
                    ;; No meaningful release date for a git snapshot.
                    ((" date=\"@DATE@\"") ""))
                  (copy-recursively "assets/app-icon/hicolor"
                                    (string-append share "/icons/hicolor"))
                  (for-each (lambda (file)
                              (install-file file doc))
                            '("README.md" "LICENSE-MIT" "LICENSE-APACHE"
                              "NOTICE" "ATTRIBUTION.md")))))
            (add-after 'install 'add-dlopen-runpath
              (lambda _
                (let ((runpath
                       (string-join
                        (list #$@(map (lambda (lib) (file-append lib "/lib"))
                                      %mailcraft-runtime-libraries))
                        ":")))
                  (for-each
                   (lambda (program)
                     (invoke "patchelf" "--add-rpath" runpath
                             (string-append #$output "/bin/" program)))
                   '#$binaries)))))))
      (native-inputs (list patchelf pkg-config python))
      (inputs (append %mailcraft-runtime-libraries mailcraft-cargo-inputs))
      (supported-systems '("x86_64-linux" "aarch64-linux"))
      (home-page "https://mailcraft.work")
      (synopsis "Mail, calendar, contacts and tasks application")
      (description
       "MailCraft is a native, GPU-rendered mail program with a calendar,
contacts and to-dos, laid out like the desktop mail clients people know: a
ribbon, a folder pane, a message list with a reading pane, conversations,
flags, categories and rules.  It speaks IMAP and SMTP, signs in to Microsoft
365 and Gmail with OAuth (keeping sign-ins in the Secret Service), reads
@file{.eml}, @file{.mbox}, @file{.ics}, @file{.vcf} and Outlook @file{.pst}
files, and handles recurring meetings and invitations.
@command{mailcraft-cli} runs its commands from scripts and includes an MCP
server for AI agents.")
      ;; MIT OR Apache-2.0; the UI fonts egui embeds are under the SIL Open
      ;; Font License.
      (license (list license:expat license:asl2.0 license:silofl1.1)))))
