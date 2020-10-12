(load "load_lib.scm")
(load "eg.scm")

(define (test_load fn)
  (format #t ";; LOADING ~a\n" fn)
  (load fn))

(test_load "os_tests.scm")
(test_load "evl_tests.scm")
