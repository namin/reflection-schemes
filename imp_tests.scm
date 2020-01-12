(eg
 (evl #f 1 '())
 '((:result . 1)))

(eg
 (evl #f '(+ 1 2 3) '())
 '((:result . 6)))

(eg
 (evl #f '(if #t 1 2) '())
 '((:result . 1)))

(eg
 (evl #f '(begin 1) '())
 '((:result . 1)))

(eg
 (evl #f '(begin (set! my 1) (+ 1 my)) '())
 '((my . 1) (:result . 2)))

(eg
 (evl #f '(begin (speculate (set! my 1)) (commit) 1) '())
 '((:result . 1) (my . 1)))

(eg
 (evl #f '(begin (speculate (set! my 1)) (commit) my) '())
 '((:result . 1) (my . 1)))

(eg
 (evl #f '(begin (speculate (set! my 1)) (undo) 1) '())
 '((:result . 1)))

(eg
 (evl #f '(begin (set! my 2) (speculate (set! my 1)) (undo) my) '())
 '((my . 2) (:result . 2)))

(eg
 (ast-of 1)
 '((:tag . :number) (:exp . 1) (:children)))

(eg
 (get (get (ast-of '(if #t 1 2)) ':children) ':consequent)
 '((:tag . :number) (:exp . 1) (:children)))

(eg
 (ast-of '(+ 1 2))
 '((:tag . :+)
   (:exp + 1 2)
   (:children
    ((:operand . 0) (:tag . :number) (:exp . 1) (:children))
    ((:operand . 1) (:tag . :number) (:exp . 2) (:children)))))
