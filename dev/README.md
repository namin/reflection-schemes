# Reflection Schemes

exploration of reflective architectures in Scheme

## Exploration Goal

A reflective architecture that can support the following case studies:

- _JIT compilation_: an object process is instrumented and optimized on the
  fly by a meta process.

- _Towers of Interpreters_: a potentially infinite tower of
  interpreters, where each level can be reified into the meta level
  and reflected back into the object level.

## Design

### Process

- API:
  - `run`: `process -> ()`
  - `exp`: `run`-specific
  - `env`: `dictionary`
  - `caller`: `option[process]`
  - `resume`: `option[() -> ()]`
  - `status`: status in operating system
     - `ready`
     - `running`
     - `blocked`
     - `terminated`

### Closure `->`

- API:
  - `apply`: `args -> process`

### Primitive Host Function

- can wrap in a `closure` interface.

### Operating System

- API:
  - `schedule`: `process -> ()`
  - `suspend`: `process, thunk -> ()`
     - suspend a running process
     - the thunk is saved in the process as `resume`
     - `(resume)` is called instead of `(run process)` when set and not `#f`
  - `step`: `() -> ()`
     - pick a scheduled process, run it if ready, and re-schedule it if not done
     - a process is done when `env.done` exists and is true
  - `step*`: `() -> ()`
    - run `step` until there are no scheduled processes
  - `pick!`: destructively pick a process from the scheduled process

- Q: can the OS be just another process that can be inspected and
  modified?

### Case Studies

- JIT
  - given an object process `user`,
  - `jit(user)`: `process -> process`
     - `instrument(user)`: `process -> process`
        - change `user.env` to add `stats`
        - change `user.exp` to update `stats`
     - `optimize(user)`: `process -> process`
        - inspect `user.stats` in `env`
        - rewrite `user.exp` accordingly

- Towers of environment

- For towers of interpreters
  - at the beginning of the `run` of a process
    - set `this` to the self process
    - set `this.meta` to the meta process
  - `(reify)`:
    - save `this.meta.exp`
    - set `this.meta.exp` to `this.exp` after `this.context`
    - set `this.meta.env.exp` to `this.exp`
    - set `this.meta.env.env` to `this.env`
    - set `this.meta.env.obj` to `this`
    - suspend object process during previous call
  - `(reflect)` -- `this` is old `this.meta`
    - restore `this.exp`
    - set `this.env.obj.exp` to `this.exp` after `this.context`
    - unblock object process

- Q: can `(reify)` and `(reflect)` be user-defined?

## Language

    expression e = x                       (variable)
                 | #t | #f                 (boolean)
                 | n                       (number)
                 | (+|-|*|=|<|not e ...)   (arithmetic + bool logic)
                 | (cons|car|cdr e ...)    (list operations)
                 | (set! x e)              (assignment)
                 | (dict e)                (dictionary from association list)
                 | (get e selector [e])    (dictionary lookup)
                 | (upd! e selector e)     (dictionary update)
                 | (copy e)                (dictionary copy)
                 | (quote e)               (quote)
                 | (if e e e)              (conditional)
                 | (begin e ...)           (sequence)
                 | (display|newline e...)  (printing)
                 | (run e)                 (run a process)
                 | (this)                  (read-only reference to the self process)

- Q: could generalize to one form of application, covering primitives,
  special forms, closures and processes.
