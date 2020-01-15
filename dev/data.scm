(define (mk-process thunk)
  (dict (list (cons 'thunk thunk))))

(define (mk-env alist)
  (dict alist))
