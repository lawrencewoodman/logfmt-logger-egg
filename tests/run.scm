(import scheme
        test
        (chicken condition)
        (chicken irregex)
        (chicken load)
        (chicken string))


(load-relative "../logfmt-logger.scm")
(import logfmt-logger)


;; Check timestamp (ts) fields are in the expected ISO 8601 format
(define (confirm-valid-timestamps entries)
  (irregex-replace/all "ts=\\d\\d\\d\\d-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\d[+-]\\d\\d\\d\\d "
                       entries
                       "ts=#t ") )

(log-level 0)
(include-relative "logfmt-logger.scm")



(test-exit)
