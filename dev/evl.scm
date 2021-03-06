(define (lookup x env)
  (cond
   ((null? env)
    (error 'lookup (format "unbound variable ~a" x)))
   ((eq? x (caar env))
    (car env))
   (else (lookup x (cdr env)))))

(define (extend-env xs vs env)
  (append (map cons xs vs) env))

(define (evl0 f)
  (define top (mk-process (lambda (process) 'done)))
  (define evl
    (driver-process
     top
     (lambda (exp env)
       (cond
        ((number? exp) exp)
        ((boolean? exp) exp)
        ((symbol? exp) (cdr (lookup exp env)))
        ((eq? (car exp) 'if)
         (if (call evl (cadr exp) env)
             (call evl (caddr exp) env)
             (call evl (cadddr exp) env)))
        ((eq? (car exp) 'lambda)
         `(closure ,@(cdr exp) ,env))
        ((eq? (car exp) '*)
         (apply * (map (lambda (x) (call evl x env)) (cdr exp))))
        ((eq? (car exp) '-)
         (apply - (map (lambda (x) (call evl x env)) (cdr exp))))
        ((eq? (car exp) '=)
         (apply = (map (lambda (x) (call evl x env)) (cdr exp))))
        (else
         (let ((f (call evl (car exp) env))
               (vs (map (lambda (x) (call evl x env)) (cdr exp))))
           (if (eq? (car f) 'closure)
               (let ((body (caddr f))
                     (xs (cadr f))
                     (envf (cadddr f)))
                 (call evl body (extend-env xs vs envf)))
               (error 'evl (format "unapplicable ~a" f)))))))))

  (set! evl (f evl))

  (lambda (exp env)
    (let ((result (call evl exp env)))
      (schedule top)
      (step*)
      result)))

(define evl (evl0 (lambda (x) x)))
