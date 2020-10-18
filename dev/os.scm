(define scheduled '())

(define (reset!)
  (set! scheduled '()))

(define (schedule process)
  (upd! process 'status 'ready)
  (set! scheduled (append scheduled (list process)))
  process)

(define (wait caller callee)
  (upd! callee 'callers (cons caller (get callee 'callers '())))
  (upd! caller 'callees (cons callee (get caller 'callees '())))
  (upd! caller 'status 'blocked)
  (step*))

(define (within-wait caller callee resume)
  (schedule callee)
  (wait caller callee)
  (upd! caller 'status 'ready)
  (resume caller))

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
           (run process (get process 'fun) process)
           (upd! process 'status 'terminated)
           (for-each
            (lambda (caller)
              (let ((callees (remq process (get caller 'callees))))
                (upd! caller 'callees callees)
                (if (and (null? callees) (eq? 'blocked (get caller 'status #f)))
                    (upd! caller 'status 'ready))))
            (get process 'callers '())))
          ((eq? 'blocked status)
           (schedule process))
          (else (error 'step (format "unexpected status ~a" status)))))))

(define (step*)
  (if (done?)
      'done
      (begin
        (step)
        (step*))))
