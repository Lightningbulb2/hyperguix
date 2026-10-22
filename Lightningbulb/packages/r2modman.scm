;;; Lightningbulb channel --- r2modman
;;;
;;; r2modman (r2modmanPlus) is a Quasar/Vue + Electron application.  The web
;;; front end and Electron main process are built from source with pnpm
;;; against an offline mirror of upstream's pnpm-lock.yaml (see
;;; js-offline.scm and r2modman-deps.scm); the result runs on nonguix's
;;; prebuilt `electron' of the major version upstream pins, instead of the
;;; Electron copy electron-builder would bundle.
;;;
;;; Guix-specific changes:
;;;  - Steam detection also looks in the sandbox home of nonguix's `steam'
;;;    container (~/.local/share/guix-sandbox-home), maps the library paths
;;;    Steam records inside the container back to the host, and launches
;;;    games through the `steam' wrapper on PATH, because steam.sh only runs
;;;    inside that FHS container.
;;;  - The `r2modman' wrapper adds r2modman's data folder to
;;;    GUIX_SANDBOX_EXTRA_SHARES so a Steam container started from r2modman
;;;    can see the mod profiles (BepInEx & co. load from there).
;;;  - The self-updater is disabled.

(define-module (Lightningbulb packages r2modman)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages node)
  #:use-module (nongnu packages electron)
  #:use-module (Lightningbulb packages js-offline)
  #:use-module (Lightningbulb packages r2modman-deps))

