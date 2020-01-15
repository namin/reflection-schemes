(define (metatower-ev-cases end)
  `(begin
     (if (tagged? 'reify _e)
         (begin
           (upd! _this '(:ctx) _next-ctx)
           (upd! _this '(:stack) (cons ':reify _stack))
           (upd! _this '(:level) (get process '(:level) 0))
           (upd! process '(:dump)
                 (cons
                  _this
                  (get process '(:dump) '())))
           (set! _level (+ 1 (get process '(:level))))
           (set! _meta
                 (dict (list (cons ':env (dict (list
                                                (cons 'process process)
                                                (cons ':exp (get _this '(:exp)))
                                                (cons ':env (get _this '(:env))))))
                             (cons ':obj _this)
                             (cons ':exp (get _this '(:meta-exp) metatower-ev-exp))
                             (cons ':run (get _this '(:run)))
                             (cons ':level _level)
                             (cons ':ctx '())
                             (cons ':stack '())
                             (cons ':history (dict '())))))
           (upd! _meta '(:env :this) _this)
           (upd! process '(:env process) _meta)
           (upd! process '(:env process :dump) (get process '(:dump)))
           (set! _this _meta)
           (set! _ctx ':none)
           (set! _result ':none))
         (if (tagged? 'reflect _e)
             (begin
               (set! _dump (get process '(:env process :dump)))
               (set! _obj (car _dump))
               (upd! process '(:dump) (cdr _dump))
               (set! _this _obj)
               (upd! _this '(:env :this) _this)
               (set! _ctx (get _this '(:ctx)))
               (set! _ctx _next-ctx)
               (set! _stack (get _this '(:stack)))
               (set! _result ':reflect))
             (if (tagged? 'up _e)
                 'TODO
                 ,end)))))
(define metatower-ev-exp
  (meta-ev-exp metatower-ev-cases))
(define metatower-ev (meta-setup metatower-ev-exp))
