(load "eg.scm")

(define (test_load fn)
  (format #t ";; LOADING ~a\n" fn)
  (load fn))

(load "os_tests.scm")
