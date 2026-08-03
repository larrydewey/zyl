# Zyl Progress Tracker

## Current State

All 9 core compilation phases are implemented and tested. The compiler builds and runs successfully. The struct system, ADT system, float support, actor concurrency, closure support, FFI, try/catch, and I/O all have full pipeline coverage across all phases.

**Full details:** `docs/implementation-status.md`

---

## Completed

| Phase | Status | Details |
|-------|--------|---------|
| 1. Parsing (Lexer + Parser → AST) | ✅ Complete | Full error model, no-dispatch parsing, 47 reserved keywords, ~1860 lines |
| 2. Post-Processing | ✅ Complete | Call/Apply → specialized ExprInner in ast.rs |
| 3. Macro Expansion | ✅ Complete | Gensym hygiene, innermost-first, variadic patterns, ~1449 lines |
| 4. Region Inference | ✅ Complete | Two-pass algorithm, R1–R8 rules, escape analysis, capture analysis, ~1158 lines |
| 5. Type Inference | ✅ Complete | HM inference, trait resolution, derive validation, capability types, ~2156 lines |
| 6. Monomorphization | ✅ Complete | Canonical naming, trait bound verification, ~1549 lines |
| 7. ICNF Generation | ✅ Complete | SSA IR, region annotations, embedded control flow, ~2941 lines |
| 8. Optimization | ✅ Complete | Constant folding (fixed-point), dead code elimination (BFS), ~529 lines |
| 9. Code Generation | ✅ Complete | x86_64, System V AMD64 ABI, SSE floats, struct/ADT/actor/FFI/closure support, ~5254 lines |
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
| Trait System | ✅ Complete | `(trait T (method ...))` + `(impl T Type (defn ...))`; receiver-type dispatch `(Trait.method receiver ...)` → `Trait.method_Type`; impl bodies emitted as top-level defns; dotted names safe in ABI (`_` sanitization) |
| buf-append builtin | ✅ Complete | `(buf-append dst src)` byte-copy append into raw heap arena (StringBuffer backend) |
| Nested Conditionals | ✅ Complete | Int, float, and bool nested `if` expressions with phi slot handling |
| Macros | ✅ Complete | unless, when, nested macros, gensym hygiene |
| read-line | ✅ Complete | I/O via PostProcessor → ICNF → codegen → sys_read syscall |

### Recent Fixes (Applied)

