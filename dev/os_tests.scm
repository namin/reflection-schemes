(define (factorial-process n)
  (dict `((:env . ,(dict `((n . ,n) (:result . 1))))
          (:exp
           .
           (if (= n 0)
               (set! :done #t)
               (begin
                 (set! :result (* n :result))
                 (set! n (- n 1)))))
          (:run . ,(lambda (process) (evl process (get process '(:exp)) (get process '(:context) '())))))))

(eg
 (let ((f6 (factorial-process 6)))
   (schedule f6)
   (step*)
   (get f6 '(:env :result)))
 720)
