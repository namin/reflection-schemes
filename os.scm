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
      (let* ((process (car processes))
             (process (upd! process ':status (lambda (old) ':running) #f)))
        (run process)
        (if (get (get process ':env) ':done #f)
            (begin
              (upd! process ':status (lambda (old) ':terminated))
              (cdr processes))
            (begin
              (upd! process ':status
                    (lambda (status)
                      (if (eq? ':running status)
                          ':ready
                          status)))
              (append (cdr processes) (list process)))))))

(define (step* processes)
  (if (null? processes)
      'done
      (step* (step processes))))
