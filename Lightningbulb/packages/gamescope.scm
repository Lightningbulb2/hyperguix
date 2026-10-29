;;; Lightningbulb channel --- gamescope
;;;
;;; gamescope is Valve's micro-compositor: it runs a game inside its own
;;; Xwayland/Wayland server and presents the result through Vulkan, either
;;; nested in a desktop session (the SDL/Wayland backends; what Heroic's
;;; "Gamescope" game setting uses) or directly on DRM/KMS.
;;;
;;; Upstream builds several dependencies as git submodules at pinned commits.
;;; We fetch them recursively and then swap in Guix packages wherever Guix
;;; carries the same thing:
;;;   - wlroots: pinned at d783533, which is exactly the 0.20.2 tag -> Guix
;;;     `wlroots' (0.20.2), patched for FHS containers (`wlroots/gamescope').
;;;   - openvr: any version >= 2.7 is accepted -> Guix `openvr'.
;;;   - libdisplay-info: pinned at 0.4.0, Guix has 0.2.0.  Upstream accepts
;;;     anything < 0.5, and Guix's wlroots already links 0.2.0; bundling 0.4.0
;;;     statically next to it would interpose wlroots' di_* symbols, so the
;;;     Guix one is used.
;;;   - glm, stb: Meson wraps that would be downloaded at configure time ->
;;;     Guix `glm' (same 1.0.1) and the stb header packages.
;;;   - SPIRV-Headers: pinned at a 2023 commit (sdk-1.3.261.0+6) -> the newer
;;;     Guix `spirv-headers'.
;;; Kept bundled: libliftoff and vkroots (meson.build refuses to configure
;;; unless they are forced fallbacks), Joshua Ashton's reshade fork (only its
;;; effect compiler sources are built; its own deps/ are deleted) and sol2
;;; (thirdparty/sol, headers only).

(define-module (Lightningbulb packages gamescope)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages check)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages game-development)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages stb)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages window-management)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (nonguix multiarch-container)
  #:use-module (nongnu packages game-client)
  #:use-module (nongnu packages nvidia))

;; Heroic and Steam run games in `guix shell --container', which shares the
;; host's /tmp but maps only the user's own UID; root-owned /tmp/.X11-unix
;; then shows up as owned by the kernel's overflow UID (nobody), and wlroots
;; refuses to put gamescope's Xwayland socket there ("/tmp/.X11-unix not owned
;; by root or us").  Accept the overflow UID too.  This also accepts a
;; /tmp/.X11-unix owned by any other unmapped user, but the sticky-bit check
;; that follows still applies, and outside a user namespace nothing changes.
(define wlroots/gamescope
  (hidden-package
   (package/inherit wlroots
     (arguments
      (substitute-keyword-arguments (package-arguments wlroots)
        ((#:phases phases)
         #~(modify-phases #$phases
             (add-after 'unpack 'accept-overflow-uid-for-x11-socket-dir
               (lambda _
                 (substitute* "xwayland/sockets.c"
                   (("static bool check_socket_dir\\(void\\) \\{" all)
                    (string-append "\
/* Root-owned files appear as the overflow UID inside user namespaces that
 * do not map root, such as guix shell --container. */
static uid_t overflow_uid(void) {
	unsigned int uid = 65534;
	FILE *f = fopen(\"/proc/sys/kernel/overflowuid\", \"r\");
	if (f) {
		if (fscanf(f, \"%u\", &uid) != 1) {
			uid = 65534;
		}
		fclose(f);
	}
	return (uid_t)uid;
}

" all))
                   (("\\(buf\\.st_uid == getuid\\(\\)\\)\\)\\)")
                    "(buf.st_uid == getuid()) ||
			(buf.st_uid == overflow_uid())))")))))))))))

(define-public gamescope
  (package
    (name "gamescope")
    (version "3.17.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ValveSoftware/gamescope")
             (commit version)
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "07vgfsv8jcpx509v44xhlh1z9mn76vc7c29340ja5wzcsgmq5qpg"))
       (modules '((guix build utils)))
       (snippet
        ;; Drop the submodules and wraps replaced by Guix packages (see the
        ;; header comment).
        #~(begin
            (for-each delete-file-recursively
                      '("subprojects/wlroots"
                        "subprojects/openvr"
                        "subprojects/libdisplay-info"
                        "thirdparty/SPIRV-Headers"
                        "src/reshade/deps"))
            (for-each delete-file
                      '("subprojects/glm.wrap"
                        "subprojects/stb.wrap"))))))
    (build-system meson-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list "-Dpipewire=enabled"
              "-Drt_cap=enabled"
              "-Ddrm_backend=enabled"
              "-Dsdl2_backend=enabled"
              "-Davif_screenshots=enabled"
              "-Dinput_emulation=enabled"
              ;; Only builds an uninstalled micro-benchmark.
              "-Dbenchmark=disabled")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'use-guix-glm-and-stb
            ;; Stand-ins for the subprojects the deleted wraps would have
            ;; downloaded, pointing at the Guix headers instead.
            (lambda* (#:key inputs #:allow-other-keys)
              (define (include-dir header)
                (dirname (search-input-file inputs header)))
              (mkdir-p "subprojects/glm")
              (call-with-output-file "subprojects/glm/meson.build"
                (lambda (port)
                  (format port "project('glm', 'cpp', version: '1.0.1')
glm_dep = declare_dependency(include_directories: include_directories('~a'))
meson.override_dependency('glm', glm_dep)~%"
                          (dirname (include-dir "include/glm/glm.hpp")))))
              (mkdir-p "subprojects/stb")
              (call-with-output-file "subprojects/stb/meson.build"
                (lambda (port)
                  (format port "project('stb', 'c', version: '0.1.0')
stb_dep = declare_dependency(include_directories: include_directories(~{'~a'~^, ~}))
meson.override_dependency('stb', stb_dep)~%"
                          (map include-dir
                               '("include/stb_image.h"
                                 "include/stb_image_write.h"
                                 "include/stb_image_resize.h")))))))
          (add-after 'unpack 'use-guix-spirv-headers
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "src/meson.build"
                (("'\\.\\./thirdparty/SPIRV-Headers/include/spirv/unified1'")
                 (string-append
                  "'" (dirname (search-input-file
                                inputs "include/spirv/unified1/spirv.hpp"))
                  "'")))))
          (add-after 'unpack 'patch-version-and-paths
            (lambda _
              ;; There is no .git directory to run `git describe' in.
              (substitute* "src/meson.build"
                (("vcs_tag = run_command.*")
                 (string-append "vcs_tag = '" #$version "'\n")))
              ;; The system ReShade shader directory is hardcoded to /usr.
              (substitute* "src/Utils/DirHelpers.cpp"
                (("return \"/usr\";")
                 (string-append "return \"" #$output "\";")))
              ;; Look for user ReShade shaders in $XDG_DATA_HOME/gamescope
              ;; rather than always ~/.local/share/gamescope.
              (substitute* "src/reshade_effect_manager.cpp"
                (("std::string local_reshade_path = .*")
                 "std::string local_reshade_path = \
                  getenv(\"XDG_DATA_HOME\") && *getenv(\"XDG_DATA_HOME\") \
                  ? std::string{ getenv(\"XDG_DATA_HOME\") } + \"/gamescope/reshade\" \
                  : gamescope::GetLocalUsrDir() + gamescope_reshade_share_path;\n"))
              ;; gamescope re-executes its reaper helper through $PATH, which
              ;; need not contain it (e.g. inside an FHS container).
              (substitute* "src/Utils/Process.cpp"
                (("\\(char \\*\\)\"gamescopereaper\"")
                 (string-append "(char *)\"" #$output
                                "/bin/gamescopereaper\"")))
              (patch-shebang "default_extras_install.sh")))
          (replace 'install
            ;; Don't install the static libliftoff/vkroots bits.
            (lambda _
              (invoke "meson" "install" "--skip-subprojects"))))))
    (native-inputs
     (list catch2
           glslang
           pkg-config
           wayland))
    (inputs
     (list glm
           hwdata
           libavif
           libcap
           libdecor
           libdisplay-info
           libdrm
           libei
           libinput
           libx11
           libxcb
           libxcomposite
           libxcursor
           libxdamage
           libxext
           libxfixes
           libxi
           libxkbcommon
           libxmu
           libxrender
           libxres
           libxtst
           libxxf86vm
           luajit
           openvr
           pipewire
           pixman
           sdl2
           spirv-headers
           stb-image
           stb-image-resize
           stb-image-write
           vulkan-headers
           vulkan-loader
           wayland
           wayland-protocols
           wlroots/gamescope))
    (home-page "https://github.com/ValveSoftware/gamescope")
    (synopsis "Micro-compositor for running games")
    (description
     "Gamescope is the compositor used by SteamOS.  It runs games in an
isolated Xwayland server and composites them with Vulkan, either nested inside
an existing Wayland or X11 session or directly on top of DRM/KMS.  It can
present the game at a different resolution than it renders at, with FSR, NIS
or integer upscaling, limit its frame rate, force fullscreen, enable HDR and
VRR, and apply ReShade effects.  It also installs a Vulkan WSI layer that lets
games bypass Xwayland when running inside gamescope.")
    ;; gamescope itself is BSD-2; bundled: libliftoff (Expat), vkroots
    ;; (Expat/Apache 2.0), reshade (BSD-3), sol2 (Expat).
    (license (list license:bsd-2 license:expat license:bsd-3
                   license:asl2.0))))

;; gamescope as used inside nonguix's FHS game containers (see below).  Its
;; Xwayland needs NVIDIA's GBM backend and EGL vendor/platform files for glamor
;; (otherwise it falls back to llvmpipe and OpenGL games render on the CPU).
;; Outside the container these come from the system profile's search paths,
;; but the container preserves none of them; fhs-internal does however link the
;; files to /lib64/gbm and /usr/share/{glvnd,egl}, so point there.  The search
;; paths alone are not enough: Xwayland must also load NVIDIA's libgbm/libEGL
;; (glvnd) rather than plain Mesa's, hence `replace-mesa'.
(define (gamescope-for-fhs-container driver)
  (replace-mesa
   (package/inherit gamescope
     (name "gamescope-fhs")
     (inputs (modify-inputs (package-inputs gamescope)
               (prepend bash-minimal)))
     (arguments
      (substitute-keyword-arguments (package-arguments gamescope)
        ((#:phases phases)
         #~(modify-phases #$phases
             (add-after 'install 'wrap-for-fhs-container
               (lambda _
                 (wrap-program (string-append #$output "/bin/gamescope")
                   '("GBM_BACKENDS_PATH" ":" suffix ("/lib64/gbm"))
                   '("__EGL_VENDOR_LIBRARY_DIRS" ":" suffix
                     ("/usr/share/glvnd/egl_vendor.d"))
                   '("__EGL_EXTERNAL_PLATFORM_CONFIG_DIRS" ":" suffix
                     ("/usr/share/egl/egl_external_platform.d"))))))))))
   #:driver driver))

;; Heroic (like Steam) runs games inside a `guix shell --container' whose
;; /bin is the union of the container's package list; nothing from the host
;; profiles is on PATH or even mounted.  Heroic's "Gamescope" game setting
;; therefore needs gamescope inside that union.  This mirrors nonguix's
;; `heroic-nvidia-new-feature' (same driver, same preserved NVIDIA environment)
;; with gamescope added; it installs a `heroic' command like the original, so
;; replace the original with it rather than installing both.
(define-public heroic-nvidia-new-feature-gamescope
  (package
    (inherit
     (nonguix-container->package
      (nonguix-container
        (inherit (heroic-container-for
                  nvda-new-feature
                  #:extra-packages
                  `(("gamescope"
                     ,(gamescope-for-fhs-container nvda-new-feature)))))
        ;; Not exported; this is what `define-nvidia-container' uses.
        (preserved-env
         (@@ (nongnu packages nvidia) %nvidia-environment-variable-regexps)))))
    (name "heroic-nvidia-new-feature-gamescope")))
