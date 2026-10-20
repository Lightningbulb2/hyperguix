;; reboot-to-bios.scm
;;
;; Provides a `bios` command that asks the UEFI firmware to boot straight
;; into its setup screen on the next reboot, by setting the
;; EFI_OS_INDICATIONS_BOOT_TO_FW_UI bit in the OsIndications efivar --
;; without disturbing any other bits already set in that variable.

(define-module (Lightningbulb packages reboot-to-bios)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages admin))

(define-public reboot-to-bios
  (package
    (name "reboot-to-bios")
    (version "1.1")
    (source #f)
    (build-system trivial-build-system)
    ;; bash: the script itself, plus its arithmetic/substring handling
    ;; coreutils: dd, od, tr, printf
    ;; e2fsprogs: chattr
    ;; shepherd: reboot
    (inputs (list bash coreutils e2fsprogs shepherd))
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let* ((bin (string-append #$output "/bin"))
                 (script (string-append bin "/bios")))
            (mkdir-p bin)
            (call-with-output-file script
              (lambda (port)
                (display (string-append "#!" #$bash "/bin/bash\n") port)
                (display "set -euo pipefail\n\n" port)
                (display "EFIVAR=\"/sys/firmware/efi/efivars/OsIndications-8be4df61-93ca-11d2-aa0d-00e098032b8c\"\n\n" port)
                (display "if [ ! -d /sys/firmware/efi ]; then\n" port)
                (display "  echo 'Error: System was not booted in UEFI mode.' >&2\n" port)
                (display "  exit 1\n" port)
                (display "fi\n\n" port)
                (display "# Read the current 8-byte little-endian OsIndications value (skipping\n" port)
                (display "# the 4-byte attribute header) so we can OR in our bit instead of\n" port)
                (display "# clobbering anything else firmware or other tools have already set.\n" port)
                (display "if [ -e \"$EFIVAR\" ]; then\n" port)
                (display (string-append "  CURRENT_HEX=$(" #$coreutils "/bin/dd if=\"$EFIVAR\" bs=1 skip=4 count=8 2>/dev/null | " #$coreutils "/bin/od -An -tx1 | " #$coreutils "/bin/tr -d ' \\n')\n") port)
                (display "else\n" port)
                (display "  CURRENT_HEX=\"0000000000000000\"\n" port)
                (display "fi\n" port)
                (display (string-append "CURRENT_HEX=$(" #$coreutils "/bin/printf '%-16s' \"$CURRENT_HEX\" | " #$coreutils "/bin/tr ' ' '0')\n\n") port)
                (display "# efivars are marked immutable by the kernel; bypass that so we can write.\n" port)
                (display "if [ -e \"$EFIVAR\" ]; then\n" port)
                (display (string-append "  " #$e2fsprogs "/bin/chattr -i \"$EFIVAR\" 2>/dev/null || true\n") port)
                (display "fi\n\n" port)
                (display "# Only touch the least-significant byte: bit 0 is\n" port)
                (display "# EFI_OS_INDICATIONS_BOOT_TO_FW_UI. Every other bit is preserved.\n" port)
                (display "FIRST_BYTE=$(( 0x${CURRENT_HEX:0:2} | 0x01 ))\n" port)
                (display "REST_HEX=${CURRENT_HEX:2:14}\n" port)
                (display (string-append "NEW_DATA_HEX=$(" #$coreutils "/bin/printf '%02x%s' \"$FIRST_BYTE\" \"$REST_HEX\")\n\n") port)
                (display "# 4-byte attribute header: non-volatile + boot-service + runtime access.\n" port)
                (display "WRITE_HEX=\"07000000${NEW_DATA_HEX}\"\n\n" port)
                (display "PRINTF_FMT=\"\"\n" port)
                (display "for ((i=0; i<${#WRITE_HEX}; i+=2)); do\n" port)
                (display "  PRINTF_FMT+=\"\\x${WRITE_HEX:i:2}\"\n" port)
                (display "done\n\n" port)
                (display (string-append #$coreutils "/bin/printf \"$PRINTF_FMT\" > \"$EFIVAR\"\n\n") port)
                (display (string-append "exec " #$shepherd "/sbin/reboot\n") port)))
            (chmod script #o555)))))
    (synopsis "Command to reboot directly into UEFI firmware setup")
    (description "Provides the @code{bios} command, which sets the
@code{EFI_OS_INDICATIONS_BOOT_TO_FW_UI} bit in the UEFI @code{OsIndications}
variable -- without disturbing any other bits already set there -- and
reboots directly into the motherboard's firmware setup screen.")
    (home-page #f)
    (license license:gpl3+)))
