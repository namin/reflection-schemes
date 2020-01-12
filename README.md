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
    - [x] quote
    - [x] get by key
    - [ ] update by key
    - [ ] add sugar for get and update chains
  - [x] blocking process call
  - [ ] reify and reflect
  - [ ] Q: semantics of re-entrancy?
- [x] `jit`: jit for `imp`
  - [x] speculates on conditionals
- [x] `os`: operating system
  - [x] interleaves process runs until all done
  - [x] process status: ready, running, terminated, blocked
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
  - worlds ([PDF](http://www.vpri.org/pdf/tr2011001_final_worlds.pdf))
- [ ] `spec`: verification
- [ ] `rea`: reactive programming
- [ ] `rel`: relational programming
- [ ] `neu`: neuro-symbolics
- [ ] `cog`: consciousness

## Alternatives

- [ ] instead of ubiquitous dictionary
  - [ ] [generic procedures](https://www.gnu.org/software/mit-scheme/documentation/mit-scheme-sos/Generic-Procedures.html#Generic-Procedures) (MIT Scheme)
  - [ ] [protocols](https://clojure.org/reference/protocols) (Clojure)
  - [ ] actors instead of processes?
  - [ ] Q: can the mechanism be reified, reflected and copied like dictionaries?

- [ ] instead of Scheme
  - [ ] Python to experiment with neuro-symbolics?
  - [ ] Rust to fine-tune concurrency model?
  - [ ] Clojure for batteries and to fine-tune mutation model?
  - [ ] Coq, Agda, or Idris for a verified system?
