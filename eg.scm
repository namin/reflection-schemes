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
               (error 'eg
                      (format "Failed: ~a~%Expected: ~a~%Computed: ~a~%"
                              'tested-expression expected produced)))))))))


