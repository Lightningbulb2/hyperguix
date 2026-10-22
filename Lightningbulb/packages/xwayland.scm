;;; Lightningbulb channel --- Xwayland that X11 idle detection works with
;;;
;;; Steam (and other X11 programs) tell whether you're away through the
;;; MIT-SCREEN-SAVER extension's idle time.  Rootless Xwayland -- how every
;;; Wayland compositor runs it -- disables that extension, because it only
;;; sees input aimed at X11 windows, so Steam can't measure idleness at all.
;;;
;;; This variant keeps the extension, and counts a screen saver reset
;;; (`xset s reset', XResetScreenSaver) as user activity.  A helper that
;;; watches real idleness through the compositor (ext-idle-notify, e.g.
;;; swayidle) and resets the screen saver while you're active then gives X11
;;; programs a correct idle time.  Blanking stays off, as upstream has it.
;;;
;;; It also finds the system's EGL/GBM drivers (NVIDIA's included) without
;;; relying on the environment the compositor passes it; see the wrapper.

(define-module (Lightningbulb packages xwayland)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages xorg))

(define-public xwayland-with-idle-time
  (package
    (inherit xorg-server-xwayland)
    (name "xwayland-with-idle-time")
    (source
     (origin
       (inherit (package-source xorg-server-xwayland))
       (patches
        (cons (local-file "aux-files/xwayland-idle-time.patch")
              (origin-patches (package-source xorg-server-xwayland))))))
    (arguments
     (substitute-keyword-arguments (package-arguments xorg-server-xwayland)
       ((#:phases phases #~%standard-phases)
        #~(modify-phases #$phases
            ;; cosmic-comp (smithay) starts Xwayland with an almost empty
            ;; environment, so it couldn't find NVIDIA's EGL and GBM
            ;; back ends and fell back to software rendering ("failed to
            ;; setup GBM backend") -- every X11 program, Steam and Wine
            ;; games included, drew with llvmpipe.  Point it at the system
            ;; profile, where the NVIDIA driver puts them; values set by
            ;; the caller still come first.
            (add-after 'install 'wrap-graphics-search-paths
              (lambda _
                (let ((profile "/run/current-system/profile"))
                  (wrap-program (string-append #$output "/bin/Xwayland")
                    `("__EGL_VENDOR_LIBRARY_DIRS" suffix
                      (,(string-append profile "/share/glvnd/egl_vendor.d")))
                    `("GBM_BACKENDS_PATH" suffix
                      (,(string-append profile "/lib/gbm")))
                    `("__EGL_EXTERNAL_PLATFORM_CONFIG_DIRS" suffix
                      (,(string-append
                         profile "/share/egl/egl_external_platform.d")))))))))))
    (inputs
     (modify-inputs (package-inputs xorg-server-xwayland)
       (prepend bash-minimal)))
    (synopsis "Xwayland server that reports X11 idle time")
    (description
     "This is Xwayland, the X server running as a Wayland client, changed to
keep the MIT-SCREEN-SAVER extension when rootless and to treat a screen saver
reset as user activity.  Together with a helper that resets the screen saver
while the user is active on the Wayland side, X11 programs such as Steam get a
meaningful idle time.")))
