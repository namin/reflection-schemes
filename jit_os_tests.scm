(define (test)
  (define f6 (factorial_process 6))
  (define j6 (jit! f6))
  (step* (list j6 f6))
  f6 ;; ok
  (repeat  60 (lambda () (run f6)))
  (run j6)
  f6 ;; not right
  )
