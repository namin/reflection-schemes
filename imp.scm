;; tiny imperative language

;; interface
(define (analyze program)
  (add-ids (ast-of program)))

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



;; implementation
(define (to-id x) x)
(define (add-ids ast)
  (traverse!
   ast
   (lambda (ast context)
     (upd! ast ':id (lambda (old) (if old old (to-id context))) #f))))

(define
  tags
  '((if . :if)
    (set! . :set!)
    (begin . :begin)
    (+ . :+)))
(define
  tag-children
  '((:if :conditional :consequent :alternative)
    (:set! :variable :value)
    (:+ . :operand)
    (:begin . :exp)))

(define (tag-of x)
  (get tags x))

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
