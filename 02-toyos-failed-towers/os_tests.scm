(define (factorial-process n)
  (dict `((:env . ,(dict `((n . ,n) (:result . 1))))
          (:exp
           .
           (if (= n 0)
               (set! :done #t)
               (begin
                 (set! :result (* n :result))
                 (set! n (- n 1)))))
          (:run . ,ev))))

(eg
 (let ((f6 (factorial-process 6)))
   (schedule f6)
   (step*)
   (get f6 '(:env :result)))
 720)

(define (even?-process)
  (dict
   `((:env . ,(dict '()))
     (:exp
      .
      (if (= n 0)
          (begin
            (set! :result #t)
            (set! :done #t))
          (if (= n 1)
              (begin
                (set! :result #f)
                (set! :done #t))
              (begin
                (set! n (- n 2))
                ;; for tail-recursive, we can just stop here
                ;; but if we want to spawn, we must copy
                ;; otherwise, the statuses will clash
                (set! this-copy (copy (this)))
                (run this-copy)
                (set! :result (get this-copy '(:env :result)))))))
     (:run . ,ev))))

(define (test-even? n)
  (let ((p (even?-process)))
    (upd! p '(:env n) n)
    (schedule p)
    (step*)
    (get p '(:env :result))))

(eg (test-even? 0) #t)
(eg (test-even? 1) #f)
(eg (test-even? 2) #t)
(eg (test-even? 3) #f)

(define (parity?-process name b)
  (dict
   `((:name . ,name)
     (:env . ,(dict '()))
     (:exp
      .
      (begin
        (if (= n 0)
            (begin
              (set! :result ,b))
            (if (= n 1)
                (begin
                  (set! :result (not ,b)))
                (begin
                  (set! other (copy other))
                  (upd! other '(:env n) (- n 1))
                  (upd! other '(:resume) #f)
                  (run other)
                  (set! :result (get other '(:env :result))))))
        (set! :done #t)))
     (:run . ,ev))))

(define (test-odd? n)
  (let ((p0 (parity?-process 'even #t))
        (p1 (parity?-process 'odd #f)))
    (upd! p1 '(:env n) n)
    (upd! p0 '(:env other) p1)
    (upd! p1 '(:env other) p0)
    (schedule p1)
    (step*)
    (get p1 '(:env :result))))

(eg (test-odd? 0) #f)
(eg (test-odd? 1) #t)
(eg (test-odd? 2) #f)
(eg (test-odd? 3) #t)
(eg (test-odd? 4) #f)

(define (rec-factorial-process n)
  (dict `((:env . ,(dict `((n . ,n) (stack . (1)))))
          (:exp
           .
           (if (= n 0)
               (if (null? (cdr stack))
                   (begin
                     (set! :result (car stack))
                     (set! :done #t))
                   (set! stack
                         (cons (* (car stack) (car (cdr stack)))
                               (cdr (cdr stack)))))
               (begin
                 (set! stack (cons n stack))
                 (set! n (- n 1)))))
          (:run . ,ev))))

(eg
 (let ((f6 (rec-factorial-process 6)))
   (schedule f6)
   (step*)
   (get f6 '(:env :result)))
 720)
