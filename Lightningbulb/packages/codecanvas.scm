;;; Lightningbulb channel --- CodeCanvas, an infinite canvas for source code
;;;
;;; Three repositories: CodeCanvas (the desktop app, Rust on GPUI),
;;; CodeCanvas-vscode (the VS Code / VSCodium extension) and CodeCanvas-zed
;;; (the Zed extension and the bridge program that connects it to the app).
;;;
;;; The sources are pinned commits of the local checkouts, read through
;;; `git-checkout', until the repositories are on GitHub: then change
;;; %codecanvas-base-url and use git-fetch origins with hashes.
;;;
;;; Crates are in codecanvas-crates.scm.

(define-module (Lightningbulb packages codecanvas)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages node)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages js-offline)
  #:use-module (Lightningbulb packages codecanvas-crates))

(define %codecanvas-base-url "file:///home/Lightningbulb/")

(define (codecanvas-source repository commit)
  (git-checkout
   (url (string-append %codecanvas-base-url repository))
   (commit commit)))

(define-public codecanvas
  (package
    (name "codecanvas")
    (version "0.1.0")
    (source (codecanvas-source "CodeCanvas"
                               "c1c27d3c5f5ffde4218986708c7b274bcaf66c6b"))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.95
      #:install-source? #f
      #:tests? #f                       ;the window toolkit needs a display
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-desktop-file
            (lambda _
              (install-file "packaging/codecanvas.desktop"
                            (string-append #$output "/share/applications"))
              (install-file "packaging/codecanvas.svg"
                            (string-append
                             #$output "/share/icons/hicolor/scalable/apps"))))
          (add-after 'install-desktop-file 'wrap-runtime-libraries
            ;; GPUI dlopen()s these at run time.
            (lambda* (#:key inputs #:allow-other-keys)
              (wrap-program (string-append #$output "/bin/codecanvas")
                `("LD_LIBRARY_PATH" ":" prefix
                  ,(map (lambda (name)
                          (string-append (assoc-ref inputs name) "/lib"))
                        '("libxkbcommon" "vulkan-loader" "wayland"
                          "libxcb" "mesa")))))))))
    (native-inputs (list pkg-config))
    (inputs
     (cons* bash-minimal fontconfig freetype libxcb libxkbcommon mesa
            vulkan-loader wayland
            codecanvas-cargo-inputs))
    (propagated-inputs (list font-dejavu))
    (home-page "https://github.com/Lightningbulb2/CodeCanvas")
    (synopsis "Infinite canvas for source code")
    (description
     "CodeCanvas lays source files out on an infinite canvas, where lines can
be cut into movable snippets and merged back into files.  Each file and
snippet can have its own chat with a local or remote language model.")
    (license license:expat)))

(define-public codecanvas-zed-bridge
  (package
    (name "codecanvas-zed-bridge")
    (version "0.1.0")
    (source (codecanvas-source "CodeCanvas-zed"
                               "1d7f3e85f3052935539d10eaea0c2a0ec8ea0192"))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.95
      #:install-source? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'install-extension-source
            ;; The extension's source, for reference.  Zed compiles dev
            ;; extensions itself with rustup and the wasm32-wasip2 target,
            ;; neither of which Guix has, so on Guix System the bridge is
            ;; started directly instead (see the description).
            (lambda _
              (let ((share (string-append #$output "/share/codecanvas-zed")))
                (for-each (lambda (file) (install-file file share))
                          '("extension.toml" "Cargo.toml" "Cargo.lock"
                            "README.md" "LICENSE"))
                (copy-recursively "src" (string-append share "/src")))))
          (add-after 'install-extension-source 'chdir
            (lambda _
              (chdir "bridge"))))))
    (inputs codecanvas-zed-bridge-cargo-inputs)
    (home-page "https://github.com/Lightningbulb2/CodeCanvas-zed")
    (synopsis "Connects the Zed editor to CodeCanvas")
    (description
     "This is the program the CodeCanvas extension for Zed starts as an MCP
server.  It finds the @command{codecanvas} application, keeps a task and a
keyboard shortcut for it in Zed's configuration, and gives Zed's agent a tool
that opens a canvas.  On Guix System, where Zed cannot compile the extension,
add it to Zed's @file{settings.json} as a context server:
@code{\"context_servers\": @{\"codecanvas\": @{\"command\":
\"codecanvas-zed-bridge\"@}@}}.  Elsewhere, point the extension's
@code{bridge_path} setting at it.  The extension's source is in
@file{share/codecanvas-zed}.")
    (license license:expat)))

