(define (test1)
  (define f6 (factorial_process 6))
  (define t6 (tracer f6))

  (eg
   (begin
     (step* (list t6))
     (get (get t6 ':env) ':trace))
   '(((result . 1) (n . 6))
     ((:result . 6) (result . 6) (n . 5))
     ((:result . 30) (result . 30) (n . 4))
     ((:result . 120) (result . 120) (n . 3))
     ((:result . 360) (result . 360) (n . 2))
     ((:result . 720) (result . 720) (n . 1))
     ((:result . 720) (result . 720) (n . 0))
     ((:done . #t) (:result . 720) (result . 720) (n . 0)))))

(test1)
