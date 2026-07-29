# Zyl Progress Tracker

## Current State

All 9 core compilation phases are implemented and tested. The compiler builds and runs successfully. The struct system, ADT system, float support, actor concurrency, closure support, FFI, try/catch, and I/O all have full pipeline coverage across all phases.

**Full details:** `docs/implementation-status.md`

---

## Completed

| Phase | Status | Details |
|-------|--------|---------|
| 1. Parsing (Lexer + Parser → AST) | ✅ Complete | Full error model, no-dispatch parsing, 47 reserved keywords, ~1820 lines |
| 2. Post-Processing | ✅ Complete | Call/Apply → specialized ExprInner in ast.rs |
| 3. Macro Expansion | ✅ Complete | Gensym hygiene, innermost-first, variadic patterns, ~1427 lines |
| 4. Region Inference | ✅ Complete | Two-pass algorithm, R1–R8 rules, escape analysis, capture analysis, ~1132 lines |
| 5. Type Inference | ✅ Complete | HM inference, trait resolution, derive validation, capability types, ~1836 lines |
| 6. Monomorphization | ✅ Complete | Canonical naming, trait bound verification, ~1459 lines |
| 7. ICNF Generation | ✅ Complete | SSA IR, region annotations, embedded control flow, ~2862 lines |
| 8. Optimization | ✅ Complete | Constant folding (fixed-point), dead code elimination (BFS), ~514 lines |
| 9. Code Generation | ✅ Complete | x86_64, System V AMD64 ABI, SSE floats, struct/ADT/actor/FFI/closure support, ~4738 lines |
| Linking | ✅ Complete | cc with actor_runtime.c, -lpthread |

### Language Features

| Feature | Status | Details |
|---------|--------|---------|
| Float (Float64) | ✅ Complete | Constants, unary negation, all BinOp/UnOp, comparisons, print, SSE codegen, nested conditionals |
| Struct System | ✅ Complete | defstruct, defstruct+, make-*, struct-get, all phases, exhaustive test coverage |
| ADT System | ✅ Complete | deftype, match, exhaustive checking, discriminant-based dispatch |
| For Loop | ✅ Complete | 3-arg syntax: `(for (init-bindings) condition body)` |
| Try/Catch | ✅ Complete | Error handling with catch variable binding, handler body |
| Closure (fn/lambda) | ✅ Complete | Capture analysis (TCap/TMut), env struct allocation, wrapper functions |
| Actor Concurrency | ✅ Complete | C runtime (pthread-based), Spawn/Send/SendClosure, mailbox, wait_all |
| FFI (ffi-call/ffi-pin/ffi-unpin) | ✅ Complete | Timeout enforcement, Pin region, type checking |
| Read-Line I/O | ✅ Complete | sys_read syscall, 64-bit pointer storage, string output |
| File I/O | ✅ Complete | file-open/file-read/file-write/file-close, sys_open/read/write/close, inline strlen, null-terminated buffers |
| Nested Conditionals | ✅ Complete | Int, float, and bool nested `if` expressions with phi slot handling |
| Macros | ✅ Complete | unless, when, nested macros, gensym hygiene |
| read-line | ✅ Complete | I/O via PostProcessor → ICNF → codegen → sys_read syscall |

### Recent Fixes (Applied)

- [x] Function names with hyphens: fully sanitized in ICNF layer (all call sites), verified end-to-end
- [x] Nested conditionals: fixed phi slot collision, register clobbering, float condition detection
- [x] Struct function calls: fixed MakeStruct rbp marker stack corruption
- [x] 2-arg let/let-mut: PostProcessor and macro_expander accept `args.len() >= 2`
- [x] Float division multi-operand chains: left-associative chaining
- [x] FFI code generation: fixed ICNF arg collection, entry point calls user main
- [x] Actor runtime: C runtime with pthread-based actors, Spawn/Send, wait_all
- [x] Actor spawn race: added `zyl_actor_wait_all()` at end of main
- [x] Spawn wrapper: anonymous wrappers emitted as standalone functions
- [x] Closure capture: env struct from rdi, metadata tracking in ICNF→CodeGen
- [x] send-closure: captured variable support, C runtime closure dispatch
- [x] File I/O: file-open/read/write/close, syscalls with correct flags (577=O_WRONLY|O_CREAT|O_TRUNC), handle loading via emit_load_into, operand_ids collection for file ops, null-terminated read buffers

---

## Remaining Work

### Low Priority
- [ ] ~160 compiler warnings (mostly unused variables, dead code, naming)
- [ ] Self-hosting (not yet targeting Zyl source code generation)
- [ ] Contract injection (Phase 10 — optional overlay per spec §23)
- [ ] Hash finalization (Phase 11 — SHA-256 binary fingerprinting)
- [ ] Full REPL (currently a minimal stub, ~4 lines)

---

## Next Priorities

1. Reduce compiler warnings (~160)
2. Contract injection (optional overlay)
3. Hash finalization (deterministic binary fingerprinting)
4. Full REPL implementation
5. Self-hosting (Zyl → Zyl code generation)

---

## History

Detailed phase-by-phase implementation history, debugging notes, and fix documentation are preserved in:
- `docs/implementation-status.md` — current phase details
- `specifications/` — historical specification versions (v1.0 through v4.1)
- Git commit history
