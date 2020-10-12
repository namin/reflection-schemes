(define (schedule-fun p env)
  (let ((this (mk-process p)))
    (upd! this 'env env)
    (schedule this)
    this))

(define (fun* p args)
  (let ((this (schedule-fun p (mk-env args))))
    (step*)
    (gets this '(env result))))

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
