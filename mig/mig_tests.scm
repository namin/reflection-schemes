;; low-level example

;; we're using structures:
;; https://cisco.github.io/ChezScheme/csug9.5/compat.html#./compat:h3
;; rather than records:
;; https://scheme.com/tspl4/records.html#./records:h0

(define-structure (foo1 n))
(define-structure (foo2 x y))
(define-structure (foo3 n x y))
(define-structure (foo4 x))

(define stamp-of
  ;; hack: this relies on the internal representation of structs as vectors
  (lambda (o) (vector-ref o 0)))

(define foo1-to-foo2
  (lambda (o)
    (make-foo2 (foo1-n o) 0)))

(define foo2-to-foo1
  (lambda (o)
    (make-foo1 (+ (foo2-x o) (foo2-y o)))))

(define foo3-to-foo2
  (lambda (o)
    (make-foo2 (foo3-x o) (foo3-y o))))

(define stamp-table
  (list
   (cons '(foo1 foo2) foo1-to-foo2)
   (cons '(foo2 foo1) foo2-to-foo1)
   (cons '(foo3 foo2) foo3-to-foo2)))

(define get-migration
  (lambda (stamp1 stamp2)
    (cond
      ((assoc (list stamp1 stamp2) stamp-table)
       => cdr)
      (else #f))))

(define map-some
  (lambda (predicate xs)
    (cond
      ((null? xs) #f)
      ((predicate (car xs)) => (lambda (x) x))
      (else (some predicate (cdr xs))))))

(define find-migration
  (lambda (stamp stamps)
    ;; TODO: consider more sophisticated migrations?
    (map-some (lambda (stamp2) (get-migration stamp stamp2)) stamps)))

(define require-stamp
  (lambda (o stamps)
    (cond
      ((member (stamp-of o) stamps)
       o)
      ((find-migration (stamp-of o) stamps)
       => (lambda (m) (m o)))
      (else
       (error 'require-stamp "cannot migrate" o stamps)))))

(define my
  (lambda (o)
    (let ((o (require-stamp o
                            ;;'(foo2 foo3) ;; TODO: cannot do this, because accessors are not shared!
                            '(foo2)
                            )))
      (- (foo2-x o) (foo2-y o)))))

(eg
 (my (make-foo1 3))
 3)

(eg
 (my (make-foo2 4 1))
 3)

(eg
 (my (make-foo3 10 4 1))
 3)

(eg_error
 (my (make-foo4 3)))
