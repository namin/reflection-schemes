(define (metalang-process exp)
  (dict `((:env . ,(dict '()))
          (:exp . ,exp)
          (:run . ,meta-ev))))

(eg
 (run* (metalang-process 1))
 1)

(eg
 (run* (metalang-process (begin 1 2 3)))
 3)

(eg
 (run* (metalang-process (begin (set! x 1) x)))
 1)
