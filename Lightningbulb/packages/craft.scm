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
;;;   texturecraft    texture painting    (... on Substance Painter)
;;;   craft-anything  explains how a program works, and helps rebuild it
;;;   craft-launcher  installer/launcher for the suite
;;;
;;; All of them are Rust workspaces built on egui/wgpu and need Rust 1.95,
;;; which Guix provides as `rust-1.95' (the default `rust' is older);
;;; craft-anything needs 1.97, from rust-next.scm.  Their
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
  #:use-module (gnu packages fontutils)
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
  #:use-module (Lightningbulb packages cargo-suite)
  #:use-module (Lightningbulb packages rust-next)
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
                    (rust rust-1.95)
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
      #:rust rust
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
          #$@(fast-cargo-release-phases)
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
  (craft-app "photocraft" "0.23.1" "45066c48292e92229ada3459a83453439514c83d"
             "1v6iwr3n2c1gh3ilz567zj5hx1ck41zjbli6x1bza1jh2j8rh70j"
             #:cargo-inputs photocraft-cargo-inputs
             #:git-crates photocraft-git-crates
             ;; As in upstream's release builds: open HEIC/HEIF photos.
             #:features '("heif")
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
  (craft-app "effectcraft" "0.24.1" "582344dd4ef462362c02e56e3094de7af01847ab"
             "0isavqvf2qy84ga2pdsmpg7gk609j16vgjgcfrzxg6kikni8znkn"
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
  (craft-app "filmcraft" "0.20.1" "cedf0c9bd060eb06a977d532402be2097c9ebe42"
             "056m39ncjr0jx3bakk7k3vinjjqr0w28gx2cxdxspryjz6ax9ybr"
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
  (craft-app "lightcraft" "0.21.0" "d4f11018adafc3caba8c48da04113e7d44599ef0"
             "0jv3dw4ssvhsnnrajfaxsb0q18m1gli30jzacm8akvfy6qwgjyf6"
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
  (craft-app "vectorcraft" "0.24.0" "0faabbfe85fd2c02469f53c107f3ec2a2edfac95"
             "1iyjknfzmwpqz20fkpmd7rizcks8h1k7iliaxb6nvj0h03sg45hm"
             #:cargo-inputs vectorcraft-cargo-inputs
             #:git-crates vectorcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Vector illustration program"
             #:description
             "VectorCraft is a vector illustration program modelled on Adobe
Illustrator: paths and shapes, boolean operations, brushes, gradients, type,
image tracing and effects.  It reads and writes SVG, PDF and PDF-compatible
Illustrator files, and exports PNG, JPEG and WebP.  @command{vectorcraft-cli}
runs batch jobs without a window."))

(define-public designcraft
  (craft-app "designcraft" "0.20.1" "33a467872268c98536231491865b4011b0275b17"
             "03m2mi711zg1103w67gwc3m9v3h3z9p49giwx4w69jl2mqbizi5f"
             #:cargo-inputs designcraft-cargo-inputs
             #:git-crates designcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Desktop publishing and page layout program"
             #:description
             "DesignCraft is a desktop publishing program modelled on Adobe
InDesign: parent pages, threaded text frames, paragraph and character styles,
tables and text wrap, with a Knuth-Plass paragraph composer and hyphenation.
It reads and writes IDML, imports INDD, and exports PDF (including PDF/X-4
and PDF/A-2b), EPUB, PPTX and PNG.  @command{designcraft-cli} converts and
exports documents from the command line."))

(define-public pdfcraft
  (craft-app "pdfcraft" "0.21.1" "b503b2e62dfeec5598f344e4e287d9c9cbdb34fa"
             "0fzhb4qrbj03k60vn1l58ipy5vjh9841lp7qlp8i36zvvb3a4zfr"
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
  (craft-app "wordcraft" "0.18.1" "079f478bd85df7bcc567e3bafa7d7219096f9c3c"
             "1sv25cjl3bpk4cng2w5y4myxzkvqxdgqlafzlpy702zs4li51h4z"
             #:cargo-inputs wordcraft-cargo-inputs
             #:git-crates wordcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Word processor with DOCX support"
             #:description
             "WordCraft is a word processor modelled on Microsoft Word: the
ribbon, styles, tables, tracked changes, references and mail merge, with
offline spelling and grammar checking.  It reads and writes DOCX, ODT, RTF,
HTML, Markdown, LaTeX and plain text, opens legacy DOC files, and exports
PDF.  @command{wordcraft-cli} converts, inspects and renders documents from
the command line."))

(define-public gridcraft
  (craft-app "gridcraft" "0.19.1" "476448d7d9f3a5f8e93fcf7d98b47fd52293fe7f"
             "1k1csrp90aljgrwhp2799hdw9yrvbna64v7sdzzbyw417y723ngx"
             #:cargo-inputs gridcraft-cargo-inputs
             #:git-crates gridcraft-git-crates
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Spreadsheet program with XLSX support"
             #:description
             "GridCraft is a spreadsheet program modelled on Microsoft Excel: a
dependency-graph calculation engine with dynamic arrays and more than 500
worksheet functions, number formats, conditional formatting, tables, charts
and pivot tables.  XLSX is its native format; it also reads and writes CSV
and TSV, and imports XLS, XLSB and ODS data.  @command{gridcraft-cli}
inspects, converts and evaluates workbooks from the command line."))

(define-public soundcraft
  (craft-app "soundcraft" "0.20.1" "a52bbdccbe15342f44e0de1906bf71a621e7a68f"
             "0k3yn0r3l17qyl7kq4mmpf7s8lj6b5sq8szn71y0wn8a71d3bv21"
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
  (craft-app "cadcraft" "0.20.1" "7526dc62c14e71b3c8d46e73bbf1fa29ef506af1"
             "1zj4wx4gygafjg21mkjdfm6j3rcnnjxqkbv2dgvkbczkz8zas32p"
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
  (craft-app "figcraft" "0.18.1" "4acc293c2ec941ac1400837ee7e3ab51780399f8"
             "1bxhkivs1x7wh99byais9dz0jqps4iigkbcd644kggb1q6ar4s9g"
             #:cargo-inputs figcraft-cargo-inputs
             #:git-crates figcraft-git-crates
             ;; Up to 0.16 its path code used isolate_lowest_one (Rust 1.97);
             ;; 0.18 no longer does, so it builds with 1.95 in the suite.
             #:fonts (craft-fonts "37827adc41fd165f9a9234ac40f94dbad353aa69"
                                  "1vqsvwd3ix67gbj0q6kzmr2rah78ysc1m84fvf9b4blbzln4rw85")
             ;; yeslogic-fontconfig-sys (system fonts in the font picker).
             #:extra-inputs (list fontconfig)
             #:synopsis "Interface design and prototyping tool"
             #:description
             "FigCraft is an interface design and prototyping tool modelled on
Figma: frames with auto layout, components and variants, vector networks,
styles, variables and prototypes.  It imports and exports SVG, PNG, JPEG,
WebP and PDF, and opens Figma files.  @command{figcraft-cli} exports,
converts and renders files from the command line."))

(define-public deckcraft
  (craft-app "deckcraft" "0.18.1" "7cc73ab1895ed2e30c8afbcada20c70b9ea0a440"
             "0f2xlj31g6xzmd8s35drrv7dr223x38ild5zhxk5646636z1knlw"
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

(define-public texturecraft
  (craft-app "texturecraft" "0.6.1" "34a196190fe2daa2f43017a0f32b254cca4836f2"
             "0l1kknfyywhkaaj6xxd5pcjnk9x4ylg38y0s1bpq0fw6ni6ggr2y"
             #:cargo-inputs texturecraft-cargo-inputs
             #:git-crates texturecraft-git-crates
             #:fonts (craft-fonts "aced4137c022f1f587624d48e81ec77e1914a9cc"
                                  "0krhvqc3v6wi79dz0jdqf2jdi404xsy6vmsz5frx62hcl4pyys74")
             #:synopsis "3D texture painting program"
             #:description
             "TextureCraft paints PBR materials directly onto 3D models, in
layers with masks, in the spirit of Adobe Substance 3D Painter.  It bakes mesh
maps, drives smart materials from them, and exports texture sets for game
engines.  @command{texturecraft-cli} bakes and exports from the command line,
and includes an MCP server for AI agents."))

(define-public craft-anything
  (craft-app "craft-anything" "0.6.1" "48a9c5a60ff83ff620f98661339be6281a7debc6"
             "0vislijzag60m3cw7nclqkg0n282mlhprljxwp5a2prwhfnnn9bp"
             #:cargo-inputs craft-anything-cargo-inputs
             #:git-crates craft-anything-git-crates
             ;; Its oxc crates (JavaScript analysis) use APIs stabilized in
             ;; Rust 1.97.
             #:rust rust-1.97
             #:fonts (craft-fonts "b076417b5880bd4154bd22f00695b1d28c6bea83"
                                  "0ix1yqh09iwmrzlqi14j33ix6lp6jmhyq4pv8rxg18a3082db7cd")
             #:synopsis "Study how a program works, then rebuild it with an AI agent"
             #:description
             "Craft Anything studies a website, app or game with inspection
tools and answers questions about how it works, with the evidence for each
answer.  Given a goal, it has a coding agent build a new project, checks the
result against the original and refines it.  @command{craft-anything-cli}
does the same from the command line and includes an MCP server."))

(define-public craft-launcher
  (craft-app "craft-launcher" "0.19.2" "9f950e01ef728a3d32d997d59607051dee98a51d"
             "0qkriwdixcga6bsjmrqpq229gc9ifj05rnj9p44ma0mf2fagib52"
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

;;; The Craft apps on Rust 1.95 are built together, so that the egui/wgpu
;;; stack and the other crates they share are compiled once instead of 15
;;; times (see cargo-suite.scm).  The public names above are replaced by the
;;; suite's builds of them.  craft-anything needs Rust 1.97 and stays a
;;; separate package.  Bumping any of these apps rebuilds the suite.

(define-public craft-suite
  (cargo-suite "craft-suite"
               ;; figcraft and pdfcraft first: the members most likely to
               ;; break (figcraft moved off Rust 1.97; pdfcraft pins winprint
               ;; at two git revisions), so a failure shows up early.
               (list figcraft pdfcraft photocraft effectcraft filmcraft
                     lightcraft vectorcraft designcraft wordcraft gridcraft
                     soundcraft cadcraft deckcraft texturecraft craft-launcher)
               #:rust rust-1.95))

(set! photocraft (suite-member craft-suite photocraft))
(set! effectcraft (suite-member craft-suite effectcraft))
(set! filmcraft (suite-member craft-suite filmcraft))
(set! lightcraft (suite-member craft-suite lightcraft))
(set! vectorcraft (suite-member craft-suite vectorcraft))
(set! designcraft (suite-member craft-suite designcraft))
(set! pdfcraft (suite-member craft-suite pdfcraft))
(set! wordcraft (suite-member craft-suite wordcraft))
(set! gridcraft (suite-member craft-suite gridcraft))
(set! soundcraft (suite-member craft-suite soundcraft))
(set! cadcraft (suite-member craft-suite cadcraft))
(set! figcraft (suite-member craft-suite figcraft))
(set! deckcraft (suite-member craft-suite deckcraft))
(set! texturecraft (suite-member craft-suite texturecraft))
(set! craft-launcher (suite-member craft-suite craft-launcher))
