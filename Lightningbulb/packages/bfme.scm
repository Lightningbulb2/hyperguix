;;; Lightningbulb channel --- BFME All In One Launcher
;;;
;;; The Bfme Foundation Project's "All In One Launcher" installs, patches and
;;; starts The Battle for Middle-earth I/II and Rise of the Witch-king, and
;;; hosts their online play (Arena) and the mod Workshop.  It is a Windows
;;; WPF (.NET 8) application, so it runs under Wine.
;;;
;;; Why the launcher itself is not built here:
;;;  - Upstream installs and updates it at run time: whichever copy you start
;;;    downloads the current build into %APPDATA%\BFME All In One Launcher,
;;;    compares its MD5 with bfmeladder.com on every start and replaces
;;;    itself when they differ.  A store copy (built from source or fetched
;;;    by Guix) would be overwritten by that mechanism on first start, and
;;;    the download URL is unversioned, so a pinned hash breaks with every
;;;    upstream build.
;;;  - The GitHub sources (last change Dec 2025) lag the published builds
;;;    (rebuilt Oct 2026), which talk to live online services.
;;;  - The repository has no license, so it is not free software anyway.
;;;
;;; This package therefore provides what upstream's installer does on
;;; Windows -- download the current build (checked against upstream's MD5)
;;; into its own Wine prefix under $XDG_DATA_HOME -- plus a menu entry and
;;; icon taken from the (pinned) sources.  The games the launcher installs
;;; live in the same prefix.

(define-module (Lightningbulb packages bfme)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages xorg)
  #:use-module ((Lightningbulb packages radmin-vpn)
                #:select (dxvk-3 wine64-wow64/prefix-update))
  #:use-module ((nongnu packages fonts)
                #:select (font-microsoft-arial font-microsoft-courier-new
                          font-microsoft-times-new-roman)))

