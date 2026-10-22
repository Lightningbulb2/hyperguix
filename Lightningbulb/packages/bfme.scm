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
  #:use-module (gnu packages wine)
  #:use-module ((nongnu packages wine) #:select (dxvk-next)))

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
                  (mkdir-p bin)
                  (call-with-output-file script
                    (lambda (port)
                      (format port "#!~a
# BFME All In One Launcher under Wine, in its own prefix.
#   BFME_WINEPREFIX  prefix to use (default: $XDG_DATA_HOME/bfme-aio-launcher/prefix)
#   BFME_WINE        wine executable (default: Guix's wine64)
#   BFME_DXVK=1      use DXVK (Direct3D 9-11 over Vulkan) instead of WineD3D
set -e
data=\"${XDG_DATA_HOME:-$HOME/.local/share}/bfme-aio-launcher\"
export WINEPREFIX=\"${BFME_WINEPREFIX:-$data/prefix}\"
wine=\"${BFME_WINE:-~a}\"
dxvk=\"~a\"
# Don't let Wine put menu entries/icons for the launcher's shortcuts into
# ~/.local/share/applications; this package provides its own entry.
overrides=\"winemenubuilder.exe=d\"

notify() {
  zenity --notification --text=\"$1\" 2>/dev/null || echo \"$1\" >&2
}

if [ ! -f \"$WINEPREFIX/system.reg\" ]; then
  notify \"Setting up the Wine prefix for the BFME All In One Launcher...\"
  mkdir -p \"$WINEPREFIX\"
  WINEDLLOVERRIDES=\"$overrides\" \"$wine\" wineboot -i
  # Keep the prefix self-contained: Wine links Desktop, Documents etc. to
  # the folders in $HOME, and the launcher drops a shortcut on the desktop.
  for dir in \"$WINEPREFIX\"/drive_c/users/*/; do
    for f in Desktop Documents Downloads Music Pictures Videos Templates; do
      if [ -L \"$dir$f\" ]; then
        rm -f -- \"${dir:?}$f\"
        mkdir -p -- \"$dir$f\"
      fi
    done
  done
  # WPF's Direct3D path is the least reliable part of WPF under Wine.
  WINEDLLOVERRIDES=\"$overrides\" \"$wine\" reg add \\
    'HKCU\\Software\\Microsoft\\Avalon.Graphics' \\
    /v DisableHWAcceleration /t REG_DWORD /d 1 /f >/dev/null
fi

if [ \"${BFME_DXVK:-0}\" = 1 ]; then
  sys=\"$WINEPREFIX/drive_c/windows\"
  for dll in d3d9 d3d10core d3d11 dxgi; do
    cp -f \"$dxvk/share/dxvk/lib/$dll.dll\" \"$sys/system32/$dll.dll\"
    cp -f \"$dxvk/share/dxvk/lib32/$dll.dll\" \"$sys/syswow64/$dll.dll\"
  done
  overrides=\"$overrides;d3d9,d3d10core,d3d11,dxgi=n,b\"
fi
export WINEDLLOVERRIDES=\"$overrides${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}\"

appdata=$(\"$wine\" cmd /c 'echo %APPDATA%' 2>/dev/null | tr -d '\\r')
appdir=\"$(\"$wine\" winepath -u \"$appdata\" 2>/dev/null)/BFME All In One Launcher\"
exe=\"$appdir/AllInOneLauncher.exe\"

# First start: what upstream's installer does.  Later updates are done by
# the launcher itself.
if [ ! -f \"$exe\" ]; then
  mkdir -p \"$appdir\"
  hash=$(curl -fsSL 'https://bfmeladder.com/api/applications/versionHash?name=all-in-one-launcher&version=main')
  notify \"Downloading the BFME All In One Launcher (about 280 MB)...\"
  curl -fL --retry 3 -o \"$exe.part\" \\
    'https://arena-files.bfmeladder.com/application-builds/all-in-one-launcher-main'
  if [ \"$(md5sum \"$exe.part\" | cut -d' ' -f1)\" != \"$hash\" ]; then
    rm -f \"$exe.part\"
    notify \"BFME All In One Launcher: download corrupted, try again.\"
    exit 1
  fi
  mv \"$exe.part\" \"$exe\"
fi

cd \"$appdir\"
exec \"$wine\" \"$exe\" \"$@\"~%"
                              (search-input-file inputs "bin/bash")
                              (search-input-file inputs "bin/wine")
                              #$(this-package-input "dxvk"))))
                  (chmod script #o755)
                  (wrap-program script
                    `("PATH" prefix
                      ,(map (lambda (cmd)
                              (dirname (search-input-file
                                        inputs (string-append "bin/" cmd))))
                            '("wine" "curl" "md5sum" "zenity"))))
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
                  (mkdir-p apps)
                  (call-with-output-file
                      (string-append apps "/bfme-aio-launcher.desktop")
                    (lambda (port)
                      (format port "[Desktop Entry]
Type=Application
Name=BFME All In One Launcher
Comment=Install, patch and play The Battle for Middle-earth games (Wine)
Exec=~a
Icon=bfme-aio-launcher
Terminal=false
Categories=Game;
# Wine names windows after the lowercased .exe (X11 WM_CLASS and Wayland
# app_id).
StartupWMClass=allinonelauncher.exe
" script)))))))))
      (native-inputs (list icoutils))
      (inputs (list bash-minimal coreutils curl dxvk-next wine64 zenity))
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
@env{BFME_DXVK} to 1 to use DXVK for the games.")
      ;; The launcher has no license, and the build it downloads is
      ;; proprietary.
      (license (license:nonfree
                "https://github.com/MarcellVokk/BfmeFoundationProject#license")))))
