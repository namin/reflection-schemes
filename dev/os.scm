(define scheduled '())

(define (reset!)
  (set! scheduled '()))

(define (schedule process)
  (set! scheduled (append scheduled (list process))))

(define (pick!)
  (let ((process (car scheduled)))
    (set! scheduled (cdr scheduled))
    process))

(define (done?)
  (null? scheduled))

(define (suspend process)
  'TODO)

(define (step)
  (if (done?)
      (error 'step (format "no step to take!"))
      (let* ((process (pick!))
             (status (get process '(:status) ':ready))
             (run?
              (cond
                ((eq? ':ready status)
                 (upd! process '(:status) ':running)
                 #t)
                ((eq? ':blocked status)
                 #f)
                (else 'step (format "unexpected status ~a" status)))))
        (cond
          ((eq? ':ready status)
           ((get process '(:run)) process)
           (if (get process '(:env :done) #f)
               (upd! process '(:status) ':terminated)
               (begin
                 (if (eq? ':running (get process '(:status)))
                     (upd! process '(:status) ':ready))
                 (schedule process))))
          ((eq? :blocked status)
           (schedule process))
          (else (error 'step (format "unexpected status ~a" status)))))))

(define (step*)
  (if (done?)
      'done
      (begin
        (step)
        (step*))))
