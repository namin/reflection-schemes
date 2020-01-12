;; tiny imperative language

;; interface
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


(define (to-id prefix context)
  (string->symbol (apply string-append (map symbol->string (cons prefix context)))))

;; implementation
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

(define
  tags
  '((if . :if)
    (set! . :set!)
    (begin . :begin)
    (+ . :+)))
(define
  tag-children
  '((:if :condition :consequent :alternative)
    (:set! :variable :value)
    (:+ . :operand)
    (:begin . :exp)))

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
