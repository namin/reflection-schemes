;; dictionaries

(define get
  (lambda (d key . defaults)
    (let ((r (assoc key d)))
      (if r
          (cdr r)
          (if (null? defaults)
              (error 'get (format "key not found: ~a not in ~a" key d))
              (car defaults))))))

(define upd!
  (lambda (d key val-upd . defaults)
    (let ((r (assoc key d)))
      (if r
          (begin
            (set-cdr! r (val-upd (cdr r)))
            d)
          (if (null? defaults)
              (error 'upd! (format "key not found: ~a" key))
              (cons (cons key (val-upd (car defaults))) d))))))


;; lists

(define (range a b)
  (if (< a b)
      (cons a (range (+ a 1) b))
      '()))

(define (geti xs i)
  (cond
    ((null? xs)
     (error 'geti "index ~a not found ~a" i xs))
    ((not (pair? xs))
     (cons xs i))
    ((= i 0)
     (car xs))
    (else (geti (cdr xs) (- i 1)))))

(define (mapi f . xss)
  (apply map `(,f ,(range 0 (lengths xss)) . ,xss)))

(define (lengths xss)
  (if (null? xss)
      #f
      (let ((lcdr (lengths (cdr xss)))
            (lcar (length (car xss))))
        (if lcdr
            (if (= lcar lcdr)
                lcar
                (error 'lengths (format "inconsistent lengths ~a vs ~a" lcar lcdr)))
            lcar))))
