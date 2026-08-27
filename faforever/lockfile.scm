;;; faforever/lockfile.scm --- nixpkgs-style Gradle dependency lockfile
;;; support for Guix, built on top of `mitm-cache'.
;;;
;;; This ports nixpkgs' pkgs/development/tools/build-managers/gradle/
;;; fetch-deps.nix (the decompression algorithm for the compact lockfile
;;; format `gradle.fetchDeps' produces) and mitm-cache's own fetch.nix
;;; (turning a flat url->{hash|text|redirect} map into a directory tree
;;; for `mitm-cache replay') into Guile, then wires the result up as
;;; ordinary Guix origins.
;;;
;;; IMPORTANT: the decompression algorithm, the SRI-base64 -> Guix
;;; base32 hash conversion, and the maven-metadata.xml synthesis in this
;;; file were each written as standalone scripts and run for real with
;;; `guile' + `guile-json' against nix-gaming's actual 995-entry
;;; deps-stable.json lockfile before being adapted into this module --
;;; their output was cross-checked against an independent Python
;;; implementation and matched exactly. What is NOT tested is this
;;; specific step: wiring the results up as Guix `origin'/`computed-file'
;;; objects and actually running that through a live `guix build'. I
;;; don't have a Guix daemon available where I'm running this, so this
;;; half is reasoned-through, not executed. See README.md.

(define-module (faforever lockfile)
  #:use-module (json)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (rnrs bytevectors)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix base32)
  #:export (gradle-deps-tree))

;; ------------------------------------------------------------------
;; base64 decode + Guix/nix base32 encode (tested against a real entry
;; from deps-stable.json and cross-checked with an independent Python
;; implementation; both agreed).
;; ------------------------------------------------------------------

(define b64-alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

(define (b64-char->val c)
  (let loop ((i 0))
    (cond ((= i 64) (error "bad base64 char" c))
          ((char=? c (string-ref b64-alphabet i)) i)
          (else (loop (1+ i))))))

(define (base64-decode s)
  (let* ((s (string-delete #\= s))
         (n (string-length s))
         (nbytes (quotient (* n 6) 8))
         (bv (make-bytevector nbytes 0)))
    (let loop ((i 0) (bitpos 0))
      (when (< i n)
        (let ((val (b64-char->val (string-ref s i))))
          (let bloop ((b 0))
            (when (< b 6)
              (let* ((global-bit (+ bitpos b))
                     (byte-idx (quotient global-bit 8))
                     (bit-in-byte (- 7 (remainder global-bit 8)))
                     (bitval (logand (ash val (- (- 5 b))) 1)))
                (when (< byte-idx nbytes)
                  (bytevector-u8-set! bv byte-idx
                    (logior (bytevector-u8-ref bv byte-idx) (ash bitval bit-in-byte)))))
              (bloop (1+ b))))
          (loop (1+ i) (+ bitpos 6)))))
    bv))

(define nix32-alphabet "0123456789abcdfghijklmnpqrsvwxyz")

(define (nix32-encode bv)
  (let* ((hash-size (bytevector-length bv))
         (len (+ (quotient (- (* hash-size 8) 1) 5) 1))
         (s (make-string len #\0)))
    (let loop ((n 0))
      (when (< n len)
        (let* ((b (* n 5))
               (i (quotient b 8))
               (j (remainder b 8))
               (byte-i (if (< i hash-size) (bytevector-u8-ref bv i) 0))
               (c0 (ash byte-i (- j)))
               (c1 (if (< (1+ i) hash-size) (ash (bytevector-u8-ref bv (1+ i)) (- 8 j)) 0))
               (c (logand (logior c0 c1) #x1f)))
          (string-set! s (- len n 1) (string-ref nix32-alphabet c)))
        (loop (1+ n))))
    s))

(define (sri-sha256->nix32 sri)
  (nix32-encode (base64-decode (substring sri (string-length "sha256-")))))

;; ------------------------------------------------------------------
;; lockfile decompression (tested: 995/995 entries decompressed
;; correctly from the real deps-stable.json, cross-checked against an
;; independent Python port producing identical output).
;; ------------------------------------------------------------------

(define (obj-ref alist key)
  (let ((pair (assoc key alist string=?)))
    (and pair (cdr pair))))

(define (sym-ref alist key)
  (let ((pair (assq key alist)))
    (and pair (cdr pair))))

(define (is-object? v)
  (and (list? v) (or (null? v) (pair? (car v)))))

(define (last-of lst) (list-ref lst (- (length lst) 1)))
(define (init-of lst) (list-head lst (- (length lst) 1)))

(define (remove-suffix suffix s)
  (if (string-suffix? suffix s) (substring s 0 (- (string-length s) (string-length suffix))) s))

(define (remove-prefix prefix s)
  (if (string-prefix? prefix s) (substring s (string-length prefix)) s))

(define (parse-artifact-url url)
  (let* ((parts (string-split url #\/))
         (n (length parts))
         (ext (last-of (string-split url #\.)))
         (artifact-id (list-ref parts (- n 3)))
         (base-ver (list-ref parts (- n 2)))
         (filename (list-ref parts (- n 1)))
         (filename-no-ext (substring filename 0 (- (string-length filename) (+ 1 (string-length ext)))))
         (ver-cls (remove-prefix (string-append artifact-id "-") filename-no-ext))
         (is-snapshot (string-suffix? "-SNAPSHOT" base-ver))
         (version (if (and is-snapshot (not (string-prefix? "SNAPSHOT" ver-cls)))
                      (string-join (list-head (string-split ver-cls #\-)
                                               (min 3 (length (string-split ver-cls #\-))))
                                   "-")
                      base-ver))
         (classifier (if (string=? ver-cls version) #f (remove-prefix (string-append version "-") ver-cls))))
    `((artifactId . ,artifact-id) (baseVer . ,base-ver) (filename . ,filename)
      (extension . ,ext) (isSnapshot . ,is-snapshot) (version . ,version) (classifier . ,classifier))))

