(define (jit! process)
  (instrument! process)
  (monitor optimize! process))

(define (counter-of context branch)
  (to-id ':hits (cons branch context)))
(define (instrumented-if? process context)
  (get (get process ':env) (counter-of context ':consequent) #f))
(define (instrument! process)
  (define (gen ast context branch)
    (let ((id (counter-of context branch)))
      (upd! process ':env (lambda (env) (upd! env id (lambda (x) x) 0)))
      `(begin
         (set! ,id (+ ,id 1))
         ,(get (get (get ast ':children) branch) ':exp))))
  (upd!
   process ':exp
   (lambda (program)
     (synthesize
      (traverse!
       (analyze program)
       (lambda (ast context)
         (if (eq? ':if (get ast ':tag))
             (analyze
              `(if ,(get (get (get ast ':children) ':condition) ':exp)
                   ,(gen ast context ':consequent)
                   ,(gen ast context ':alternative)))
             ast)))))))

;; rewrite between
;; (if C A B) [default]
;; and
;; (begin (speculate A) (if C (commit) (begin (undo) B))) [if hitsA >> hitsB]
;; and
;; (begin (speculate B) (if C (begin (undo) A) (commit))) [if hitsB >> hitsA]
(define (>> a b)
  (> a (* 10 b)))
(define (optimize-if! on process ast context)
  (let ((hitsA (get (get process ':env) (counter-of context ':consequent)))
        (hitsB (get (get process ':env) (counter-of context ':alternative))))
    (cond
      ((>> hitsA hitsB)
       (speculate! on ':consequent process ast context))
      ((>> hitsB hitsA)
       (speculate! on ':alternative process ast context))
      (else
       (speculate! on #f process ast context)))))
(define (ABC-of on ast)
  (cond ((eq? ':consequent on)
         (list (get (get (get (get ast ':children) '(:exp . 0)) ':children) ':exp)
               (get (get (get (get (get (get ast ':children) '(:exp . 1)) ':children) ':alternative) ':children) '(:exp . 1))
               (get (get (get (get ast ':children) '(:exp . 1)) ':children) ':condition)))
        ((eq? ':alternative on)
         (list (get (get (get (get (get (get ast ':children) '(:exp . 1)) ':children) ':consequent) ':children) '(:exp . 1))
               (get (get (get (get ast ':children) '(:exp . 0)) ':children) ':exp)
               (get (get (get (get ast ':children) '(:exp . 1)) ':children) ':condition)))
        (else (list
               (get (get ast ':children) ':consequent)
               (get (get ast ':children) ':alternative)
               (get (get ast ':children) ':condition)))))
(define (speculate! old_on on process ast context)
  (if (eq? old_on on)
      (get ast ':exp)
      (let* ((ABC (map synthesize (ABC-of old_on ast)))
             (A (geti ABC 0))
             (B (geti ABC 1))
             (C (geti ABC 2)))
        (cond ((eq? on ':consequent)
               `(begin
                  (speculate ,A)
                  (if ,C (commit) (begin (undo) ,B))))
              ((eq? on ':alternative)
               `(begin
                  (speculate ,B)
                  (if ,C (begin (undo) ,A) (commit))))
              (else `(if ,C ,A ,B))))))

(define (optimize! process)
  (upd!
   process ':exp
   (lambda (program)
     (synthesize
      (traverse!
       (analyze program)
       (lambda (ast context)
         (if (instrumented-if? process context)
             (cond
               ((eq? ':if (get ast ':tag))
                (analyze (optimize-if! #f process ast context)))
               ((and (eq? ':begin (get ast ':tag))
                     (eq? ':speculate (get (get (get ast ':children) '(:exp . 0)) ':tag))
                     (eq? ':if (get (get (get ast ':children) '(:exp . 1)) ':tag)))
                (analyze (optimize-if!
                          (if (eq? ':commit (get (get (get (get (get ast ':children) '(:exp . 1)) ':children) ':consequent) ':tag))
                              ':consequent
                              ':alternative)
                          process ast context)))
               (else (error 'optimize! (format "unknown if shape"))))
             ast)))))))

(define (monitor optimize! process)
  `((:eval . ,(lambda (this exp env)
              (if (get (get process ':env) ':done #f)
                  (upd! env ':done (lambda (old) #t))
                  ;; still optimize even if done...
                  )
              (exp)
              env))
    (:exp . ,(lambda () (optimize! process)))
    (:env . ((:done . #f)))))

