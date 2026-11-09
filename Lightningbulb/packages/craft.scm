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
;;; craft-anything and figcraft need 1.97, from rust-next.scm.  Their
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
  (craft-app "photocraft" "0.21.0" "efb7ebd0c0dab1fc108ee4642aa47c22694271a8"
             "14l0vm4ajvyn0hafsqw314mp1ill0jx6znspgd1q9pxn3agbsdaf"
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
  (craft-app "effectcraft" "0.22.0" "42e3c6a6c119d973aa59ab0437487ea6cae6a15d"
             "1yazjfw1h4n4cr5nli4n1vwjyrwkgvqslpqm3nm303s0v7zq6r8v"
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
  (craft-app "filmcraft" "0.18.0" "015d5b3ea37e1202a529e6245d3cc021c8c16ffd"
             "0zy48nj5fsnb1pwgl1iq9ikpq48xsrq4sdb0i9cxhmhdwx8zs7zm"
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
  (craft-app "lightcraft" "0.19.0" "16636c45a63bff3065a6fd31aecc22a6fc15ca53"
             "03wxx9hg5cppazh7351ybi2cbazq92dzvngmgjh924cvn128w1ji"
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
  (craft-app "vectorcraft" "0.22.0" "654749c16eb20b6d3182a96defb66e11d1a9649a"
             "1031w9n4anrwaghq2dkpqsxmi6qcwgb0kf638fn13il85v0zn9p0"
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
  (craft-app "designcraft" "0.18.0" "58ac6d29b260e033f4291afc4318b507cfd90fd9"
             "1rj9gm257g8psiz84y95bslnk8dghj8q2ajnf1vw22xzkmvskh6q"
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
  (craft-app "pdfcraft" "0.19.0" "8c572792d6760bdc903d6f9a032e3e38e8f71cb8"
             "16n6lr25qxvzyqq0nnnhb64jk1rnh94f1n138x8akhzkjpa55acs"
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
  (craft-app "wordcraft" "0.16.0" "02a802cbafe45b5c8fecc00490c8f6b78c5ba251"
             "1rdg748p0x7h603zhx34jcbc18bxxxdvsr42k6q6jprfspvmsipf"
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
  (craft-app "gridcraft" "0.17.0" "a6a6a49a0415087474251b08e887a3581fab9e14"
             "0bj4d5mhm2744jhm0b17mcyvgjikm7svhlwh4r1hxx03926255pp"
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
  (craft-app "soundcraft" "0.18.0" "5ff012ab88490cdfc635ee304c1019885e1b880d"
             "1511r1r92dgdxnapz1l8abf68f3ibkm12319ymbnbb533vlwy51b"
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
  (craft-app "cadcraft" "0.18.0" "32238e83c2c8bf643994132883e94bc96961f649"
             "1vxidrp3yr8x3sf6s9zfvxj87s1d6mzdvdsyaj2bsp3ymykzd4a2"
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
  (craft-app "figcraft" "0.16.0" "f45b261687880e56d1bad11ec82b45131e57ef8b"
             "1n9i2bnx16479r37wyq7z33nn0km0cicb75kqc58v42lgwh2sm0l"
             #:cargo-inputs figcraft-cargo-inputs
             #:git-crates figcraft-git-crates
             ;; Despite its rust-version of 1.95, its path code uses
             ;; isolate_lowest_one, stable since Rust 1.97.
             #:rust rust-1.97
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
  (craft-app "deckcraft" "0.16.0" "a3e2254d3de32ed1718f156f070b54a34b949b54"
             "10jlix3q1a118b71lr82d72wfv06siiwzriicacfak547qhaihgz"
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
  (craft-app "texturecraft" "0.4.0" "16e9d21516434a63ac457f49ffd09005f649c02f"
             "0gzyiskdwdycl463xs089k79w431jply9f7jr4zjriisr8hx3kma"
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
  (craft-app "craft-anything" "0.5.0" "622d023cdfdb91c00df8b9a37c486a2a18fb0917"
             "0m4i8w8czj9ivxvqc0kvdxyk7l5qrqw1rgsswp149qqpwf65nap1"
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
  (craft-app "craft-launcher" "0.16.1" "2d577485fc2684cefd8742fdc735252def3a9daa"
             "0c8kn2hf7qxpwl7i3xvrbijvrgj54d4xf7gwqbz17fcckgs39sh9"
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