(define %codecanvas-vscode-tarballs
  (list (npm-tarball "@types/node/-/node-20.19.43.tgz"
                     "0gcgcp8d22ajwxy3rxrsa34vwp41k3364qpqkjznvcnjjv5z4qwr")
        (npm-tarball "@types/vscode/-/vscode-1.145.0.tgz"
                     "1gxzcanb3kjallnqfb072i6x53n80aghxl2v40sy4ivsqfpfq4lg")
        (npm-tarball "typescript/-/typescript-5.9.3.tgz"
                     "1lx1hwb5g73x06pylqzgrkran1dlbx8iizrx0mwjhpvxrz4hiq8h")
        (npm-tarball "undici-types/-/undici-types-6.21.0.tgz"
                     "0vfidx8iwc7ab1p13fxy6bf35njqkii6nkwgah78b249w6jsk8fg")))

(define-public codecanvas-vscode
  (package
    (name "codecanvas-vscode")
    (version "0.7.3")
    (source (codecanvas-source "CodeCanvas-vscode"
                               "d1592fd01a19f34840c18fb8979334a9fe4827df"))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 format))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (replace 'build
            (lambda _
              (setenv "HOME" (getcwd))
              (setenv "npm_config_cache"
                      (string-append (getcwd) "/.npm-cache"))
              (let ((registry #$(start-offline-npm-registry
                                 (offline-npm-registry
                                  "codecanvas-vscode"
                                  %codecanvas-vscode-tarballs))))
                (invoke "npm" "ci" "--ignore-scripts")
                (kill registry SIGTERM))
              (invoke "node" "node_modules/typescript/bin/tsc" "-p" ".")))
          (replace 'install
            ;; The extension as an unpacked directory (for --extensions-dir)
            ;; and as a .vsix (for --install-extension), which is a zip of
            ;; the extension and two small metadata files.
            (lambda _
              (let* ((id (string-append "codecanvas.codecanvas-" #$version))
                     (share (string-append #$output "/share/vscode"))
                     (dest (string-append share "/extensions/" id))
                     (vsix (string-append share "/codecanvas-" #$version
                                          ".vsix")))
                (for-each
                 (lambda (file) (install-file file dest))
                 '("package.json" "README.md" "LICENSE"))
                (for-each
                 (lambda (dir)
                   (copy-recursively dir (string-append dest "/" dir)))
                 '("out" "media"))
                (mkdir-p "vsix")
                (symlink dest "vsix/extension")
                (with-directory-excursion "vsix"
                  (call-with-output-file "extension.vsixmanifest"
                    (lambda (port)
                      (format port "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<PackageManifest Version=\"2.0.0\" xmlns=\"http://schemas.microsoft.com/developer/vsx-schema/2011\">
  <Metadata>
    <Identity Language=\"en-US\" Id=\"codecanvas\" Version=\"~a\" Publisher=\"codecanvas\"/>
    <DisplayName>CodeCanvas</DisplayName>
    <Description>An infinite canvas for your code.</Description>
  </Metadata>
  <Installation><InstallationTarget Id=\"Microsoft.VisualStudio.Code\"/></Installation>
  <Dependencies/>
  <Assets>
    <Asset Type=\"Microsoft.VisualStudio.Code.Manifest\" Path=\"extension/package.json\" Addressable=\"true\"/>
  </Assets>
</PackageManifest>
" #$version)))
                  (call-with-output-file "[Content_Types].xml"
                    (lambda (port)
                      (display "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">
  <Default Extension=\".vsixmanifest\" ContentType=\"text/xml\"/>
  <Default Extension=\".json\" ContentType=\"application/json\"/>
  <Default Extension=\".js\" ContentType=\"application/javascript\"/>
  <Default Extension=\".css\" ContentType=\"text/css\"/>
  <Default Extension=\".html\" ContentType=\"text/html\"/>
  <Default Extension=\".svg\" ContentType=\"image/svg+xml\"/>
  <Default Extension=\".png\" ContentType=\"image/png\"/>
  <Default Extension=\".md\" ContentType=\"text/markdown\"/>
</Types>
" port)))
                  (mkdir-p share)
                  (invoke "zip" "-qrX" vsix "extension.vsixmanifest"
                          "[Content_Types].xml" "extension"))))))))
    (native-inputs (list node zip))
    (home-page "https://github.com/Lightningbulb2/CodeCanvas-vscode")
    (synopsis "CodeCanvas extension for VS Code and VSCodium")
    (description
     "This extension opens an infinite canvas for source code inside VS Code
or VSCodium.  Install @file{share/vscode/codecanvas-*.vsix} with
@command{codium --install-extension}.")
    (license license:expat)))
