(define (top-eval exp)
  (ev (dict `((:exp . ,exp) (:env . ,(dict '()))))))

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
 (top-eval
  '(begin
     (set! d (dict '((a . 1) (b . 2))))
     (upd! d '(a) 3)
     (get d '(a))))
 3)

(eg
 (top-eval '(not #t))
 #f)
