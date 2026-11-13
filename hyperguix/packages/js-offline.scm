;;; hyperguix --- offline npm/pnpm installs inside Guix builds
;;;
;;; Guix builds have no network.  The Tauri applications in this channel ship
;;; a lockfile (package-lock.json or pnpm-lock.yaml) that pins every npm
;;; tarball by hash, so we fetch each tarball as an ordinary fixed-output
;;; origin (see node-deps.scm), lay them out the way registry.npmjs.org does,
;;; and during the build serve that tree from a tiny HTTP server on
;;; 127.0.0.1.  `npm ci' and `pnpm install --frozen-lockfile' then run
;;; unmodified against it: npm rewrites registry.npmjs.org URLs to the
;;; configured registry, and pnpm derives tarball URLs from it.

(define-module (hyperguix packages js-offline)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:export (npm-tarball
            offline-npm-registry
            offline-npm-registry-server
            start-offline-npm-registry))

(define (npm-tarball path hash)
  "Return (PATH . ORIGIN) for the registry tarball at PATH, e.g.
\"@types/react/-/react-18.3.12.tgz\", whose sha256 is HASH (nix-base32)."
  (cons path
        (origin
          (method url-fetch)
          (uri (string-append "https://registry.npmjs.org/" path))
          (file-name
           (string-append "npm-"
                          (string-map (lambda (c)
                                        (if (or (char-alphabetic? c)
                                                (char-numeric? c)
                                                (memv c '(#\. #\- #\_ #\+)))
                                            c
                                            #\-))
                                      ;; "@types/react/-/x.tgz" -> "@types/react"
                                      (dirname (dirname path)))
                          "-" (basename path)))
          (sha256 (base32 hash)))))

(define (offline-npm-registry name tarballs)
  "Return a directory mirroring the registry layout for TARBALLS, a list of
(PATH . ORIGIN) pairs as returned by `npm-tarball'."
  (computed-file
   (string-append name "-npm-registry")
   (with-imported-modules '((guix build utils))
     #~(begin
         (use-modules (guix build utils))
         (for-each (lambda (entry)
                     (let ((dest (string-append #$output "/" (car entry))))
                       (mkdir-p (dirname dest))
                       (symlink (cdr entry) dest)))
                   (list #$@(map (lambda (entry)
                                   #~(cons #$(car entry) #$(cdr entry)))
                                 tarballs)))))))

(define offline-npm-registry-server
  (plain-file "offline-npm-registry.js" "\
// Minimal read-only npm registry serving pre-fetched tarballs.
'use strict';
const http = require('http');
const fs = require('fs');
const path = require('path');
const [root, portFile] = process.argv.slice(2);
const server = http.createServer((req, res) => {
  const rel = decodeURIComponent(req.url.split('?')[0]).replace(/^\\/+/, '');
  const file = path.join(root, rel);
  fs.stat(file, (err, st) => {
    if (err || !st.isFile()) {
      console.error('offline-registry: 404 ' + req.method + ' ' + req.url);
      res.writeHead(404, { 'content-type': 'application/json' });
      res.end('{\"error\":\"Not found\"}');
      return;
    }
    res.writeHead(200, { 'content-type': 'application/octet-stream',
                         'content-length': st.size });
    fs.createReadStream(file).pipe(res);
  });
});
server.listen(0, '127.0.0.1', () => {
  fs.writeFileSync(portFile + '.tmp', String(server.address().port));
  fs.renameSync(portFile + '.tmp', portFile);
});
"))

(define (start-offline-npm-registry registry)
  "Return a gexp that starts the offline registry serving REGISTRY (as
returned by `offline-npm-registry') in the background, points npm and pnpm at
it through npm_config_registry, and evaluates to the server's PID.  `node'
must be on PATH."
  #~(let ((port-file (string-append (getcwd) "/.offline-registry-port")))
      (let ((pid (primitive-fork)))
        (when (zero? pid)
          (catch #t
            (lambda ()
              (execlp "node" "node" #$offline-npm-registry-server #$registry
                      port-file))
            (lambda _ (primitive-_exit 127))))
        (let wait ((tries 0))
          (unless (file-exists? port-file)
            (when (> tries 600)
              (error "offline npm registry did not start"))
            (usleep 100000)
            (wait (+ tries 1))))
        (let ((url (string-append "http://127.0.0.1:"
                                  (number->string
                                   (call-with-input-file port-file read))
                                  "/")))
          (format #t "offline npm registry listening on ~a~%" url)
          (setenv "npm_config_registry" url)
          ;; No update checks, audits or funding pings: they would 404.
          (setenv "npm_config_update_notifier" "false")
          (setenv "npm_config_audit" "false")
          (setenv "npm_config_fund" "false")
          pid))))