(define-public bfme-aio-launcher
  (let ((commit "1c8d53935505b6ccecf08a7f25e47b86b7bf5a3c")
        (revision "0"))
    (package
      (name "bfme-aio-launcher")
      ;; Upstream has no versions; this is the version of this wrapper.
      (version (git-version "0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/MarcellVokk/BfmeFoundationProject")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0yphzvc2n9mwc9nz4dfwdpbq9vmnjjan63qliwv5h8qnvn3mwz5n"))))
      (build-system copy-build-system)
      (arguments
       (list
        #:install-plan ''()
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'install 'install-launcher
              (lambda* (#:key inputs #:allow-other-keys)
                (let* ((bin (string-append #$output "/bin"))
                       (script (string-append bin "/bfme-aio-launcher"))
                       (apps (string-append #$output "/share/applications"))
                       (icons (string-append #$output "/share/icons/hicolor")))
                  ;; The script: aux-files/bfme-aio-launcher.sh.
                  (mkdir-p bin)
                  (copy-file #$(local-file "aux-files/bfme-aio-launcher.sh")
                             script)
                  (substitute* script
                    (("@bash@") (search-input-file inputs "bin/bash"))
                    (("@wine@") (search-input-file inputs "bin/wine"))
                    (("@dxvk@") #$(this-package-input "dxvk"))
                    (("@fonts@")
                     (string-join
                      (map (lambda (font)
                             (string-append font "/share/fonts/truetype"))
                           (list #$(this-package-input "font-microsoft-arial")
                                 #$(this-package-input
                                    "font-microsoft-courier-new")
                                 #$(this-package-input
                                    "font-microsoft-times-new-roman"))))))
                  (chmod script #o755)
                  (wrap-program script
                    `("PATH" prefix
                      ,(map (lambda (cmd)
                              (dirname (search-input-file
                                        inputs (string-append "bin/" cmd))))
                            '("wine" "curl" "md5sum" "sed" "zenity"
                              "wrestool" "xrandr"))))
                  ;; Icon: upstream's .ico, split into hicolor PNGs.
                  (invoke "icotool" "-x" "-o" "."
                          "src/BfmeFoundationProject_AllInOneLauncher/allinonelaunchericon.ico")
                  (for-each
                   (lambda (png)
                     ;; allinonelaunchericon_N_WxHxD.png
                     (let* ((size (car (string-split
                                        (caddr (string-split
                                                (basename png ".png") #\_))
                                        #\x)))
                            (dir (string-append icons "/" size "x" size "/apps")))
                       (mkdir-p dir)
                       (copy-file png (string-append dir "/bfme-aio-launcher.png"))))
                   (find-files "." "^allinonelaunchericon_.*\\.png$"))
                  ;; Menu entry, and entries that only name windows: docks
                  ;; match windows to entries by StartupWMClass, which has
                  ;; to be what Wine sets as the X11 WM_CLASS and Wayland
                  ;; app_id, the lowercased .exe file name.  Without one,
                  ;; COSMIC names a window after the last dot-separated part
                  ;; of that ("EXE"), with no icon.  The games run in a
                  ;; virtual desktop by default, whose window wine64-wow64
                  ;; names after the desktop, "bfme"; the game icons are
                  ;; taken from the games by the script.  The Quit actions (in the dock's menu)
                  ;; end the games, or everything, which a fullscreen game
                  ;; may not do on a close request.
                  (mkdir-p apps)
                  (for-each
                   (lambda (entry)
                     (call-with-output-file
                         (string-append apps "/" (car entry) ".desktop")
                       (lambda (port)
                         (format port "[Desktop Entry]
Type=Application
Name=~a
Comment=~a
Exec=~a
Icon=~a
Terminal=false
~aStartupWMClass=~a
Actions=quit;

[Desktop Action quit]
Name=~a
Exec=~a ~a
"
                                 (list-ref entry 1) (list-ref entry 2) script
                                 (list-ref entry 3) (list-ref entry 4)
                                 (list-ref entry 5) (list-ref entry 6) script
                                 (list-ref entry 7)))))
                   ;; file, name, comment, icon, other keys, window class,
                   ;; quit action name and option
                   `(("bfme-aio-launcher" "BFME All In One Launcher"
                      "Install, patch and play The Battle for Middle-earth games (Wine)"
                      "bfme-aio-launcher" "Categories=Game;\n"
                      "allinonelauncher.exe"
                      "Quit the launcher and the games" "--stop")
                     ("bfme-desktop" "The Battle for Middle-earth"
                      "The games' virtual desktop"
                      "bfme-desktop" "NoDisplay=true\n" "bfme"
                      "Quit the game" "--stop-game")
                     ("bfme-rotwk"
                      "The Lord of the Rings: The Rise of the Witch-king"
                      "The game's window, without a virtual desktop"
                      "bfme-rotwk" "NoDisplay=true\n" "lotrbfme2ep1.exe"
                      "Quit the game" "--stop-game")
                     ("bfme-game" "The Battle for Middle-earth"
                      "The game's window (I and II), without a virtual desktop"
                      "bfme-game" "NoDisplay=true\n" "game.dat"
                      "Quit the game" "--stop-game")))))))))
      (native-inputs (list icoutils))
      (inputs (list bash-minimal coreutils curl dxvk-3 font-microsoft-arial
                    font-microsoft-courier-new font-microsoft-times-new-roman
                    icoutils sed wine64-wow64/prefix-update xrandr zenity))
      (supported-systems '("x86_64-linux"))
      (home-page "https://bfmeladder.com/")
      (synopsis "Run the BFME All In One Launcher under Wine")
      (description
       "The All In One Launcher of the Bfme Foundation Project installs,
patches and starts The Battle for Middle-earth, The Battle for Middle-earth II
and The Rise of the Witch-king, with online play through Arena and mods from
the BFME Workshop.  This package runs it under Wine in a prefix of its own,
@file{$XDG_DATA_HOME/bfme-aio-launcher/prefix}, where the games it installs
also live.  On first start it downloads the launcher from bfmeladder.com, as
upstream's installer does; the launcher then keeps itself up to date.  Set
@env{BFME_DXVK} to 1 to use DXVK for the games.  The games run in a Wine
virtual desktop the size of the primary monitor, which keeps the mouse right
on multi-monitor setups under Xwayland; set @env{BFME_VIRTUAL_DESKTOP} to
@code{off}, or to a size such as @code{1600x900}, to change that.
@command{bfme-aio-launcher --stop-game} ends the games, @command{--stop} the
launcher too.")
      ;; The launcher has no license, and the build it downloads is
      ;; proprietary.
      (license (license:nonfree
                "https://github.com/MarcellVokk/BfmeFoundationProject#license")))))
