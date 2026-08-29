;;; guix.scm --- standalone entry point, no channel required
;;;
;;; Quick ways to use this file directly from a checkout of this repo:
;;;
;;;   guix build -f guix.scm
;;;   guix shell -Df guix.scm            # dev shell with build deps only
;;;   guix package -f guix.scm -i        # install into your profile
;;;
;;; This loads the real definition from radmin-vpn/packages/vpn.scm (see
;;; that file for everything of substance) and returns the package
;;; object, which is what `-f' expects as the file's final value.
;;;
;;; Deliberately uses `load' + a fully-qualified `@' reference here
;;; rather than `add-to-load-path' + `use-modules': `guix build -f'
;;; auto-compiles this file, which macro-expands the whole thing as one
;;; unit before any of it runs -- so `use-modules' would resolve against
;;; the load path as it stood *before* `add-to-load-path' ever executed,
;;; leaving the package variable unbound even though nothing errors
;;; along the way. `load' is a plain runtime procedure call (not a
;;; macro), so it isn't subject to that ordering at all.

(load (string-append (dirname (current-filename))
                      "/radmin-vpn/packages/vpn.scm"))

(@ (radmin-vpn packages vpn) radmin-vpn-linux)
