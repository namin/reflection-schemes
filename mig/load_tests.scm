(load "eg.scm")

(define (test_load fn)
  (format #t ";; LOADING ~a\n" fn)
  (load fn))

(test_load "mig_tests.scm")
