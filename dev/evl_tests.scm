(eg
 (lookup 'x '((x . 1) (y . 2)))
 '(x . 1))

(eg
 (lookup 'y '((x . 1) (y . 2)))
 '(y . 2))

;;(lookup 'z '((x . 1) (y . 2)))

(eg
 (extend-env '(x y z) '(1 2 3) '((x . 10)))
 '((x . 1) (y . 2) (z . 3) (x . 10)))

(eg
 (evl 1 '())
 1)

(eg
 (evl '(if #t 2 3) '())
 2)

(eg
 (evl '((lambda (x) x) 3) '())
 3)

(eg
 (evl '((lambda (x) (- x 1)) 3) '())
 2)

(define y
  '(lambda (fun)
     ((lambda (F)
        (F F))
      (lambda (F)
        (fun (lambda (x) ((F F) x)))))))

(eg
 (evl `((,y (lambda (f) (lambda (x) x))) 3) '())
 3)

(define factorial
  '(lambda (factorial)
     (lambda (n)
       (if (= n 0)
           1
           (* n (factorial (- n 1)))))))

(eg
 (evl `((,y ,factorial) 6) '())
 720)




