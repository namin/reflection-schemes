# Reflection Schemes

exploration of reflective architectures in Scheme

## Run

`(load "load.scm")`

## Roadmap of Toys

- [x] `imp`: low-level imperative language
  - [x] no loops (outer loop handled at process level)
  - [x] speculation
  - [ ] list and dictionary
  - [ ] reify and reflect
- [x] `jit`: jit for `imp`
  - [x] speculates on conditionals
- [x] `os`: operating system
  - [x] interleaves process runs until all done
  - [ ] suspend and ready
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
- [ ] `rea`: reactive programming
- [ ] `rel`: relational programming
