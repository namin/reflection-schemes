(define (metatower-ev-cases end)
  `(begin
     (if (tagged? 'reify _e)
         (begin
           (set! _meta (get _this '(:meta) #f))
           (if (not _meta)
               (set! _meta (dict (list (cons ':env (dict (list
                                                          (cons ':exp (get _this '(:exp)))
                                                          (cons ':env (get _this '(:env))))))
                                       (cons ':obj _this)
                                       (cons ':exp (get _this '(:meta-exp) metatower-ev-exp))
                                       (cons ':run (get _this '(:run)))
                                       (cons ':ctx '())
                                       (cons ':stack '())
                                       (cons ':history (dict '()))))))
           (set! _result ':reify)
           (upd! _this '(:ctx) _next-ctx)
           (set! _ctx '())
           (set! _this _meta)
           (upd! (this) '(:cur) _this))
         (if (tagged? 'reflect _e)
             (begin
               (set! _this (get _this '(:obj) _this))
               (upd! (this) '(:cur) _this)
               (set! _result ':reflect)
               (set! _ctx (get _this '(:ctx)))
               (set! _ctx
                     (if (null? _ctx)
                         '()
                         (cons (+ 1 (car _ctx)) (cdr _ctx)))))
             (if (tagged? 'up _e)
                 (begin
                   (set! _x (geti _e 1))
                   (if (not (symbol? _x))
                       (error 'up (format "up takes a variable, not ~a" _x))
                       (begin
                         (set! _meta (get _this '(:meta) #f))
                         (if (not _meta)
                             (error 'up (format "level ~a does not exists" (+ _level 1))))
                         (set! _result (get _meta (list ':env _x)))
                         (set! _ctx _next-ctx))))
                 ,end)))))
(define metatower-ev-exp
  (meta-ev-exp metatower-ev-cases))
(define metatower-ev
  (eval `(lambda (process)
           (let ((this (lambda () process)))
             ,metatower-ev-exp (lambda (x) x)))))
