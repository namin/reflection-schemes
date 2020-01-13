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


