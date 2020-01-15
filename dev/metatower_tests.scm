(define (metatower-process exp)
  (dict `((:env . ,(dict '()))
          (:exp . ,exp)
          (:run . ,metatower-ev))))

(eg
 (run* (metatower-process
        '(begin
           (set! x 3)
           (set! :result x)
           (set! :done #t))))
 3)

(eg
 (run* (metatower-process
        '(begin
           (set! :result 1)
           (set! :done #t)
           (reify)
           (reflect))))
 1)

(eg
 (run* (metatower-process
        '(begin
           (reify)
           (display "hello from meta")
           (newline)
           (reflect)
           (display "hello from obj")
           (newline)
           (set! :result 1)
           (set! :done #t))))
 1)

(eg
 (run* (metatower-process
        '(begin
           (reify)
           (reflect)
           (set! :result 1)
           (set! :done #t))))
 1)

(eg
 (run* (metatower-process
        '(begin
           (set! x 3)
           (set! :result x)
           (reify)
           (reflect)
           (set! :done #t))))
 3)

(eg
 (run* (metatower-process
        '(begin
           (set! x 3)
           (reify)
           (set! x 4)
           (reflect)
           (set! :result x)
           (set! :done #t))))
 3)

(eg
 (run* (metatower-process
        '(begin
           (set! x 3)
           (reify)
           (set! x 4)
           (reflect)
           (set! :result (up x))
           (set! :done #t))))
 4)

(eg
 (run* (metatower-process
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

(eg_TODO
 (run* (metatower-process
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

