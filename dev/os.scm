(define scheduled '())

(define (reset!)
  (set! scheduled '()))

(define (schedule thunk)
  (let ((process (mk-process thunk)))
    (upd! process 'status 'ready)
    (set! scheduled (append scheduled (list process)))
    process))

(define (pick!)
  (let ((process (car scheduled)))
    (set! scheduled (cdr scheduled))
    process))

(define (done?)
  (null? scheduled))

(define (step)
  (if (done?)
      (error 'step (format "no step to take!"))
      (let* ((process (pick!))
             (status (get process 'status)))
        (cond
          ((eq? 'ready status)
           (upd! process 'status 'running)
           ((get process 'thunk)))
          ((eq? 'blocked status)
           (schedule process))
          (else (error 'step (format "unexpected status ~a" status)))))))

(define (step*)
  (if (done?)
      'done
      (begin
        (step)
        (step*))))
