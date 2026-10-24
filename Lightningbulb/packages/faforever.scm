;;; Lightningbulb channel --- FAForever client (Rust + Tauri rewrite)
;;;
;;; The client is built from source: the React front end with pnpm against an
;;; offline mirror of pnpm-lock.yaml (see js-offline.scm), the Rust/Tauri
;;; shell with cargo against the crates in Cargo.lock (rust-crates.scm).
;;;
;;; Its "natives" are a different matter.  Upstream's `pnpm tauri' downloads
;;; them, checksum-verified, at build time; we fetch the very same files with
;;; the very same SHA-256 digests (copied from scripts/ensure-*.mjs):
;;;
;;;   faf-uid          FAF's official machine-id helper.  It embeds a secret
;;;                    key, so a self-built copy is rejected by the lobby;
;;;                    the prebuilt binary is the only one that works.
;;;   faf-pioneer      Go ICE adapter (experimental, selectable in Settings).
;;;   faf-ice-adapter  Java ICE adapter (the default) + GodFuper's WebRTC
;;;                    build as the "experimental" choice.
;;;   libsteam_api.so  Valve Steamworks, for Steam "now playing" status; it
;;;                    lives in the client's own repository.
;;;
;;; Instead of upstream's bundled Temurin JRE, the adapters run on Guix's
;;; OpenJDK.  The game itself (Forged Alliance) still has to come from your
;;; own Steam/Wine setup and is configured inside the client: FAF copies the
;;; original game's libraries into its own install ($XDG_DATA_HOME/faforever
;;; here) and runs that ForgedAlliance.exe through Settings -> Game ->
;;; "Launch command".  Left empty, that is our faf-wine: Wine (new WoW64)
;;; with DXVK, in the prefix $XDG_DATA_HOME/faforever/wine ($FAF_WINEPREFIX).

(define-module (Lightningbulb packages faforever)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages java)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages node)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xorg)
  #:use-module ((Lightningbulb packages radmin-vpn)
                #:select (dxvk-3 wine64-wow64/prefix-update))
  #:use-module (Lightningbulb packages js-offline)
  #:use-module (Lightningbulb packages node-deps)
  #:use-module (Lightningbulb packages rust-crates))

(define (github-release-asset owner repo tag asset hash)
  (origin
    (method url-fetch)
    (uri (string-append "https://github.com/" owner "/" repo
                        "/releases/download/" tag "/" asset))
    (file-name asset)
    (sha256 (base32 hash))))

(define faf-uid-binary
  ;; scripts/ensure-faf-uid.mjs, v4.0.7
  (github-release-asset "FAForever" "uid" "v4.0.7" "faf-uid"
                        "1nk1mk6bj7rsga5dkzfpcfzr1rmsqkd3y13mscm6hqbyrphx0dhi"))

(define faf-pioneer-binary
  ;; scripts/ensure-faf-pioneer.mjs, 0.2.2
  (github-release-asset "FAForever" "faf-pioneer" "0.2.2"
                        "faf-pioneer-0.2.2-linux-amd64"
                        "0azm1zx76p9rl6vni9gscklzsdf2nmzkhklfagrq80cwq32mv7wl"))

(define faf-java-ice-adapter
  ;; scripts/ensure-java-ice-adapter.mjs, 3.3.14
  (github-release-asset "FAForever" "java-ice-adapter" "3.3.14"
                        "faf-ice-adapter-3.3.14-linux.jar"
                        "0mnn0x8zy10yhpc4dcq184704xc3mz7kk0zlxkdlska2d74c6mnp"))

(define faf-exp-java-ice-adapter
  ;; scripts/ensure-exp-java-ice-adapter.mjs, 4.0.1
  (github-release-asset "GodFuper" "java-ice-adapter" "4.0.1"
                        "faf-ice-adapter-4.0.1-linux.jar"
                        "0yzxnd053bhm4jxqn92dy4xil9gpn9fm1zby7w8gvjzkh5s8wm7d"))

