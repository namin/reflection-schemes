(define (top-process name exp . env)
  (dict `((:env . ,(dict env))
          (:exp . ,exp)
          (:run . ,(lambda (process) (format #t "running ~a...\n" name))))))

(define (top-eval exp . env)
  (evl (apply top-process 'top exp env) exp '()))

(eg
 (top-eval '(+ 1 2))
 3)

(eg
 (top-eval '(begin 1 2 3))
 3)

(eg
 (top-eval '(begin (set! x 3) 3))
 3)

(eg
 (top-eval '(begin (run p) 3) (cons 'p (top-process 'p 1)))
 3)

(reset!)
