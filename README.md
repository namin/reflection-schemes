# Reflection Schemes

exploration of reflective architectures in Scheme

## Run

`(load "load.scm")`

in [Chez Scheme](http://cisco.github.io/ChezScheme/).

## Roadmap

- [x] `imp`: low-level imperative language
  - [x] no loops (outer loop handled at process level)
  - [x] speculation
  - [ ] list and dictionary
  - [ ] reify and reflect
- [x] `jit`: jit for `imp`
  - [x] speculates on conditionals
- [x] `os`: operating system
  - [x] interleaves process runs until all done
  - [x] process status: ready, running, terminated
  - [ ] process status: blocked
  - [ ] Q: how do an evaluator (a closure) becomes a process?
- [ ] `dbg`: debugger
  - [x] process tracer as higher-order process
  - [ ] process tracer as a reflective program
  - [ ] ...
- [ ] `lam`: high-level functional language
- [ ] `mea`: instrumentation for `lam`
- [ ] `mix`: mixing `imp` and `lam`
- [ ] `tow`: reflective tower of interpreters
- [ ] `sem`: changing semantics on the fly
- [ ] `his`: recording and projecting history
- [ ] `pov`: point of views
- [ ] `lay`: pyramid of abstractions
- [ ] `com`: communication
  - pi-calculus
- [ ] `err`: error recovery
- [ ] `eff`: effects
  - worlds
- [ ] `spec`: verification
- [ ] `rea`: reactive programming
- [ ] `rel`: relational programming
- [ ] `neu`: neuro-symbolics
- [ ] `cog`: consciousness

## Alternatives

- [ ] instead of ubiquitous dictionary
  - [ ] [generic procedures](https://www.gnu.org/software/mit-scheme/documentation/mit-scheme-sos/Generic-Procedures.html#Generic-Procedures) (MIT Scheme)
  - [ ] [protocols](https://clojure.org/reference/protocols) (Clojure)
  - [ ] Q: can the mechanism be reified, reflected and copied like dictionaries?
