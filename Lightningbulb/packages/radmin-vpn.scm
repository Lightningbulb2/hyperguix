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
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
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
  #:use-module (gnu packages wine))

(define %mingw32 "i686-w64-mingw32")
(define %mingw64 "x86_64-w64-mingw32")

(define (mingw-toolchain triplet)
  (list (cross-gcc triplet
                   #:xbinutils (cross-binutils triplet)
                   #:libc (cross-libc triplet))
        (cross-binutils triplet)))

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
                       (bash  (search-input-file inputs "bin/bash")))
                  ;; Build artefacts, where run.sh looks for them via $BUILD_DIR.
                  (for-each (lambda (f) (install-file (string-append "build/" f) lib))
                            '("tap_bridge" "rvpn_dnsfix.so" "rvpn_reuseport.so"
                              "rvpn_filter_ui" "rvpnnetmp.sys" "netsh64.exe"
                              "adapter_hook.dll" "rvpn_launcher.exe" "netsh.exe"
                              "drvinst.exe"))
                  ;; Launcher scripts; run.sh sources lib.sh from its own dir.
                  (for-each (lambda (f) (install-file f share))
                            '("run.sh" "run_vps.sh" "run_datacenter.sh"
                              "health_check.sh" "lib.sh"
                              "patch_qwindows_font.py"))
                  (install-file "contrib/run-in-netns.sh" share)
                  ;; Entry point: upstream's AppRun minus the bundled Wine.
                  (mkdir-p bin)
                  (copy-file "packaging/AppRun" launcher)
                  (substitute* launcher
                    (("^#!/bin/bash") (string-append "#!" bash))
                    (("^APPDIR=.*") "")
                    ;; Guix's wine64 is used instead of the AppImage's copy.
                    (("^export (PATH|WINELOADER|WINESERVER)=\"\\$APPDIR/wine.*") "")
                    (("\"\\$APPDIR/usr/lib/radmin-vpn\"")
                     (string-append "\"" lib "\""))
                    (("\"\\$APPDIR/usr/bin/run.sh\"")
                     (string-append "\"" share "/run.sh\"")))
                  (chmod launcher #o755)
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
export WINEPREFIX=\"${WINEPREFIX:-$DATA_DIR/wineprefix}\"
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
                      (("^Exec=.*") (string-append "Exec=" launcher "\n")))))))
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
       (list bash coreutils curl diffutils findutils gawk glibc grep gtk
             iproute kmod procps python sed util-linux wine64 zenity))
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

Start it with @command{radmin-vpn}.  On first run it downloads the pinned
Radmin VPN installer into @file{~/.local/share/radmin-vpn-linux}.  Root (via
@command{sudo}) is needed to create the TAP device and routes.  Radmin VPN
itself is proprietary and is not part of this package.")
      (license license:gpl3))))
