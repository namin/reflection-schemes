(eg
 (run-program-once
  '(begin
     (set! say 'hello)
     (meta
      (display :env)
      (newline))
     say))
 'hello
 )

(eg
 (run-program-once
  '(begin
     (set! say 'hello)
     (meta
      (display :env)
      (newline)
      (update! :env 'say 'goodbye))
     say))
 'goodbye
)

