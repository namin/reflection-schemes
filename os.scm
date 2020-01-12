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
             (status (get process ':status ':ready))
             (process
              (cond
                ((eq? ':ready status)
                 (upd! process ':status (lambda (old) ':running) #f))
                ((eq? ':block status)
                 #f)
                ((eq? ':running status)
                 (error 'step (format "process already running")))
                ((eq? ':terminated status)
                 (error 'step (format "process already terminated")))
                (else
                 (error 'step (format "unknown process status ~a" status))))))
        (if process
            (begin
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
                    (append (cdr processes) (list process)))))
            ;; warning: step* will loop if all processes are blocked
            (append (cdr processes) (list process))))))

(define (step* processes)
  (if (null? processes)
      'done
      (step* (step processes))))