(define-public faforever-client
  (let ((commit "f86737ac3d3d332a15e214b64bd63165ded1afb5")) ;tag v0.9.2
    (package
      (name "faforever-client")
      (version "0.9.2")
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/FAForeverRustClient/FAForeverRustClient")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1sa03ajh5q6v4yl6xsk6wqhdh4l363szbgkzhhnamynszr8mvavv"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:install-source? #f
        #:tests? #f                     ;several suites need network/display
        #:imported-modules `(,@%cargo-build-system-modules
                             ,@%glib-or-gtk-build-system-modules)
        #:modules '((guix build cargo-build-system)
                    ((guix build glib-or-gtk-build-system) #:prefix gtk:)
                    (guix build utils))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'build-frontend
              (lambda _
                (let ((top (getcwd)))
                  (setenv "HOME" (string-append top "/.home"))
                  (setenv "XDG_DATA_HOME" (string-append top "/.home/share"))
                  (setenv "XDG_CACHE_HOME" (string-append top "/.home/cache"))
                  (setenv "XDG_CONFIG_HOME" (string-append top "/.home/config"))
                  (mkdir-p ".pnpm")
                  (invoke "tar" "xf" #$faforever-client-pnpm-tarball "-C" ".pnpm")
                  ;; Upstream refuses packages younger than a day; checking
                  ;; that needs registry metadata we don't have (and the
                  ;; lockfile already pins everything by hash).
                  (substitute* ".npmrc"
                    (("^minimum-release-age=.*") ""))
                  (let ((port (open-file "pnpm-workspace.yaml" "a")))
                    (display "\nminimumReleaseAge: 0\n" port)
                    (close-port port))
                  (let ((registry #$(start-offline-npm-registry
                                     (offline-npm-registry
                                      "faforever-client"
                                      faforever-client-npm-tarballs))))
                    (invoke "node" ".pnpm/package/bin/pnpm.mjs" "install"
                            "--frozen-lockfile" "--ignore-scripts"
                            "--reporter=append-only"
                            (string-append "--registry="
                                           (getenv "npm_config_registry"))
                            (string-append "--store-dir=" top "/.pnpm-store"))
                    (kill registry SIGTERM))
                  ;; "pnpm build" minus its pnpm-only guard script -> ui/dist
                  (invoke "node" "node_modules/vite/bin/vite.js" "build"))))
            (add-after 'unpack 'find-nonguix-steam
              ;; Also auto-detect Forged Alliance under the sandbox home of
              ;; nonguix's `steam' package, next to the native and Flatpak
              ;; Steam folders upstream already checks.  That Steam runs in a
              ;; container whose $HOME is the sandbox home, so the library
              ;; paths it writes to libraryfolders.vdf are translated too.
              (lambda _
                (substitute* "crates/faf-app/src/infra/game_updater/install.rs"
                  (("^( *)roots\\.push\\(home\\.join\\(\"\\.var/app/com\\.valvesoftware\\.Steam/\\.local/share/Steam\"\\)\\);"
                    all indent)
                   (string-append
                    all "\n" indent
                    "roots.extend(guix_sandbox_home().map(|h| h.join(\".local/share/Steam\")));"))
                  (("^( *)\\.flat_map\\(\\|vdf\\| steam_library_paths\\(&vdf\\)\\)" all indent)
                   (string-append
                    all "\n" indent
                    ".flat_map(|library| {
            let inside = directories::BaseDirs::new().and_then(|dirs| {
                let rel = library.strip_prefix(dirs.home_dir()).ok()?;
                Some(guix_sandbox_home()?.join(rel))
            });
            std::iter::once(library).chain(inside)
        })"))
                  (("^fn steam_retail_install_paths_in\\(" all)
                   (string-append
                    "/// nonguix's containerised Steam: $GUIX_SANDBOX_HOME, by default
/// ~/.local/share/guix-sandbox-home, is its $HOME.
fn guix_sandbox_home() -> Option<PathBuf> {
    match std::env::var_os(\"GUIX_SANDBOX_HOME\").filter(|v| !v.is_empty()) {
        Some(dir) => Some(PathBuf::from(dir)),
        None => directories::BaseDirs::new()
            .map(|dirs| dirs.home_dir().join(\".local/share/guix-sandbox-home\")),
    }
}

" all)))))
            (add-after 'unpack 'xdg-data-home
              ;; FAF's own copy of the game (and replay install) goes to
              ;; $XDG_DATA_HOME/faforever instead of ~/.faforever.  An
              ;; existing ~/.faforever (the Java client's) is still found.
              (lambda _
                (substitute* "crates/faf-app/src/infra/game.rs"
                  (("directories::BaseDirs::new\\(\\)\\.map\\(\\|dirs\\| dirs\\.home_dir\\(\\)\\.join\\(\"\\.faforever\"\\)\\)")
                   "directories::BaseDirs::new().map(|dirs| dirs.data_dir().join(\"faforever\"))"))
                ;; The map/mod vault defaults to "Documents/My Games/...", but
                ;; without an XDG Documents directory that became the
                ;; relative "./My Games/..." -- i.e. ~/My Games when started
                ;; from the desktop.  Use $XDG_DATA_HOME/faforever/vault.
                (substitute* "crates/faf-app/src/infra/faf_content.rs"
                  (("vec!\\[vault\\(documents\\.unwrap_or\\(Path::new\\(\"\\.\"\\)\\)\\)\\]")
                   "vec![documents.map(|d| vault(d)).unwrap_or_else(|| {
        directories::BaseDirs::new()
            .map(|dirs| dirs.data_dir().join(\"faforever\").join(\"vault\"))
            .unwrap_or_else(|| PathBuf::from(\"faforever-vault\"))
    })]"))))
            (add-after 'unpack 'default-launch-command
              ;; Forged Alliance is a Windows program, and with Settings ->
              ;; Game -> "Launch command" empty the client exec()s the .exe
              ;; itself, which fails with EACCES -- shown as "The folder is
              ;; locked or read-only".  An empty setting now means
              ;; $FAF_DEFAULT_LAUNCH_WRAPPER, which the launcher points at
              ;; our faf-wine (below).  Set here, so the game's arguments
              ;; also get Wine (Z:\) paths, as for a typed launch command.
              (lambda _
                (substitute* "crates/faf-app/src/infra/game.rs"
                  (("^( *)config\\.launch_wrapper = wrapper;" _ indent)
                   (string-append
                    indent "config.launch_wrapper = if wrapper.trim().is_empty() {\n"
                    indent "    std::env::var(\"FAF_DEFAULT_LAUNCH_WRAPPER\").unwrap_or_default()\n"
                    indent "} else {\n"
                    indent "    wrapper\n"
                    indent "};")))))
            (add-after 'unpack 'steam-presence-command
              ;; Steam status: the client's helper calls SteamAPI_Init on the
              ;; host, where nonguix's containerized Steam can't be found.
              ;; With FAF_STEAM_PRESENCE_COMMAND set, that command is started
              ;; instead (with the same LIBRARY GAME_PID arguments): our
              ;; faf-steam-presence, which runs a helper inside the Steam
              ;; container.
              (lambda _
                (substitute* "crates/faf-app/src/infra/steam_presence.rs"
                  (("^( *)let mut command = tokio::process::Command::new\\(executable\\);"
                    _ indent)
                   (string-append
                    indent "let mut command = match std::env::var_os(\"FAF_STEAM_PRESENCE_COMMAND\")\n"
                    indent "    .filter(|command| !command.is_empty())\n"
                    indent "{\n"
                    indent "    Some(wrapper) => tokio::process::Command::new(wrapper),\n"
                    indent "    None => {\n"
                    indent "        let mut command = tokio::process::Command::new(executable);\n"
                    indent "        command.arg(HELPER_FLAG);\n"
                    indent "        command\n"
                    indent "    }\n"
                    indent "};"))
                  (("^ *\\.arg\\(HELPER_FLAG\\)") ""))))
            (add-after 'unpack 'disable-self-update
              ;; The client offers its own AppImage/.deb/.rpm as updates,
              ;; including a "required" update gate; none of that can replace
              ;; a store item.  Release notes ("What's new") still load.
              (lambda _
                (substitute* "crates/faf-app/src/infra/client_update.rs"
                  (("Ok\\(pick_release\\(&releases, channel\\)\\)")
                   "Ok(pick_release(&releases, channel).filter(|_| false))"))))
            (add-after 'unpack 'quit-argument
              ;; `faforever-client --quit' asks a running client to quit,
              ;; as the tray menu's Quit does (asking first during a game).
              ;; For the .desktop action: the tray icon only opens its menu
              ;; on right click, and a client hidden to the tray during a
              ;; game is otherwise hard to end.
              (lambda _
                (substitute* "src-tauri/src/lib.rs"
                  (("^( *)tray::restore_main_window\\(app\\);" all indent)
                   (string-append
                    indent "if argv.iter().any(|arg| arg == \"--quit\") {\n"
                    indent "    if crate::exit::on_close_request(app, crate::exit::Origin::Tray)\n"
                    indent "        == crate::exit::Decision::Exit\n"
                    indent "    {\n"
                    indent "        app.exit(0);\n"
                    indent "    }\n"
                    indent "    return;\n"
                    indent "}\n" all))
                  ;; ...and without a running client, does nothing.
                  (("^( *)\\.setup\\(\\|app\\| \\{" all indent)
                   (string-append
                    all "\n" indent
                    "    if std::env::args().any(|arg| arg == \"--quit\") {\n"
                    indent "        std::process::exit(0);\n"
                    indent "    }")))))
            (replace 'build
              (lambda _
                (invoke "cargo" "build" "--offline" "--release"
                        "--package" "faforever-rust-client"
                        "--features" "tauri/custom-protocol")))
            (replace 'install
              (lambda* (#:key inputs #:allow-other-keys)
                (define (cargo-output name)
                  ;; target/release/NAME, or target/<triplet>/release/NAME
                  ;; when the build system sets CARGO_BUILD_TARGET.
                  (let ((hits (filter (lambda (f)
                                        (string-suffix?
                                         (string-append "/release/" name) f))
                                      (find-files "target"
                                                  (string-append "^" name "$")))))
                    (if (null? hits)
                        (error "cannot find cargo output" name)
                        (car hits))))
                (let* ((libdir  (string-append #$output "/lib/faforever-client"))
                       (natives (string-append libdir "/natives"))
                       (bin     (string-append #$output "/bin"))
                       (real    (string-append libdir "/faforever-rust-client"))
                       (ld.so   (search-input-file inputs
                                                   "lib/ld-linux-x86-64.so.2"))
                       ;; gcc:lib is referenced here rather than listed as an
                       ;; input: an input labelled "gcc" would replace the
                       ;; compiler cargo-build-system exports as $CC.
                       (rpath   (string-append (ungexp gcc "lib") "/lib"
                                               ":" (dirname ld.so))))
                  (define (install-native source target)
                    (mkdir-p (dirname target))
                    (copy-file source target)
                    (chmod target #o755))
                  (define (patch-prebuilt file)
                    ;; Make the prebuilt ELF files usable on Guix: point the
                    ;; dynamic ones at Guix's loader and libraries.  Static
                    ;; ones have no interpreter and are left alone.
                    (when (false-if-exception
                           (invoke "patchelf" "--print-interpreter" file))
                      (invoke "patchelf" "--set-interpreter" ld.so file))
                    (when (false-if-exception
                           (invoke "patchelf" "--print-needed" file))
                      (invoke "patchelf" "--set-rpath" rpath file)))
                  ;; The client resolves its helpers relative to its own
                  ;; executable, so it lives next to natives/ in libdir.
                  (install-file (cargo-output "faforever-rust-client") libdir)
                  (install-native #$faf-uid-binary
                                  (string-append natives "/faf-uid"))
                  (install-native #$faf-pioneer-binary
                                  (string-append natives "/faf-pioneer"))
                  (install-native #$faf-java-ice-adapter
                                  (string-append natives
                                                 "/java-ice-adapter/faf-ice-adapter.jar"))
                  (install-native #$faf-exp-java-ice-adapter
                                  (string-append natives
                                                 "/exp-java-ice-adapter/faf-ice-adapter.jar"))
                  (install-native "vendor/steamworks/linux64/libsteam_api.so"
                                  (string-append natives "/steam/libsteam_api.so"))
                  (for-each patch-prebuilt
                            (map (lambda (f) (string-append natives f))
                                 '("/faf-uid" "/faf-pioneer"
                                   "/steam/libsteam_api.so")))
                  ;; Steam status inside nonguix's Steam container (see
                  ;; 'steam-presence-command): a helper built for the
                  ;; container's FHS glibc and an unpatched libsteam_api.so,
                  ;; kept under share/ where nothing rewrites them.
                  (let ((dir (string-append #$output
                                            "/share/faforever-client/steam-presence")))
                    (mkdir-p dir)
                    (invoke "gcc" "-O2" "-o"
                            (string-append dir "/faf-steam-presence-helper")
                            #$(local-file "aux-files/faf-steam-presence-helper.c"))
                    (invoke "patchelf" "--set-interpreter"
                            "/lib64/ld-linux-x86-64.so.2" "--remove-rpath"
                            (string-append dir "/faf-steam-presence-helper"))
                    (copy-file "vendor/steamworks/linux64/libsteam_api.so"
                               (string-append dir "/libsteam_api.so"))
                    (let ((script (string-append libdir "/faf-steam-presence")))
                      (copy-file #$(local-file "aux-files/faf-steam-presence.sh")
                                 script)
                      (chmod script #o755)
                      (substitute* script
                        (("@bash@") (search-input-file inputs "bin/bash"))
                        (("@helper@")
                         (string-append dir "/faf-steam-presence-helper"))
                        (("@library@") (string-append dir "/libsteam_api.so"))
                        (("@nsenter@") (search-input-file inputs "bin/nsenter"))
                        (("@pgrep@") (search-input-file inputs "bin/pgrep"))
                        (("@sed@") (search-input-file inputs "bin/sed"))
                        (("@(id|head|tr|mkdir|install|tail)@" _ program)
                         (search-input-file inputs
                                            (string-append "bin/" program))))))
                  ;; Launcher.  Every default can be overridden from the
                  ;; environment, as documented in upstream's README.  GTK
                  ;; names the window (Wayland app_id) after argv[0], so that
                  ;; is fixed to match the .desktop file and StartupWMClass.
                  (mkdir-p bin)
                  (call-with-output-file (string-append bin "/faforever-client")
                    (lambda (port)
                      (format port "#!~a
export FAF_JAVA_PATH=\"${FAF_JAVA_PATH:-~a}\"
export FAF_UID_PATH=\"${FAF_UID_PATH:-~a/faf-uid}\"
export FAF_ICE_ADAPTER_JAR=\"${FAF_ICE_ADAPTER_JAR:-~a/java-ice-adapter/faf-ice-adapter.jar}\"
export FAF_EXP_JAVA_ICE_ADAPTER_JAR=\"${FAF_EXP_JAVA_ICE_ADAPTER_JAR:-~a/exp-java-ice-adapter/faf-ice-adapter.jar}\"
export FAF_ICE_ADAPTER_PATH=\"${FAF_ICE_ADAPTER_PATH:-~a/faf-pioneer}\"
export FAF_STEAM_API_PATH=\"${FAF_STEAM_API_PATH:-~a/steam/libsteam_api.so}\"
export FAF_DEFAULT_LAUNCH_WRAPPER=\"${FAF_DEFAULT_LAUNCH_WRAPPER:-~a}\"
export FAF_STEAM_PRESENCE_COMMAND=\"${FAF_STEAM_PRESENCE_COMMAND:-~a}\"
# The client reads game.prefs from the same prefix the game runs in.  Its
# own variable, so that a WINEPREFIX set for other programs doesn't apply.
export WINEPREFIX=\"${FAF_WINEPREFIX:-${XDG_DATA_HOME:-$HOME/.local/share}/faforever/wine}\"
# Replays in the data directory, not ~/FAForever/replays.
export FAF_REPLAYS_DIR=\"${FAF_REPLAYS_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/faforever/replays}\"
exec -a faforever-client ~a \"$@\"~%"
                              (search-input-file inputs "bin/bash")
                              (search-input-file inputs "bin/java")
                              natives natives natives natives natives
                              (string-append libdir "/faf-wine")
                              (string-append libdir "/faf-steam-presence")
                              real)))
                  (chmod (string-append bin "/faforever-client") #o755)
                  ;; The default launch command: Wine, with DXVK's Direct3D 9
                  ;; (Vulkan) instead of wined3d.  The DLL goes next to the
                  ;; executable (the FAF-managed bin/ directory, not the
                  ;; prefix), where a native override finds it first.
                  ;; The game also hangs after loading its sound banks with
                  ;; Wine's builtin XACT, so -- as Steam does on first launch
                  ;; -- the DirectX redistributable shipped with the original
                  ;; game (fa_path in fa_path.lua) is installed into the
                  ;; prefix once, and its XACT engines are preferred.  Gecko
                  ;; and Mono are not packaged; don't offer them.  Wine's
                  ;; menu builder is off: it put entries for the prefix's
                  ;; file types in ~/.local/share/applications.
                  ;; In its own fullscreen window, the game switched the
                  ;; (Xwayland-emulated) display mode to its default
                  ;; 1024x768 and back, flickering, and could hang on the
                  ;; loading screen.  So it runs in a Wine virtual desktop
                  ;; ("FAF", set for ForgedAlliance.exe in AppDefaults) as
                  ;; big as the monitor, and that default resolution is
                  ;; replaced by the desktop's.  FAF_VIRTUAL_DESKTOP=off
                  ;; turns this off; WIDTHxHEIGHT picks another size.
                  (call-with-output-file (string-append libdir "/faf-wine")
                    (lambda (port)
                      (format port "#!~a
# Usage: faf-wine GAME.EXE [ARGUMENT...]
exe=\"$1\"
d3d9=~a/share/dxvk/lib32/d3d9.dll
mkdir -p \"$WINEPREFIX\"
wine=\"${FAF_WINE:-~a}\"
# DXVK's log, which it otherwise writes to the working directory (often
# $HOME) or next to the game.
dxvk_cache=\"${XDG_CACHE_HOME:-$HOME/.cache}/faforever/dxvk\"
mkdir -p \"$dxvk_cache\"
export DXVK_LOG_PATH=\"${DXVK_LOG_PATH:-$dxvk_cache}\"
if [ -f \"$exe\" ]; then
  ~a -m 644 \"$d3d9\" \"${exe%/*}/d3d9.dll\"
fi
# The game's own logo, for its window's entries (faforever-game-*.desktop).
icons=\"${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor\"
if [ -f \"$exe\" ] && [ ! -e \"$icons/256x256/apps/faforever-game.png\" ]; then
  tmp=$(mktemp -d)
  if ~a -x -t 14 -n IDI_WIN_FAICON -o \"$tmp\" \"$exe\" 2>/dev/null &&
     ~a -x -o \"$tmp\" \"$tmp\"/*.ico 2>/dev/null; then
    # NAME_N_WxHxDEPTH.png, by increasing depth: the deepest of a size stays.
    for depth in 4 8 32; do
      for png in \"$tmp\"/*x$depth.png; do
        [ -f \"$png\" ] || continue
        size=${png##*_}; size=${size%x*}
        mkdir -p \"$icons/$size/apps\"
        cp \"$png\" \"$icons/$size/apps/faforever-game.png\"
      done
    done
  fi
  rm -rf \"$tmp\"
fi
xact=xactengine2_0,xactengine2_1,xactengine2_2,xactengine2_3,xactengine2_4
xact=$xact,xactengine2_5,xactengine2_6,xactengine2_7,xactengine2_8
xact=$xact,xactengine2_9,xactengine2_10
export WINEDLLOVERRIDES=\"mscoree,mshtml=;winemenubuilder.exe=d;d3d9=n,b;$xact=n,b${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}\"
desktop=\"${FAF_VIRTUAL_DESKTOP:-auto}\"
if [ \"$desktop\" = auto ]; then
  desktop=
  while IFS= read -r line; do
    case $line in
      *' connected primary '[0-9]*x[0-9]*+*)
        desktop=${line#*' connected primary '}; desktop=${desktop%%+*}; break ;;
      *' connected '[0-9]*x[0-9]*+*)
        [ -n \"$desktop\" ] || { desktop=${line#*' connected '}; desktop=${desktop%%+*}; } ;;
    esac
  done <<EOF
$(~a --query 2>/dev/null)
EOF
  desktop=${desktop:-1920x1080}
fi
key='HKCU\\Software\\Wine\\AppDefaults\\ForgedAlliance.exe\\Explorer'
stamp=\"$WINEPREFIX/.faf-virtual-desktop\"
if [ \"$(cat \"$stamp\" 2>/dev/null)\" != \"$desktop\" ]; then
  case $desktop in
    off|no|0)
      \"$wine\" reg delete \"$key\" /v Desktop /f >/dev/null 2>&1 || true ;;
    *)
      \"$wine\" reg add \"$key\" /v Desktop /t REG_SZ /d FAF /f >/dev/null
      \"$wine\" reg add 'HKCU\\Software\\Wine\\Explorer\\Desktops' \\
        /v FAF /t REG_SZ /d \"$desktop\" /f >/dev/null
      \"$wine\" reg add 'HKCU\\Control Panel\\Colors' \\
        /v Background /t REG_SZ /d '0 0 0' /f >/dev/null ;;
  esac
  printf '%s\\n' \"$desktop\" > \"$stamp\"
fi
case $desktop in
  [1-9]*x[1-9]*)
    prefs=\"$WINEPREFIX/drive_c/users/$USER/AppData/Local/Gas Powered Games/Supreme Commander Forged Alliance/Game.prefs\"
    [ ! -f \"$prefs\" ] ||
      ~a -i \"s/primary_adapter = '1024,768,60'/primary_adapter = '${desktop%x*},${desktop#*x},60'/\" \"$prefs\" ;;
esac
stamp=\"$WINEPREFIX/.faf-directx-installed\"
if [ ! -e \"$stamp\" ] && [ -f \"${exe%/*}/../fa_path.lua\" ]; then
  while IFS= read -r line; do
    case $line in
      'fa_path = \"'*) retail=${line#'fa_path = \"'}; retail=${retail%\\\"*} ;;
    esac
  done < \"${exe%/*}/../fa_path.lua\"
  if [ -f \"$retail/DirectX/DXSETUP.exe\" ]; then
    \"$wine\" \"$retail/DirectX/DXSETUP.exe\" /silent && : > \"$stamp\"
  fi
fi
exec \"$wine\" \"$@\"~%"
                              (search-input-file inputs "bin/bash")
                              #$(this-package-input "dxvk")
                              (search-input-file inputs "bin/wine")
                              (search-input-file inputs "bin/install")
                              (search-input-file inputs "bin/wrestool")
                              (search-input-file inputs "bin/icotool")
                              (search-input-file inputs "bin/xrandr")
                              (search-input-file inputs "bin/sed"))))
                  (chmod (string-append libdir "/faf-wine") #o755)
                  ;; Desktop integration (incl. the replay file types the
                  ;; Tauri bundle would register).
                  (for-each
                   (lambda (pair)
                     (let ((dir (string-append #$output "/share/icons/hicolor/"
                                               (cdr pair) "/apps")))
                       (mkdir-p dir)
                       (copy-file (string-append "src-tauri/icons/" (car pair))
                                  (string-append dir "/faforever-client.png"))))
                   '(("32x32.png" . "32x32")
                     ("64x64.png" . "64x64")
                     ("128x128.png" . "128x128")
                     ("128x128@2x.png" . "256x256")
                     ("icon.png" . "512x512")))
                  (let ((apps (string-append #$output "/share/applications"))
                        (mime (string-append #$output "/share/mime/packages")))
                    (mkdir-p apps)
                    (mkdir-p mime)
                    (call-with-output-file (string-append apps "/faforever-client.desktop")
                      (lambda (port)
                        (format port "[Desktop Entry]
Type=Application
Name=FAForever Client
Comment=Forged Alliance Forever client
Exec=~a/faforever-client %f
Icon=faforever-client
Terminal=false
Categories=Game;StrategyGame;
MimeType=application/x-fafreplay;application/x-scfareplay;
StartupWMClass=faforever-client
Actions=quit;

[Desktop Action quit]
Name=Quit
Exec=~a/faforever-client --quit
" bin bin)))
                    ;; The game's window, for docks: its virtual desktop
                    ;; ("faf", see faf-wine) or, without one, the game's own.
                    ;; faf-wine takes the icon from the game.
                    (for-each
                     (lambda (class)
                       (call-with-output-file
                           (string-append apps "/faforever-game-" class ".desktop")
                         (lambda (port)
                           (format port "[Desktop Entry]
Type=Application
Name=Supreme Commander: Forged Alliance
Comment=The game, started from the FAForever client
Exec=~a/faforever-client
Icon=faforever-game
Terminal=false
NoDisplay=true
StartupWMClass=~a
" bin class))))
                     '("faf" "forgedalliance.exe"))
                    (call-with-output-file (string-append mime "/faforever-client.xml")
                      (lambda (port)
                        (display "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mime-info xmlns=\"http://www.freedesktop.org/standards/shared-mime-info\">
  <mime-type type=\"application/x-fafreplay\">
    <comment>Forged Alliance Forever replay</comment>
    <glob pattern=\"*.fafreplay\"/>
  </mime-type>
  <mime-type type=\"application/x-scfareplay\">
    <comment>Supreme Commander replay</comment>
    <glob pattern=\"*.scfareplay\"/>
  </mime-type>
</mime-info>
" port)))))))
            ;; Prebuilt natives: leave them as upstream shipped them.
            (delete 'strip)
            (add-after 'install 'glib-or-gtk-wrap
              (assoc-ref gtk:%standard-phases 'glib-or-gtk-wrap))
            (add-after 'glib-or-gtk-wrap 'wrap-program
              (lambda* (#:key inputs #:allow-other-keys)
                (wrap-program (string-append #$output "/bin/faforever-client")
                  ;; The tray icon dlopen()s libappindicator3.
                  `("LD_LIBRARY_PATH" suffix
                    (,#$(file-append (this-package-input "libappindicator")
                                     "/lib")))
                  ;; "Open in browser" etc. go through xdg-open.
                  `("PATH" suffix
                    (,(dirname (search-input-file inputs "bin/xdg-open"))))))))))
      (native-inputs (list node patchelf pkg-config))
      (inputs
       (append
        (list bash-minimal
              coreutils
              dbus                    ;libdbus-sys
              dxvk-3
              glib-networking
              icoutils
              gsettings-desktop-schemas
              gtk+
              libappindicator
              librsvg
              openjdk
              openssl
              procps                  ;pgrep, for faf-steam-presence
              webkitgtk-for-gtk3
              sed
              util-linux              ;nsenter, for faf-steam-presence
              wine64-wow64/prefix-update
              xdg-utils
              xrandr
              ;; Guix makes zstd-sys link the system libzstd.
              `(,zstd "lib"))
        faforever-client-cargo-inputs))
      (supported-systems '("x86_64-linux"))
      (home-page "https://github.com/FAForeverRustClient/FAForeverRustClient")
      (synopsis "Client for Forged Alliance Forever, written in Rust and Tauri")
      (description
       "This is a modular client for FAForever, the community-run online
platform for Supreme Commander: Forged Alliance.  It covers logging in
(OAuth), custom games and matchmaking (parties, map pool vetoes, co-op,
Galactic War), lobby chat, the map/mod/replay vault with live spectating and
the Neroxis map generator, tournaments, leaderboards and clans.  It needs a
separately installed copy of Forged Alliance (e.g. Steam with Proton/Wine) to
actually play.")
      (license license:expat))))
