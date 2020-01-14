(define scheduled '())
(define back-to-os! (lambda () '()))

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
  (get process '(:status) ':blocked)
  (back-to-os!))

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
               (begin
                 (upd! process '(:status) ':terminated)
                 (let ((caller (get process '(:caller) #f)))
                   (if caller
                       (upd! caller '(:status) ':ready))))
               (begin
                 (if (eq? ':running (get process '(:status)))
                     (upd! process '(:status) ':ready))
                 (schedule process))))
          ((eq? ':blocked status)
           (schedule process))
          (else (error 'step (format "unexpected status ~a" status)))))))

(define (step*)
  (call/cc
   (lambda (k)
     (set! back-to-os (lambda (k) (k '())))
     (if (done?)
         'done
         (begin
           (step)
           (step*))))))
