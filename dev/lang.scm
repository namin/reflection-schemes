(define (evl this exp ctx)
  (define (evli exp i)
    (evl this (geti exp i) (cons i ctx)))
  (cond ((symbol? exp)
         (get this `(:env ,exp)))
        ((or (number? exp) (boolean? exp))
         exp)
        ((or
          (tagged? '+ exp)
          (tagged? '- exp)
          (tagged? '* exp)
          (tagged? '= exp))
         (apply
          (eval (car exp))
          (mapi (lambda (i e) (evli exp (+ 1 i))) (cdr exp))))
        ((tagged? 'set! exp)
         (let ((x (geti exp 1))
               (v (evli exp 2)))
           (upd! this `(:env ,x) v)))
        ((tagged? 'get exp)
         (let ((dict (evli exp 1))
               (selector (evli exp 2)))
           (if (existsi exp 3)
               (get dict selector (evli exp 3))
               (get dict selector))))
        ((tagged? 'upd! exp)
         (let ((dict (evli exp 1))
               (selector (evli exp 2))
               (val (evli exp 3)))
           (upd! dict selector val)))
        ((tagged? 'quote exp)
         (geti exp 1))
        ((tagged? 'if exp)
         (if (evli exp 1)
             (evli exp 2)
             (evli exp 3)))
        ((tagged? 'begin exp)
         (last (mapi (lambda (i e) (evli exp (+ 1 i))) (cdr exp))))
        ((tagged? 'run exp)
         (let ((p (evli exp 1)))
           (upd! p '(:caller) this)
           (upd! this '(:context) ctx)
           (schedule p)
           (suspend this)))
        (else
         (error 'evl (format "unknown expression ~a" exp)))))
