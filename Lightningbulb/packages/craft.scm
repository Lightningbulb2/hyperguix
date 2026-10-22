;;; Lightningbulb channel --- the ArtCraft "Craft" creative suite
;;;
;;;   photocraft      image editor        (a clean-room take on Photoshop)
;;;   effectcraft     motion/VFX          (... on After Effects)
;;;   filmcraft       video editor        (... on Premiere)
;;;   lightcraft      photo library/raw   (... on Lightroom)
;;;   vectorcraft     vector illustration (... on Illustrator)
;;;   designcraft     page layout         (... on InDesign)
;;;   pdfcraft        PDF editor          (... on Acrobat)
;;;   wordcraft       word processor      (... on Word)
;;;   gridcraft       spreadsheet         (... on Excel)
;;;   soundcraft      audio workstation   (... on Pro Tools)
;;;   cadcraft        2D/3D CAD           (... on AutoCAD)
;;;   figcraft        interface design    (... on Figma)
;;;   craft-launcher  installer/launcher for the suite
;;;
;;; All of them are Rust workspaces built on egui/wgpu and need Rust 1.95,
;;; which Guix provides as `rust-1.95' (the default `rust' is older).  Their
;;; crates.io dependencies come from craft-crates.scm; crates they take from
;;; git (craft-libs, winprint.rs, filmcraft's codec crates, ...) are vendored
;;; with the helper in cargo-git.scm.

(define-module (Lightningbulb packages craft)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (Lightningbulb packages cargo-git)
  #:use-module (Lightningbulb packages craft-crates))

;; Libraries winit, wgpu and friends dlopen() at run time; added to RUNPATH.
(define %craft-runtime-libraries
  (list libx11 libxcb libxcursor libxi libxrandr libxkbcommon mesa
        vulkan-loader wayland))

(define (craft-fonts commit hash)
  "Checkout of storytold/craft-fonts at COMMIT.  Release builds embed the
fonts it lists (CJK, Arabic, Thai, ...) through CRAFT_FONTS_DIR."
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/storytold/craft-fonts")
          (commit commit)))
    (file-name (git-file-name "craft-fonts" (string-take commit 7)))
    (sha256 (base32 hash))))

