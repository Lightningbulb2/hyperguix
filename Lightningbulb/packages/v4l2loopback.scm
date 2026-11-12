;;; Lightningbulb channel --- v4l2loopback for the nonguix kernel
;;;
;;; A virtual camera device that programs can feed (Isocast's and OBS's
;;; Virtual Camera) and video calls can pick like a webcam.  Guix's
;;; v4l2loopback-linux-module is built for linux-libre; this builds the same
;;; source for nonguix's `linux', the kernel this system boots.
;;;
;;;   %v4l2loopback-services  -- add to the OS `services' list.
;;;
;;; It creates one device, labelled "Isocast Camera" (the label Isocast
;;; looks for), with exclusive_caps=1 so that browsers and Chromium-based
;;; apps list it as a camera.

(define-module (Lightningbulb packages v4l2loopback)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services linux)
  #:use-module (gnu services shepherd)
  #:use-module (nongnu packages linux)
  #:export (v4l2loopback-for-linux
            %v4l2loopback-services))

(define v4l2loopback-for-linux
  (package
    (inherit v4l2loopback-linux-module)
    (name "v4l2loopback-for-linux")
    (arguments
     (substitute-keyword-arguments
         (package-arguments v4l2loopback-linux-module)
       ((#:linux _ #f) linux)))))

(define %v4l2loopback-options
  '("devices=1" "exclusive_caps=1" "card_label=Isocast Camera"))

(define %v4l2loopback-services
  ;; The module goes in the kernel profile.  Guix's kmod doesn't read
  ;; /etc/modprobe.d, so a one-shot service loads it with its options
  ;; through the system's modprobe, as kernel-module-loader does.
  (list (simple-service 'v4l2loopback-kernel-module
                        linux-loadable-module-service-type
                        (list v4l2loopback-for-linux))
        (simple-service
         'v4l2loopback-load shepherd-root-service-type
         (list (shepherd-service
                (documentation "Load v4l2loopback with Isocast's camera.")
                (provision '(v4l2loopback))
                (requirement '(udev))
                (one-shot? #t)
                (modules `((rnrs io ports) ,@%default-modules))
                (start
                 #~(lambda _
                     (let ((modprobe (call-with-input-file
                                         "/proc/sys/kernel/modprobe"
                                       get-line)))
                       (zero? (system* modprobe "v4l2loopback"
                                       #$@%v4l2loopback-options))))))))))
