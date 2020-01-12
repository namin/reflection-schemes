;; A process is a dictionary containing keys:
;; - :exp, a program step
;; - :env, a key-value store that, for `imp`, maps directly to variable-value store in the program.
;; - :eval, a Scheme procedure taking the self process, the :exp and the :env. Defaults to `imp`'s `evl`.

;; The `os` adds a key :status to a process which can be:
;; - :ready, when a process is ready to be ran for a step.
;; - :running, when a process is selected to run for a step.
;; - :blocked, when a process suspends waiting for another process to complete.
;; - :terminated, when after a step, a process has the special key :done set to #t in its :env.
;; The `os` steps through the processes FIFO, re-queining after each step.

;; The impure API allows processes to add processes to the queue.

(define (run process)
  (call/cc
   (lambda (k)
     (let* ((jump (lambda (env) (upd! process ':env (lambda (old) env)) (k env)))
            (process (cons (cons ':suspend! jump) process)) ;; don't make the binding eternal!
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

(define alive-processes '())
(define (add-alive-process! process)
  (set! alive-processes (append alive-processes (list process))))

(define (step!)
  (if (null? alive-processes)
      '()
      (let* ((processes alive-processes)
             (_ (set! alive-processes '()))
             (processes (step processes)))
        (set! alive-processes (append alive-processes processes))
        alive-processes)))

(define (step*!)
  (if (null? alive-processes)
      'done
      (begin
        (step!)
        (step*!))))

(define (block! process-to-block process-to-terminate)
  (if (not (eq? ':terminated (get process-to-terminate ':status #f)))
      (upd! process-to-block
            ':status
            (lambda (old)
              (if (eq? old ':terminated)
                  old
                  (begin
                    (if (not (memq process-to-terminate alive-processes))
                        (add-alive-process! process-to-terminate))
                    (add-alive-process! (unblock-monitor process-to-block process-to-terminate))
                    ':blocked))))))

(define (unblock-monitor process-blocked process-to-terminate)
  (full-copy
   `((:eval
      .
      ,(lambda (this exp env)
         (let ((status-to-terminate (get process-to-terminate ':status #f))
               (status-blocked (get process-blocked ':status)))
           (if (eq? ':blocked status-blocked)
               (if (eq? ':terminated status-to-terminate)
                   (begin
                     (upd! process-blocked ':status (lambda (old) ':ready))
                     (upd! env ':done (lambda (old) #t)))
                   ;; still blocked
                   )
               ;; nothing to do
               (upd! env ':done #t)))
         env))
     (:exp . ())
     (:env . ((:done . #f))))))

(define (run-only process)
  (set! alive-processes (list process))
  (step*!)
  (get (get process ':env) ':result))

(define (run-program-once exp)
  (run-only (full-copy
             `((:exp . (begin
                         (set! result ,exp)
                         (set! :done #t)
                         result))
               (:env . ((result . :none)))))))
