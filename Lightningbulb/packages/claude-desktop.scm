;;; Lightningbulb channel --- claude-desktop
;;;
;;; Anthropic's official Claude desktop app for Linux (beta), repackaged from
;;; the .deb in Anthropic's apt repository the way nonguix packages other
;;; Electron applications (element-desktop, signal-desktop): the ELF files are
;;; patched to use Guix's loader and libraries and the entry point is wrapped.
;;; This is a non-free binary package.
;;;
;;; Claude Code sessions inside the app run a `claude' executable that the app
;;; downloads at run time into its user data folder.  That binary expects
;;; /lib64/ld-linux-x86-64.so.2, which Guix System lacks unless the system
;;; configuration provides it (see the description).
;;;
;;; Updating: the version and file name are in
;;; https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages
;;; (the pool may drop old versions, so update when the download 404s).

(define-module (Lightningbulb packages claude-desktop)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages virtualization)
  #:use-module (nonguix build-system chromium-binary)
  #:use-module ((nonguix licenses) #:prefix license:))

(define-public claude-desktop
  (package
    (name "claude-desktop")
    (version "4.4212.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/"
             "c/claude-desktop/claude-desktop_" version "_amd64.deb"))
       (sha256
        (base32 "113szpxqnbg8c00ajgpcn1hy5g6zh5r2i4r5p053k5f81y76bksg"))))
    (supported-systems '("x86_64-linux"))
    (build-system chromium-binary-build-system)
    (arguments
     (list
      #:validate-runpath? #f      ;fails on the wrapped binary and the .node files
      #:substitutable? #f
      #:wrapper-plan
      #~(let ((lib "lib/claude-desktop/"))
          `((,(string-append lib "claude-desktop")
             (("out" "/lib/claude-desktop")))
            ,(string-append lib "chrome_crashpad_handler")
            ,(string-append lib "chrome-sandbox")
            ,(string-append lib "libffmpeg.so")
            ,(string-append lib "libvk_swiftshader.so")
            ,(string-append lib "libvulkan.so.1")
            ;; Native-messaging host for the "Claude in Chrome" extension.
            ,(string-append lib "resources/chrome-native-host")
            ;; The one other dynamically linked helper (libc only); the
            ;; others in resources/ are static.
            ,(string-append lib "resources/disclaimer")
            ;; Shares folders with the Cowork VM.
            ,(string-append lib "resources/virtiofsd")
            ,(string-append lib "resources/app.asar.unpacked/node_modules/"
                            "@ant/claude-native/claude-native-binding.node")
            ,(string-append lib "resources/app.asar.unpacked/node_modules/"
                            "node-pty/prebuilds/linux-x64/pty.node")))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'binary-unpack 'setup-cwd
            (lambda _
              (copy-recursively "usr/" ".")
              (delete-file-recursively "usr")
              ;; Debian-only bits; the D-Bus search provider is for GNOME
              ;; Shell and expects a gjs on PATH.
              (delete-file-recursively "share/lintian")
              (delete-file "bin/claude-desktop")))
          (add-after 'install 'install-integration
            (lambda _
              (let ((app (string-append #$output "/share/applications/"
                                        "com.anthropic.Claude.desktop"))
                    (mime (string-append #$output "/share/mime/packages")))
                ;; Exec=claude-desktop -> the store path, as Guix does.  The
                ;; file name, StartupWMClass and Icon already match the
                ;; Wayland app_id / WM_CLASS (com.anthropic.Claude) and the
                ;; hicolor icons.
                (substitute* app
                  (("^Exec=claude-desktop")
                   (string-append "Exec=" #$output "/bin/claude-desktop")))
                ;; What the postinst would register: .mcpb/.dxt/.skill types.
                (install-file
                 (string-append #$output "/lib/claude-desktop/resources/"
                                "linux-mime/com.anthropic.Claude.xml")
                 mime))))
          (add-before 'install-wrapper 'symlink-binary-file
            (lambda _
              (mkdir-p (string-append #$output "/bin"))
              (symlink (string-append #$output "/lib/claude-desktop/claude-desktop")
                       (string-append #$output "/bin/claude-desktop"))))
          (add-after 'install-wrapper 'wrap-more
            (lambda _
              (wrap-program (string-append #$output "/bin/claude-desktop")
                ;; The Wayland app_id comes from $CHROME_DESKTOP, which may be
                ;; inherited from another Chromium/Electron program.
                `("CHROME_DESKTOP" = ("com.anthropic.Claude.desktop"))
                ;; Set in e.g. VS Code's terminals; would start plain Node.js.
                `("ELECTRON_RUN_AS_NODE" = (""))))))))
    (inputs
     ;; Beyond the Electron libraries chromium-binary-build-system adds:
     ;; libraries of the bundled native modules and virtiofsd, plus the
     ;; tools the deb Recommends that end up on the wrapper's PATH
     ;; (sandboxing Claude Code's tools, SSH remotes).
     (list bubblewrap
           libcap-ng
           libseccomp
           openssh
           pipewire
           socat))
    (home-page "https://claude.com/download")
    (synopsis "Claude desktop application (official Linux beta)")
    (description
     "This is Anthropic's desktop application for Claude: chat, Cowork and
Claude Code sessions with diff review, an integrated terminal and app preview.
It is the official Linux beta build, repackaged from Anthropic's Debian
package.

Claude Code sessions run an executable the application downloads into its
data folder; it needs the conventional dynamic loader path, which Guix System
can provide with
@code{(extra-special-file \"/lib64/ld-linux-x86-64.so.2\" (file-append glibc
\"/lib/ld-linux-x86-64.so.2\"))} in the operating system's services.  Cowork
additionally needs KVM and QEMU with UEFI firmware at Debian's paths and is
not expected to work.  Computer Use and dictation are not part of the Linux
beta.")
    (license (license:nonfree "https://www.anthropic.com/legal/consumer-terms"))))
