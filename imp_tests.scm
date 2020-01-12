(eg
 (ast-of 1)
 '((:tag . :number) (:exp . 1) (:children)))

(eg
 (get (get (ast-of '(if #t 1 2)) ':children) ':consequent)
 '((:tag . :number) (:exp . 1) (:children)))

(eg
 (get (get (get (get (get (analyze '(if #t (if #f 1 2) 3)) ':children) ':consequent) ':children) ':alternative) ':id)
 '(:alternative :consequent))

(eg
 (ast-of '(+ 1 2))
 '((:tag . :+)
   (:exp + 1 2)
   (:children
    ((:operand . 0) (:tag . :number) (:exp . 1) (:children))
    ((:operand . 1) (:tag . :number) (:exp . 2) (:children)))))