- [x] Multi-operand call + BinOp register clobbering: fixed emit_binop_direct save/restore (push rax for left operand, pop rcx after right operand load), fixed emit_call_direct argument save/restore (push rax/r64 before loading next arg, pop all before call)
- [x] BinOp in main emit loop: added skip for BinOp/UnOp when they're operands to Print/Call (emitted on-demand via emit_load_into instead of during main loop)
- [x] BinOp operation code: fixed Add/Sub/Mul/Div/And/Or to use correct registers (mov eax, ecx / add eax, edx pattern)
- [x] Push/pop register naming: changed to 64-bit register names (rdi/rax/etc.) for assembler compatibility
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
- [x] Module system: ModuleResolver wired into pipeline, use statement resolution, stdlib path lookup, symbol filtering, circular dependency detection, E_MODULE_NOT_FOUND/E_SYMBOL_NOT_EXPORTED/E_CIRCULAR_MODULE error codes
- [x] Stdlib: core.zyl (inlined Option/Result/List ADTs + helpers), list.zyl, option.zyl, result.zyl
- [x] Generic ADT instantiation collection: `TypeInferer::collect` walks top-level expressions via `collect_adt_instantiations_expr`, recording MakeVariant concrete field types (declared String recorded as-is; generic fields inferred). Enables monomorphized ADT labels (`match_arm_Opt_String_*`) and correct struct/string field loads in match arms
- [x] Match arm bindings: pattern variables now bind to concrete ADT field types (with `resolve_nominal` + `adt_field_types` helpers + primitive-name mapping) instead of fresh type vars; scrutinee ADT resolved through substitutions
- [x] `function_bodies` population: now filled in the `ExprInner::Defn` collection branch (previously only via `Call(defn)`), enabling `handle_apply` body re-inference and correct `resolved_returns` for user-defined functions (e.g. `assoc-get => Prim(String)`)
- [x] Print string detection via function return types: codegen gained `func_returns` field + `with_func_returns` builder; Print string detection traces Assign→Call and direct Call operands through `func_returns`. Function names sanitized (`-` → `_`) consistently at both construction (main.rs) and lookup (codegen.rs)
- [x] 64-bit pointer preservation for Call-valued Assigns: on-demand `emit_load_into` for Call/FfiCall/StructGet now targets `rax` and stores 64-bit (`mov [rbp-N], rax`), fixing potential truncation of ADT/struct/string pointers returned by calls
- [x] Multi-param generic ADTs: `Assoc<K,V>` (`zyl_map_test.zyl` with `assoc-put`/`assoc-get`) now compiles and prints `one`/`missing` correctly
- [x] send-closure handler dispatch (message passing): ICNF `SendClosure` now carries the sanitized handler name; codegen emits a `_ZYL_closure_N` wrapper that forwards captured state as handler args and calls `_ZYL_<handler>` (buffered in `spawn_wrappers`). Actor intermediate nodes (Spawn/Closure) survive `let` bodies via `convert_expr_to_stmts`. Type inference unifies handler params with captured message types, enabling String-param print detection. Runtime mailbox drain loop now waits for messages until `wait_all` stops actors (fixes send-after-spawn race). Register preservation (r12/r13) added to Send/SendClosure emit so actor_id/closure_ptr survive malloc + capture emission
- [x] String-typed function params: codegen gains `func_params` + `string_params`; String params stored 64-bit and printed as strings (fixes `(print name)` printing a pointer as an int)
- [x] Trait system end-to-end: lexer `.` in identifiers; post-processor converts `(trait ...)`/`(impl ...)` to TraitDecl/ImplBlock; uppercase-ident heuristics exclude dotted names; type inference registers trait/impl/struct defs; monomorphization emits impl methods as `Trait.method_Type` top-level defns and dispatches dotted calls by receiver type (threaded `var_types` map); ICNF binds typed struct params into `struct_bindings` so `struct-get` resolves field offsets (e.g. StringBuffer "fd" at offset 8)
- [x] Stdlib: OutputStream trait + Stdout/StringBuffer impls + `make-stdout`/`make-string-buffer` in `stdlib/io/io.zyl`; `test_trait.zyl` verifies `(use io/io)` dispatch + StringBuffer buffering end-to-end
- [x] Pre-existing `try`/`catch` bug documented: spec §12.2 Result-sugar never desugared; `(try A (catch n B))` stays a raw Call under no_dispatch parsing (post-processor expects ≥3 args) → codegen emits undefined `_ZYL_try`/`_ZYL_catch` → link failure. io-safe-read/write/close rewritten to explicit `Ok`/`Err` as a stopgap (behaviorally identical). Fix tracked in Remaining Work.

### Recent Fixes (ADT/Match Recursion)

