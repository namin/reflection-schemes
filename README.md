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
- [ ] `ben`: instrumentation for `lam`
- [ ] `mix`: mixing `imp` and `lam`
- [ ] `sem`: changing semantics
- [ ] `his`: recording and projecting history
- [ ] `com`: communication
- [ ] `err`: error recovery
- [ ] `eff`: effects
- [ ] `rea`: reactive programming
