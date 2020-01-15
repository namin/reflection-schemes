(define (dict kvs)
  (let ((d (make-eqv-hashtable (length kvs))))
    (for-each
      (lambda (kv)
        (upd! d (car kv) (cdr kv)))
      kvs)
    d))

(define (copy d) (hashtable-copy d #t))

(define (get d k . defaults)
  (apply gets d (list k) defaults))

(define (gets d ks . defaults)
  (if (null? defaults)
      (gets-nd d ks)
      (gets-d d ks (car defaults))))

(define default-tag
  '(default))

(define (gets-nd d ks)
  (if (null? ks)
      d
      (let ((v (hashtable-ref d (car ks) default-tag)))
        (if (eq? default-tag v)
            (error 'gets (format "key ~a not found in dictionary ~a" (car ks) (hashtable-keys d)))
            (gets-nd v (cdr ks))))))

(define (gets-d d ks default)
  (if (null? ks)
      d
      (let ((v (hashtable-ref d (car ks) default-tag)))
        (if (eq? default-tag v)
            default
            (gets-d v (cdr ks) default)))))

(define (upd! d k v)
  (upds! d (list k) v))
(define (upds! d ks v)
  (if (null? (cdr ks))
      (hashtable-set! d (car ks) v)
      (let ((d2 (hashtable-ref d (car ks) default-tag)))
        (if (eq? default-tag d2)
            (error 'upds! (format "key ~a not found in dictionary ~a" (car ks) (hashtable-keys d)))
            (upds! d2 (cdr ks) v)))))

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

(define (geti xs i . initial)
  (set! initial (if (null? initial)
                    (list xs i)
                    (car initial)))
  (cond
    ((null? xs)
     (error 'geti (format "index ~a not found ~a, initially ~a" i xs initial)))
    ((= i 0)
     (car xs))
    (else (geti (cdr xs) (- i 1) initial))))

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
