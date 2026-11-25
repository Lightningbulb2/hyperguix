;;; GRUB with a working USB keyboard when the firmware's fast boot skips USB.
;;;
;;; GRUB has no xHCI driver of its own, so it borrows the firmware's keyboard.
;;; With fast boot set to "Ultra Fast" (AMI firmware; ASRock and others) the
;;; firmware never connects its USB drivers and GRUB has no keyboard.
;;;
;;; `grub-efi-usb-keyboard-bootloader' installs GRUB exactly as
;;; `grub-efi-bootloader' does, then adds a boot entry that starts the UEFI
;;; shell first: its startup.nsh runs `connect -r' (connect every driver, USB
;;; included) and starts \EFI\Guix\grubx64.efi.  If the shell can't do that it
;;; exits, and the firmware boots the next entry (Guix's GRUB, keyboard or
;;; not).  grub-install puts "Guix" first in BootOrder on every reconfigure,
;;; so the installer moves this entry back in front each time.

(define-module (hyperguix packages grub-usb-keyboard)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module ((gnu packages linux) #:select (efibootmgr util-linux))
  #:export (grub-efi-usb-keyboard-bootloader))

(define-public uefi-shell
  (package
    (name "uefi-shell")
    (version "2.2-26H2")
    ;; EDK2's ShellPkg, built by github.com/pbatard/UEFI-Shell from the EDK2
    ;; stable tag.  Building EDK2 here would need its whole toolchain for one
    ;; binary that never runs under Linux.
    (source (origin
              (method url-fetch)
              (uri "https://github.com/pbatard/UEFI-Shell/releases/download/26H2/shellx64.efi")
              (file-name (string-append name "-" version "-x64.efi"))
              (sha256
               (base32 "1cc3vrg5wdb7pahh7p4wx98ydyybss5fp92xissqlbf9ba4dj8j9"))))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((dir (string-append #$output "/share/uefi-shell")))
            (mkdir-p dir)
            (copy-file #$source (string-append dir "/shellx64.efi"))))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/pbatard/UEFI-Shell")
    (synopsis "UEFI shell for x86_64")
    (description "The EDK2 UEFI shell as a standalone EFI program, installed as
@file{share/uefi-shell/shellx64.efi}.")
    (license license:bsd-2)))

(define %entry-label "GRUB (USB keyboard)")
(define %entry-dir "usbgrub")              ;\EFI\usbgrub on the ESP

;; CRLF, as the shell expects.  %homefilesystem% is the volume the shell was
;; started from, i.e. the ESP.
(define %startup.nsh
  (string-append "@echo -off\r\n"
                 "connect -r\r\n"
                 "%homefilesystem%\\EFI\\Guix\\grubx64.efi\r\n"
                 "exit\r\n"))

(define install-grub-efi-usb-keyboard
  #~(lambda (bootloader efi-dir mount-point)
      (#$(bootloader-installer grub-efi-bootloader) bootloader efi-dir mount-point)
      (when efi-dir
        (let* ((esp (if (file-exists? (string-append mount-point efi-dir))
                        (string-append mount-point efi-dir)
                        efi-dir))
               (dir (string-append esp "/EFI/" #$%entry-dir))
               (efibootmgr #$(file-append efibootmgr "/sbin/efibootmgr")))
          (define (output-of program . args)
            (let* ((port (apply (@ (ice-9 popen) open-pipe*)
                                OPEN_READ program args))
                   (text ((@ (ice-9 rdelim) read-string) port)))
              (and (zero? (status:exit-val ((@ (ice-9 popen) close-pipe) port)))
                   (string-trim-both text))))
          (define (efibootmgr-lines)
            (string-split (or (output-of efibootmgr) "") #\newline))
          (define (entry-number line)
            ;; "Boot0003* GRUB (USB keyboard)\tHD(...)" -> "0003" if the label
            ;; matches.  The 9th character is "*" (active) or " ".
            (and (> (string-length line) 10)
                 (string-prefix? "Boot" line)
                 (string->number (substring line 4 8) 16)
                 (memv (string-ref line 8) '(#\* #\space))
                 (char=? (string-ref line 9) #\space)
                 (string=? (car (string-split (substring line 10) #\tab))
                           #$%entry-label)
                 (substring line 4 8)))
          (define (find-entry)
            (let loop ((lines (efibootmgr-lines)))
              (cond ((null? lines) #f)
                    ((entry-number (car lines)) => identity)
                    (else (loop (cdr lines))))))
          (define (boot-order)
            (let loop ((lines (efibootmgr-lines)))
              (cond ((null? lines) '())
                    ((string-prefix? "BootOrder: " (car lines))
                     (delete "" (string-split (substring (car lines) 11) #\,)))
                    (else (loop (cdr lines))))))

          (mkdir-p dir)
          (let ((target (string-append dir "/shellx64.efi")))
            (when (file-exists? target) (delete-file target))  ;copied read-only
            (copy-file #$(file-append uefi-shell "/share/uefi-shell/shellx64.efi")
                       target))
          (call-with-output-file (string-append dir "/startup.nsh")
            (lambda (port) (display #$%startup.nsh port)))

          ;; Boot entries live in the firmware: only when this machine booted
          ;; with UEFI (not for an image or a chroot without efivars).
          (if (not (file-exists? "/sys/firmware/efi/efivars"))
              (format (current-error-port)
                      "warning: no efivars; not adding the ~s boot entry~%"
                      #$%entry-label)
              (catch #t
                (lambda ()
                  (let ((num
                         (or (find-entry)
                             (let* ((part (output-of #$(file-append util-linux "/bin/findmnt")
                                                     "-no" "SOURCE"
                                                     (canonicalize-path esp)))
                                    (disk (output-of #$(file-append util-linux "/bin/lsblk")
                                                     "-no" "PKNAME" part))
                                    (partnum (call-with-input-file
                                                 (string-append "/sys/class/block/"
                                                                (basename part) "/partition")
                                               (@ (ice-9 rdelim) read-line))))
                               ;; The shell skips argv[0], hence "shellx64.efi".
                               (invoke/quiet efibootmgr "-q" "-C"
                                             "-d" (string-append "/dev/" disk)
                                             "-p" partnum
                                             "-L" #$%entry-label
                                             "-l" (string-append "\\EFI\\" #$%entry-dir
                                                                 "\\shellx64.efi")
                                             "-u" "shellx64.efi -delay 0")
                               (or (find-entry)
                                   (error "boot entry not created"))))))
                    (invoke/quiet efibootmgr "-q" "-o"
                                  (string-join
                                   (cons num (delete num (boot-order) string-ci=?))
                                   ","))))
                (lambda args
                  (format (current-error-port)
                          "warning: could not set up the ~s boot entry: ~s~%"
                          #$%entry-label args))))))))

(define grub-efi-usb-keyboard-bootloader
  (bootloader
   (inherit grub-efi-bootloader)
   (name 'grub-efi-usb-keyboard)
   (installer install-grub-efi-usb-keyboard)))
