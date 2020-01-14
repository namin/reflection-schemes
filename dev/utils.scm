(define (dict kvs)
  (let ((d (make-eqv-hashtable (length kvs))))
    (for-each
      (lambda (kv)
        (upd! d (list (car kv)) (cdr kv)))
      kvs)
    d))

(define (copy d) (hashtable-copy d #t))

(define (get d ks . defaults)
  (if (null? defaults)
      (get-nd d ks)
      (get-d d ks (car defaults))))

(define default-tag
  '(default))

(define (get-nd d ks)
  (if (null? ks)
      d
      (let ((v (hashtable-ref d (car ks) default-tag)))
        (if (eq? default-tag v)
            (error 'get (format "key ~a not found in dictionary ~a" (car ks) (hashtable-keys d)))
            (get-nd v (cdr ks))))))

(define (get-d d ks default)
  (if (null? ks)
      d
      (let ((v (hashtable-ref d (car ks) default-tag)))
        (if (eq? default-tag v)
            default
            (get-d v (cdr ks) default)))))

(define (upd! d ks v)
  (if (null? (cdr ks))
      (hashtable-set! d (car ks) v)
      (let ((d2 (hashtable-ref d (car ks) default-tag)))
        (if (eq? default-tag d2)
            (error 'upd! (format "key ~a not found in dictionary ~a" (car ks) (hashtable-keys d)))
            (upd! d2 (cdr ks) v)))))

(define (tagged? tag exp)
  (and (pair? exp) (eq? tag (car exp))))

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
     (error 'geti (format "index ~a not found ~a" i xs)))
    ((= i 0)
     (car xs))
    (else (geti (cdr xs) (- i 1)))))

(define (existsi xs i)
  (< i (length xs)))

(define (mapi f . xss)
  ;;map is not deterministic!
  ;;(apply map `(,f ,(range 0 (lengths xss)) . ,xss))
  (let ((r '()))
    (apply
     for-each
     `(,(lambda args (set! r (cons (apply f args) r)))
       ,(range 0 (lengths xss))
       . ,xss))
    (reverse r)))

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

(define (take n xs)
  (if (= n 0)
      '()
      (if (null? xs)
          (error 'take "not enough to take")
          (cons (car xs) (take (- n 1) (cdr xs))))))

(define (drop n xs)
  (if (= n 0)
      xs
      (if (null? xs)
          (error 'drop "not enough to drop")
          (drop (- n 1) (cdr xs)))))
