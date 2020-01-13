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
  - `exp`
  - `env`
  - `context`
  - `run`: `() -> ()`
  - `status`

### Closure `->`

- API:
  - `apply`: `args -> process`

### Primitive Host Function

- can wrap in a `closure` interface.

### Operating System

- API:
  - `queue`: a list of active processes
  - `step`: pop and run a process in the queue, re-queue if process is not done
  - `step*`: run `step` until queue is empty

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

## Language

    expression e = x                       (variable)
                 | n                       (number)
                 | (set! x e)              (assignment)
                 | (get e selector ...)    (dictionary lookup)
                 | (upd! e e selector ...) (dictionary update)
                 | (cons e e)              (pair creation)
                 | (car e)                 (pair elimination 0)
                 | (cdr e)                 (pair elimination 1)
                 | (quote e)               (quote)
                 | (if e e e)              (conditional)
                 | (begin e ...)           (sequence)
                 | (run e)                 (run a process)
