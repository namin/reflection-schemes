(define (metalang-process exp)
  (dict `((:env . ,(dict '()))
          (:exp . ,exp)
          (:run . ,meta-ev))))

(eg
 (run* (metalang-process '(begin (set! :result 2) (set! :done #t))))
 2)

(eg
 (run* (metalang-process '(begin (set! :result 3) (set! :done #t))))
 3)

(eg
 (run* (metalang-process '(begin 1 (set! :result 3) (set! :done #t))))
 3)

(eg
 (run* (metalang-process '(begin (begin 1 (set! :result 3)) (set! :done #t))))
 3)

(eg
 (run* (metalang-process '(begin (set! :result (begin 1 2 3)) (set! :done #t))))
 3)

(eg
 (run* (metalang-process '(begin (set! x 1) (set! :result x) (set! :done #t))))
 1)
