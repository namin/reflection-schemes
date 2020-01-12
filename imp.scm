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

(define (evl this exp env)
  (let ((envs (imp_eval this (analyze exp) (list env))))
    (if (= (length envs) 1)
        (car envs)
        (error 'evl (format "too much speculation")))))

(define (imp_eval this ast envs)
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
            (let ((envs (imp_eval this (get cs ':condition) envs)))
              (if (get (car envs) ':result)
                  (imp_eval this (get cs ':consequent) envs)
                  (imp_eval this (get cs ':alternative) envs))))
           ((eq? tag ':set!)
            (let* ((x (get (get cs ':variable) ':exp))
                   (envs (imp_eval this (get cs ':value) envs))
                   (v (get (car envs) ':result)))
              (set-car! envs (upd! (car envs) x (lambda (old) v) 0))
              envs))
           ((or (eq? tag ':+) (eq? tag ':-) (eq? tag ':*) (eq? tag ':=))
            (let ((op (get tag-ops tag)))
              (imp_eval_list this (map cdr cs) envs (lambda (vs) (apply op vs)))))
           ((eq? tag ':begin)
            (imp_eval_list this (map cdr cs) envs (lambda (vs) (last vs)) '()))
           ((eq? tag ':quote)
            (set-result! (get (get cs ':exp) ':exp)))
           ((eq? tag ':get)
            (imp_eval_list
             this (map cdr cs) envs
             (lambda (vs)
               (let ((dict (car vs))
                     (key (cadr vs))
                     (defaults (cddr vs)))
                 (apply get dict key defaults)))))
           ((eq? tag ':update!)
            (imp_eval_list
             this (map cdr cs) envs
             (lambda (vs)
               (let ((dict (geti vs 0))
                     (key (geti vs 1))
                     (val (geti vs 2)))
                 (upd! dict key (lambda (old) val) #f)))))
           ((eq? tag ':display)
            (let ((envs (imp_eval this (get cs ':exp) envs)))
              (display (get (car envs) ':result))
              envs))
           ((eq? tag ':newline)
            (newline)
            envs)
           ((eq? tag ':block)
            (let* ((envs (imp_eval this (get cs ':p) envs))
                   (p (get (car envs) ':result)))
              (if (eq? ':terminated (get p ':status #f))
                  envs ;; carry on
                  (begin
                    (block! this p)
                    ((get this ':suspend!) (car envs))))))
           ((eq? tag ':meta)
            (set-car!
             envs
             (get
              (evl this
                   (cons 'begin (map (lambda (kc) (get (cdr kc) ':exp)) cs))
                   (list (cons ':env (car envs))))
              ':env))
            envs)
           ((eq? tag ':speculate)
            (imp_eval this (get cs ':exp) (cons (copy (car envs)) envs)))
           ((eq? tag ':undo)
            (cdr envs))
           ((eq? tag ':commit)
            (set-car!
             (cdr envs)
             (transfer! (car envs) (car (cdr envs))))
            (cdr envs))
           (else (error 'imp_eval this (format "unknown ast ~a" ast)))))))))

(define (imp_eval_list this exps envs f . defaults)
  (apply imp_eval_list_iter this exps envs f '() defaults))

(define (imp_eval_list_iter this exps envs f vs . defaults)
  (cond
    ((null? exps)
     (set-car! envs (upd! (car envs) ':result (lambda (old) (f (reverse vs))) 0))
     envs)
    (else
     (let* ((envs (imp_eval this (car exps) envs))
            (v (apply get (car envs) ':result defaults)))
       (apply imp_eval_list_iter this (cdr exps) envs f (cons v vs) defaults)))))

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
  (string->symbol
   (apply
    string-append
    (map (lambda (x)
           (if (symbol? x)
               (symbol->string x)
               (string-append
                (symbol->string (car x))
                (number->string (cdr x)))))
         (cons prefix context)))))

(define
  tags
  '((if . :if)
    (set! . :set!)
    (begin . :begin)
    (quote . :quote)
    (+ . :+)
    (- . :-)
    (* . :*)
    (= . :=)
    (get . :get)
    (update! . :update!)
    (display . :display)
    (newline . :newline)
    (block . :block)
    (meta . :meta)
    (speculate . :speculate)
    (undo . :undo)
    (commit . :commit)))
(define
  tag-children
  '((:if :condition :consequent :alternative)
    (:set! :variable :value)
    (:+ . :operand)
    (:- . :operand)
    (:* . :operand)
    (:= . :operand)
    (:begin . :exp)
    (:quote :exp)
    (:get :dict :key . :defaults)
    (:update! :dict :key :val)
    (:display :exp)
    (:newline)
    (:block :p)
    (:meta . :exp)
    (:speculate :exp)
    (:undo)
    (:commit)))
(define
  tag-ops
  `((:+ . ,+)
    (:- . ,-)
    (:* . ,*)
    (:= . ,=)))

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
