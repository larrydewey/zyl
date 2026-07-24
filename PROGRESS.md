# Zyl Progress Tracker

## Current State

All 9 core compilation phases are complete. The compiler builds and runs successfully. The struct system has exhaustive test coverage. Nested conditionals work correctly for int, float, and bool.

**Full details:** `docs/implementation-status.md`

---

## Completed

| Phase | Status | Details |
|-------|--------|---------|
| 1. Parsing (Lexer + Parser → AST) | ✅ Complete | Full error model, no-dispatch parsing, reserved keywords |
| 2. Post-Processing | ✅ Complete | Call/Apply → specialized ExprInner |
| 3. Macro Expansion | ✅ Complete | Gensym hygiene, innermost-first, variadic patterns |
| 4. Region Inference | ✅ Complete | Two-pass algorithm, R1–R8 rules, escape analysis |
| 5. Type Inference | ✅ Complete | HM inference, trait resolution, derive validation |
| 6. Monomorphization | ✅ Complete | Canonical naming, trait bound verification |
| 7. ICNF Generation | ✅ Complete | SSA IR, region annotations, embedded control flow |
| 8. Optimization | ✅ Complete | Constant folding, dead code elimination |
| 9. Code Generation | ✅ Complete | x86_64, System V AMD64 ABI, struct support |
| Float Support | ✅ Complete | Constants, unary negation, two-operand BinOp, comparisons, print, SSE code generation, nested conditionals |
| Struct System | ✅ Complete | defstruct, defstruct+, make-, struct-get, all phases |
| ADT System | ✅ Complete | deftype, match, exhaustive checking |
| Nested Conditionals | ✅ Complete | Int, float, and bool nested `if` expressions with correct phi slot handling |

---

## Known Issues

### High Priority
- [x] Function names with hyphens: fully sanitized in ICNF layer (all 9 call sites), verified end-to-end with `stdlib_test.zyl`
- [x] Nested conditionals: fixed phi slot collision, register clobbering, and float condition detection
- [x] Struct function calls: fixed MakeStruct rbp marker stack corruption and operand tracking
- [x] 2-arg let/let-mut: PostProcessor and macro_expander now accept `args.len() >= 2` (value as body), fixing inner let expressions in struct contexts that had only 2 args instead of 3

### Medium Priority
- [x] Floating-point division multi-operand chains: fixed `convert_div` with left-associative chaining `((a / b) / c) / d`
- [x] FFI code generation: fixed ICNF arg collection (intermediate Const nodes were lost), fixed entry point to call user main
- [ ] Actor concurrency runtime: type checking implemented, runtime deferred

### Low Priority
- [ ] ~160 compiler warnings (mostly unused variables, dead code, naming)
- [ ] Self-hosting (not yet targeting Zyl source code generation)
- [ ] Package management (spec v5.0 features not implemented per instructions)

---

## Next Priorities

1. FFI code generation (`ffi-call` → x86_64)
2. Actor concurrency runtime
3. Closure runtime support
4. Reduce compiler warnings

---

## History

Detailed phase-by-phase implementation history, debugging notes, and fix documentation are preserved in:
- `docs/implementation-status.md` — current phase details
- `specifications/` — historical specification versions (v1.0 through v4.1)
- Git commit history
