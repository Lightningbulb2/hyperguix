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
;;;   deckcraft       presentations       (... on PowerPoint)
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
                    (revision "0")
                    (repository name)
                    ;; Workspace packages to build; each has one binary of
                    ;; the same name.
                    (binaries (list name (string-append name "-cli")))
                    (app-id (string-append "ai.storyteller." name))
                    (features '())
                    (fonts #f)          ;a `craft-fonts' origin, or #f
                    (extra-inputs '()) (extra-native-inputs '())
                    ;; Spliced at the end of `modify-phases'.
                    (extra-phases '())
                    synopsis description)
  (package
    (name name)
    (version (git-version version revision commit))
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
                ;; Some apps keep the icons' credits beside them.
                (for-each delete-file
                          (find-files (string-append share "/icons")
                                      "\\.attribution$"))
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
                 '#$binaries))))
          #$@extra-phases)))
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
  (craft-app "photocraft" "0.17.0" "b8c3f3aa8e2918032cadc0e042664414a03be333"
             "1fzpqyvc1m05si6dj7z4wdakbfsfx2bylhgqrra5ppwsbcpqrpm0"
             #:cargo-inputs photocraft-cargo-inputs
             #:git-crates photocraft-git-crates
             ;; As in upstream's release builds: open HEIC/HEIF photos.
             #:features '("heif")
             ;; aws-lc-sys (TLS for winprint's signature checks) wants cmake.
             #:extra-native-inputs (list cmake-minimal)
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Layer-based image editor with PSD support"
             #:description
             "PhotoCraft is an image editor modelled on Adobe Photoshop:
layers, masks, adjustment layers, layer styles, type and vector layers,
brushes, and reading and writing PSD files, as well as common image formats
including HEIC/HEIF.  It also ships @command{photocraft-cli} for batch
processing."))

(define-public effectcraft
  (craft-app "effectcraft" "0.18.0" "c3600f9b59b109da97871a43a6898683a0163cb1"
             "17w75nbjry0rgfzf6d29yy2yfk2d1sipl19zjmdkznl4qbvwnc75"
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
  (craft-app "filmcraft" "0.14.0" "a2d8e9ce269aba9c399e36262522e11456df6fbf"
             "1b47d5hxjamgwm17i8sl8lpyxch2hxb5yskn67bkwid15k2cyjyr"
             #:cargo-inputs filmcraft-cargo-inputs
             #:git-crates filmcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
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
  (craft-app "lightcraft" "0.15.0" "e381c1ae6b2006ce627b243fe41697ce0d9608e0"
             "0c4215gfphrnd0ywd8m6hr9d6pm4k47z262wbznwjr2rj51fwyx1"
             #:cargo-inputs lightcraft-cargo-inputs
             #:git-crates lightcraft-git-crates
             ;; As in upstream's release builds: open HEIC/HEIF photos.
             #:features '("lightcraft/heif" "lightcraft-cli/heif")
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Photo library and raw developer"
             #:description
             "LightCraft is a photo library and raw developer modelled on
Adobe Lightroom.  Every adjustment is non-destructive and renders through a
scene-referred, 32-bit floating point pipeline: exposure and tone, white
balance, color mixing and grading, tone curves, texture, clarity, dehaze,
vignette and grain.  It opens camera raw files, JPEG, PNG, TIFF, WebP and
HEIC/HEIF.  @command{lightcraft-cli} renders photos without a window."))

(define-public vectorcraft
  (craft-app "vectorcraft" "0.18.0" "68b68a30acad9b3d8a72802b35f43b82e2bd7d3a"
             "1pbdzd4kpysmjxv9xcni38cpy8nx0kh5936kbsq061njx7smv25y"
             #:cargo-inputs vectorcraft-cargo-inputs
             #:git-crates vectorcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             ;; aws-lc-sys (TLS for winprint's signature checks) wants cmake.
             #:extra-native-inputs (list cmake-minimal)
             #:synopsis "Vector illustration program"
             #:description
             "VectorCraft is a vector illustration program modelled on Adobe
Illustrator: paths and shapes, boolean operations, brushes, gradients, type,
image tracing and effects.  It reads and writes SVG, PDF and PDF-compatible
Illustrator files, and exports PNG, JPEG and WebP.  @command{vectorcraft-cli}
runs batch jobs without a window."))

(define-public designcraft
  (craft-app "designcraft" "0.14.0" "7da69c16ce221f46e8f27cb41e0c88167c8be416"
             "04vw60q9na9aw14v8k3lcls8p7rma36h3p89bkblh380vrjc62kr"
             #:cargo-inputs designcraft-cargo-inputs
             #:git-crates designcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             ;; aws-lc-sys (TLS for winprint's signature checks) wants cmake.
             #:extra-native-inputs (list cmake-minimal)
             #:synopsis "Desktop publishing and page layout program"
             #:description
             "DesignCraft is a desktop publishing program modelled on Adobe
InDesign: parent pages, threaded text frames, paragraph and character styles,
tables and text wrap, with a Knuth-Plass paragraph composer and hyphenation.
It reads and writes IDML, imports INDD, and exports PDF (including PDF/X-4
and PDF/A-2b), EPUB, PPTX and PNG.  @command{designcraft-cli} converts and
exports documents from the command line."))

(define-public pdfcraft
  (craft-app "pdfcraft" "0.15.0" "75360d1d7db06fed974f48c914d4c04132757187"
             "0gbvj2wza56kl8vkb1nm53ylhlqvkgaqp356ffvczccmyzhi4y7m"
             #:cargo-inputs pdfcraft-cargo-inputs
             #:git-crates pdfcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
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
  (craft-app "wordcraft" "0.12.0" "3de6ff95af86c19d67030cd96dba15cd6a45a25e"
             "0963x8a9x9zchwp5j7mf8ihn2hwsmrpz48z0hnixangpq6c4l6if"
             #:cargo-inputs wordcraft-cargo-inputs
             #:git-crates wordcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             ;; aws-lc-sys (TLS for winprint's signature checks) wants cmake.
             #:extra-native-inputs (list cmake-minimal)
             #:synopsis "Word processor with DOCX support"
             #:description
             "WordCraft is a word processor modelled on Microsoft Word: the
ribbon, styles, tables, tracked changes, references and mail merge, with
offline spelling and grammar checking.  It reads and writes DOCX, ODT, RTF,
HTML, Markdown, LaTeX and plain text, opens legacy DOC files, and exports
PDF.  @command{wordcraft-cli} converts, inspects and renders documents from
the command line."))

(define-public gridcraft
  (craft-app "gridcraft" "0.13.0" "43284377d2466037628e57d8ad0c891778fdb45c"
             "16cj8gz635785dl0bgdvzx7v43fqn8xabhsglpxpyndp9ci1nn9g"
             #:cargo-inputs gridcraft-cargo-inputs
             #:git-crates gridcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             ;; aws-lc-sys (TLS for winprint's signature checks) wants cmake.
             #:extra-native-inputs (list cmake-minimal)
             #:synopsis "Spreadsheet program with XLSX support"
             #:description
             "GridCraft is a spreadsheet program modelled on Microsoft Excel: a
dependency-graph calculation engine with dynamic arrays and more than 500
worksheet functions, number formats, conditional formatting, tables, charts
and pivot tables.  XLSX is its native format; it also reads and writes CSV
and TSV, and imports XLS, XLSB and ODS data.  @command{gridcraft-cli}
inspects, converts and evaluates workbooks from the command line."))

(define-public soundcraft
  (craft-app "soundcraft" "0.14.0" "c6befe57afd0dc35fc4b86a01b2a19011ae1df1e"
             "0w6bliw2s06acmzy9z7pq3r7agdpvxh5spvlx353qmi7zaar39mv"
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
  (craft-app "cadcraft" "0.14.0" "fbd97d432cdf36a566c0c53739481bd6f0c32b0d"
             "1fmyaxxk9668vcir1yjn0qgx66w0g0r44gq5p74j4q21242a2xp7"
             #:cargo-inputs cadcraft-cargo-inputs
             #:git-crates cadcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "2D and 3D computer-aided design program"
             #:description
             "CADCraft is a computer-aided design and drafting program
modelled on AutoCAD: the command line, object snaps, layers, dimensions,
hatches and blocks, and reading and writing DXF and DWG drawings.
@command{cadcraft-cli} converts and exports drawings and runs scripts from
the command line."))

(define-public figcraft
  (craft-app "figcraft" "0.12.1" "ef9721c5b9d0f1cc19a74449cbe175fc06bf8efa"
             "06ibayfbsh001dppvacdw9f2r78a127q2lgsf6ny2qdvd1jcbndd"
             #:cargo-inputs figcraft-cargo-inputs
             #:git-crates figcraft-git-crates
             #:fonts (craft-fonts "37827adc41fd165f9a9234ac40f94dbad353aa69"
                                  "1vqsvwd3ix67gbj0q6kzmr2rah78ysc1m84fvf9b4blbzln4rw85")
             #:synopsis "Interface design and prototyping tool"
             #:description
             "FigCraft is an interface design and prototyping tool modelled on
Figma: frames with auto layout, components and variants, vector networks,
styles, variables and prototypes.  It imports and exports SVG, PNG, JPEG,
WebP and PDF, and opens Figma files.  @command{figcraft-cli} exports,
converts and renders files from the command line."))

(define-public deckcraft
  (craft-app "deckcraft" "0.12.0" "29f0f7772c47aa2bfb74fcbb0c4d3b1503300849"
             "0q3i56jvq1x3p1hqd39snid5r5qvnkjxvnc618l8y1k8b4slhr05"
             #:cargo-inputs deckcraft-cargo-inputs
             #:git-crates deckcraft-git-crates
             #:fonts (craft-fonts "37827adc41fd165f9a9234ac40f94dbad353aa69"
                                  "1vqsvwd3ix67gbj0q6kzmr2rah78ysc1m84fvf9b4blbzln4rw85")
             ;; cpal (sound in slide shows).
             #:extra-inputs (list alsa-lib)
             #:synopsis "Presentation program with PPTX support"
             #:description
             "DeckCraft is a presentation program modelled on Microsoft
PowerPoint and Apple Keynote: themes and layouts, shapes, pictures, tables,
charts, transitions and animations, and full-screen slide shows.  It opens
and saves PPTX presentations.  @command{deckcraft-cli} converts and renders
decks from the command line."))

(define-public craft-launcher
  (craft-app "craft-launcher" "0.9.0" "9613c285dd40095c47772ee4e47494c06618d57a"
             "0kqm07j04a5vsih06y6jgabfw6z07ibhydqc6d1j0n2pir7j94ay"
             #:cargo-inputs craft-launcher-cargo-inputs
             #:git-crates craft-launcher-git-crates
             #:binaries '("artcraft-launcher")
             #:app-id "ai.storyteller.artcraft-launcher"
             #:extra-phases
             (list
              #~(add-after 'unpack 'patch-for-guix
                  (lambda _
                    ;; The window's app_id (and X11 class) is the bundle id,
                    ;; not the binary name.
                    (substitute* "packaging/linux/ai.storyteller.artcraft-launcher.desktop"
                      (("^StartupWMClass=.*")
                       "StartupWMClass=ai.storyteller.artcraft-launcher\n"))
                    (substitute* "crates/native/src/login.rs"
                      ;; The login entry would name this store item, which
                      ;; goes away with the next upgrade; use PATH instead.
                      (("std::env::current_exe\\(\\)\\.map_err\\(\\|e\\| format!\\(\"couldn't find this program \\(\\{e\\}\\)\"\\)\\)")
                       "Ok(PathBuf::from(\"artcraft-launcher\"))"))
                    (substitute* "crates/native/src/detect.rs"
                      ;; Put downloaded AppImages in ~/.local/bin, which it
                      ;; searches already, rather than a new ~/Applications.
                      (("h\\.join\\(\"Applications\"\\)")
                       "h.join(\".local\").join(\"bin\")")
                      (("vec!\\[home\\.join\\(\"Applications\"\\), ")
                       "vec![")))))
             #:synopsis "Installer and launcher for the Craft app suite"
             #:description
             "ArtCraft Launcher lists the apps of the Craft suite (PhotoCraft,
FilmCraft, PdfCraft and others), opens the installed ones, and can download
and update upstream's release builds of the others.  Note that those
prebuilt binaries expect a conventional file system layout and may not run
on Guix System; prefer the Guix packages of the apps."))
