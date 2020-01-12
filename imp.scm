;; tiny imperative language

(define (analyze program)
  (ast-of program))

(define (synthesize ast)
  (program-of ast))

(define (traverse! ast f . contexts)
  (let ((context (if (null? contexts) '() (car contexts))))
    (f (upd!
        ast ':children
        (lambda (cs)
          (map
           (lambda (kv)
             (cons (car kv)
                   (traverse!
                    (cdr kv)
                    f
                    (cons (car kv) context))))
           cs))) context)))

(define (evl exp env)
  (let ((envs (imp_eval (analyze exp) (list env))))
    (if (= (length envs) 1)
        (car envs)
        (error 'evl (format "too much speculation")))))

(define (imp_eval ast envs)
  (let ((set-result!
         (lambda (v)
           (set-car! envs (upd! (car envs) ':result (lambda (old) v) 0))
           envs))
        (tag (get ast ':tag)))
    (cond
      ((eq? tag ':variable)
       (set-result! (get (car envs) (get ast ':exp))))
      ((or (eq? tag ':number) (eq? tag ':boolean))
       (set-result! (get ast ':exp)))
      (else
       (let ((cs (get ast ':children)))
         (cond
           ((eq? tag ':if)
            (let ((envs (imp_eval (get cs ':condition) envs)))
              (if (get (car envs) ':result)
                  (imp_eval (get cs ':consequent) envs)
                  (imp_eval (get cs ':alternative) envs))))
           ((eq? tag ':set!)
            (let* ((x (get (get cs ':variable) ':exp))
                   (envs (imp_eval (get cs ':value) envs))
                   (v (get (car envs) ':result)))
              (set-car! envs (upd! (car envs) x (lambda (old) v) 0))
              envs))
           ((eq? tag ':+)
            (imp_eval_list (map cdr cs) envs (lambda (vs) (apply + vs))))
           ((eq? tag ':begin)
            (imp_eval_list (map cdr cs) envs (lambda (vs) (last vs)) '()))
           ((eq? tag ':speculate)
            (imp_eval (get cs ':exp) (cons (copy (car envs)) envs)))
           ((eq? tag ':undo)
            (cdr envs))
           ((eq? tag ':commit)
            (set-car!
             (cdr envs)
             (transfer! (car envs) (car (cdr envs))))
            (cdr envs))
           (else (error 'imp_eval (format "unknown ast ~a" ast)))))))))

(define (imp_eval_list exps envs f . defaults)
  (apply imp_eval_list_iter exps envs f '() defaults))

(define (imp_eval_list_iter exps envs f vs . defaults)
  (cond
    ((null? exps)
     (set-car! envs (upd! (car envs) ':result (lambda (old) (f (reverse vs))) 0))
     envs)
    (else
     (let* ((envs (imp_eval (car exps) envs))
            (v (apply get (car envs) ':result defaults)))
       (apply imp_eval_list_iter (cdr exps) envs f (cons v vs) defaults)))))

(define (program-of ast)
  (get (traverse! ast refresh-exp) ':exp))

(define (refresh-exp ast context)
  (if (null? (get ast ':children))
      ast
      (upd!
       ast ':exp
       (lambda (old)
         (cons (reverse-tag-of (get ast ':tag))
               (map (lambda (kv) (get (cdr kv) ':exp)) (get ast ':children)))))))

(define (to-id prefix context)
  (string->symbol (apply string-append (map symbol->string (cons prefix context)))))

(define
  tags
  '((if . :if)
    (set! . :set!)
    (begin . :begin)
    (+ . :+)
    (speculate . :speculate)
    (undo . :undo)
    (commit . :commit)))
(define
  tag-children
  '((:if :condition :consequent :alternative)
    (:set! :variable :value)
    (:+ . :operand)
    (:begin . :exp)
    (:speculate :exp)
    (:undo)
    (:commit)))

(define (tag-of x)
  (get tags x))
(define (reverse-tag-of x)
  (get (map (lambda (kv) (cons (cdr kv) (car kv))) tags) x))

(define (ast-of program)
  (cond
    ((symbol? program)
     `((:tag . :variable) (:exp . ,program) (:children . ())))
    ((number? program)
     `((:tag . :number) (:exp . ,program) (:children . ())))
    ((boolean? program)
     `((:tag . :boolean) (:exp . ,program) (:children . ())))
    ((pair? program)
     (let* ((tag (tag-of (car program)))
            (children (get tag-children tag)))
       `((:tag . ,tag)
         (:exp . ,program)
         (:children . ,(mapi (lambda (i sub) (cons (geti children i) (ast-of sub))) (cdr program))))))
    (else (error 'ast-of (format "unknown expression ~a" program)))))
