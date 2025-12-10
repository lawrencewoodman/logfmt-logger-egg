;; Tests for logfmt-logger


(test "log-info sets level to 'info' and sets the timestamp and message"
      "ts=#t level=info msg=message\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "message")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info encloses msg value in quotes if it contains spaces"
      "ts=#t level=info msg=\"This is a message with spaces\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "This is a message with spaces")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info sets value as \"\" if there is no value because some parsers do odd things if no value"
      "ts=#t level=info msg=hello selector=\"\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "hello" '(selector . ""))
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info allows multipe key/value pairs to be used and quotes them when appropriate"
      "ts=#t level=info msg=\"This is a message\" tag=something phrase=\"after midnight\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "This is a message" '(tag . something) '(phrase . "after midnight"))
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info escapes \\n in strings"
      "ts=#t level=info msg=\"One\\nTwo\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "One\nTwo")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info escapes \\r in strings"
      "ts=#t level=info msg=\"One\\rTwo\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "One\rTwo")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info escapes \\f in strings"
      "ts=#t level=info msg=\"One\\fTwo\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "One\fTwo")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info escapes \\t in strings"
      "ts=#t level=info msg=\"One\\tTwo\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "One\tTwo")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info escapes \" in strings"
      "ts=#t level=info msg=\"One\\\"Two\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info (string-translate "One@Two" #\@ #\"))
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info wraps a string containing '=' in quotes"
      "ts=#t level=info msg=\"One=Two\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "One=Two")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info wraps a string containing '\\' in quotes"
      "ts=#t level=info msg=\"One\\Two\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "One\\Two")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info doesn't allow 'level' key to be overwritten"
      "ts=#t level=info msg=\"This is a message\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "This is a message" '(level . critical))
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info doesn't allow 'ts' key to be overwritten"
      "ts=#t level=info msg=\"This is a message\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "This is a message" '(ts . something))
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-info doesn't allow 'msg' key to be overwritten"
      "ts=#t level=info msg=\"This is a message\"\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "This is a message" '(msg . suprise))
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-debug sets level to 'debug' and sets the timestamp and message"
      "ts=#t level=debug msg=message\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-debug "message")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-warning sets level to 'warning' and sets the timestamp and message"
      "ts=#t level=warning msg=message\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-warning "message")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-error sets level to 'error' and sets the timestamp and message"
      "ts=#t level=error msg=message\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-error "message")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-critical sets level to 'critical' and sets the timestamp and message"
      "ts=#t level=critical msg=message\n"
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-critical "message")
          (confirm-valid-timestamps (get-output-string port) ) ) ) )


(test "log-debug outputs while log-level is <= 10"
      (string-intersperse (list
        "ts=#t level=debug msg=message log-level=9"
        "ts=#t level=debug msg=message log-level=10\n")
        "\n")
      (let ((port (open-output-string)))
        (for-each (lambda (l)
                    (parameterize ((log-port port)
                                   (log-level l))
                      (log-debug "message" (cons 'log-level l))))
                  '(9 10 11))
        (confirm-valid-timestamps (get-output-string port) ) ) )


(test "log-info outputs while log-level is <= 20"
      (string-intersperse (list
        "ts=#t level=info msg=message log-level=19"
        "ts=#t level=info msg=message log-level=20\n")
        "\n")
      (let ((port (open-output-string)))
        (for-each (lambda (l)
                    (parameterize ((log-port port)
                                   (log-level l))
                      (log-info "message" (cons 'log-level l))))
                  '(19 20 21))
        (confirm-valid-timestamps (get-output-string port) ) ) )


(test "log-warning outputs while log-level is <= 30"
      (string-intersperse (list
        "ts=#t level=warning msg=message log-level=29"
        "ts=#t level=warning msg=message log-level=30\n")
        "\n")
      (let ((port (open-output-string)))
        (for-each (lambda (l)
                    (parameterize ((log-port port)
                                   (log-level l))
                      (log-warning "message" (cons 'log-level l))))
                  '(29 30 31))
        (confirm-valid-timestamps (get-output-string port) ) ) )


(test "log-error outputs while log-level is <= 40"
      (string-intersperse (list
        "ts=#t level=error msg=message log-level=39"
        "ts=#t level=error msg=message log-level=40\n")
        "\n")
      (let ((port (open-output-string)))
        (for-each (lambda (l)
                    (parameterize ((log-port port)
                                   (log-level l))
                      (log-error "message" (cons 'log-level l))))
                  '(39 40 41))
        (confirm-valid-timestamps (get-output-string port) ) ) )


(test "log-critical outputs while log-level is <= 50"
      (string-intersperse (list
        "ts=#t level=critical msg=message log-level=49"
        "ts=#t level=critical msg=message log-level=50\n")
        "\n")
      (let ((port (open-output-string)))
        (for-each (lambda (l)
                    (parameterize ((log-port port)
                                   (log-level l))
                      (log-critical "message" (cons 'log-level l))))
                  '(49 50 51))
        (confirm-valid-timestamps (get-output-string port) ) ) )


(test "log-info handles values of each of the supported types: string, symbol, integer, real and boolean"
      (string-intersperse (list
        "ts=#t level=info msg=message type=string value=hello"
        "ts=#t level=info msg=message type=symbol value=howdy"
        "ts=#t level=info msg=message type=integer value=-563"
        "ts=#t level=info msg=message type=integer value=563"
        "ts=#t level=info msg=message type=real value=-563.23"
        "ts=#t level=info msg=message type=real value=563.23"
        "ts=#t level=info msg=message type=boolean value=#t"
        "ts=#t level=info msg=message type=boolean value=#f\n")
        "\n")
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (log-info "message" (cons 'type "string") (cons 'value "hello"))
          (log-info "message" (cons 'type "symbol") (cons 'value 'howdy))
          (log-info "message" (cons 'type "integer") (cons 'value -563))
          (log-info "message" (cons 'type "integer") (cons 'value 563))
          (log-info "message" (cons 'type "real") (cons 'value -563.23))
          (log-info "message" (cons 'type "real") (cons 'value 563.23))
          (log-info "message" (cons 'type "boolean") (cons 'value #t))
          (log-info "message" (cons 'type "boolean") (cons 'value #f)))
        (confirm-valid-timestamps (get-output-string port) ) ) )


(test "log-info raises an error if a value is of an unsupported type"
      '(encode-value "unsupported type for value: ()")
      (let ((port (open-output-string)))
        (parameterize ((log-port port))
          (handle-exceptions ex
            (list (get-condition-property ex 'exn 'location)
                  (get-condition-property ex 'exn 'message))
            (log-info "message" (cons 'value '()))
            (confirm-valid-timestamps (get-output-string port) ) ) ) ) )

(test "log-level returns 10 if 'debug supplied"
      10
      (log-level 'debug) )


(test "log-level returns 20 if 'info supplied"
      20
      (log-level 'info) )


(test "log-level returns 30 if 'warning supplied"
      30
      (log-level 'warning) )


(test "log-level returns 40 if 'error supplied"
      40
      (log-level 'error) )


(test "log-level returns 50 if 'critical supplied"
      50
      (log-level 'critical) )


(test "log-level returns supplied number"
      (list 0 1 5 10 15 20 30 40 50 60 100)
      (map log-level (list 0 1 5 10 15 20 30 40 50 60 100) ) )


(test "log-level raises an error if unknown symbol supplied"
      '(log-level "unsupported value: fred")
      (handle-exceptions ex
        (list (get-condition-property ex 'exn 'location)
              (get-condition-property ex 'exn 'message))
        (log-level 'fred) ) )

