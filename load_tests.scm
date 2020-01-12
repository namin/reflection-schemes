(load "eg.scm")

(define (test_load fn)
  (format #t ";; LOADING ~a\n" fn)
  (load fn))

(test_load "data_tests.scm")
(test_load "imp_tests.scm")
(test_load "jit_tests.scm")
(test_load "os_tests.scm")
(test_load "jit_os_tests.scm")
(test_load "tracer_tests.scm")
