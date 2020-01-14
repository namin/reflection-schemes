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

(eg
 (run* (metalang-process '(begin (set! d (dict '((:foo . :bar)))) (set! :result (get d '(:foo))) (set! :done #t))))
 ':bar)

(eg
 (run* (metalang-process '(begin (set! d (dict '((:foo . :bar)))) (set! :result (get d '(:foo) ':miao)) (set! :done #t))))
 ':bar)

(eg
 (run* (metalang-process '(begin (set! :result (get (dict '()) '(foo) 1)) (set! :done #t))))
 1)

(eg
 (run* (metalang-process '(begin
                            (set! _seen? 1)
                            (set! :result (+ 1 (if _seen? _seen? 0)))
                            (set! :done #t))))
 2)

(eg_TODO
 (run* (metalang-process '(begin
                            (set! d '(dict '()))
                            (set! _seen? 1)
                            (upd! d '(:history) 2)
                            (set! :result (get d '(:history)))
                            (set! :done #t))))
 2)
