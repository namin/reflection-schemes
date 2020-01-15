(define
  p-even?
  (lambda (env)
    (if (= (get env 'n) 0)
        (upd! env 'result #t)
        (begin
          (upd! env 'n (- (get env 'n) 1))
          (schedule (lambda () (p-odd? env)))))))

(define
  p-odd?
  (lambda (env)
    (if (= (get env 'n) 0)
        (upd! env 'result #f)
        (if (= (get env 'n) 1)
            (upd! env 'result #t)
            (begin
              (upd! env 'n (- (get env 'n) 1))
              (schedule (lambda () (p-even? env))))))))

(define (is-even? n)
  (let ((env (mk-env (list (cons 'n n)))))
    (let ((process (schedule (lambda () (p-even? env)))))
      (step*)
      (get env 'result))))

(reset!)
(eg (is-even? 0) #t)
(eg (is-even? 1) #f)
(eg (is-even? 2) #t)
(eg (is-even? 3) #f)
