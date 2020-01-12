# Reflection Schemes

exploration of reflective architectures in Scheme

## Run

`(load "load.scm")`

## Roadmap of Toys

- [x] `imp`: low-level imperative language
  - no loops (outer loop handled at process level)
  - speculation
- [x] `jit`: jit for `imp`
  - speculates on conditionals
- [x] `os`: operating system
  - interleaves process runs until all done
- [ ] `lam`: high-level functional language
- [ ] `mea`: instrumentation for `lam`
- [ ] `dbg`: debugger
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
