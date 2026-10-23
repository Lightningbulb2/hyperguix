;;; Lightningbulb channel --- radmin-vpn-linux
;;;
;;; Runs the (proprietary, user-downloaded) Windows Radmin VPN client under
;;; Wine, replacing its NDIS driver with a shim that bridges to a Linux TAP
;;; device.  This package builds the shim pieces from source:
;;;
;;;   native:  tap_bridge, rvpn_dnsfix.so, rvpn_reuseport.so, rvpn_filter_ui
;;;   win64:   rvpnnetmp.sys (kernel driver for Wine), netsh64.exe
;;;   win32:   adapter_hook.dll, rvpn_launcher.exe, netsh.exe, drvinst.exe
;;;
;;; and installs upstream's launcher scripts with a `radmin-vpn' entry point
;;; modelled on their AppImage's AppRun.  Radmin VPN itself is NOT packaged:
;;; it is downloaded by run.sh on first start (or pass --installer FILE).

(define-module (Lightningbulb packages radmin-vpn)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages cross-base)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mingw)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages wine)
  #:use-module ((nongnu packages fonts) #:select (font-microsoft-arial))
  #:export (wine64-wow64 wine64-wow64/prefix-update))

(define %mingw32 "i686-w64-mingw32")
(define %mingw64 "x86_64-w64-mingw32")

