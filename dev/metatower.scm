;; this is just a tower of environments for now
(define (metatower-ev-cases end)
  `(begin
     (set! _envs (get this '(:envs) (list (get this '(:env)))))
     (set! _level (get this '(:level) 0))
     (if (tagged? 'reify _e)
         (begin
           (if (not (existsi _envs (+ _level 1)))
               (upd! this '(:envs) (append _envs (list (dict '())))))
           (upd! this '(:env) (geti (get this '(:envs)) (+ _level 1)))
           (upd! this '(:level) (+ _level 1)))
         (if (tagged? 'reflect _e)
             (begin
               (if (<= _level 0)
                   (error 'tower-evl (format "reflect cannot go below zero levels")))
               (upd! this '(:env) (geti (get this '(:envs)) (- _level 1)))
               (upd! this '(:level) (- _level 1)))
             (if (tagged? 'up _e)
                 (begin
                   (set! _x (geti _e 1))
                   (if (not (symbol? _x))
                       (error 'up (format "up takes a variable, not ~a" _x))
                       (begin
                         (if (not (existsi _envs (+ _level 1)))
                             (error 'up (format "level ~a does not exists" (+ _level 1))))
                         (get (geti _envs (+ _level 1)) (list x)))))
                 ,end)))))
(define metatower-ev-exp
  (meta-ev-exp metatower-ev-cases))
(define metatower-ev
  (eval `(lambda (this) ,metatower-ev-exp)))
