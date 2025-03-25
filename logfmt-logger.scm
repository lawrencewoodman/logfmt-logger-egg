;;; A logging module using logfmt for Chicken Scheme
;;;
;;; Copyright (C) 2025 Lawrence Woodman <https://lawrencewoodman.github.io/>
;;;
;;; Licensed under an MIT licence.  Please see LICENCE.md for details.
;;;

(module logfmt-logger
  (log-debug
   log-info
   log-warning
   log-error
   log-critical
   log-level
   log-port)

(import scheme
        (chicken base)
        (chicken format)
        (chicken string)
        (chicken time)
        (chicken time posix)
        (chicken type)
        srfi-13)

;; Import notes -------------------------------------------------------------
;; srfi-13  - String library


(define-type kv-pair (pair (or symbol string) (or string symbol integer float)))

;; Exported Definitions ------------------------------------------------------

;; Control which log entries are output
;; If the entries have a level-number >= (log-level) they will be output
;; Accepts level numbers or symbols:
;;   10 = 'debug
;;   20 = 'info
;;   30 = 'warning
;;   40 = 'error
;;   50 = 'critical
;; Defaults to 30, 'warning
(define log-level (make-parameter 30 (lambda (level)
  (case level
    ('debug 10)
    ('info 20)
    ('warning 30)
    ('error 40)
    ('critical 50)
    (else (if (integer? level)
              level
              (error 'log-level (sprintf "unsupported value: ~A" level) ) ) ) ) ) ) )


;; The port that output is sent to when most log-* commands are called
;; Defaults to (current-error-port)
(define log-port (make-parameter (current-error-port)))


;; Add a log entry with log=debug
;; Key 'ts' will be set to the current date and time using an
;; ISO 8601 timestamp including the offset from UTC.
;; Key 'msg' will be set to the message passed in via parameter 'msg'.
;; The remaining parameters are key/value pairs which will be added
;; to the log entry. Duplicate keys appearing in the key/value pairs
;; are overwritten by later matching keys except the default
;; keys: ts, level and msg, which can't be overwritten.
;; The log entry will be output to (log-port).
(: log-debug (string #!rest (list-of kv-pair) --> undefined))
(define (log-debug msg . args)
  (log-entry 10 "debug" msg args) )


;; Add a log entry with level=info
;; See log-debug for more details
(: log-info (string #!rest (list-of kv-pair) --> undefined))
(define (log-info msg . args)
  (log-entry 20 "info" msg args) )


;; Add a log entry with level=warning
;; See log-info for more details
(: log-warning (string #!rest (list-of kv-pair) --> undefined))
(define (log-warning msg . args)
  (log-entry 30 "warning" msg args) )


;; Add a log entry with level=error
;; See log-info for more details
(: log-error (string #!rest (list-of kv-pair) --> undefined))
(define (log-error msg . args)
  (log-entry 40 "error" msg args) )


;; Add a log entry with level=critical
;; See log-info for more details
(: log-critical (string #!rest (list-of kv-pair) --> undefined))
(define (log-critical msg . args)
  (log-entry 50 "critical" msg args) )


;; Internal Definitions ------------------------------------------------------


;; This is the generic function used by the exported log-* functions.
;; Keys ts, level and msg can be overwritten to increase speed by reducing checks.
;; level-number is used so that output can be controlled by log-level, it
;; isn't output in the key/value pairs.
;; TODO: Choose a name and export this so that additional log- functions
;; TODO: can be created
(: log-entry (integer (or string symbol) string (list-of kv-pair) --> undefined))
(define (log-entry level-number level-str msg kv-pairs)
  (when (>= level-number (log-level))
    (let* ((base-kv-pairs (list (cons 'ts (timestamp))
                                (cons 'level (encode-value level-str))
                                (cons 'msg (encode-value msg))))
           (final-kv-pairs (append base-kv-pairs (encode-values/dedup kv-pairs))))
      (fprintf (log-port) "~A\n" (alist->logfmt-str-entry final-kv-pairs))
      (flush-output (log-port) ) ) ) )


(define (alist->logfmt-str-entry alist)
  (substring (foldl (lambda (str assoc)
                      (string-append str (sprintf " ~A=~A" (car assoc) (cdr assoc))))
             ""
             alist)
             1) )


;; Encode values and de-duplicate keys
(define (encode-values/dedup alist)
  ;; alist-update is used to prevent duplicate keys
  (foldl (lambda (dedup-alist assoc)
           (let ((key (car assoc)))
             (if (memq key '(ts level msg))
                 dedup-alist
                 (alist-update key (encode-value (cdr assoc)) dedup-alist))))
         '()
         alist) )


(define (encode-value value)
  (cond ((string? value) (encode-string value))
        ((symbol? value) (encode-string (symbol->string value)))
        ((integer? value) value)
        ((real? value) value)
        (else (error 'encode-value (sprintf "unsupported type for value: ~A" value) ) ) ) )


;; Escape \n, \r, \f, \t, '"', and Wraps string in quotes if it contains
;; whitespace, '=' or '\' after initial escaping is performed
;; Empty strings are wrapped in quotes because parsers are inconsistent with
;; how they handle empty values.
;; TODO: Detect and handle other characters <= ' '
;; TODO: Quote if other whitespace such as \u00A0
;; TODO: With Chicken 5.4, char-whitespace? doesn't detect all whitespace
;; TODO: Make faster
(define (encode-string str)
  (let ((first-pass (string-translate* str '(("\n" . "\\n")
                                             ("\r" . "\\r")
                                             ("\f" . "\\f")
                                             ("\t" . "\\t")
                                             ("\"" . "\\\"")))))
    (if (or (substring-index " " first-pass)
            (substring-index "\\" first-pass)
            (substring-index "=" first-pass)
            (= (string-length first-pass) 0))
        (sprintf "\"~A\"" first-pass)
        first-pass) ) )


;; Return the current date and time using an ISO 8601 timestamp
;; including the offset from UTC
(define (timestamp)
  (time->string (seconds->local-time (current-seconds)) "%Y-%m-%dT%H:%M:%S%z") )




)

