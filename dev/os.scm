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
  (call/cc
   (lambda (k)
     (schedule process)
     (upd! process '(:resume) (lambda () (k '())))
     ((get process '(:suspend))))))

(define (step)
  (call/cc
   (lambda (k)
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
                   ((eq? ':terminated status)
                    #f)
                   (else 'step (format "unexpected status ~a" status)))))
           (cond
             ((eq? ':ready status)
              (upd! process '(:suspend) (lambda () (k '())))
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
             ((eq? ':terminated status)
              'done)
             (else (error 'step (format "unexpected status ~a" status)))))))))

(define (step*)
  (if (done?)
      'done
      (begin
        (step)
        (step*))))