(define* (craft-app name version commit hash
                    #:key cargo-inputs git-crates
                    (repository name)
                    ;; Workspace packages to build; each has one binary of
                    ;; the same name.
                    (binaries (list name (string-append name "-cli")))
                    (app-id (string-append "ai.storyteller." name))
                    (features '())
                    (fonts #f)          ;a `craft-fonts' origin, or #f
                    (extra-inputs '()) (extra-native-inputs '())
                    synopsis description)
  (package
    (name name)
    (version (git-version version "0" commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append "https://github.com/storytold/" repository))
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256 (base32 hash))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.95
      #:install-source? #f
      ;; The test suites need a GPU and a display, and would build the
      ;; whole workspace a second time in debug mode.
      #:tests? #f
      ;; The standard build phase honours --cores (-j).
      #:features `',features
      #:cargo-build-flags
      `'("--release"
         ,@(append-map (lambda (binary) (list "--package" binary))
                       binaries))
      #:phases
      #~(modify-phases %standard-phases
          #$@(vendor-git-crates-phases git-crates)
          #$@(if fonts
                 (list #~(add-before 'build 'set-craft-fonts
                           (lambda _
                             (setenv "CRAFT_FONTS_DIR" #$fonts)
                             ;; Fail rather than ship empty glyph boxes.
                             (setenv "CRAFT_FONTS_REQUIRED" "1"))))
                 '())
          (replace 'install
            (lambda _
              (let* ((app-id #$app-id)
                     (bin (string-append #$output "/bin"))
                     (share (string-append #$output "/share"))
                     (doc (string-append share "/doc/" #$name "-"
                                         #$(package-version this-package)))
                     (pkg "packaging/linux/")
                     (mime (string-append pkg app-id ".mime.xml"))
                     (metainfo (string-append share "/metainfo/"
                                              app-id ".metainfo.xml")))
                (for-each
                 (lambda (program)
                   (install-file
                    (car (filter (lambda (f)
                                   (string-suffix?
                                    (string-append "/release/" program) f))
                                 (find-files "target"
                                             (string-append "^" program "$"))))
                    bin))
                 '#$binaries)
                (install-file (string-append pkg app-id ".desktop")
                              (string-append share "/applications"))
                (when (file-exists? mime)
                  (mkdir-p (string-append share "/mime/packages"))
                  (copy-file mime (string-append share "/mime/packages/"
                                                 app-id ".xml")))
                (mkdir-p (dirname metainfo))
                (copy-file (string-append pkg app-id ".metainfo.xml.in")
                           metainfo)
                (substitute* metainfo
                  (("@VERSION@") #$version)
                  ;; No meaningful release date for a git snapshot.
                  ((" date=\"@DATE@\"") ""))
                (copy-recursively "assets/app-icon/hicolor"
                                  (string-append share "/icons/hicolor"))
                ;; As upstream's packages: the licence of each embedded
                ;; craft-fonts family.
                #$@(if fonts
                       (list
                        #~(for-each
                           (lambda (licence)
                             (install-file licence
                                           (string-append
                                            doc "/fonts/"
                                            (basename (dirname licence)))))
                           (find-files (string-append #$fonts "/fonts")
                                       "^OFL\\.txt$")))
                       '()))))
          (add-after 'install 'add-dlopen-runpath
            (lambda _
              (let ((runpath
                     (string-join
                      (list #$@(map (lambda (lib) (file-append lib "/lib"))
                                    %craft-runtime-libraries))
                      ":")))
                (for-each
                 (lambda (program)
                   (invoke "patchelf" "--add-rpath" runpath
                           (string-append #$output "/bin/" program)))
                 '#$binaries)))))))
    (native-inputs
     (append (list patchelf pkg-config)
             (if (null? git-crates) '() (list python))
             extra-native-inputs))
    (inputs
     (append %craft-runtime-libraries
             extra-inputs
             cargo-inputs))
    (supported-systems '("x86_64-linux" "aarch64-linux"))
    (home-page (string-append "https://github.com/storytold/" repository))
    (synopsis synopsis)
    (description description)
    ;; The code is MIT OR Apache-2.0; the fonts it embeds (its own UI fonts,
    ;; egui's and craft-fonts) are under the SIL Open Font License.
    (license (list license:expat license:asl2.0 license:silofl1.1))))

(define-public photocraft
  (craft-app "photocraft" "0.10.0" "03d0c7e3b39cfb401cdbba590431141ee4c6c8fa"
             "0hwhqzzh8nw2av9vhw538v1i4h3b6xzj65gpha354dnx02vyxqnw"
             #:cargo-inputs photocraft-cargo-inputs
             #:git-crates photocraft-git-crates
             ;; As in upstream's release builds: open HEIC/HEIF photos.
             #:features '("heif")
             #:fonts (craft-fonts "abb83316d96aa59c1cf64784289e378fe9fa5695"
                                  "081q9bkxgvr64wz6zw846w3yfy6sf081hpv3xbhm8018wsj8gvkv")
             #:synopsis "Layer-based image editor with PSD support"
             #:description
             "PhotoCraft is an image editor modelled on Adobe Photoshop:
layers, masks, adjustment layers, layer styles, type and vector layers,
brushes, and reading and writing PSD files, as well as common image formats
including HEIC/HEIF.  It also ships @command{photocraft-cli} for batch
processing."))

(define-public effectcraft
  (craft-app "effectcraft" "0.12.0" "ef74d82902ba486891b02afa87e42963cc9b84cc"
             "08rf1kgfcx8c0bzv8hj0wlirqnldyl7igcyqswr8amb0igb6fp0c"
             #:cargo-inputs effectcraft-cargo-inputs
             #:git-crates effectcraft-git-crates
             ;; cpal (audio preview).
             #:extra-inputs (list alsa-lib)
             #:synopsis "Motion graphics and visual effects compositor"
             #:description
             "EffectCraft is a compositor for motion graphics and visual
effects in the spirit of Adobe After Effects: compositions, layers and
keyframes, some 300 effects, layer styles, expressions, 3D cameras and lights,
and a render queue.  @command{effectcraft-cli} renders projects from the
command line."))

(define-public filmcraft
  (craft-app "filmcraft" "0.9.0" "fb4cbda47a134eedabd89fe02cd59ebc69462737"
             "1j18bdmj0wj56zszxcsg6c8w3l56d0khg6sxjzw992rhv31p59pw"
             #:cargo-inputs filmcraft-cargo-inputs
             #:git-crates filmcraft-git-crates
             #:fonts (craft-fonts "abb83316d96aa59c1cf64784289e378fe9fa5695"
                                  "081q9bkxgvr64wz6zw846w3yfy6sf081hpv3xbhm8018wsj8gvkv")
             ;; cpal (audio playback).
             #:extra-inputs (list alsa-lib)
             #:synopsis "Non-linear video editor with color and audio tools"
             #:description
             "FilmCraft is a non-linear video editor: a multi-track timeline,
color correction and grading, audio mixing, titles and transitions, with its
own codecs for common formats (H.264, HEVC, AV1, VP9, ProRes, DNx, AAC, Opus)
and containers.  @command{filmcraft-cli} renders and converts projects from
the command line."))

(define-public lightcraft
  (craft-app "lightcraft" "0.10.0" "abb49bdd76e64acd20afe2e4d7bb1cf71c548d1d"
             "1njdgn2ccbrh72g2li3zl5krb89accmqvdgbvdn2bg1qfn1nb0q2"
             #:cargo-inputs lightcraft-cargo-inputs
             #:git-crates lightcraft-git-crates
             ;; As in upstream's release builds: open HEIC/HEIF photos.
             #:features '("lightcraft/heif" "lightcraft-cli/heif")
             #:fonts (craft-fonts "3d9ab3a132ed0eff457e424226a435a901da30d3"
                                  "0c89azfbjmn9w8737fr3hkpin28449nqkrnws7smb9qf2z6c7ncq")
             #:synopsis "Photo library and raw developer"
             #:description
             "LightCraft is a photo library and raw developer modelled on
Adobe Lightroom.  Every adjustment is non-destructive and renders through a
scene-referred, 32-bit floating point pipeline: exposure and tone, white
balance, color mixing and grading, tone curves, texture, clarity, dehaze,
vignette and grain.  It opens camera raw files, JPEG, PNG, TIFF, WebP and
HEIC/HEIF.  @command{lightcraft-cli} renders photos without a window."))

(define-public vectorcraft
  (craft-app "vectorcraft" "0.14.0" "cb0a7d9b31522dd57742b4cfe4550f2ec0a5e5c3"
             "14yxy2dp7xp3cabi4zvy7ddiycjd8varmx8zrj67iryrn6fcyyra"
             #:cargo-inputs vectorcraft-cargo-inputs
             #:git-crates vectorcraft-git-crates
             #:fonts (craft-fonts "a71c20e30af613287c504f7e685ca8fad77752bc"
                                  "0nbnmfpfgb1gvv7ddzx3pwp3g8nnv3mjzbdzv140d6j6pa6rcg19")
             #:synopsis "Vector illustration program"
             #:description
             "VectorCraft is a vector illustration program modelled on Adobe
Illustrator: paths and shapes, boolean operations, brushes, gradients, type,
image tracing and effects.  It reads and writes SVG, PDF and PDF-compatible
Illustrator files, and exports PNG, JPEG and WebP.  @command{vectorcraft-cli}
runs batch jobs without a window."))

(define-public designcraft
  (craft-app "designcraft" "0.10.0" "3ce3a24f08d03935bc8cf7cb23755aca8065558c"
             "0xgvyk1pps50l7d5ilppnq9973566p0a7nq7w9lkcpa88rdqkna2"
             #:cargo-inputs designcraft-cargo-inputs
             #:git-crates designcraft-git-crates
             #:fonts (craft-fonts "abb83316d96aa59c1cf64784289e378fe9fa5695"
                                  "081q9bkxgvr64wz6zw846w3yfy6sf081hpv3xbhm8018wsj8gvkv")
             #:synopsis "Desktop publishing and page layout program"
             #:description
             "DesignCraft is a desktop publishing program modelled on Adobe
InDesign: parent pages, threaded text frames, paragraph and character styles,
tables and text wrap, with a Knuth-Plass paragraph composer and hyphenation.
It reads and writes IDML, imports INDD, and exports PDF (including PDF/X-4
and PDF/A-2b), EPUB, PPTX and PNG.  @command{designcraft-cli} converts and
exports documents from the command line."))

(define-public pdfcraft
  (craft-app "pdfcraft" "0.10.1" "416495145354828a9efefc39df381ba3ee8f864f"
             "0jpb7abq87s7k7gkknvldf5dfr3gfr3sqrws2d5rfj42z98zcnv8"
             #:cargo-inputs pdfcraft-cargo-inputs
             #:git-crates pdfcraft-git-crates
             #:fonts (craft-fonts "3d9ab3a132ed0eff457e424226a435a901da30d3"
                                  "0c89azfbjmn9w8737fr3hkpin28449nqkrnws7smb9qf2z6c7ncq")
             ;; aws-lc-sys (TLS for signature checks) wants cmake.
             #:extra-native-inputs (list cmake-minimal)
             #:synopsis "PDF reader and editor"
             #:description
             "PdfCraft is a PDF reader and editor modelled on Adobe Acrobat.
It renders complex scripts, vertical CJK text, transparency and color emoji,
repairs damaged files, and can annotate, edit, organize, combine, split,
measure and encrypt documents; saves are incremental, so the original bytes
are kept.  @command{pdfcraft-cli} inspects and renders PDF files from the
command line."))

(define-public wordcraft
  (craft-app "wordcraft" "0.9.0" "e05b7fe86f3b85454000dffc321de638d7009817"
             "1qpwrk9kk74izmh6plff9g5kk7g4piixd4zb4k22h7xp7cvyrr6n"
             #:cargo-inputs wordcraft-cargo-inputs
             #:git-crates wordcraft-git-crates
             #:fonts (craft-fonts "8dcdacd5153e64560d109541a47d806f26f048c0"
                                  "1qjgv7l6bndaww2nnpzhgm2glng04yfbxsamqkykvrs4v2p4wkz0")
             #:synopsis "Word processor with DOCX support"
             #:description
             "WordCraft is a word processor modelled on Microsoft Word: the
ribbon, styles, tables, tracked changes, references and mail merge, with
offline spelling and grammar checking.  It reads and writes DOCX, ODT, RTF,
HTML, Markdown, LaTeX and plain text, opens legacy DOC files, and exports
PDF.  @command{wordcraft-cli} converts, inspects and renders documents from
the command line."))

(define-public gridcraft
  (craft-app "gridcraft" "0.9.0" "37e41424ed425b33520ae98c6b8f660e518cecad"
             "03mvj7qbazgxkm97fd2pm7hrphmpziixz87p4fciwcbk27a3whi7"
             #:cargo-inputs gridcraft-cargo-inputs
             #:git-crates gridcraft-git-crates
             #:fonts (craft-fonts "abb83316d96aa59c1cf64784289e378fe9fa5695"
                                  "081q9bkxgvr64wz6zw846w3yfy6sf081hpv3xbhm8018wsj8gvkv")
             #:synopsis "Spreadsheet program with XLSX support"
             #:description
             "GridCraft is a spreadsheet program modelled on Microsoft Excel: a
dependency-graph calculation engine with dynamic arrays and more than 500
worksheet functions, number formats, conditional formatting, tables, charts
and pivot tables.  XLSX is its native format; it also reads and writes CSV
and TSV, and imports XLS, XLSB and ODS data.  @command{gridcraft-cli}
inspects, converts and evaluates workbooks from the command line."))

(define-public soundcraft
  (craft-app "soundcraft" "0.10.0" "7b339fe921dfc1231051cd1263d582f6da589e75"
             "1wgq3aja251m1abd51yscgbl20c6c5y4ljwr2lmd8lcxrbzvvgf3"
             #:cargo-inputs soundcraft-cargo-inputs
             #:git-crates soundcraft-git-crates
             ;; cpal (audio input and output).
             #:extra-inputs (list alsa-lib)
             #:synopsis "Digital audio workstation"
             #:description
             "SoundCraft is a digital audio workstation for recording, editing
and mixing audio, modelled on the Avid Pro Tools workflow: multitrack editing,
a mixer with sends, busses and automation, MIDI, built-in effects and
instruments, and CLAP plug-ins.  @command{soundcraft-cli} edits, converts and
bounces sessions from the command line."))

(define-public cadcraft
  (craft-app "cadcraft" "0.10.0" "0cf3bdea83ebbe02fb2e674b23f07de4acfa73da"
             "02mk9avaqjk8cypc97zfnxj5nji9yfh63pd5376vjan1gy59bk9v"
             #:cargo-inputs cadcraft-cargo-inputs
             #:git-crates cadcraft-git-crates
             #:fonts (craft-fonts "3d9ab3a132ed0eff457e424226a435a901da30d3"
                                  "0c89azfbjmn9w8737fr3hkpin28449nqkrnws7smb9qf2z6c7ncq")
             #:synopsis "2D and 3D computer-aided design program"
             #:description
             "CADCraft is a computer-aided design and drafting program
modelled on AutoCAD: the command line, object snaps, layers, dimensions,
hatches and blocks, and reading and writing DXF and DWG drawings.
@command{cadcraft-cli} converts and exports drawings and runs scripts from
the command line."))

(define-public figcraft
  (craft-app "figcraft" "0.8.0" "35da7b7cff99ca7f5aba7574d0c72155461e7cf1"
             "0z456a78msm9r4bq2cgqv8bb57n0pmvs8571nfrhg5yxkay475wg"
             #:cargo-inputs figcraft-cargo-inputs
             #:git-crates figcraft-git-crates
             #:fonts (craft-fonts "43913056ce82a3fdad0ef69f6b88d1dc922a8104"
                                  "0in06alnrhzjgmw12s2f4bcsp50iiblfmjksbv7jr4jyrbkc4mxv")
             #:synopsis "Interface design and prototyping tool"
             #:description
             "FigCraft is an interface design and prototyping tool modelled on
Figma: frames with auto layout, components and variants, vector networks,
styles, variables and prototypes.  It imports and exports SVG, PNG, JPEG,
WebP and PDF, and opens Figma files.  @command{figcraft-cli} exports,
converts and renders files from the command line."))

(define-public craft-launcher
  (craft-app "craft-launcher" "0.6.1" "ba3b0345f0b14f5cb892dcb8b917ca212c124cf9"
             "06h2cp7gvp6960gr764xmplrk4bwm8hvfcasxba8lrfwg4ihvg7y"
             #:cargo-inputs craft-launcher-cargo-inputs
             #:git-crates craft-launcher-git-crates
             #:binaries '("artcraft-launcher")
             #:app-id "ai.storyteller.artcraft-launcher"
             #:synopsis "Installer and launcher for the Craft app suite"
             #:description
             "ArtCraft Launcher lists the apps of the Craft suite (PhotoCraft,
FilmCraft, PdfCraft and others), opens the installed ones, and can download
and update upstream's release builds of the others.  Note that those
prebuilt binaries expect a conventional file system layout and may not run
on Guix System; prefer the Guix packages of the apps."))
