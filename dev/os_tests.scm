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
              (upd! env 'result result))))))

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

(define (driver top f)
  (let ((env (mk-env '())))
    (lambda args
      (let* ((this (mk-process
                    (lambda (process) (upd! env 'result (apply f args)))))
             (super (get env 'this #f)))
        (upd! env 'this this)
        (schedule this)
        (if super
            (begin
              (wait super this)
              (upd! env 'this super))
            (wait top this))
        (get env 'result)))))

(define (fib-1)
  (define top (mk-process (lambda (process) 'done)))
  (define
    fib
    (driver top
     (lambda (n)
       (if (<= n 1)
           n
           (+ (fib (- n 1))
              (fib (- n 2)))))))

  (lambda (n)
    (let ((result (fib n)))
      (schedule top)
      (step*)
      result)))

(test-fib (fib-1))

(define (driver-process top f)
  (let ((env (mk-env '())))
    (lambda args
      (let* ((this (mk-process
                    (lambda (process) (upd! env 'result (apply f args)))))
             (super (get env 'this #f)))
        (upd! this 'env env)
        (upd! env 'this this)
        (schedule this)
        (if super
            (begin
              (wait super this)
              (upd! env 'this super))
            (wait top this))
        this))))

(define (call f . args)
  (let ((this (apply f args)))
    (gets this '(env result))))

(define (trace-process name f)
  (let ((indent ""))
    (lambda args
      (format #t "~a calling ~a\n" indent (cons name args))
      (set! indent (string-append indent " "))
      (let ((result (apply f args)))
        (string-truncate! indent (- (string-length indent) 1))
        (format #t "~a done ~a\n" indent (cons name args))
        result))))

(define (fib-2)
  (define top (mk-process (lambda (process) 'done)))
  (define
    fib
    (driver-process top
     (lambda (n)
       (if (<= n 1)
           n
           (+ (call fib (- n 1))
              (call fib (- n 2)))))))

  (set! fib (trace-process 'fib fib))

  (lambda (n)
    (let ((result (call fib n)))
      (schedule top)
      (step*)
      result)))

(test-fib (fib-2))
