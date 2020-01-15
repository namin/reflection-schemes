(define scheduled '())
(define continuation (lambda (x) x))

(define (reset!)
  (set! scheduled '())
  (set! continuation (lambda (x) x)))

(define (schedule process)
  (upd! process 'status 'ready)
  (set! scheduled (append scheduled (list process)))
  process)

(define (wait caller callee)
  (call/cc
   (lambda (k)
     (upd! callee 'callers (cons caller (get callee 'callers '())))
     (upd! caller 'callees (cons callee (get caller 'callees '())))
     (upd! caller 'status 'blocked)
     (upd! caller 'resume (lambda () (k 'resume)))
     (step*))))

(define (pick!)
  (let ((process (car scheduled)))
    (set! scheduled (cdr scheduled))
    process))

(define (done?)
  (null? scheduled))

(define (run process f . args)
  (apply f args))

(define (step)
  (if (done?)
      (error 'step (format "no step to take!"))
      (let* ((process (pick!))
             (status (get process 'status)))
        (cond
          ((eq? 'ready status)
           (upd! process 'status 'running)
           (let ((resume (get process 'resume #f)))
             (if resume
                 (begin
                   (upd! process 'resume #f)
                   (run process resume))
                 (run process (get process 'fun) process))
             (upd! process 'status 'terminated)
             (for-each
               (lambda (callee)
                 (let ((callers (remq process (get callee 'callers))))
                   (upd! callee 'callers callers)
                   (if (and (null? callers) (eq? 'blocked (get callee 'status #f)))
                       (upd! callee 'status 'ready))))
               (get process 'callees '()))))
          ((eq? 'blocked status)
           (schedule process))
          (else (error 'step (format "unexpected status ~a" status)))))))

(define (step*)
  (if (done?)
      'done
      (begin
        (step)
        (step*))))
