(define (tower-process exp)
  (dict `((:env . ,(dict '()))
          (:exp . ,exp)
          (:run . ,tower-ev))))

(eg
 (run* (tower-process
        '(begin
           (set! x 3)
           (set! :result x)
           (set! :done #t))))
 3)

(eg
 (run* (tower-process
        '(begin
           (set! x 3)
           (set! :result x)
           (reify)
           (reflect)
           (set! :done #t))))
 3)

(eg
 (run* (tower-process
        '(begin
           (set! x 3)
           (reify)
           (set! x 4)
           (reflect)
           (set! :result x)
           (set! :done #t))))
 3)

(eg
 (run* (tower-process
        '(begin
           (set! x 3)
           (reify)
           (set! x 4)
           (reflect)
           (set! :result (up x))
           (set! :done #t))))
 4)

(eg
 (run* (tower-process
        '(begin
           (set! x 3)
           (reify)
           (set! x 4)
           (reflect)
           (set! x 2)
           (reify)
           (set! x (+ x 1))
           (reflect)
           (set! :result (up x))
           (set! :done #t))))
 5)

(eg
 (run* (tower-process
        '(begin
           (set! x 3)
           (reify)
           (reify)
           (set! x 4)
           (reflect)
           (set! x 2)
           (reify)
           (set! x (+ x 1))
           (reflect)
           (set! x (up x))
           (reflect)
           (set! :result (up x))
           (set! :done #t))))
 5)

