(define-syntax eg
  (syntax-rules ()
    ((_ tested-expression expected-result)
     (begin
       (format #t "Testing ~a\n" 'tested-expression)
       (let* ((expected expected-result)
              (produced tested-expression))
         (or (equal? expected produced)
             (begin
               (format #t "Failed: ~a~%Expected: ~a~%Computed: ~a~%"
                       'tested-expression expected produced)
               (error
                'eg
                (format "failed test ~a" 'tested-expression)))))))))

(define-syntax eg_TODO
  (syntax-rules ()
    ((_ tested-expression expected-result)
     (begin
       (format #t "TODO ~a\n" 'tested-expression)))))

(define (try thunk)
  (call/cc
    (lambda (k)
      (with-exception-handler
        (lambda (x) (k 'error))
        thunk))))

(define-syntax eg_error
  (syntax-rules ()
    ((_ tested-expression)
     (eg (try (lambda () tested-expression)) 'error))))
