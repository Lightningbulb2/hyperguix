;;; vpn.scm --- Guix package definition for radmin-vpn-linux
;;;
;;; Packages https://github.com/baptisterajaut/radmin-vpn-linux : a Wine
;;; shim (custom NDIS-miniport replacement + Linux TAP bridge) that lets
;;; Radmin VPN's Windows client run on Linux.  Radmin VPN itself is
;;; proprietary and is NOT distributed here or by upstream: `run.sh`
;;; downloads the vendor installer into the user's own Wine prefix on
;;; first run and verifies it against a pinned sha256 (see lib.sh).  Only
;;; the interoperability shim (GPL-3.0) is built and installed by this
;;; package.
;;;
;;; ---------------------------------------------------------------------
;;; BEFORE YOU BUILD THIS, READ radmin-vpn-guix/README.md.
;;;
;;; Every package name below has now been checked against an actual Guix
;;; checkout (gnu/packages/*.scm), not just recollection -- see README.md
;;; for what that did and didn't catch.
;;;
;;; The file ends with a bare `radmin-vpn-linux' reference (after the
;;; `define-public') so `guix build -f vpn.scm' returns the package
;;; directly -- `define-public' alone doesn't hand back its value as the
;;; file's last-evaluated expression.
;;; ---------------------------------------------------------------------

(define-module (radmin-vpn packages vpn)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (ice-9 ftw)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)          ; coreutils findutils grep sed gawk glibc
  #:use-module (gnu packages cross-base)    ; cross-gcc, cross-binutils
  #:use-module (gnu packages curl)          ; curl
  #:use-module (gnu packages freedesktop)   ; desktop-file-utils
  #:use-module (gnu packages gawk)          ; gawk
  #:use-module (gnu packages gtk)           ; gtk (this IS GTK4 in Guix --
                                             ; gtk+/gtk+-2 are the GTK3/2 names)
  #:use-module (gnu packages linux)         ; iproute procps net-tools nftables iptables
  #:use-module (gnu packages mingw)         ; mingw-w64-i686, mingw-w64-x86_64
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)        ; python
  #:use-module (gnu packages tls)           ; openssl
  #:use-module (gnu packages web)           ; websockify
  #:use-module (gnu packages wget)          ; wget
  #:use-module (gnu packages wine)          ; wine64
  #:use-module (gnu packages xorg))         ; xorg-server, for Xvfb

;; ---------------------------------------------------------------------
;; Runtime tool sets.  Kept as plain lists (rather than inlined) so it's
;; obvious what's core (run.sh / run_vps.sh / health_check.sh) versus
;; only needed by the optional browser-GUI mode (run_datacenter.sh).
;; ---------------------------------------------------------------------

(define %radmin-core-runtime-inputs
  (list wine64                 ; wine, wineserver, wineboot -- Guix's wine64 has
                                ; 32-bit/WoW64 support built in (it literally
                                ; copies wine's 32-bit binaries+libs in at
                                ; build time), so this alone covers
                                ; adapter_hook.dll + rvpn_launcher.exe too
        python                 ; patch_qwindows_font.py (--fix-chat)
        coreutils               ; cp, sha256sum, stat, timeout, mktemp, tr...
        findutils               ; find
        grep
        sed
        gawk                    ; awk
        iproute                 ; ip, ss -- the Guix variable is `iproute',
                                 ; though the package (and its input label)
                                 ; is named "iproute2"
        procps                  ; pgrep, pkill (both explicitly shipped by
                                 ; Guix's procps, per its own description)
        glibc                   ; iconv (service.log is UTF-16LE)
        curl
        wget                    ; _http_get() falls back to wget if curl is absent
        openssl                 ; installer-hash fallback if sha256sum/shasum missing
        nftables
        iptables
        net-tools               ; netstat, only used as a fallback behind `ss`
        desktop-file-utils))    ; update-desktop-database, for the hijacked
                                 ; file-association cleanup in lib.sh

(define %radmin-datacenter-runtime-inputs
  ;; Backs only the optional `radmin-vpn-datacenter' entry point
  ;; (browser-GUI-over-VNC mode) -- radmin-vpn-linux and radmin-vpn-vps
  ;; don't need any of this.
  ;;
  ;; IMPORTANT: neither x11vnc nor noVNC exist as packages anywhere in
  ;; Guix (checked: no `define-public' for either, under any module, in
  ;; gnu/packages/). Without them, run_datacenter.sh's VNC server and web
  ;; UI genuinely can't start -- Xvfb and websockify alone aren't enough.
  ;; This is left in, rather than dropped, because `wrap-program' below
  ;; uses PATH *prefix*, not replacement: if you separately get x11vnc
  ;; and noVNC onto your profile's PATH (write a quick local package for
  ;; them, use a container, whatever), radmin-vpn-datacenter will find
  ;; them there with no further changes needed here. See README.md.
  (list xorg-server             ; Xvfb
        websockify))

;; ---------------------------------------------------------------------
;; Package
;; ---------------------------------------------------------------------

(define-public radmin-vpn-linux
  (package
    (name "radmin-vpn-linux")
    ;; Latest tag is v1.1.0; this pins one commit past it (the installer
    ;; sha256-verification patch).  Bump both COMMIT and VERSION together
    ;; when a new v* tag lands, and drop back to a plain "X.Y.Z" version
    ;; once you're packaging an actual tag instead of a snapshot.
    (version "1.1.0-1.4ac03ec")
    (source
     (let ((commit "4ac03ecde3f2c40523b3d5dbca3ddfb47e80c715"))
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/baptisterajaut/radmin-vpn-linux")
               (commit commit)))
         (file-name (git-file-name "radmin-vpn-linux" commit))
         (sha256
          (base32
           "1w8l23slb2fdybpky9q3y7vl4v37b5cc52pww4p9y35q8r31q32m")))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f              ; upstream ships no test suite
      ;; The phases below use `any' (SRFI-1) and `ftw' (ice-9 ftw).
      ;; Top-level #:use-module only affects host-side evaluation of
      ;; this file; code inside #~(modify-phases ...) runs later in an
      ;; isolated build sandbox that only sees whatever is listed here.
      ;; Overriding #:modules replaces the default set entirely, so the
      ;; two gnu-build-system defaults have to be re-listed alongside
      ;; the extra modules the phases actually need.
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (srfi srfi-1)
                  (srfi srfi-13))
      #:phases
      #~(modify-phases %standard-phases
          ;; No ./configure script -- it's a plain Makefile project.
          (delete 'configure)
          ;; No `make check' target either.
          (delete 'check)

          ;; The Makefile auto-detects DDK headers by probing hardcoded
          ;; FHS paths (/usr/x86_64-w64-mingw32/include/ddk and friends),
          ;; none of which exist in the store, and where exactly
          ;; mingw-w64-x86_64 (a from-source Guix package, unlike
          ;; upstream mingw-w64's prebuilt Debian/Fedora packaging) lands
          ;; its "ddk" headers subdirectory isn't nailed down by its own
          ;; package definition either -- so find it by walking store
          ;; trees instead of guessing a fixed relative path. DDK_INC is
          ;; a plain `:=' assignment in the Makefile, so a command-line
          ;; override here wins over it.
          ;;
          ;; Deliberately doesn't `(assoc-ref inputs "mingw-w64-x86_64")'
          ;; for a starting point either: that returned #f on a real
          ;; build (input label mismatch -- Guix versions differ, or my
          ;; reading of the source was wrong in some other way I haven't
          ;; pinned down). Instead this searches every input whose label
          ;; merely *mentions* "mingw" (catches mingw-w64-x86_64, and
          ;; harmlessly also the two mingw-target cross-gcc/cross-binutils
          ;; inputs, whose trees just won't contain a "ddk" directory) --
          ;; robust to the exact label being something other than
          ;; expected, at the cost of a few extra seconds walking a
          ;; couple of extra store trees before finding it.
          (add-before 'build 'find-ddk-headers
            (lambda* (#:key inputs #:allow-other-keys)
              (define (directory-named root name)
                (and root
                     (call-with-current-continuation
                      (lambda (return)
                        (ftw root
                             (lambda (filename statinfo flag)
                               (when (and (eq? flag 'directory)
                                          (string=? (basename filename) name))
                                 (return filename))
                               #t))
                        #f))))
              ;; Same idea as directory-named, but for a specific file --
              ;; used below to find wherever libntoskrnl.a/libhal.a
              ;; actually live, the same way directory-named locates
              ;; "ddk". Returns *all* directories containing a matching
              ;; file (not just the first) -- see why below.
              (define (files-named root name)
                (or (and root
                         (let ((matches '()))
                           (ftw root
                                (lambda (filename statinfo flag)
                                  (when (and (eq? flag 'regular)
                                             (string=? (basename filename) name))
                                    (set! matches (cons (dirname filename) matches)))
                                  #t))
                           (reverse matches)))
                    '()))
              ;; rvpnnetmp.sys (the only Makefile target that reads
              ;; DDK_INC) is built with $(MINGW64) = x86_64-w64-mingw32-gcc,
              ;; so this must only search x86_64-labeled inputs -- not just
              ;; anything mentioning "mingw". The i686 entries are listed
              ;; earlier in native-inputs below, and `any' takes the first
              ;; match, so without this filter it silently resolves to the
              ;; 32-bit ddk headers instead (wrong arch, no build error,
              ;; just a broken/mismatched rvpnnetmp.sys).
              (define (arch-mingw-inputs arch)
                (filter (lambda (input)
                          (and (string-contains (car input) "mingw")
                               (string-contains (car input) arch)))
                        inputs))
              ;; adapter_hook.dll, rvpn_launcher.exe, netsh.exe,
              ;; netsh64.exe, and drvinst.exe pass zero -I flags at all
              ;; -- upstream wrote this Makefile assuming the
              ;; cross-compiler's own default sysroot already covers
              ;; <windows.h>, <winsock2.h>, etc. the way Debian/Fedora's
              ;; mingw-w64-gcc packages do. Guix's cross-gcc doesn't (see
              ;; the DDK_INC/excpt.h story above -- same root cause,
              ;; different header). <windows.h> is the one header
              ;; guaranteed to sit directly in any non-trivial mingw-w64
              ;; header tree's top-level include dir, so anchor on it to
              ;; find that directory for a given arch's inputs.
              (define (base-header-dir arch-inputs)
                (let ((candidates (append-map
                                    (lambda (input) (files-named (cdr input) "windows.h"))
                                    arch-inputs)))
                  (and (pair? candidates) (car candidates))))
              ;; adapter_hook.dll, rvpn_launcher.exe, netsh.exe,
              ;; netsh64.exe, and drvinst.exe also pass no -L or default
              ;; libraries at all -- same missing-sysroot story, but for
              ;; the linker: <dllcrt2.o> (the DLL startup object) and the
              ;; usual runtime import libs (kernel32, msvcrt, mingw32,
              ;; mingwex, etc.) all need an explicit -L too. Don't assume
              ;; this is the same directory as libntoskrnl.a's above --
              ;; ddk/ turned out to be its own separate subdirectory
              ;; rather than merged into the main headers, so the kernel
              ;; DDK import libs may equally be split from the general
              ;; runtime ones. Anchor on <dllcrt2.o> specifically, the
              ;; exact file `ld' reported missing, and apply the same
              ;; lib32-exclusion as libntoskrnl.a on the off chance the
              ;; x86_64 package's split applies here too.
              (define (base-lib-dir arch-inputs)
                (let ((candidates (append-map
                                    (lambda (input) (files-named (cdr input) "dllcrt2.o"))
                                    arch-inputs)))
                  (find (lambda (dir) (not (string-contains dir "lib32")))
                        candidates)))
              (let* ((mingw64-inputs (arch-mingw-inputs "x86_64"))
                     (mingw32-inputs (arch-mingw-inputs "i686"))
                     (ddk (any (lambda (input) (directory-named (cdr input) "ddk"))
                               mingw64-inputs)))
                (unless ddk
                  (error "could not find a 'ddk' directory under any x86_64 mingw input; searched:"
                         (map car mingw64-inputs)))
                ;; wdm.h (pulled in via ntddk.h from inside ddk/) also
                ;; expects plain CRT headers like <excpt.h> to be
                ;; reachable on the include path. On the Debian/Fedora
                ;; layouts this Makefile's own DDK_INC comment was
                ;; written for, that's automatic: the base include dir
                ;; (ddk's parent) is already on the cross-compiler's own
                ;; default search path. Guix's cross-gcc doesn't bake
                ;; that in the same way, and this particular package
                ;; ships ddk/ without excpt.h landing anywhere the
                ;; compiler already looks -- so add ddk's parent
                ;; explicitly too. Since DDK_INC is substituted directly
                ;; after a single `-I' in the Makefile with no quoting,
                ;; a second "-I<dir>" appended here becomes a genuine
                ;; second -I flag on the actual compile line.
                (setenv "RADMIN_DDK_INC"
                        (string-append ddk " -I" (dirname ddk)))
                ;; Same disease as DDK_INC, one Makefile variable over:
                ;; MINGW64_LIB is also a wildcard over Debian/Fedora FHS
                ;; paths (/usr/x86_64-w64-mingw32/lib and friends), none
                ;; of which exist in the store, so it silently resolves
                ;; empty and the rvpnnetmp.sys recipe's `-L' never gets
                ;; added -- `ld' then can't find -lntoskrnl/-lhal at all.
                ;; Find wherever libntoskrnl.a actually landed instead.
                ;; MINGW64_LIB is also a plain `:=' assignment, so this
                ;; command-line override wins the same way DDK_INC's does.
                ;;
                ;; This particular package ships BOTH a 32-bit compat
                ;; copy under .../lib32 AND the real x86_64 one
                ;; elsewhere -- confirmed on a real build, where `any'
                ;; grabbed lib32 first (directory-walk order, not
                ;; architecture) and `ld' rejected it as "incompatible"
                ;; for every symbol. So collect every directory that has
                ;; a copy and explicitly exclude lib32, rather than
                ;; trusting the first one found to be the right one.
                (let* ((candidates
                        (append-map (lambda (input)
                                      (files-named (cdr input) "libntoskrnl.a"))
                                    mingw64-inputs))
                       (lib (find (lambda (dir) (not (string-contains dir "lib32")))
                                  candidates)))
                  (unless lib
                    (error "could not find an x86_64-compatible directory containing libntoskrnl.a (only lib32 copies, if any); candidates were:"
                           candidates))
                  (setenv "RADMIN_MINGW64_LIB" lib))
                (let ((hdr32 (base-header-dir mingw32-inputs))
                      (hdr64 (base-header-dir mingw64-inputs)))
                  (unless hdr32
                    (error "could not find windows.h under any i686 mingw input"))
                  (unless hdr64
                    (error "could not find windows.h under any x86_64 mingw input"))
                  (setenv "RADMIN_MINGW32_INC" hdr32)
                  (setenv "RADMIN_MINGW64_INC" hdr64))
                (let ((libdir32 (base-lib-dir mingw32-inputs))
                      (libdir64 (base-lib-dir mingw64-inputs)))
                  (unless libdir32
                    (error "could not find an i686-compatible directory containing dllcrt2.o"))
                  (unless libdir64
                    (error "could not find an x86_64-compatible directory containing dllcrt2.o"))
                  (setenv "RADMIN_MINGW32_LIBDIR" libdir32)
                  (setenv "RADMIN_MINGW64_LIBDIR" libdir64)))))
          (replace 'build
            (lambda _
              ;; The mingw-w64/winpthreads inputs get their include/lib
              ;; dirs exported onto CPATH/C_INCLUDE_PATH/
              ;; CPLUS_INCLUDE_PATH/LIBRARY_PATH by Guix's generic input
              ;; search-path machinery. That's what breaks the *native*
              ;; $(CC) targets (tap_bridge, the two LD_PRELOAD .so
              ;; shims, rvpn_filter_ui): they see Windows-only
              ;; headers/libs ahead of glibc's, and _mingw.h's Win32-only
              ;; #error, or `ld' picking mingw's crt1.o over glibc's,
              ;; follow.
              ;;
              ;; It turned out NOT to be what the cross targets rely on,
              ;; though -- despite looking that way at first. Guix's
              ;; cross-gcc doesn't bake in a default sysroot the way
              ;; Debian/Fedora's mingw-w64-gcc packages do (confirmed
              ;; directly: rvpnnetmp.sys still couldn't find <excpt.h>
              ;; even with CPATH completely untouched, until it got an
              ;; explicit -I below). So the cross targets need *explicit*
              ;; -I flags regardless of what's on CPATH; see
              ;; find-ddk-headers above and the MINGW32/MINGW64
              ;; overrides below for where those come from.
              ;;
              ;; What CPATH/etc *do* still carry are legitimate entries
              ;; the native compiler needs (e.g. the Linux kernel headers
              ;; behind glibc's <bits/fcntl-linux.h> -> <linux/falloc.h>)
              ;; mixed in alongside the mingw ones -- so those variables
              ;; can't just be blanked for the CC wrapper either (tried
              ;; `env -u VAR', which stripped the kernel headers right
              ;; along with the mingw entries and broke tap_bridge the
              ;; other way). Compute each variable with only its
              ;; mingw-labeled entries removed instead, scoped to just
              ;; the native $(CC) targets via a command-line override of
              ;; the Makefile's CC variable (a plain `=' assignment, so
              ;; the override wins).
              (define (filtered-path var)
                (let ((val (getenv var)))
                  (if val
                      (string-join
                       (filter (lambda (dir) (not (string-contains dir "mingw")))
                               (string-split val #\:))
                       ":")
                      "")))
              (define cc-wrapper
                (string-append
                 "env"
                 " CPATH=" (filtered-path "CPATH")
                 " C_INCLUDE_PATH=" (filtered-path "C_INCLUDE_PATH")
                 " CPLUS_INCLUDE_PATH=" (filtered-path "CPLUS_INCLUDE_PATH")
                 " LIBRARY_PATH=" (filtered-path "LIBRARY_PATH")
                 " gcc"))
              ;; adapter_hook.dll, rvpn_launcher.exe, netsh.exe,
              ;; netsh64.exe, and drvinst.exe pass no -I at all (and
              ;; adapter_hook.dll's recipe doesn't even reference
              ;; $(CFLAGS), so a CFLAGS= override can't reach it
              ;; either). Bake the needed -I directly into the compiler
              ;; command itself via a command-line override of MINGW32/
              ;; MINGW64 (also plain `=' assignments) -- same trick as
              ;; DDK_INC and CC above: Make substitutes these verbatim
              ;; into the recipe with no quoting, so extra words here
              ;; just become extra arguments on the actual compile line.
              ;; -L for the general runtime import libs/dllcrt2.o rides
              ;; along the same way, for the same reason (no -L reaches
              ;; these recipes either -- only rvpnnetmp.sys's own
              ;; explicit -L$(MINGW64_LIB) is wired up in the Makefile).
              (define mingw32-wrapper
                (string-append "i686-w64-mingw32-gcc"
                                " -I" (getenv "RADMIN_MINGW32_INC")
                                " -L" (getenv "RADMIN_MINGW32_LIBDIR")))
              (define mingw64-wrapper
                (string-append "x86_64-w64-mingw32-gcc"
                                " -I" (getenv "RADMIN_MINGW64_INC")
                                " -L" (getenv "RADMIN_MINGW64_LIBDIR")))
              (invoke "make"
                      (string-append "DDK_INC=" (getenv "RADMIN_DDK_INC"))
                      (string-append "MINGW64_LIB=" (getenv "RADMIN_MINGW64_LIB"))
                      (string-append "CC=" cc-wrapper)
                      (string-append "MINGW32=" mingw32-wrapper)
                      (string-append "MINGW64=" mingw64-wrapper))))

          ;; There's no `install' target upstream, so this replaces the
          ;; default phase entirely.  Layout mirrors what the companion
          ;; Nix flake does: everything (scripts + lib.sh + the freshly
          ;; built build/ directory) stays together under
          ;; share/radmin-vpn-linux, because run.sh locates lib.sh and
          ;; BUILD_DIR relative to its own $(dirname "$0") -- splitting
          ;; them across bin/ and share/ would break that.
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out   (assoc-ref outputs "out"))
                     (share (string-append out "/share/radmin-vpn-linux")))
                (mkdir-p share)
                (copy-recursively "build" (string-append share "/build"))
                (copy-recursively "contrib" (string-append share "/contrib"))
                (when (file-exists? "docs")
                  (copy-recursively "docs" (string-append share "/docs")))
                (for-each (lambda (f) (install-file f share))
                          '("run.sh" "run_datacenter.sh" "run_vps.sh"
                            "lib.sh" "health_check.sh"
                            "patch_qwindows_font.py"
                            "README.md" "LICENSE"))
                ;; copy-recursively/install-file should preserve modes, but
                ;; don't rely on it -- everything here should be readable
                ;; and executable, nothing here needs to be more private
                ;; than that.
                (for-each (lambda (f) (chmod f #o555))
                          (append
                           (find-files share "\\.(sh|py)$")
                           (find-files (string-append share "/build"))))
                #t)))

          ;; Robustness patch applied to the *installed* copies in
          ;; share/: every `cp' upstream becomes `cp -f'.  Mirrors the
          ;; same patch the companion Nix flake applies during preBuild,
          ;; for the same reason: several of these run under `sudo
          ;; cp ...' to refresh files already present in the user's
          ;; wineprefix on re-runs/updates, and an inherited `alias
          ;; cp=cp -i' on the invoking shell can otherwise hang waiting
          ;; on a confirmation prompt nobody will answer.
          (add-after 'install 'robustify-cp-calls
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out   (assoc-ref outputs "out"))
                     (share (string-append out "/share/radmin-vpn-linux")))
                (substitute* (find-files share "\\.sh$")
                  (("cp ") "cp -f "))
                #t)))

          ;; Wrap in place (so lib.sh/build/ stay reachable via
          ;; dirname "$0"), then expose short names in bin/ via plain
          ;; symlinks to the now-wrapped scripts.
          (add-after 'robustify-cp-calls 'wrap-and-link-scripts
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out   (assoc-ref outputs "out"))
                     (share (string-append out "/share/radmin-vpn-linux"))
                     (bin   (string-append out "/bin"))
                     (bin-of (lambda (pkg-name)
                               (let ((dir (assoc-ref inputs pkg-name)))
                                 (and dir (string-append dir "/bin")))))
                     (present? (lambda (x) x))
                     (core (filter present?
                                    (map bin-of
                                         '("wine64" "python" "coreutils"
                                           "findutils" "grep" "sed" "gawk"
                                           "iproute2" "procps" "glibc"
                                           "curl" "wget" "openssl"
                                           "nftables" "iptables"
                                           "net-tools"
                                           "desktop-file-utils"))))
                     (datacenter-extra
                      (filter present?
                              (map bin-of '("xorg-server" "websockify"))))
                     ;; A fixed, writable, per-user prefix -- the
                     ;; upstream default ($(dirname "$0")/wineprefix)
                     ;; would otherwise land inside the read-only store.
                     (wineprefix
                      '("WINEPREFIX" =
                        ("$HOME/.local/share/radmin-vpn-linux/wineprefix"))))
                (mkdir-p bin)
                ;; The find-ddk-headers phase already showed once that an
                ;; assumed input label can just be wrong on a real build
                ;; without erroring anywhere obvious -- bin-of above would
                ;; make the same mistake silently (a missing entry just
                ;; quietly drops out of `core' via the present? filter).
                ;; Turn that into a loud, specific build failure instead
                ;; of a mysterious runtime "command not found" later, by
                ;; actually checking the binaries this package can't
                ;; function without are somewhere on the resolved PATH.
                (for-each
                 (lambda (binary)
                   (unless (any (lambda (dir)
                                  (file-exists? (string-append dir "/" binary)))
                                core)
                     (error
                      (string-append
                       "wrap-and-link-scripts: '" binary "' isn't on the "
                       "PATH this package assembled -- one of the bin-of "
                       "labels above is wrong for this Guix version; "
                       "check (map car inputs) for the real label")
                      core)))
                 '("wine" "python3" "ip" "find" "grep" "sed" "awk" "curl"))
                (wrap-program (string-append share "/run.sh")
                  `("PATH" ":" prefix ,core) wineprefix)
                (wrap-program (string-append share "/run_vps.sh")
                  `("PATH" ":" prefix ,core) wineprefix)
                (wrap-program (string-append share "/health_check.sh")
                  `("PATH" ":" prefix ,core) wineprefix)
                (wrap-program (string-append share "/run_datacenter.sh")
                  `("PATH" ":" prefix ,(append core datacenter-extra))
                  wineprefix)
                (for-each
                 (lambda (link-name real-name)
                   (symlink (string-append share "/" real-name)
                            (string-append bin "/" link-name)))
                 '("radmin-vpn-linux" "radmin-vpn-datacenter"
                   "radmin-vpn-vps" "radmin-vpn-health-check")
                 '("run.sh" "run_datacenter.sh"
                   "run_vps.sh" "health_check.sh"))
                #t))))))
    (native-inputs
     (list pkg-config
           ;; Guix has no single ready-made "mingw cross toolchain"
           ;; package (unlike nixpkgs' pkgsCross.mingwW64) -- it's
           ;; assembled from cross-gcc/cross-binutils (built for the
           ;; target but built to run natively) plus the target's
           ;; headers/import-libs, matching exactly how Guix's own
           ;; mingw-w64-{i686,x86_64} packages bootstrap themselves in
           ;; (gnu packages mingw).  This produces binaries under the
           ;; usual cross-tool names the Makefile already expects,
           ;; e.g. x86_64-w64-mingw32-gcc, x86_64-w64-mingw32-strip.
           (cross-binutils "i686-w64-mingw32")
           (cross-gcc "i686-w64-mingw32")
           mingw-w64-i686
           (cross-binutils "x86_64-w64-mingw32")
           (cross-gcc "x86_64-w64-mingw32")
           mingw-w64-x86_64))
    (inputs
     (append
      (list gtk)                ; rvpn_filter_ui (native GTK4 build+link) --
                                 ; `gtk' is GTK4 in Guix; gtk+/gtk+-2 are
                                 ; the GTK3/GTK2 names
      %radmin-core-runtime-inputs
      %radmin-datacenter-runtime-inputs))
    (synopsis "Run Radmin VPN on GNU/Linux via a Wine compatibility shim")
    (description
     "This package builds the Linux-side interoperability layer used by
@url{https://github.com/baptisterajaut/radmin-vpn-linux, radmin-vpn-linux}
to run the proprietary Windows Radmin VPN client under Wine.  It replaces
Radmin's Windows NDIS miniport driver with a Wine driver that bridges to a
Linux TAP device, plus a small hook DLL and a few native helpers that work
around specific Wine gaps (service SIDs, missing perflib exports, TCP
port-reuse NAT traversal, and reverse-DNS stalls on private addresses).

Installs three working entry points: @command{radmin-vpn-linux} (desktop
use, equivalent to upstream's run.sh), @command{radmin-vpn-vps} (headless,
fixed adapter GUID, no GUI), and @command{radmin-vpn-health-check}
(diagnostics).  A fourth, @command{radmin-vpn-datacenter} (headless with
the real GUI exposed over VNC/noVNC in a browser), is installed too but
needs x11vnc and noVNC on your PATH from some other source, as neither is
currently packaged in Guix -- see the package definition and README.md.

On first run, these download and verify the pinned upstream Radmin VPN
installer into a private Wine prefix under
@file{~/.local/share/radmin-vpn-linux/wineprefix}; no Famatech code is
built, bundled, or otherwise distributed by this package.  A working
@code{sudo} configuration on the host is required at run time, for TAP
device creation and routing -- it is intentionally not pulled in as a
package input.")
    (home-page "https://github.com/baptisterajaut/radmin-vpn-linux")
    ;; Upstream LICENSE is GPL-3.0 (not "or later").
    (license license:gpl3)))

;; So `guix build -f vpn.scm' works directly: `define-public' doesn't
;; hand its value back as the file's last-evaluated expression, so a
;; bare reference to the name has to be the actual last thing in the
;; file.
radmin-vpn-linux
