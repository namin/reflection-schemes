(define (jit! process)
  (instrument! process)
  (monitor! process))

(define (instrument! process)
  (define (gen ast context branch)
    (let ((id (to-id ':hits (cons branch context))))
      (upd! process ':env (lambda (env) (upd! env id (lambda (x) x) 0)))
      `(begin
         (set! ,id (+ ,id 1))
         ,(get (get (get ast ':children) branch) ':exp))))
  (upd!
   process ':exp
   (lambda (program)
     (program-of
      (traverse!
       (analyze program)
       (lambda (ast context)
         (if (eq? ':if (get ast ':tag))
             (analyze
              `(if ,(get (get (get ast ':children) ':condition) ':exp)
                   ,(gen ast context ':consequent)
                   ,(gen ast context ':alternative)))
             ast)))))))

