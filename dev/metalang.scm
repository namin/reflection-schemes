(define (navigate-context xs exp)
  (if (null? xs)
      exp
      (if (existsi exp (car xs))
          (navigate-context (cdr xs) (geti exp (car xs)))
          ':none)))

(define (orfun . args)
  (if (null? args)
      #f
      (if (car args)
          #t
          (apply orfun (cdr args)))))

;; meta-circular evaluator
(define (meta-ev-exp more-cases)
  `(begin
    (set! _ctx (get this '(:ctx) '()))
    (set! _e (navigate-context (reverse _ctx) (get this '(:exp))))
    (set! _stack (get this '(:stack) '()))
    (set! _history (get this '(:history) (dict '())))
    (upd! this '(:history) _history)
    (if (eq? _e ':none)
        (begin
          (set! _ctx (cdr _ctx))
          (set! _e (navigate-context (reverse _ctx) (get this '(:exp))))))
    (set!
     _next-ctx
     (if (null? _ctx)
         '()
         (cons (+ 1 (car _ctx)) (cdr _ctx))))
    (set! _seen? (get this (list ':history _ctx) #f))
    (upd! this (list ':history _ctx) (+ 1 (if _seen? _seen? 0)))
    (set! _result ':none)
    (if (symbol? _e)
        (begin
          (set! _result (get this (list ':env _e)))
          (set! _ctx _next-ctx))
        (if (orfun (number? _e) (boolean? _e) (string? _e))
            (begin
              (set! _result _e)
              (set! _ctx _next-ctx))
            (if (orfun
                 (tagged? '+ _e)
                 (tagged? '- _e)
                 (tagged? '* _e)
                 (tagged? '= _e)
                 (tagged? '< _e)
                 (tagged? '<= _e)
                 (tagged? 'not _e)
                 (tagged? 'cons _e)
                 (tagged? 'car _e)
                 (tagged? 'cdr _e)
                 (tagged? 'dict _e)
                 (tagged? 'copy _e)
                 (tagged? 'display _e)
                 (tagged? 'newline _e)
                 (tagged? 'list _e)
                 (tagged? 'null? _e)
                 (tagged? 'length _e)
                 (tagged? 'reverse _e)
                 (tagged? 'symbol? _e)
                 (tagged? 'number? _e)
                 (tagged? 'boolean? _e)
                 (tagged? 'string? _e)
                 (tagged? 'eq? _e)
                 (tagged? 'tagged? _e)
                 (tagged? 'apply _e)
                 (tagged? 'eval _e)
                 (tagged? 'error _e)
                 (tagged? 'existsi _e)
                 (tagged? 'geti _e)
                 (tagged? 'orfun _e)
                 (tagged? 'navigate-context _e)
                 (tagged? 'format _e))
                (if _seen?
                    (begin
                      (set! _pending (reverse (take (length (cdr e)) _stack)))
                      (set! _stack (drop (length (cdr e)) _stack))
                      (set! _result
                            (apply
                             (eval (car _e))
                             _pending))
                      (set! _ctx _next-ctx))
                    (set! _ctx (cons 1 _ctx)))
                (if (tagged? 'set! _e)
                    (if _seen?
                        (begin
                          (set! _x (geti _e 1))
                          (set! _v (car _stack))
                          (set! _stack (cdr _stack))
                          (upd! this (list ':env _x) _v)
                          (set! _result _v)
                          (set! _ctx _next-ctx))
                        (set! _ctx (cons 2 _ctx)))
                    (if (tagged? 'get _e)
                        (if _seen?
                            (begin
                              (set! _pending (cons 'get (reverse (take (length (cdr e)) _stack))))
                              (set! _stack (drop (length (cdr e)) _stack))
                              (set! _dict (geti _pending 1))
                              (set! _selector (geti _pending 2))
                              (if (existsi _e 3)
                                  (set! _result (get _dict _selector (geti _pending 3)))
                                  (set! _result (get _dict _selector)))
                              (set! _ctx _next-ctx))
                            (set! _ctx (cons 1 _ctx)))
                        (if (tagged? 'upd! _e)
                            (if _seen?
                                (begin
                                  (set! _pending (cons 'upd! (reverse (take (length (cdr e)) _stack))))
                                  (set! _stack (drop (length (cdr e)) _stack))
                                  (set! _dict (geti _pending_rev 1))
                                  (set! _selector (geti _pending_rev 2))
                                  (set! _val (geti _pending_rev 3))
                                  (upd! _dict _selector _val)
                                  (set! _ctx _next-ctx))
                                (set! _ctx (cons 1 _ctx)))
                            (if (tagged? 'quote _e)
                                (begin
                                  (set! _result (geti _e 1))
                                  (set! _ctx _next-ctx))
                                (if (tagged? 'if _e)
                                    (if _seen?
                                        (if (= 1 _seen?)
                                            (begin
                                              (set! _condition (car _stack))
                                              (set! _stack (cdr stack))
                                              (if (_condition)
                                                  (set! _ctx (cons 2 _ctx))
                                                  (set! _ctx (cons 3 _ctx))))
                                            (begin
                                              (set! _result (car _stack))
                                              (set! _stack (cdr _stack))
                                              (set! _ctx _next-ctx)))
                                        (set! _ctx (cons 1 _ctx)))
                                    (if (tagged? 'begin _e)
                                        (if  _seen?
                                            (begin
                                              (set! _result (car _stack))
                                              (set! _stack (cdr _stack))
                                              (set! _ctx _next-ctx))
                                            (set! _ctx (cons 1 _ctx)))
                                        (if (tagged? 'this _e)
                                            (begin
                                              (set! _result this)
                                              (set! _ctx _next-ctx))
                                            ,(more-cases '(error 'evl (format "unknown expression ~a" _e)))))))))))))
    (upd! this '(:ctx) _ctx)
    (if (not (eq? _result ':none))
        (upd! this '(:stack) (cons _result _stack)))))

(define meta-ev
  (eval `(lambda (this) ,(meta-ev-exp (lambda (x) x)))))
