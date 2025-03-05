logfmt-logger
=============
A logging module using [logfmt](https://brandur.org/logfmt) for [Chicken Scheme](https://call-cc.org/).


Logfmt
-------
There isn't an offical or canonical description of _logfmt_ but the module is based on the following articles:
* [logfmt](https://brandur.org/logfmt)
* [Introduction to Logfmt](https://betterstack.com/community/guides/logging/logfmt/)
* [Logfmt Log Formatting](https://docs.appsignal.com/logging/formatting/logfmt.html)


Module Usage
------------

```
;; The output port for log entries is controlled by the 'log-port' parameter.
;; This defaults to (current-error-port) and therefore the following line is redundant.
(log-port (current-error-port))

;; The level at which log entries are output is controlled by the 'log-level' parameter.
;; The default is 30, warning

;; This would enable all log entries to be output
(log-level 0)

;; This would allow anything from 'level=debug' and up to output
(log-level 10)

;; This would allow anything from 'level=info' and up to output
(log-level 20)

;; This would allow anything from 'level=warning' and up to output
(log-level 30)

;; This would allow anything from 'level=error' and up to output
(log-level 40)

;; This would disable all the currently supported log functions from outputting
(log-level 100)


;; This would output a message of the form:
;;    ts=2025-03-04T13:13:51+0000 level=debug msg=hello\n
;; where ts is an ISO 8601 timestamp including the offset from UTC.
(log-debug "hello")

;; This would output a message of the form:
;;    ts=2025-03-04T13:13:51+0000 level=info msg="this is a message" tag=train dir=north\n
;; log-debug, log-info, log-warning, log-error can take a series of key value
;; pairs after the message.
(log-info "this is a message" (cons 'tag 'train) (cons 'dir "north"))

;; This would output a message of the form:
;;    ts=2025-03-04T13:13:51+0000 level=warning msg="a message" phrase="two birds..."\n
(log-warning "a message" (cons 'phrase "two birds..."))

;; This would output an error of the form:
;;    ts=2025-03-04T13:13:51+0000 level=error msg="an error" phrase="two birds..."\n
(log-error "an error" (cons 'phrase "two birds..."))
```



Requirements
------------
* Chicken Scheme 5.4+


Testing
-------
There is a testsuite in `tests/`.  To run it:

    $ csi tests/run


Licence
-------
Copyright (C) 2025 Lawrence Woodman <https://lawrencewoodman.github.io/>

This software is licensed under an MIT Licence.  Please see the file, [LICENCE.md](https://github.com/lawrencewoodman/logfmt-logger-egg/blob/master/LICENCE.md), for details.

