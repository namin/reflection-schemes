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

(define (suspend process k)
  (upd! process '(:resume) (lambda () (k '()))))

(define (step)
  (if (done?)
      (error 'step (format "no step to take!"))
      (let* ((process (pick!))
             (status (get process '(:status) ':ready)))
        (cond
          ((eq? ':ready status)
           (upd! process '(:status) ':running)
           (let ((resume (get process '(:resume) #f)))
             (if resume
                 (begin
                   (upd! process '(:resume) #f)
                   (resume))
                 ((get process '(:run)) process)))
           (if (get process '(:env :done) #f)
               (begin
                 (upd! process '(:status) ':terminated)
                 (let ((caller (get process '(:caller) #f)))
                   (if (and caller (eq? ':blocked (get caller '(:status) #f)))
                       (upd! caller '(:status) ':ready))))
               (begin
                 (if (eq? ':running (get process '(:status)))
                     (upd! process '(:status) ':ready))
                 (schedule process))))
          ((eq? ':blocked status)
           (schedule process))
          (else (error 'step (format "unexpected status ~a" status)))))))

(define (step*)
  (if (done?)
      'done
      (begin
        (step)
        (step*))))

(define (run* . processes)
  (reset!)
  (for-each schedule processes)
  (step*)
  (get (car processes) '(:env :result)))

(define (debug-run* . processes)
  (reset!)
  (for-each schedule processes)
  (step*)
  (get (car processes) '(:env :result)))
