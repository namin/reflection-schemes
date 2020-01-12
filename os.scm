(define (run process)
  (call/cc
   (lambda (k)
     (let* ((jump (lambda (env) (upd! process ':env (lambda (old) env)) (k env)))
            (process (upd! process ':suspend! (lambda (x) x) jump))
            (env
             ((get process ':eval evl)
              process
              (get process ':exp)
              (get process ':env))))
       (jump env)))))

(define (step processes)
  (if (null? processes)
      (error 'step "nothing to do")
      (let* ((process (car processes))
             (status (get process ':status ':ready))
             (process
              (cond
                ((eq? ':ready status)
                 (upd! process ':status (lambda (old) ':running) #f))
                ((eq? ':blocked status)
                 process)
                ((eq? ':running status)
                 (error 'step (format "process already running ~a" process)))
                ((eq? ':terminated status)
                 (error 'step (format "process already terminated ~a" process)))
                (else
                 (error 'step (format "unknown process status ~a" status))))))
        (if (not (eq? ':blocked (get process ':status)))
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

(define alive_processes '())
(define (add-alive-process! process)
  (set! alive_processes (append alive_processes (list process))))

(define (step!)
  (if (null? alive_processes)
      '()
      (let* ((processes alive_processes)
             (_ (set! alive_processes '()))
             (processes (step processes)))
        (set! alive_processes (append alive_processes processes))
        alive_processes)))

(define (step*!)
  (if (null? alive_processes)
      'done
      (begin
        (step!)
        (step*!))))

(define (block! process_to_block process_to_terminate)
  (if (not (eq? ':terminated (get process_to_terminate ':status #f)))
      (upd! process_to_block
            ':status
            (lambda (old)
              (if (eq? old ':terminated)
                  old
                  (begin
                    (if (not (memq process_to_terminate alive_processes))
                        (add-alive-process! process_to_terminate))
                    (add-alive-process! (unblock-monitor process_to_block process_to_terminate))
                    ':blocked))))))

(define (unblock-monitor process_blocked process_to_terminate)
  (full-copy
   `((:eval
      .
      ,(lambda (this exp env)
         (let ((status_to_terminate (get process_to_terminate ':status #f))
               (status_blocked (get process_blocked ':status)))
           (if (eq? ':blocked status_blocked)
               (if (eq? ':terminated status_to_terminate)
                   (begin
                     (upd! process_blocked ':status (lambda (old) ':ready))
                     (upd! env ':done (lambda (old) #t)))
                   ;; still blocked
                   )
               ;; nothing to do
               (upd! env ':done #t)))
         env))
     (:exp . ())
     (:env . ((:done . #f))))))
