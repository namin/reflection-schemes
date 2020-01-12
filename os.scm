(define (run process)
  (let ((env
         ((get process ':eval evl)
          (get process ':exp)
          (get process ':env))))
    (upd! process ':env (lambda (old) env))
    env))

(define (step processes)
  (if (null? processes)
      (error 'step "nothing to do")
      (let ((process (car processes)))
        (run process)
        (if (get (get process ':env) ':done #f)
            (cdr processes)
            (append (cdr processes) (list process))))))

(define (step* processes)
  (if (null? processes)
      'done
      (step* (step processes))))

(define (step-list processes acc)
  (if (null? processes)
      (reverse acc)
      (step-list (step processes) (cons processes acc))))
