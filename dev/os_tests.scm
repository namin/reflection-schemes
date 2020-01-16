(reset!)

(define (schedule-fun p env)
  (let ((this (mk-process p)))
    (upd! this 'env env)
    (schedule this)
    this))

(define (fun* p args)
  (let ((this (schedule-fun p (mk-env args))))
    (step*)
    (gets this '(env result))))

(define (is-even?-0)
  (define
    p-even?
    (lambda (this)
      (if (= (gets this '(env n)) 0)
          (upds! this '(env result) #t)
          (begin
            (upds! this '(env n) (- (gets this '(env n)) 1))
            (schedule-fun p-odd? (get this 'env))))))

  (define
    p-odd?
    (lambda (this)
      (if (= (gets this '(env n)) 0)
          (upds! this '(env result) #f)
          (if (= (gets this '(env n)) 1)
              (upds! this '(env result) #t)
              (begin
                (upds! this '(env n) (- (gets this '(env n)) 1))
                (schedule-fun p-even? (get this 'env)))))))

  (define (is-even? n)
    (fun* p-even? (list (cons 'n n))))

  is-even?)

(define (test-is-even? is-even?)
  (eg (is-even? 0) #t)
  (eg (is-even? 1) #f)
  (eg (is-even? 2) #t)
  (eg (is-even? 3) #f))

(test-is-even? (is-even?-0))

(define (fib-0)
  (define
    p-fib
    (lambda (this)
      (let ((env (get this 'env)))
        (if (<= (get env 'n) 1)
            (upd! env 'result (get env 'n))
            (let ((env1 (copy env))
                  (env2 (copy env))
                  (result 0))
              (upd! env1 'n (- (get env 'n) 1))
              (wait this (schedule-fun p-fib env1))
              (set! result (+ result (get env1 'result)))
              (upd! env2 'n (- (get env 'n) 2))
              (wait this (schedule-fun p-fib env2))
              (set! result (+ result (get env2 'result)))
              (upd! env'result result))))))

  (define (fib n)
    (fun* p-fib (list (cons 'n n))))

  fib)

(define (test-fib fib)
  (eg (fib 0) 0)
  (eg (fib 1) 1)
  (eg (fib 2) 1)
  (eg (fib 3) 2)
  (eg (fib 5) 5))

(test-fib (fib-0))

(define (driver f)
  (let ((env (mk-env '())))
    (lambda args
      (let* ((this (mk-process
                    (lambda (process) (upd! env ':result (apply f args)))))
             (super (get env 'this #f)))
        (upd! env 'this this)
        (schedule this)
        (if super
            (begin
              (wait super this)
              (upd! env 'this super)))
        (step*)
        (get env ':result)))))


(define (fib-1)
  (define
    fib
    (driver
     (lambda (n)
       (if (<= n 1)
           n
           (+ (fib (- n 1))
              (fib (- n 2)))))))

  fib)

(test-fib (fib-1))
