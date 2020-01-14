(load "eg.scm")

(define (test_load fn)
  (format #t ";; LOADING ~a\n" fn)
  (load fn))

(test_load "lang_tests.scm")
(test_load "os_tests.scm")
(test_load "metalang_tests.scm")
(test_load "tower_tests.scm")
(test_load "metatower_tests.scm")
