(define (jit-os-test1)
  (define f6-init
    '((:exp
       begin
       (if (= n 0)
           (begin
             (set! :hits:consequent:exp0 (+ :hits:consequent:exp0 1))
             (set! :done #t))
           (begin
             (set! :hits:alternative:exp0 (+ :hits:alternative:exp0 1))
             (begin (set! result (* n result)) (set! n (- n 1)))))
       result)
      (:env
       (result . 1)
       (n . 6)
       (:hits:consequent:exp0 . 0)
       (:hits:alternative:exp0 . 0))))

  (define f6-repeat3
    '((:exp
       begin
       (begin
         (speculate
          (begin
            (set! :hits:alternative:exp0 (+ :hits:alternative:exp0 1))
            (begin (set! result (* n result)) (set! n (- n 1)))))
         (if (= n 0)
             (begin
               (undo)
               (begin
                 (set! :hits:consequent:exp0 (+ :hits:consequent:exp0 1))
                 (set! :done #t)))
             (commit)))
       result)
      (:env
       (result . 120)
       (n . 3)
       (:hits:consequent:exp0 . 0)
       (:hits:alternative:exp0 . 3)
       (:result . 120))))

  (define f6-overdone
    '((:exp
       begin
       (begin
         (speculate
          (begin
            (set! :hits:consequent:exp0 (+ :hits:consequent:exp0 1))
            (set! :done #t)))
         (if (= n 0)
             (commit)
             (begin
               (undo)
               (begin
                 (set! :hits:alternative:exp0 (+ :hits:alternative:exp0 1))
                 (begin (set! result (* n result)) (set! n (- n 1)))))))
       result)
      (:env
       (result . 720) (n . 0)
       (:hits:consequent:exp0 . 65) (:hits:alternative:exp0 . 6)
       (:result . 720) (:done . #t))
      (:status . :terminated)))

  (define f6 (factorial-process 6))
  (define j6 (jit! f6))

  (eg f6-init f6)

  (repeat 3 (lambda () (run f6) (run j6)))

  (eg f6-repeat3 f6)

  (step* (list j6 f6))

  (eg (get f6 ':exp) (get f6-init ':exp))
  (eg (get f6 ':env)
      '((result . 720) (n . 1)
        (:hits:consequent:exp0 . 1) (:hits:alternative:exp0 . 5)
        (:result . 720) (:done . #t)))

  (repeat 5 (lambda () (run f6)))
  (run j6)
  (eg (get f6 ':exp) (get f6-init ':exp))

  (repeat  60 (lambda () (run f6)))
  (run j6)
  (eg f6-overdone f6)
  )

(jit-os-test1)
