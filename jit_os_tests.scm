(define f6 (factorial_process 6))
(define j6 (jit! f6))
(run j6)
(run f6)
