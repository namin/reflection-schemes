;; this is just a tower of environments for now
(define (metaenvtower-ev-cases end)
  `(begin
     (set! _envs (get _this '(:envs) (list (get _this '(:env)))))
     (set! _level (get _this '(:level) 0))
     (if (tagged? 'reify _e)
         (begin
           (if (not (existsi _envs (+ _level 1)))
               (upd! _this '(:envs) (append _envs (list (dict '())))))
           (upd! _this '(:env) (geti (get _this '(:envs)) (+ _level 1)))
           (upd! _this '(:level) (+ _level 1))
           (set! _result (+ _level 1))
           (set! _ctx _next-ctx))
         (if (tagged? 'reflect _e)
             (begin
               (if (<= _level 0)
                   (error 'tower-evl (format "reflect cannot go below zero levels")))
               (upd! _this '(:env) (geti (get _this '(:envs)) (- _level 1)))
               (upd! _this '(:level) (- _level 1))
               (set! _result (- _level 1))
               (set! _ctx _next-ctx))
             (if (tagged? 'up _e)
                 (begin
                   (set! _x (geti _e 1))
                   (if (not (symbol? _x))
                       (error 'up (format "up takes a variable, not ~a" _x))
                       (begin
                         (if (not (existsi _envs (+ _level 1)))
                             (error 'up (format "level ~a does not exists" (+ _level 1))))
                         (set! _result (get (geti _envs (+ _level 1)) (list _x)))
                         (set! _ctx _next-ctx))))
                 ,end)))))
(define metaenvtower-ev-exp
  (meta-ev-exp metaenvtower-ev-cases))
(define metaenvtower-ev (meta-setup metaenvtower-ev-exp))
