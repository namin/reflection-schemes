(eg
 (lookup 'x '((x . 1) (y . 2)))
 '(x . 1))

(eg
 (lookup 'y '((x . 1) (y . 2)))
 '(y . 2))

;;(lookup 'z '((x . 1) (y . 2)))

(eg
 (extend-env '(x y z) '(1 2 3) '((x . 10)))
 '((x . 1) (y . 2) (z . 3) (x . 10)))

(eg
 (evl 1 '())
 1)

(eg
 (evl '(if #t 2 3) '())
 2)

(eg
 (evl '((lambda (x) x) 3) '())
 3)

(eg
 (evl '((lambda (x) (- x 1)) 3) '())
 2)

(define y
  '(lambda (fun)
     ((lambda (F)
        (F F))
      (lambda (F)
        (fun (lambda (x) ((F F) x)))))))

(eg
 (evl `((,y (lambda (f) (lambda (x) x))) 3) '())
 3)

(define (trace-process-factorial f)
  (let ((indent ""))
    (lambda args
      (let ((exp (car args))
            (env (cadr args)))
        (if (and (pair? exp) (eq? (car exp) 'factorial))
            (begin
              (format #t "~a evaluating ~a with ~a\n" indent exp (lookup 'n env))
              (set! indent (string-append indent " "))
              (let ((result (apply f args)))
                (string-truncate! indent (- (string-length indent) 1))
                (format #t "~a done ~a with ~a: ~a\n" indent exp (lookup 'n env) (gets result '(env result)))
                result))
            (apply f args))))))


(define evl-trace-factorial (evl0 trace-process-factorial))
(define factorial
  '(lambda (factorial)
     (lambda (n)
       (if (= n 0)
           1
           (* n (factorial (- n 1)))))))

(eg
 (evl-trace-factorial `((,y ,factorial) 6) '())
 720)

(eg
 (add-speculation factorial)
 '(lambda (factorial)
    (lambda (n)
      (speculate 0 0 (if (= n 0) 1 (* n (factorial (- n 1))))))))

(define (trace-process-speculation f)
  (let ((indent ""))
    (lambda args
      (let ((exp (car args))
            (env (cadr args)))
        (if (and (pair? exp) (eq? (car exp) 'speculate))
            (begin
              (format #t "~a speculating ~a ~a\n" indent (cadr exp) (caddr exp))
              (set! indent (string-append indent " "))
              (let ((result (apply f args)))
                (string-truncate! indent (- (string-length indent) 1))
              (format #t "~a done speculating ~a ~a\n" indent (cadr exp) (caddr exp))
                result))
            (apply f args))))))

(define evl-trace-speculation (evl0 trace-process-speculation))

(eg
 (evl (add-speculation `((,y ,factorial) 6)) '())
 720)

(eg
 (evl-trace-speculation (add-speculation `((,y ,factorial) 6)) '())
 720)
