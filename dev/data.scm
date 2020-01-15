(define (mk-process fun)
  (dict (list (cons 'fun fun))))

(define (mk-env alist)
  (dict alist))
