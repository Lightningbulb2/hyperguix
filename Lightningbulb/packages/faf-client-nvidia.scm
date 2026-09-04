;; Manifest for faf-client on the NVIDIA proprietary driver.
;;
;; `fhs-run-nvda' isn't offered as a named, `guix install`-able package
;; (see faforever.scm's own comments on why: an unresolvable driver
;; name at that point would take the whole channel down for everyone,
;; not just NVIDIA users). `fhs-run-for' is exposed instead -- pass it
;; whatever driver package your system actually loads.
;;
;; IMPORTANT: this MUST be the exact same nvidia-driver package (same
;; version) as whatever your operating-system config already loads as
;; the kernel module -- a mismatched version here just trades one GLX
;; failure for another.
;;
;; Usage:
;;   guix package -m faf-client-nvidia.scm
;; or, to add it to an existing profile/manifest rather than replacing
;; it, merge this into your own manifest.scm instead of using it
;; standalone.
(define-module (Lightningbulb packages faf-client-nvidia))
(use-modules (guix profiles)
             (guix packages)
             (Lightningbulb packages faforever)
             (nongnu packages nvidia))

(packages->manifest
 (list (package
         (inherit faf-client)
         (propagated-inputs (list (fhs-run-for nvidia-driver-new-feature))))))