(define (mingw-toolchain triplet)
  (list (cross-gcc triplet
                   #:xbinutils (cross-binutils triplet)
                   #:libc (cross-libc triplet))
        (cross-binutils triplet)))

(define wine64-wow64
  ;; Guix's wine64 is built without a PE cross compiler, so every builtin
  ;; DLL is an ELF ".dll.so" that the Unix loader maps at a different
  ;; address in each process, and it runs 32-bit programs in a separate
  ;; 32-bit Wine ("old WoW64").  Windows programs (and upstream's injector)
  ;; that assume kernel32 is mapped at the same address in every process,
  ;; or that unwind exceptions through system DLLs, break on that.  This is
  ;; the same Wine 11.0, built the way WineHQ and the Kron4ek builds that
  ;; radmin-vpn-linux tests with are: PE builtins compiled with mingw-w64,
  ;; and the new WoW64 mode (one 64-bit Unix process also runs 32-bit code,
  ;; so no 32-bit host libraries are involved).
  (package
    (inherit wine64)
    (name "wine64-wow64")
    (source
     (origin
       (inherit (package-source wine64))
       ;; A desktop set for a program in HKCU\Software\Wine\AppDefaults\
       ;; <program>\Explorer is also used when another program starts it.
       ;; Upstream, a program started by another always runs on its
       ;; parent's desktop, so a game started by a launcher can't have a
       ;; virtual desktop of its own while the launcher runs normally
       ;; (bfme-aio-launcher needs that).  And when such a virtual desktop
       ;; ends, the programs on the normal desktop get the host's display
       ;; configuration back (the virtual desktop replaced it with its
       ;; own; the launcher's window was then off-screen and unmapped).
       ;; A virtual desktop's window is also named (WM_CLASS) after the
       ;; desktop rather than explorer.exe, so docks can tell the games of
       ;; different packages apart.
       (patches (cons* (local-file "aux-files/wine-app-desktop.patch")
                       (local-file "aux-files/wine-desktop-wm-class.patch")
                       (origin-patches (package-source wine64))))))
    (inputs (modify-inputs (package-inputs wine64)
              (delete "wine")))
    (native-inputs
     (modify-inputs (package-native-inputs wine64)
       (append (car (mingw-toolchain %mingw32))
               (cadr (mingw-toolchain %mingw32))
               (car (mingw-toolchain %mingw64))
               (cadr (mingw-toolchain %mingw64)))))
    (arguments
     (substitute-keyword-arguments (package-arguments wine64)
       ((#:phases phases)
        #~(modify-phases #$phases
            (delete 'copy-wine32-libraries)
            (delete 'copy-wine32-manpage)
            (add-before 'configure 'isolate-cross-compilers
              (lambda _
                ;; Wine builds its PE side against its own headers and CRT,
                ;; but configure's compiler checks include the C library
                ;; headers.  Give mingw's gcc the mingw-w64 headers (they
                ;; serve both architectures) and keep the native glibc ones
                ;; out of its search path.
                (setenv "CROSS_C_INCLUDE_PATH"
                        #$(file-append mingw-w64-x86_64-winpthreads "/include"))
                (for-each unsetenv
                          '("CROSS_CPLUS_INCLUDE_PATH" "CROSS_LIBRARY_PATH"))))
            (add-after 'configure 'check-pe-build
              (lambda _
                ;; Fail early rather than silently producing ELF builtins.
                (unless (zero? (system* "grep" "-q" "w64-mingw32-gcc" "Makefile"))
                  (error "configure did not pick up the mingw-w64 compiler"))))))
       ((#:configure-flags flags #~'())
        #~(list "--enable-archs=i386,x86_64"))))
    (synopsis "Implementation of the Windows API (new WoW64, PE builtins)")))

(define wine64-wow64/prefix-update
  ;; Wine updates a prefix when wine.inf is newer than the prefix's
  ;; .update-timestamp -- but every file in the store has mtime 1, so after
  ;; switching Wine builds the stamp still matches and the prefix is never
  ;; updated.  Prefixes made with Guix's wine64 then lack wow64.dll and the
  ;; other new-WoW64 files, and 32-bit programs fail with "could not load
  ;; wow64.dll" (Radmin's service).  This `wine' records which Wine build
  ;; last updated the prefix and runs `wineboot -u' when that changes; the
  ;; other commands are wine64-wow64's own.
  (package
    (inherit wine64-wow64)
    (name "wine64-wow64-prefix-update")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((wine #$wine64-wow64)
                (bin (string-append #$output "/bin")))
            (mkdir-p bin)
            (for-each (lambda (dir)
                        (symlink (string-append wine "/" dir)
                                 (string-append #$output "/" dir)))
                      '("lib" "share"))
            (for-each (lambda (program)
                        (unless (string=? (basename program) "wine")
                          (symlink program
                                   (string-append bin "/" (basename program)))))
                      (find-files (string-append wine "/bin")))
            (call-with-output-file (string-append bin "/wine")
              (lambda (port)
                (format port "#!~a
prefix=\"${WINEPREFIX:-$HOME/.wine}\"
if [ -z \"$GUIX_WINE_UPDATING\" ] && [ -f \"$prefix/system.reg\" ] &&
   [ \"$(cat \"$prefix/.guix-wine\" 2>/dev/null)\" != ~s ]; then
    # wineboot reports failure when it can't overwrite files it once copied
    # read-only from the store (identical ones); the prefix is updated anyway.
    GUIX_WINE_UPDATING=1 ~a/bin/wine wineboot -u
    # The update also starts what the prefix autostarts (Radmin's GUI and
    # its service in SCM mode); stop them -- the caller starts what it
    # wants -- instead of waiting for them to exit, which never happens.
    ~a/bin/wineserver -k
    echo ~s > \"$prefix/.guix-wine\"
fi
exec ~a/bin/wine \"$@\"
"
                        #$(file-append bash-minimal "/bin/sh")
                        wine wine wine wine wine)))
            (chmod (string-append bin "/wine") #o555)))))
    (native-inputs '())
    (inputs (list bash-minimal wine64-wow64))
    (propagated-inputs '())))

(define-public radmin-vpn-linux
  (let ((commit "754389524327ad8e9ec0eb7de8348a74cacfd1f6")
        (revision "0"))
    (package
      (name "radmin-vpn-linux")
      (version (git-version "1.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/baptisterajaut/radmin-vpn-linux")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1m1mb9vhh25fsrglaiv0fh39mqc4dkplp12bzm371n99sbbh7spa"))))
      (build-system gnu-build-system)
      (arguments
       (list
        #:tests? #f                     ;no test suite
        #:strip-binaries? #f            ;the .so files are LD_PRELOAD shims
        #:modules '((guix build gnu-build-system)
                    (guix build utils)
                    (srfi srfi-1))
        #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (replace 'build
              (lambda _
                ;; The winpthreads variants are the full mingw-w64 runtimes
                ;; (headers + CRT + import libs) plus libwinpthread, which
                ;; Guix's mingw cross-gcc links against.
                (define mingw32 #$mingw-w64-i686-winpthreads)
                (define mingw64 #$mingw-w64-x86_64-winpthreads)
                (define (dirs-containing root . files)
                  ;; The CRT's lib directory differs between the i686 and
                  ;; x86_64 builds (lib vs lib32/...), so look it up.
                  (delete-duplicates
                   (append-map (lambda (file)
                                 (map dirname
                                      (find-files root
                                                  (string-append "^" file "$"))))
                               files)))
                (define (include-dir mingw)
                  (car (dirs-containing mingw "windows\\.h")))
                (define (cross-cc mingw triplet)
                  ;; Pin each cross compiler to its own runtime.  The CROSS_*
                  ;; search paths Guix sets are shared by both compilers and
                  ;; filled from every input, so pass the directories on the
                  ;; command line instead: -B is what makes gcc find the CRT
                  ;; start files (crt2.o, dllcrt2.o); -L alone does not.
                  (let ((incs (dirs-containing mingw "windows\\.h" "pthread\\.h"))
                        (libs (dirs-containing mingw "crt2\\.o" "dllcrt2\\.o"
                                               "libkernel32\\.a"
                                               "libwinpthread\\.a")))
                    (when (null? (dirs-containing mingw "dllcrt2\\.o"))
                      (error "no dllcrt2.o in mingw-w64 runtime" mingw))
                    (format #t "~a:~%  include ~a~%  lib     ~a~%" triplet incs libs)
                    (string-join
                     (append (list (string-append triplet "-gcc"))
                             (map (lambda (d) (string-append "-B" d "/")) libs)
                             (map (lambda (d) (string-append "-L" d)) libs)
                             (map (lambda (d) (string-append "-I" d)) incs))
                     " ")))
                (define (build . targets)
                  (let ((inc64 (include-dir mingw64)))
                    (apply invoke "make"
                           (string-append "MINGW32="
                                          (cross-cc mingw32 "i686-w64-mingw32"))
                           (string-append "MINGW64="
                                          (cross-cc mingw64 "x86_64-w64-mingw32"))
                           (string-append "DDK_INC="
                                          (if (file-exists? (string-append inc64 "/ddk"))
                                              (string-append inc64 "/ddk")
                                              inc64))
                           (string-append "MINGW64_LIB="
                                          (car (dirs-containing mingw64
                                                                "libntoskrnl\\.a")))
                           (map (lambda (t) (string-append "build/" t)) targets))))
                ;; Keep the native glibc/gtk headers away from the cross
                ;; compilers.
                (unsetenv "CROSS_C_INCLUDE_PATH")
                (unsetenv "CROSS_CPLUS_INCLUDE_PATH")
                (unsetenv "CROSS_LIBRARY_PATH")
                (build "tap_bridge" "rvpn_dnsfix.so" "rvpn_reuseport.so"
                       "rvpn_filter_ui"                     ;native
                       "rvpnnetmp.sys" "netsh64.exe"        ;win64
                       "adapter_hook.dll" "rvpn_launcher.exe" ;win32
                       "netsh.exe" "drvinst.exe")))
            (replace 'install
              (lambda* (#:key inputs #:allow-other-keys)
                (let* ((lib   (string-append #$output "/lib/radmin-vpn-linux"))
                       (share (string-append #$output "/share/radmin-vpn-linux"))
                       (bin   (string-append #$output "/bin"))
                       (launcher (string-append bin "/radmin-vpn"))
                       ;; Directory with nothing but run.sh's `sudo'.
                       (shim (string-append #$output "/libexec/radmin-vpn-linux"))
                       (bash  (search-input-file inputs "bin/bash")))
                  ;; Build artefacts, where run.sh looks for them via $BUILD_DIR.
                  (for-each (lambda (f) (install-file (string-append "build/" f) lib))
                            '("tap_bridge" "rvpn_dnsfix.so" "rvpn_reuseport.so"
                              "rvpn_filter_ui" "rvpnnetmp.sys" "netsh64.exe"
                              "adapter_hook.dll" "rvpn_launcher.exe" "netsh.exe"
                              "drvinst.exe"))
                  ;; Half a second after starting rvpn_launcher.exe the
                  ;; scripts already require RvControlSvc.exe, which the
                  ;; launcher only spawns once Wine is up -- seconds later
                  ;; when Wine first updates the prefix (as after a Wine
                  ;; upgrade).  They then declared the service dead and tore
                  ;; everything down.  Count the launcher as alive too.
                  (substitute* '("run.sh" "run_vps.sh" "run_datacenter.sh")
                    (("pgrep -f RvControlSvc >/dev/null \\|\\|")
                     "pgrep -f 'RvControlSvc|rvpn_launcher' >/dev/null ||"))
                  ;; Launcher scripts; run.sh sources lib.sh from its own dir.
                  (for-each (lambda (f) (install-file f share))
                            '("run.sh" "run_vps.sh" "run_datacenter.sh"
                              "health_check.sh" "lib.sh"
                              "patch_qwindows_font.py"))
                  (install-file "contrib/run-in-netns.sh" share)
                  ;; Entry point.  Upstream's AppImage starts run.sh through
                  ;; packaging/AppRun; this is that script, minus the bundled
                  ;; Wine (wine64-wow64 above is built the same way: PE
                  ;; builtins, new WoW64) and the re-run in a terminal (it
                  ;; asks for the password with a zenity dialog and logs to
                  ;; $XDG_DATA_HOME/radmin-vpn-linux/run.log), plus:
                  ;;  - every sudo of run.sh goes through one "sudo broker"
                  ;;    process, so the password is asked once -- without a
                  ;;    terminal, sudo asks again for each parent process;
                  ;;  - `radmin-vpn --stop' quits it (the tray menu, with its
                  ;;    Exit, can't be opened from COSMIC's panel);
                  ;;  - started again, it shows the running one's window.
                  (define (install-script template file . substitutions)
                    (mkdir-p (dirname file))
                    (copy-file template file)
                    (for-each (lambda (pair)
                                (substitute* file
                                  (((car pair)) (cdr pair))))
                              (cons (cons "@bash@" bash) substitutions))
                    (chmod file #o755))
                  (install-script #$(local-file "aux-files/radmin-vpn-launcher.sh")
                                  launcher
                                  (cons "@lib@" lib)
                                  (cons "@share@" share)
                                  (cons "@shim@" shim))
                  (install-script #$(local-file "aux-files/radmin-vpn-sudo.sh")
                                  (string-append shim "/sudo")
                                  (cons "@flock@"
                                        (search-input-file inputs "bin/flock")))
                  ;; Prefix settings for the GUI (fonts, and drawing that
                  ;; Xwayland shows right), made by run.sh once Radmin is
                  ;; installed in the prefix.
                  (install-script #$(local-file "aux-files/radmin-vpn-prefix.sh")
                                  (string-append share "/radmin-vpn-prefix.sh")
                                  (cons "@arial@"
                                        #$(this-package-input
                                           "font-microsoft-arial")))
                  (substitute* (string-append share "/run.sh")
                    (("^install_components\n" all)
                     (string-append
                      all "bash \"$DIR/radmin-vpn-prefix.sh\" "
                      "|| warn \"could not set up the prefix for the GUI\"\n")))
                  (invoke "grep" "-q" "radmin-vpn-prefix" (string-append share "/run.sh"))
                  ;; Same treatment for the health check and headless modes.
                  (for-each
                   (lambda (entry)
                     (let* ((name (car entry))
                            (script (cadr entry))
                            (file (string-append bin "/" name)))
                        (call-with-output-file file
                          (lambda (port)
                            (format port "#!~a
DATA_DIR=\"${XDG_DATA_HOME:-$HOME/.local/share}/radmin-vpn-linux\"
mkdir -p \"$DATA_DIR\"
export WINEPREFIX=\"${RADMIN_WINEPREFIX:-$DATA_DIR/wineprefix}\"
export BUILD_DIR=\"~a\"
export RADMIN_DATA_DIR=\"$DATA_DIR\"
exec ~a \"~a/~a\" \"$@\"~%"
                                    bash lib bash share script)))
                       (chmod file #o755)))
                   '(("radmin-vpn-health-check" "health_check.sh")
                     ("radmin-vpn-vps" "run_vps.sh")
                     ("radmin-vpn-datacenter" "run_datacenter.sh")))
                  ;; Desktop entry and icon.
                  (install-file "packaging/radmin-vpn.svg"
                                (string-append #$output
                                               "/share/icons/hicolor/scalable/apps"))
                  (let ((desktop (string-append #$output
                                                "/share/applications/radmin-vpn.desktop")))
                    (mkdir-p (dirname desktop))
                    (copy-file "packaging/radmin-vpn.desktop" desktop)
                    (substitute* desktop
                      (("^Exec=.*") (string-append "Exec=" launcher "\n"))
                      (("^Terminal=true") "Terminal=false")
                      ;; Wine's X11 and Wayland drivers both name windows
                      ;; after the lowercased .exe file name (WM_CLASS and
                      ;; app_id "rvrvpngui.exe"); upstream's mixed-case
                      ;; value never matches, so docks show no icon.
                      (("^StartupWMClass=.*")
                       "StartupWMClass=rvrvpngui.exe\n"))
                    ;; Shown in the dock's and the app library's menu for it.
                    (let ((port (open-file desktop "a")))
                      (format port "Actions=quit;

[Desktop Action quit]
Name=Quit Radmin VPN
Exec=~a --stop
" launcher)
                      (close-port port))))))
            (add-after 'install 'wrap-launchers
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((path (map (lambda (cmd)
                                   ;; Some tools live in sbin/ (iproute's
                                   ;; `ip', for one), so look in both.
                                   (dirname
                                    (or (false-if-exception
                                         (search-input-file
                                          inputs (string-append "bin/" cmd)))
                                        (search-input-file
                                         inputs (string-append "sbin/" cmd)))))
                                 '("wine" "bash" "ls" "sed" "grep" "awk" "find"
                                   "cmp" "pgrep" "ip" "modprobe" "dmesg" "iconv"
                                   "curl" "python3" "zenity"))))
                  (for-each
                   (lambda (prog)
                     ;; Prefix: run.sh needs Wine >= 11, so don't let an older
                     ;; wine earlier in the user's PATH win.  sudo is NOT
                     ;; provided -- the setuid one in /run/setuid-programs is
                     ;; what must be used.
                     (wrap-program (string-append #$output "/bin/" prog)
                       `("PATH" prefix ,path)))
                   '("radmin-vpn" "radmin-vpn-health-check" "radmin-vpn-vps"
                     "radmin-vpn-datacenter"))))))))
      ;; The mingw-w64 runtimes are referenced directly from the build phase
      ;; (see `cross-cc'), not listed here, so that their headers never leak
      ;; into the native half of the build.
      (native-inputs
       (append (list pkg-config)
               (mingw-toolchain %mingw32)
               (mingw-toolchain %mingw64)))
      (inputs
       (list bash coreutils curl diffutils findutils font-microsoft-arial gawk
             glibc grep gtk iproute kmod procps python sed util-linux
             wine64-wow64/prefix-update zenity))
      (supported-systems '("x86_64-linux"))
      (home-page "https://github.com/baptisterajaut/radmin-vpn-linux")
      (synopsis "Run the Radmin VPN Windows client on Linux through Wine")
      (description
       "radmin-vpn-linux runs the Windows Radmin VPN client under Wine.  It
replaces Radmin's NDIS miniport driver with a small Wine driver that forwards
frames over a FIFO to @command{tap_bridge}, which exposes them on a Linux TAP
interface (@code{radminvpn0}), so peers on Radmin networks become reachable
from native Linux programs.  A hook DLL papers over Wine incompatibilities in
adapter naming and registry permissions.

Start it with @command{radmin-vpn}, and quit it with @command{radmin-vpn
--stop} (also the menu entry's ``Quit Radmin VPN'' action).  On first run it
downloads the pinned Radmin VPN installer into
@file{~/.local/share/radmin-vpn-linux}.  Root (via @command{sudo}) is needed
to create the TAP device and routes; the password is asked once per start.  Radmin VPN
itself is proprietary and is not part of this package.")
      (license license:gpl3))))