- [x] Standalone Call emission: `emit_node` now emits top-level Call nodes via `emit_call_direct` instead of falling to nop
- [x] BinOp temp slot collision: replaced hardcoded `[rbp-64]` with per-function `temp_slot_counter` — prevents collision with param slots and If result_var slots
- [x] Const{Ident} variable references: `emit_load_into` now loads from stack slot for `Const(Atom::Ident name)` nodes (ICNF's representation of variable references)
- [x] Full recursion stress test: 10 patterns verified — single recursion (factorial), double recursion (fib), mutual recursion (is-even/is-odd), list recursion (length, sum, reverse), all correct

### Recent Fixes (ADT/Match Recursion)

- [x] MakeVariant discriminant lookup: ADT definitions stored under monomorphized names (e.g. `List_Int`) but MakeVariant ICNF conversion used generic names (`List`). Fixed by trying direct lookup first, then broad search across all ADT keys.
- [x] Match arm discriminant ordering: ICNF match arms were in source order (None first, Cons second) but codegen compared discriminant against arm index `i`. Fixed by sorting match arms by discriminant value during ICNF generation so arm index equals discriminant.
- [x] ICNF `ICNFInner::Call` missing from `emit_node`: no handler → fell to `_ => nop`, causing intermediate Call nodes in arm/branch bodies to emit as NOPs. Added Call/FfiCall handlers to `emit_node`.
- [x] Arm/branch body intermediate node emission: loops emitted ALL nodes (Load, Call, BinOp, Const) as flat sequence, clobbering operands to parent BinOp. Fixed by skipping operand intermediate nodes (Call, FfiCall, BinOp, UnOp, Load, Const) — emitted on-demand via `emit_load_into` instead.
- [x] Recursive stdlib functions now work: `list-sum`, `list-length`, `list-reverse`, `list-append` all produce correct results
- [x] Recursion bug fix complete: all 10 recursion patterns (single, double, mutual, list/ADT) verified correct end-to-end

---

## Remaining Work

### Self-Hosting (Priority)

The Zyl compiler will be rewritten in Zyl. Bootstrapping path:

1. **Compiler IR in Zyl** — Define AST/ICNF types in Zyl (flat, ID-based, no recursive types)
2. **Compiler core logic** — Lexer, parser, AST manipulation, type system in Zyl
3. **ICNF + codegen in Zyl** — SSA IR generation, x86_64 codegen in Zyl
4. **Boot build** — Use Rust compiler to compile Zyl compiler → Zyl binary
5. **Self-compile + determinism check** — Zyl compiler compiles its own source, verify identical binary

- [x] Phase 1: Compiler IR in Zyl (provisional — see below)
- [ ] Phase 2: Compiler core logic (lexer, parser, AST ops)
- [ ] Phase 3: ICNF + codegen in Zyl
- [ ] Phase 4: Boot build
- [ ] Phase 5: Determinism verification

**Note on Phase 1:** Zyl's deftype does not support recursive types (no `deftype Expr (Call Atom (List Expr))`). The compiler's AST is inherently recursive (Expr contains Expr). Two approaches:

- **Approach A (flat):** Use ICNF-style flat representation — all AST nodes stored in a list, referenced by ID. No recursive types needed. This matches how the Rust compiler's ICNF works. The Zyl compiler would operate on ID lists instead of tree structures.
- **Approach B (Rust bridge):** Keep AST types in Rust, write only the pipeline logic in Zyl. Less pure but more practical.

Approach A is the goal. Approach B is a fallback if Approach A proves too limiting.

### Low Priority
- [ ] `try`/`catch` (spec §12.2 Result sugar) broken: post-processor only converts `(try A B C)` (≥3 args); the standard `(try A (catch n B))` stays raw Call → `call _ZYL_try`/`_ZYL_catch` (undefined) at link. Fix: desugar to a Result `match` in the post-processor (reuses proven match pipeline).
- [ ] ~160 compiler warnings (mostly unused variables, dead code, naming) — down to 1
- [x] Zyl source code emitter (ICNF → Zyl S-expression) — `--emit-zyl` flag
- [ ] Contract injection (Phase 10 — optional overlay per spec §23)
- [ ] Hash finalization (Phase 11 — SHA-256 binary fingerprinting)
- [ ] Full REPL (currently a minimal stub, ~4 lines)

---

## Next Priorities

1. Wire `E_CANNOT_INFER` into `src/monomorphization.rs` fallback (~line 712, silent `Type::Prim(PrimType::Int)`) per spec §6 v4.2
2. Fill `stdlib/collections/` (ADT-based Assoc/List now proven; verify via multi-param generic tests) and `stdlib/allocator/` (FFI in `src/runtime/actor_runtime.c` + pure-Zyl arena)
3. Self-hosting Phase 1: Define compiler IR in Zyl (AST types, ICNF types)
4. Self-hosting Phase 2: Lexer + parser in Zyl
5. Contract injection (optional overlay)
6. Hash finalization (deterministic binary fingerprinting)
7. Full REPL implementation

---

## History

Detailed phase-by-phase implementation history, debugging notes, and fix documentation are preserved in:
- `docs/implementation-status.md` — current phase details
- `specifications/` — historical specification versions (v1.0 through v4.1)
- Git commit history