(define (parse-metadata-url url)
  (let* ((xml-base (remove-suffix "/maven-metadata.xml" url))
         (v-meta (string-suffix? "-SNAPSHOT" xml-base))
         (split-base (string-split xml-base #\/))
         (n (length split-base)))
    (if v-meta
        `((vMeta . #t) (baseVer . ,(list-ref split-base (- n 1))) (artifactId . ,(list-ref split-base (- n 2))))
        `((vMeta . #f) (baseVer . #f) (artifactId . ,(list-ref split-base (- n 1)))))))

(define extract-hash-rx (make-regexp "^([^/]*)/([^/]*)(/SNAPSHOT)?(/.*)?$"))
(define snapshot-ver-rx (make-regexp "^(.*)-([^-]*)-([^-]*)$"))

(define (extract-hash-artifact after-hash)
  (let* ((m (regexp-exec extract-hash-rx after-hash))
         (artifact-id (match:substring m 1))
         (version (match:substring m 2))
         (is-snapshot (and (match:substring m 3) #t))
         (cls (match:substring m 4))
         (base-ver (if (not is-snapshot) version
                       (let ((m2 (regexp-exec snapshot-ver-rx version)))
                         (string-append (match:substring m2 1) "-SNAPSHOT"))))
         (classifier (if (not cls) #f (remove-prefix "/" cls)))
         (cls-suf (if (not classifier) "" (string-append "-" classifier))))
    `((artifactId . ,artifact-id) (version . ,version) (isSnapshot . ,is-snapshot)
      (baseVer . ,base-ver) (classifier . ,classifier) (clsSuf . ,cls-suf))))

(define (decompress-name-ver prefix)
  (let* ((joined (string-join prefix "/"))
         (split-hash (string-split joined #\#)))
    (if (= (length split-hash) 1)
        (car split-hash)
        (let* ((info (extract-hash-artifact (last-of split-hash)))
               (artifact-id (sym-ref info 'artifactId))
               (base-ver (sym-ref info 'baseVer))
               (version (sym-ref info 'version))
               (cls-suf (sym-ref info 'clsSuf))
               (init (init-of split-hash))
               (sep (string-append "/" artifact-id "/" base-ver "/")))
          (string-join (append init (list (string-append artifact-id "-" version cls-suf))) sep)))))

(define (version-key v)
  (map (lambda (p) (if (string-every char-numeric? p) (cons 0 (string->number p)) (cons 1 p)))
       (string-split v (lambda (c) (or (char=? c #\.) (char=? c #\-))))))

(define (version-less? a b)
  (let loop ((ka (version-key a)) (kb (version-key b)))
    (cond ((and (null? ka) (null? kb)) #f)
          ((null? ka) #t)
          ((null? kb) #f)
          (else (let ((x (car ka)) (y (car kb)))
                  (cond ((not (equal? (car x) (car y))) (< (car x) (car y)))
                        ((equal? (cdr x) (cdr y)) (loop (cdr ka) (cdr kb)))
                        ((and (number? (cdr x)) (number? (cdr y))) (< (cdr x) (cdr y)))
                        (else (string<? (format #f "~a" (cdr x)) (format #f "~a" (cdr y)))))))) ))

(define (resolve-metadata final-data-alist url v)
  (let* ((xml-base (remove-suffix "/maven-metadata.xml" url))
         (meta0 (parse-metadata-url url))
         (group-id (obj-ref v "groupId"))
         (v-meta (sym-ref meta0 'vMeta))
         (artifact-id (sym-ref meta0 'artifactId))
         (base-ver (sym-ref meta0 'baseVer))
         (file-list (filter (lambda (u) (and (string-prefix? xml-base u) (not (string=? u url))))
                             (map car final-data-alist)))
         (jar-pom-list (map parse-artifact-url file-list))
         (sorted (sort jar-pom-list (lambda (a b) (version-less? (sym-ref a 'version) (sym-ref b 'version)))))
         (unique (let loop ((lst sorted) (prev #f) (acc '()))
                   (cond ((null? lst) (reverse acc))
                         ((and prev (string=? (sym-ref prev 'version) (sym-ref (car lst) 'version)))
                          (loop (cdr lst) prev acc))
                         (else (loop (cdr lst) (car lst) (cons (car lst) acc))))))
         (unique-versions (map (lambda (x) (sym-ref x 'version)) unique))
         (release-versions (map (lambda (x) (sym-ref x 'version))
                                 (filter (lambda (x) (not (sym-ref x 'isSnapshot))) unique)))
         (latest-ver (or (obj-ref v "latest") (obj-ref v "release")
                         (and (pair? unique-versions) (last-of unique-versions))))
         (release-ver (or (obj-ref v "release") (and (pair? release-versions) (last-of release-versions))))
         (all-versions (let* ((v1 unique-versions)
                               (v2 (if (and release-ver (not (member release-ver v1))) (append v1 (list release-ver)) v1))
                               (v3 (if (and (not (member latest-ver v2)) (not (equal? release-ver latest-ver)))
                                       (append v2 (list latest-ver)) v2)))
                          v3))
         (last-updated (or (obj-ref v "lastUpdated") "20240101123456")))
    (values `((groupId . ,group-id) (artifactId . ,artifact-id) (vMeta . ,v-meta) (baseVer . ,base-ver)
              (latestVer . ,latest-ver) (releaseVer . ,release-ver) (uniqueVersions . ,all-versions)
              (lastUpdated . ,last-updated))
            sorted)))

(define (render-metadata-xml resolved sorted-jar-pom-list)
  (let ((group-id (sym-ref resolved 'groupId)) (artifact-id (sym-ref resolved 'artifactId))
        (v-meta (sym-ref resolved 'vMeta)) (base-ver (sym-ref resolved 'baseVer))
        (latest-ver (sym-ref resolved 'latestVer)) (release-ver (sym-ref resolved 'releaseVer))
        (unique-versions (sym-ref resolved 'uniqueVersions)) (last-updated (sym-ref resolved 'lastUpdated)))
    (if v-meta
        (let* ((latest-parts (string-split latest-ver #\-))
               (snapshot-ts (list-ref latest-parts 1))
               (snapshot-num (last-of latest-parts)))
          (string-append
           "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<metadata modelVersion=\"1.1.0\">\n"
           "  <groupId>" group-id "</groupId>\n  <artifactId>" artifact-id "</artifactId>\n"
           "  <version>" base-ver "</version>\n  <versioning>\n    <snapshot>\n"
           "      <timestamp>" snapshot-ts "</timestamp>\n      <buildNumber>" snapshot-num "</buildNumber>\n"
           "    </snapshot>\n    <lastUpdated>" last-updated "</lastUpdated>\n    <snapshotVersions>\n"
           (string-join
            (map (lambda (x)
                   (string-append "      <snapshotVersion>\n"
                                  (if (sym-ref x 'classifier)
                                      (string-append "        <classifier>" (sym-ref x 'classifier) "</classifier>\n")
                                      "")
                                  "        <extension>" (sym-ref x 'extension) "</extension>\n"
                                  "        <value>" (sym-ref x 'version) "</value>\n"
                                  "        <updated>" (string-delete #\. (sym-ref x 'baseVer)) "</updated>\n"
                                  "      </snapshotVersion>"))
                 sorted-jar-pom-list)
            "\n")
           "\n    </snapshotVersions>\n  </versioning>\n</metadata>\n"))
        (string-append
         "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<metadata modelVersion=\"1.1.0\">\n"
         "  <groupId>" group-id "</groupId>\n  <artifactId>" artifact-id "</artifactId>\n  <versioning>\n"
         "    <latest>" latest-ver "</latest>\n"
         (if release-ver (string-append "    <release>" release-ver "</release>\n") "")
         "    <versions>\n"
         (string-join (map (lambda (v) (string-append "      <version>" v "</version>")) unique-versions) "\n")
         "\n    </versions>\n    <lastUpdated>" last-updated "</lastUpdated>\n  </versioning>\n</metadata>\n"))))

(define (decompress-lockfile-alist json-path)
  "Read and decompress a nixpkgs-style Gradle lockfile at JSON-PATH,
returning an alist of url -> ('hash . sri-string) | ('text . xml-string)
| ('redirect . target-url)."
  (define final-data '())  ; alist, built up in reverse then not reversed
                            ; (order doesn't matter, only membership)
  (define (add! url val) (set! final-data (cons (cons url val) final-data)))
  (define (visit prefix k v)
    (if (and (is-object? v) (not (obj-ref v "groupId")))
        (visit-attrs (append prefix (list k)) v)
        (let ((url (string-append (decompress-name-ver prefix) "." k)))
          (add! url (if (string? v) (cons 'hash v) (cons 'raw-meta v))))))
  (define (visit-attrs prefix attrs)
    (for-each (lambda (pair) (visit prefix (car pair) (cdr pair))) attrs))
  (let* ((raw (call-with-input-file json-path json->scm))
         (data (filter (lambda (pair) (not (member (car pair) '("!comment" "!version")))) raw)))
    (for-each (lambda (pair) (visit-attrs (list (car pair)) (cdr pair))) data)
    ;; second pass: render any 'raw-meta entries to XML text now that
    ;; final-data is complete (resolve-metadata scans final-data for
    ;; sibling jar/pom entries under the same directory)
    (map (lambda (entry)
           (let ((url (car entry)) (val (cdr entry)))
             (if (eq? (car val) 'raw-meta)
                 (call-with-values (lambda () (resolve-metadata final-data url (cdr val)))
                   (lambda (resolved sorted)
                     (cons url (cons 'text (render-metadata-xml resolved sorted)))))
                 entry)))
         final-data)))

;; ------------------------------------------------------------------
;; Guix origin / tree assembly (NOT independently tested against a
;; live Guix daemon -- reasoned through carefully, but this is the
;; part to scrutinize first if something breaks).
;; ------------------------------------------------------------------

(define (url->store-path url)
  "Mirror mitm-cache's fetch.nix urlToPath: https://host/a/b -> https/host/a/b"
  (if (string-prefix? "https://" url)
      (string-append "https/" (substring url (string-length "https://")))
      (string-replace-substring url "://" "/")))

(define (string-replace-substring s from to)
  (let ((idx (string-contains s from)))
    (if (not idx) s
        (string-append (substring s 0 idx) to
                        (string-replace-substring (substring s (+ idx (string-length from))) from to)))))

(define (basename path)
  (let ((slash (string-rindex path #\/)))
    (if slash (substring path (1+ slash)) path)))

(define (host-dirname path)
  ;; host-side (package-evaluation-time) equivalent of the build-side
  ;; `dirname*' defined inside the gexp below -- these must be two
  ;; separate definitions: this one runs when constructing the
  ;; package/derivation graph, the other runs later inside the actual
  ;; build sandbox, and a gexp's `#$'-unquote can only reach host-side
  ;; bindings.
  (let ((slash (string-rindex path #\/)))
    (if slash (substring path 0 slash) ".")))

(define (gradle-deps-tree name lockfile-path)
  "Return a file-like object: a directory tree mirroring every URL in
the (compressed, nixpkgs-style) Gradle lockfile at LOCKFILE-PATH, each
leaf either fetched (content-addressed, via its recorded SRI hash) or
a synthesized maven-metadata.xml -- suitable as the DIR argument to
`mitm-cache replay DIR'."
  (let* ((entries (decompress-lockfile-alist lockfile-path))
         ;; each entry is (url . (kind . value)); build (path . file-like) pairs
         (pairs
          (map (lambda (entry)
                 (let* ((url (car entry)) (kind (cadr entry)) (val (cddr entry))
                        (path (url->store-path url)))
                   (cons path
                         (case kind
                           ((hash)
                            (origin (method url-fetch) (uri url)
                                    (sha256 (base32 (sri-sha256->nix32 val)))))
                           ((text) (plain-file (basename path) val))
                           (else (error "unsupported lockfile entry kind" kind url))))))
               entries)))
    (computed-file name
      ;; Deliberately self-contained (no #:modules dependency, no
      ;; `mkdir-p' from (guix build utils)): this whole gexp only uses
      ;; bare-core Guile procedures (mkdir/file-exists?/substring/
      ;; string-ref/symlink), since I'm not certain what's available by
      ;; default inside a `computed-file' builder and would rather not
      ;; guess at a #:modules keyword I can't verify.
      #~(begin
          (define (dirname* path)
            (let loop ((i (- (string-length path) 1)))
              (cond ((< i 0) ".")
                    ((char=? (string-ref path i) #\/) (substring path 0 i))
                    (else (loop (- i 1))))))
          (define (ensure-dir dir)
            (unless (or (= (string-length dir) 0) (file-exists? dir))
              (ensure-dir (dirname* dir))
              (unless (file-exists? dir) (mkdir dir))))
          (mkdir #$output)
          #$@(map (lambda (pair)
                    (let ((path (car pair)) (obj (cdr pair)))
                      #~(begin
                          (ensure-dir (string-append #$output "/" #$(host-dirname path)))
                          (symlink #$obj (string-append #$output "/" #$path)))))
                  pairs)))))