(define-public r2modman
  ;; The v3.2.20 tag points at the commit *before* "Release 3.2.20", whose
  ;; package.json still says 3.2.19; the release binaries were built from
  ;; the release commit, so use that.
  (let ((commit "4be4fec0b0cff2fe5d302c879a04e4d5c7c1415a"))
    (package
      (name "r2modman")
      (version "3.2.20")
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ebkr/r2modmanPlus")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0alydfd9ig24qdwmqx8i6z7m1sh1r6x5vlpgx6q1kvmj0hirg8dv"))))
      (build-system gnu-build-system)
      (arguments
       (list
        #:tests? #f                     ;vitest suite needs a display
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'find-nonguix-steam
              (lambda _
                (substitute* "src/r2mm/manager/linux/GameDirectoryResolver.ts"
                  ;; Look for Steam in the container's home too.
                  (("^( *)(path\\.resolve\\(os\\.homedir\\(\\), '\\.var', 'app', 'com\\.valvesoftware\\.Steam', '\\.steam'\\))"
                    _ indent last)
                   (string-append
                    indent last ",\n"
                    indent "path.resolve(os.homedir(), '.local', 'share', "
                    "'guix-sandbox-home', '.local', 'share', 'Steam'),\n"
                    indent "path.resolve(os.homedir(), '.local', 'share', "
                    "'guix-sandbox-home', '.steam', 'steam')"))
                  ;; libraryfolders.vdf records paths as seen inside the
                  ;; container, whose $HOME is the sandbox home.
                  (("^const FORCE_PROTON_FILENAME = .*" all)
                   (string-append all "
// Guix: nonguix's `steam' runs in a container whose $HOME is
// ~/.local/share/guix-sandbox-home, so the library folders it records under
// $HOME live under the sandbox home on the host.  Try both.
function guixSandboxLibrary(steamapps: string, library: string): string[] {
    const home = os.homedir();
    const sandbox = path.join(home, '.local', 'share', 'guix-sandbox-home');
    if (steamapps.startsWith(sandbox + '/') && library.startsWith(home + '/')
        && !library.startsWith(sandbox + '/')) {
        return [library, path.join(sandbox, library.slice(home.length))];
    }
    return [library];
}
"))
                  (("path\\.join\\(parsedVdf\\.(libraryfolders\\[key\\]\\.path|LibraryFolders\\[key\\]), 'steamapps'\\)"
                    all)
                   (string-append "...guixSandboxLibrary(steamapps, "
                                  all ")")))
                ;; steam.sh needs the FHS container; its wrapper hands
                ;; -applaunch to a running Steam (or starts one).
                (substitute*
                    "src/r2mm/launching/runners/linux/SteamGameRunner_Linux.ts"
                  (("const steamExecutable = `\\$\\{steamDir\\}/steam\\.sh`;")
                   "const steamExecutable = steamDir.includes('/guix-sandbox-home/')
            ? 'steam' : `${steamDir}/steam.sh`;"))))
            (add-after 'unpack 'disable-self-update
              (lambda _
                (substitute* "src-electron/ipcListeners.ts"
                  (("if \\(process\\.env\\.FLATPAK_ID\\) return;")
                   "return;    // updated through Guix"))))
            (delete 'configure)
            (replace 'build
              (lambda _
                (let ((top (getcwd))
                      (pnpm (string-append (getcwd)
                                           "/.pnpm/package/bin/pnpm.mjs")))
                  (setenv "HOME" (string-append top "/.home"))
                  (setenv "XDG_DATA_HOME" (string-append top "/.home/share"))
                  (setenv "XDG_CACHE_HOME" (string-append top "/.home/cache"))
                  (setenv "XDG_CONFIG_HOME" (string-append top "/.home/config"))
                  (mkdir-p ".pnpm")
                  (invoke "tar" "xf" #$r2modman-pnpm-tarball "-C" ".pnpm")
                  ;; Upstream refuses packages younger than a week; checking
                  ;; that needs registry metadata we don't have (and the
                  ;; lockfile already pins everything by hash).
                  (substitute* ".npmrc"
                    (("^minimum-release-age=.*") ""))
                  (let ((port (open-file "pnpm-workspace.yaml" "a")))
                    (display "\nminimumReleaseAge: 0\n" port)
                    (close-port port))
                  ;; The production dependencies the Electron main process
                  ;; loads at run time, installed from the same lockfile
                  ;; (Quasar would run a non-frozen install here).
                  (mkdir "prod")
                  (for-each (lambda (file)
                              (copy-file file (string-append "prod/" file)))
                            '("package.json" "pnpm-lock.yaml"
                              "pnpm-workspace.yaml" ".npmrc"))
                  (let ((registry #$(start-offline-npm-registry
                                     (offline-npm-registry
                                      "r2modman" r2modman-npm-tarballs))))
                    (define (pnpm-install . args)
                      (apply invoke "node" pnpm "install"
                             "--frozen-lockfile" "--ignore-scripts"
                             "--reporter=append-only"
                             (string-append "--registry="
                                            (getenv "npm_config_registry"))
                             (string-append "--store-dir=" top "/.pnpm-store")
                             args))
                    (pnpm-install)
                    (with-directory-excursion "prod"
                      (pnpm-install "--prod" "--config.node-linker=hoisted"))
                    (kill registry SIGTERM))
                  ;; sass-embedded runs a prebuilt Dart executable; without
                  ;; it Vite falls back to the pure-JavaScript `sass'.
                  (for-each (lambda (dir)
                              ;; Nested matches may already be gone.
                              (when (file-exists? dir)
                                (delete-file-recursively dir)))
                            (find-files "node_modules" "^sass-embedded"
                                        #:directories? #t))
                  ;; Build the UI, main process and preload script into
                  ;; dist/electron/UnPackaged, skipping electron-builder.
                  (invoke "node" "node_modules/@quasar/app-vite/bin/quasar.js"
                          "build" "-m" "electron" "--skip-pkg"))))
            (replace 'install
              (lambda _
                (let* ((lib (string-append #$output "/lib/r2modman"))
                       (bin (string-append #$output "/bin"))
                       (share (string-append #$output "/share"))
                       (apps (string-append share "/applications")))
                  (copy-recursively "dist/electron/UnPackaged" lib)
                  ;; macOS-only helpers (macos_proxy is a 65 MB binary).
                  (for-each (lambda (file)
                              (delete-file (string-append lib "/" file)))
                            '("macos_proxy" "macos_wrapper.sh" ".npmrc"))
                  (copy-recursively "prod/node_modules"
                                    (string-append lib "/node_modules"))
                  (with-directory-excursion (string-append lib "/node_modules")
                    ;; Fonts for the web UI; Quasar drops this dependency
                    ;; from the packaged app because Vite already bundled it.
                    (delete-file-recursively "@quasar/extras")
                    (delete-file-recursively ".bin")
                    (for-each delete-file
                              (find-files "." "^\\.(modules\\.yaml|pnpm-workspace-state.*)$")))
                  (mkdir-p bin)
                  (call-with-output-file (string-append bin "/r2modman")
                    (lambda (port)
                      (format port "#!~a
# nonguix's Steam container only sees its sandbox home plus the paths in
# GUIX_SANDBOX_EXTRA_SHARES.  Share r2modman's data folder (mod profiles) so
# games launched from here can load their mods.  This only affects a Steam
# started by r2modman; see the package description.
data=\"${XDG_CONFIG_HOME:-$HOME/.config}/r2modmanPlus-local\"
mkdir -p \"$data\"
case \":$GUIX_SANDBOX_EXTRA_SHARES:\" in
  *\":$data:\"*) ;;
  *) export GUIX_SANDBOX_EXTRA_SHARES=\"${GUIX_SANDBOX_EXTRA_SHARES:+$GUIX_SANDBOX_EXTRA_SHARES:}$data\" ;;
esac
# Set in e.g. VS Code's terminals; it would run the app as plain Node.js.
unset ELECTRON_RUN_AS_NODE
# Electron takes the Wayland app_id from this; it may be inherited from
# another Chromium/Electron app, so always match r2modman.desktop.
export CHROME_DESKTOP=r2modman.desktop
exec ~a ~a \"$@\"~%"
                              #$(file-append bash-minimal "/bin/sh")
                              #$(file-append (this-package-input "electron")
                                             "/bin/electron")
                              lib)))
                  (chmod (string-append bin "/r2modman") #o755)
                  (for-each
                   (lambda (size)
                     (let ((dir (string-append share "/icons/hicolor/"
                                               size "x" size "/apps")))
                       (mkdir-p dir)
                       (copy-file (string-append "src/assets/icon/"
                                                 size "x" size ".png")
                                  (string-append dir "/r2modman.png"))))
                   '("16" "24" "32" "48" "64" "96" "128" "192" "256"))
                  ;; Electron derives the X11 WM_CLASS from package.json's name,
                  ;; "r2modman", and the Wayland app_id from $CHROME_DESKTOP.
                  (mkdir-p apps)
                  (call-with-output-file (string-append apps "/r2modman.desktop")
                    (lambda (port)
                      (format port "[Desktop Entry]
Type=Application
Name=r2modman
Comment=Mod manager for Thunderstore games
Exec=~a/r2modman %U
Icon=r2modman
Terminal=false
Categories=Game;
MimeType=x-scheme-handler/ror2mm;
StartupWMClass=r2modman
" bin))))))
            ;; Don't point the scripts r2modman copies into the Steam
            ;; container (linux_wrapper.sh etc.) or node_modules' bin
            ;; scripts at store files; there is nothing else to patch.
            (delete 'patch-shebangs))))
      (native-inputs (list node))
      (inputs (list bash-minimal electron-38))
      (supported-systems '("x86_64-linux"))
      (home-page "https://github.com/ebkr/r2modmanPlus")
      (synopsis "Mod manager for Thunderstore games")
      (description
       "r2modman is a mod manager for games whose mods are published on
Thunderstore, such as Risk of Rain 2, Lethal Company or Valheim.  It manages
several mod profiles per game, installs mod loaders such as BepInEx, resolves
dependencies, and launches the game through Steam.

This package finds games in the Steam library of nonguix's @code{steam}
package.  Mods only load if that Steam container can see r2modman's data
folder: the @command{r2modman} command adds it to
@env{GUIX_SANDBOX_EXTRA_SHARES}, which takes effect when Steam is started by
r2modman, so quit Steam before launching a modded game, or set that variable
for the whole session.")
      ;; The Electron runtime it runs on is non-free (see `electron-38').
      (license license:expat))))
