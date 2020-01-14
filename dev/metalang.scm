(define (navigate-context xs exp)
  (if (null? xs)
      exp
      (if (existi exp (car xs))
          (navigate-context (cdr xs) (geti exp (car xs)))
          ':none)))

(define (orfun . args)
  (if (null? args)
      #f
      (if (car args)
          #t
          (apply orfun (cdr args)))))

;; meta-circular evaluator
(define meta-ev-exp
  '(begin
    (set! ctx (get this '(:ctx) '()))
    ;; Note: exp exists as an immutable variable in Chez Scheme?
    (set! e (navigate-context (reverse ctx) (get this '(:exp))))
    (if (eq? e ':none)
        (begin
          (set! ctx (cdr ctx))
          (set! e (navigate-context (reverse ctx) (get this '(:exp))))))
    (set! pending (get this '(:pending) '()))
    (set!
     next-ctx
     (if (null? ctx)
         '()
         (cons (+ 1 (car ctx)) (cdr ctx))))
    (if (symbol? e)
        (begin
          (set! result (get this (list ':env e)))
          (set! ctx next-ctx))
        (if (orfun (number? e) (boolean? e))
            (begin
              (set! result e)
              (set! ctx next-ctx))
            (if (orfun
                 (tagged? '+ e)
                 (tagged? '- e)
                 (tagged? '* e)
                 (tagged? '= e)
                 (tagged? '< e)
                 (tagged? 'not e)
                 (tagged? 'cons e)
                 (tagged? 'car e)
                 (tagged? 'cdr e)
                 (tagged? 'dict e)
                 (tagged? 'copy e)
                 (tagged? 'display e)
                 (tagged? 'newline e)
                 (tagged? 'list e)
                 (tagged? 'null? e)
                 (tagged? 'length e)
                 (tagged? 'reverse e)
                 (tagged? 'symbol? e)
                 (tagged? 'number? e)
                 (tagged? 'boolean? e)
                 (tagged? 'tagged? e)
                 (tagged? 'apply e)
                 (tagged? 'eval e)
                 (tagged? 'error e)
                 (tagged? 'existi e)
                 (tagged? 'geti e)
                 (tagged? 'orfun e)
                 (tagged? 'navigate-context e)
                 (tagged? 'format e))
                (if (= (length pending) (length (cdr e)))
                    (begin
                      (set! result
                            (apply
                             (eval (car e))
                             (reverse pending)))
                      (set! pending '())
                      (set! ctx next-ctx))
                    (set! ctx (cons 1 ctx)))
                (if (tagged? 'set! e)
                    (if (= (length pending) 1)
                        (begin
                          (set! x (geti e 1))
                          (set! v (geti pending 0))
                          (upd! this (list 'env x) v)
                          (set! pending '())
                          (set! ctx next-ctx))
                        (set! ctx (cons 2 ctx)))
                    (if (tagged? 'get e)
                        (if (= (length pending) (length (cdr e)))
                            (begin
                              (set! pending (cons 'get (reverse pending)))
                              (set! dict (geti pending 1))
                              (set! selector (geti pending 2))
                              (if (existsi e 3)
                                  (set! result (get dict selector (geti pending 3)))
                                  (set! result (get dict selector)))
                              (set! pending '())
                              (set! ctx next-ctx))
                            (set! ctx (cons 1 ctx)))
                        (if (tagged? 'upd! e)
                            (if (= (length pending) (length (cdr e)))
                                (begin
                                  (set! pending (cons 'upd! (reverse pending)))
                                  (set! dict (geti pending 1))
                                  (set! selector (geti pending 2))
                                  (set! val (geti pending 3))
                                  (upd! dict selector val)
                                  (set! pending '())
                                  (set! ctx next-ctx))
                                (set! ctx (cons 1 ctx)))
                            (if (tagged? 'quote e)
                                (begin
                                  (set! result (geti e 1))
                                  (set! ctx next-ctx))
                                (if (tagged? 'if e)
                                    (if (= (length pending) 1)
                                        (if (geti pending 0)
                                            (set! ctx (cons 2 ctx))
                                            (set! ctx (cons 3 ctx)))
                                        (if (= (length pending) 2)
                                            (begin
                                              (set! result (geti pending 0))
                                              (set! pending '())
                                              (set! ctx next-ctx))
                                            (set! ctx (cons 1 ctx))))
                                    (if (tagged? 'begin e)
                                        (if (= (length pending) (length (cdr e)))
                                            (begin
                                              (set! result (car pending))
                                              (set! pending '())
                                              (set! ctx next-ctx))
                                            (set! ctx (cons 1 ctx)))
                                        (if (tagged? 'this e)
                                            (begin
                                              (set! result this)
                                              (set! ctx next-ctx))
                                            (error 'evl (format "unknown eression ~a" e))))))))))))
    (if (orfun (not (null? ctx)) (not (null? pending)))
        (begin
          (upd! this '(:pending) (cons result pending))
          (upd! this '(:ctx) ctx))
        (begin
          (upd! this '(:pending) '())
          (upd! this '(:env :result) result)
          (upd! this '(:env :done) #t)))))

(define meta-ev
  (eval `(lambda (this) ,meta-ev-exp)))
