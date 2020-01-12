(define (factorial_process n)
  (full-copy
   `((:exp
      .
      (begin
        (if (= n 0)
            (set! :done #t)
            (begin
              (set! result (* n result))
              (set! n (- n 1))))
        result))
     (:env . ((result . 1) (n . ,n))))))

(define (double_process p)
  (full-copy-but (list p)
   `((:exp
      .
      (begin
        (block p)
        (set! result (* 2 (get (get p ':env) ':result #f)))
        (set! :done #t)
        result))
     (:env . ((:result . #f) (p . ,p))))))

(eg
 (run (factorial_process 6))
 '((result . 6) (n . 5) (:result . 6) ))

(eg
 (let ((f6 (factorial_process 6)))
   (step* (list f6))
   (get (get f6 ':env) ':result))
 720)

(eg
 (let ((f6 (factorial_process 6))
       (f5 (factorial_process 5)))
   (step* (list f6 f5))
   (list
    (get (get f6 ':env) ':result)
    (get (get f5 ':env) ':result)))
 '(720 120))

(eg
 (let ((d6 (double_process (factorial_process 6))))
   (set! alive_processes (list d6))
   (step*!)
   (get (get d6 ':env) ':result))
 1440)
