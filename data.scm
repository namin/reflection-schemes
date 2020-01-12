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
              (let ((new (list (cons key (val-upd (car defaults))))))
                (if (null? d)
                    new
                    (begin
                      ;; put at end to ensure we don't lose references
                      (append! d new)
                      d))))))))

(define (copy a)
  (map (lambda (kv) (cons (car kv) (cdr kv))) a))

(define (full-copy x)
  (cond
    ((null? x) x)
    ((pair? x) (cons (full-copy (car x)) (full-copy (cdr x))))
    (else x)))

(define (full-copy-but ks x)
  (cond
    ((null? x) x)
    ((memq x ks) x)
    ((pair? x) (cons (full-copy-but ks (car x)) (full-copy-but ks (cdr x))))
    (else x)))

(define (transfer! from to)
  (if (null? from)
      to
      (transfer! (cdr from) (upd! to (caar from) (lambda (old) (cdar from)) 0))))

(define (last xs)
  (cond
    ((null? xs)
     (error 'last (format "last of empty list")))
    ((null? (cdr xs))
     (car xs))
    (else (last (cdr xs)))))

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

(define (repeat n thunk)
  (map (lambda (i) (thunk)) (range 0 n))
  'done)
