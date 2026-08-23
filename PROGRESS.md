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
| 9. Code Generation | ✅ Complete | x86_64, System V AMD64 ABI, SSE floats, struct/ADT/actor/FFI/closure support, ~5242 lines |
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

- [x] **FFI dispatch in no_dispatch mode (parser.rs)**: Module resolver parsed imported modules with `no_dispatch = true`, routing all lists through `parse_list_no_dispatch` which created raw `Call` nodes. `ffi-call`/`ffi-pin`/`ffi-unpin`/`spawn`/`send`/`fn`/`lambda` forms were never dispatched, becoming `Call("ffi-call", ...)` → ICNF `Call("ffi_call", ...)` → codegen `call _ZYL_ffi_call` (undefined). Fixed by adding always-dispatch forms to `parse_list_no_dispatch`. Root cause: comment at parser.rs:289 claimed these forms "must always be dispatched, even in no_dispatch mode" but code was only in `parse_list`.
- [x] **Short-circuit `and`/`or` as If conditions (icnf.rs + codegen.rs)**: `and`/`or` now lower to nested `If` chains (`(and a b c) == if a (if b (if c true false) false) false`; `(or a b c) == if a true (if b true (if c true false))`) instead of a flattened BinOp. `emit_condition_inline` gained an `If` arm so a chain used as an `if`/`while` condition emits inline and tests truthiness of the chain result (`t_iA.zyl` returned 0 before, now 1). Fixed double-emission when a chain node is BOTH an enclosing branch-body statement AND the cond_ssa of a nested If (the or-chain was emitted standalone then re-emitted inline, duplicating its `.join` labels — broke `stdlib/compiler/lexer.zyl` float-marker scanning, asm `.then` label redefinition). `emit_condition_inline` now checks `emitted_ids`/`cond_ssa` first and loads the chain result from its phi slot instead of re-emitting.
- [x] **Residual 32-bit pointer truncation removed (codegen.rs)**: remaining `mov eax/mov [rbp-N],eax` sites in call/FFI reloads, FFI result copies, match-arm field loads, integer BinOp/UnOp, SetBang, for-loop init, and **all phi-slot stores/loads** converted to full 64-bit `rax` (x86-64 zero-extends 32-bit writes, so `rax` is always the safe width; slots are 8 bytes). The phi-slot 32-bit store was the root cause of the `test_stringbuffer_growth.zyl` SIGSEGV — a `mov [rbp-N],eax` left the upper 32 bits of the slot as garbage (`0x7fff00000080`), which the growth-path `arena-alloc-zeroed` call read back as its size, making the allocation return NULL and `buf-append` strlen on a NULL pointer. `alloc_reg_32` renamed to `alloc_reg_64`.
- [x] Arena allocator: region-based, deterministic-reclamation bump allocator in `actor_runtime.c` (create/alloc/alloc-zeroed/reset/destroy/used/capacity, 16-byte aligned, growable blocks, oversized-block support); `stdlib/allocator/allocator.zyl` exposes `arena-*` wrappers via FFI. Verified end-to-end in `test_arena.zyl` (alignment, zeroed reads, block growth >64 KiB, reset reclaim, reuse, destroy)
- [x] Runtime Heap/Pin regions wired to arenas: `zyl_heap_alloc`/`zyl_pin_alloc` route MakeStruct/MakeVariant/closure-env/Spawn allocations into `g_heap_arena`/`g_pin_arena` bump arenas (created in `zyl_ensure_arenas`, called from every main prologue; destroyed in `zyl_runtime_cleanup`). Region reclamation is real (R8 non-moving Pin arena).
- [x] Codegen double-emission of Call-valued lets: `emit_node`'s top-level Call arm passed a **clone** of `emitted_ids` to `emit_call_direct`, so the node was never marked emitted and a consuming `Assign` re-emitted the call on-demand — every `(let x (f ...) ...)` executed `f` twice (observable only with side-effecting FFI/counter values; hidden by pure calls). Fixed by passing the real set. `used` counters in `test_arena.zyl` now correct (96 not 192)
- [x] Actor runtime data races + busy-wait: mailbox_head/tail/count were mutated by producer and consumer threads with no lock (UB) and polled with `usleep(1000)`. Each `ZylActor` now has a `pthread_mutex_t` + `pthread_cond_t`; sends enqueue under lock + `cond_signal`, the thread waits on the condvar (no busy-wait), and `alive` is guarded. `zyl_actor_wait_all`/terminate/wait are now idempotent via a `joined` flag (no re-join UB). Verified race-free under `-fsanitize=thread`; FIFO order preserved (multi-message stress test)
- [x] Actor test files: removed redundant top-level `(main)` from `test_message_passing.zyl`/`test_spawn_capture.zyl` — the compiler auto-calls `_ZYL_main` (codegen.rs), so the explicit call ran it twice and the second `zyl_actor_wait_all` re-joined threads (hang). Tests now terminate cleanly
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
- [x] Type inference: untyped function params bound to a **fresh var per call** in `handle_apply` (was polluting the shared stored `Type::Var` in `known_functions` across call sites — e.g. invoking `alloc-write-int` with a TBox pointer then an Int value at different call sites conflicted on the same var). This was the root cause of `make-msb` / trait-dispatch StringBuffer collect failures.
- [x] Codegen pointer-truncation fixes (struct pointers truncated to 32-bit → segfaults):
    - Function prologue param-store: nominal/pointer-TCap params stored 32-bit (`mov [rbp-N], edi`) instead of 64-bit (`rdi`) — `self`/`chunk` params to `_ZYL_OutputStream_write_*` dereferenced garbage. Split the else branch: Int/Bool/Unit → 32-bit, everything else (String/Fun/pointer/nominal) → 64-bit.
    - `emit_load_into` StructGet (field load): was `mov eax, [rax+off]` (32-bit) but fields are stored as full 64-bit words (MakeStruct) — `hdr` pointers read back truncated. Now `mov rax, [rax+off]` and copies 64-bit when the target != rax.
    - standalone Call target selection: ICNF Call node `typ=None` picked `"eax"` (`mov eax, eax` zeroed pointer); added fallback to `func_returns` → `"rax"` for pointer returns.
    - `emit_load_into` Load branch: loaded pointer into `rax` then pushed stale `rdi`; now loads into the requested 64-bit target and `dest64` copy.
- [x] FileWrite codegen first argument (data) clobbering: `(file-write fd (alloc-read-int (struct-get self "hdr")))` — the data Call result in `rax` was overwritten when the handle (`fd`) was later reloaded into `rax`, so the write emitted bytes from the handle value (strlen read `[0x1]` → SIGSEGV). Reordered to preserve the data pointer on the stack (push r12 / push rax; pop rax → rsi) before loading the handle into r12.
- [x] Phase 6 Type Inference hang on monomorphized AST: `handle_apply` in `type_inference.rs` inferred the function body on every call site (lines 1579-1599), causing O(N * |body|) redundant work where N is the number of calls. Monomorphization expands generic functions and increases call-site density, making this effectively unbounded. Fixed by adding `body_infer_cache: RefCell<IndexMap<String, Type>>` to `TypeInferer` — caches inferred return types after the first body inference, skipping redundant passes on subsequent call sites. Also applied early-exit guard in `subst_expr_with_var_map` (`monomorphization.rs`) to skip deep AST cloning when substitution maps are empty. Test `test_parser_verify.zyl` now completes all 9 phases + linking successfully.
- [x] Arena-backed **StringBuffer** (fully growable): `stdlib/io/io.zyl` `OutputStream.write_StringBuffer` now reads hdr/arena/cap/len, computes `len+clen+1` vs `cap`, and either grows (arena-alloc-zeroed new-cap = max(cap*2, need); BufAppend old-content + chunk; update hdr fields) or appends in place with the arena. Added `string-buffer-len` helper. Verified end-to-end: `test_trait.zyl` prints `trait-dispatch` / `buffered content` (exit 0); `test_stringbuffer_growth.zyl` writes 4+8+16+32+44 chars past the initial 64-byte cap, prints `length: 104` (exit 0).

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

### Recent Fixes (Top-Level Codegen)

- [x] Top-level BinOp temp-slot collision (struct-get segfault): `temp_slot_counter` was reset past local/param slots for functions (codegen.rs) but never at the top level, so `let p (make-Point 5 7)` (slot 0 → `[rbp-8]`) plus `(+ (struct-get p "x") (struct-get p "y"))` caused the BinOp temp slot 0 to also write `[rbp-8]`, clobbering `p`'s pointer with the field value, then dereferencing it (`[5+8]` → SIGSEGV). Fixed by resetting `temp_slot_counter = next_slot` at the end of the top-level slot-assignment scan (before the main emit loop). All 6 struct regression tests pass (10/20, 12, 42, 30, 256, 255).
- [x] Empty `(begin)` link failure: `(begin)` with no args was intercepted by the bare-identifier arm in `icnf.rs` and lowered to `Call("begin", [])` → `call _ZYL_begin` (undefined). Added a dedicated empty-`begin` arm before it emitting `ICNFInner::Unit`. `core.zyl`'s `when`/`unless` (which expand to `(begin ...)`) now link cleanly.
- [x] Nested `defn` (closures inside functions) silently discarded: `convert_expr_to_stmts` in `icnf.rs` had no `ExprInner::Defn` handler, so nested `defn` forms inside function bodies (e.g., `add`/`double` in `test_all()`) fell through the catch-all arm and emitted a no-op `Begin`. Fixed by adding a `Defn` handler to `convert_expr_to_stmts` that creates `ICNFFuncSig` entries pushed to `self.functions` (same logic as top-level). `test_recursion_v2.zyl` now links with 56 functions (incl. `add`/`double`) and runs clean exit 0.

### Recent Fixes (Correctness Sweep — codegen/ICNF/runtime)

- [x] **System V stack args for >6-param calls (codegen.rs)**: `emit_call_direct` now spills every argument into an 8-byte scratch slot, loads register args into ABI regs, pushes args ≥6 in reverse order, pads to keep rsp 16-byte aligned at the call, and cleans up after. Function/closure prologues read stack args from `[rbp+16+8*(i-6)]`; `local_vars`/`next_slot` cover all param indices. Verified `sum8(1..8)=36`.
- [x] **64-bit param stores**: function prologues stored Int/Bool params 32-bit (`edi`) into 8-byte slots, leaving stale upper-half garbage that 64-bit slot reads picked up (root cause of `factorial-5/6` miscomputations). All params now stored full 64-bit.
- [x] **Negative Int constants sign-extended** (`emit_const_into`): `mov eax, imm32` zero-fills, so `-5` became `0x00000000FFFFFFFB` and broke 64-bit consumers (e.g. `abs -5` via stack-passed arg).
- [x] **idiv for Rem + divisor clobber fix**: `%` never emitted `idiv` (returned garbage), and the divisor lived in `rdx` which `cqo` overwrites → SIGFPE. Div/Rem now move the divisor to rbx before cqo/idiv.
- [x] **Top-level UnOp arm**: loaded its operand via hash-slot fallback (garbage for non-Const operands like If results) and didn't leave the result in rax. Now emits operand on demand into rax; result doubles as function return value.
- [x] **Branch-final value emission**: If then/else bodies skipped their final node as an "operand", storing stale rax into the phi slot. Branch loops now emit the final value-kind node fresh via `emit_load_into(.., "rax", ..)`. Fixes `(if true (not true) false)` class of bugs.
- [x] **`not` in branch bodies dropped its operand node (icnf.rs)**: the UnOp handler used `convert_expr`, which discards non-last nodes under `push_to_globals=false`, leaving orphan operand ids. Now collects operand stmts.
- [x] **Pure-value re-emission**: BinOp/UnOp/Eq arms of `emit_load_into` no longer trust a previously-emitted node's stale `eax` (intervening loads clobber it); they re-emit fresh.
- [x] **FileWrite return value + double emission**: FileWrite nodes now mark themselves emitted; `emit_load_into` emits them on demand so `print (file-write ...)` returns the syscall's byte count instead of garbage. Also handles StructGet handles freshly (stale-eax hazard).
- [x] **String equality in asserts**: Eq with string-typed operands compares content via `zyl_cstr_eq`; float comparisons detected from operand shapes (ICNF Eq/BinOp nodes often carry no type) and use UCOMISD.
- [x] **Closure param metadata**: `ICNFInner::Closure` records param names; codegen uses them instead of guessing from leading Load nodes (which missed called-but-not-loaded params, shifting all subsequent args).
- [x] **Indirect-call arg restore order**: pops now run in reverse so arg 0 lands in rdi (previously args were reversed for multi-param fn-valued calls, e.g. `(sub 10 3)` → -7).
- [x] **Closure values as call arguments**: Closure nodes mark themselves emitted; `emit_load_into` gained a Closure arm (`lea target, [_ZYL_name]`). Fixes segfault on inline closures passed to HOFs (`option-flatmap`).
- [x] **Module shadowing (module_resolver.rs)**: auto-linked/explicit module defs that the root program re-defines are dropped (duplicate `_ZYL_nand` link errors).
- [x] **Constructor type fallback (monomorphization.rs)**: unresolved returns for `make-x-y` constructors resolve to the declared struct/ADT (case/hyphen-insensitive), enabling trait dispatch on their results (`make-string-buffer` → StringBuffer). Also substituted inside Print args so trait dispatch applies there.
- [x] **Runtime**: test-harness panic recovery (setjmp/longjmp) so one failing test doesn't kill the binary; `zyl_cstr_concat`/`zyl_cstr_substr` builtins.

### Recent Fixes (Second Correctness Sweep — macros, cond, let-mut)

- [x] **Macro calls inside function bodies never expanded** (macro_expander.rs): `Defn`/`Begin`/`Lambda`/`Fn` were in the "no children to expand" list, so `(_m_dbl 5)` etc. inside a defn stayed as raw Calls → undefined `_ZYL_<macro>` at link time. Bodies now expanded.
- [x] **cond desugar self-referential If** (icnf.rs): the If node reused its condition's SSA id (`id == cond_ssa`) so codegen skipped it as its own condition; also dropped the redundant phi Assign and flattening of branch bodies.
- [x] **LetMut duplicate/stale nodes** (icnf.rs): temp-buffer merge now dedups by id in both directions; For-init values keep their position before the body. Fixes duplicated Assert/Eq ids inside test bodies.
- [x] **UnOp conditions inline** (codegen.rs): `(if (not c) ...)` emitted `xor eax,eax` (always false); Not is now applied inline.
- [x] **If-as-operand register**: loading an already-emitted If's phi value honors the requested target register instead of always rax.
- [x] **StructGet standalone emission removed** from function/closure loops — it clobbered rax between operand loads (`(+ (struct-get p "x") (struct-get p "y"))` summed y+y).
- [x] **Let struct-type propagation through constructor calls**: `let p (make-point ..)` records the binding's struct type via resolved function returns, so `struct-get` offsets resolve for function-built structs.
- [x] **defstruct+ name registration** (ast.rs): `make-X` resolution now sees defstruct+ declarations.
- [x] **Test fixes**: arithmetic mixed-arithmetic expected 12 not 10; io file-open asserts fd>0 with cleanup instead of hard-coded fd 1; macro skip-tests assert skipped-body semantics.

### Known Remaining Failures

None — all previously documented failures verified fixed (2026-08-23):
structs.zyl 34/34 (incl. struct-get-in-assert cases), ffi.zyl 4/4
(ffi-pin/unpin), concurrency.zyl 6/6, control-flow.zyl 17/17,
compiler.zyl 2/2 (pool-* stdlib fns written).

---

### Recent Fixes (Error Reporting & Spec Compliance) — earlier

- [x] **E_CANNOT_INFER for bounded generics** (monomorphization.rs): bounded generic params with no satisfying types and no call-site evidence now emit `E_CANNOT_INFER` per spec §6.4 instead of silently vanishing.
- [x] **E_TYPE_MISMATCH span** (type_inference.rs): calling a non-function variable now reports the exact span of the call expression instead of `0:0-0:0`.
- [x] **E_ARITY_MISMATCH span** (error.rs + type_inference.rs): arity mismatch errors now include the call expression span in the error message.
- [x] **E_UNBOUND_VARIABLE span** (icnf.rs): for-loop variable reference errors now use the condition expression's span instead of default.

---

## Remaining Work

### Recursive deftype (CRITICAL — blocks self-hosting)

Recursive ADTs with implicit boxing are implemented and verified (see step list below); remaining item is exposing them for the self-hosted compiler.

**Decision:** Recursive ADTs with implicit boxing. Syntax: implicit forward refs (`(deftype Tree (Leaf Int) (Node Tree Tree))` — `Tree` self-references automatically). Recursive fields are always pointers (8 bytes) in memory. Non-recursive ADTs unaffected.

**Implementation steps:**

1. **`ast.rs` PostProcessor**: ✅ DONE — Forward-declare ADT before parsing variants so self-references resolve. Also fixed: ADT variants named `Int`, `Bool`, etc. now correctly recognized as `MakeVariant` (previously blocked by `is_known_builtin_or_apply` exclusion).
2. **`type_inference.rs`**: ✅ ALREADY WORKING — Recursive field types unify correctly against `Type::Nominal(adt_name)`. No changes needed.
3. **`icnf.rs`**: ✅ ALREADY WORKING — `MakeVariant`/`Match` carry through unchanged. No changes needed.
4. **`codegen.rs`**: ✅ DONE — Fixed nested `MakeVariant` operand clobbering: `MakeVariant` field ids now collected into `main_operand_ids`/function `operand_ids` and added to both emit-loop operand-skip lists so nested constructions are emitted on-demand (not standalone, which clobbered `rax` — `(Node (Leaf 1) (Leaf 2))` summed to 4 instead of 3). Added `MakeVariant` arm to `collect_operand_ids_in_node`. Also fixed match-arm slot corruption: removed a `*arm_local_vars.entry(name).or_insert(0) += 1` bug that shifted pre-registered `Assign` slots into pattern-var slots (`let` in match-arm body summed to 2 instead of 3), and bumped `temp_slot_counter` past arm-local slots so BinOp temps never collide with pattern vars.
5. **Verify**: ✅ DONE — `(deftype Tree (Leaf Int) (Node Tree Tree))` → make, match, recursive traversal → correct output (tested: count, sum, nested nodes, let-in-arm bodies, multi-variant eval). `stdlib_test.zyl` output byte-identical to pre-fix baseline. Note: pre-existing `cond` `"x is 5"` print missing from `stdlib_test.zyl` output (unrelated, predates these fixes).
6. **Self-hosting**: Expose recursive `deftype` in Zyl syntax so the Zyl compiler can define its own AST types.

### Compiler bugs blocking self-hosting (found during Phase 2c runtime test) — RESOLVED

1. ~~Codegen >6-param stack args~~ **FIXED** (commit 7e75837): call sites now
   push scratch slots for all args, copy args 7+ into stack-arg position, and
   restore rsp by exactly `8*num_args + 8*num_stack_args`. The earlier attempt
   (ce5bb61) leaked 8 bytes per stack arg and misaligned rsp.
2. ~~Nested If flattening / Let handler global push~~ The Let handler already
   guards on `push_to_globals`; the real culprit behind the observed crashes
   was a TEST bug — `(form-cache-init ctx)` called with one argument (it takes
   `(arena ctx)`), silently accepted because body-inference errors were
   swallowed. Garbage rsi made str-intern allocate from a bogus arena,
   corrupting the heap. Fixed the call; inference errors are now surfaced as
   warnings (see type_inference first_body_error).

Phase 2c verification: `test_parser_debug.zyl` lexes "(defn foo (x) (+ x 1))"
into exactly 13 tokens and parses 1 top-level form. Phase 2c can proceed.

### Self-Hosting (Priority)

The Zyl compiler will be rewritten in Zyl. Bootstrapping path:

1. **Compiler IR in Zyl** — Define AST/ICNF types in Zyl (recursive deftype support required)
2. **Compiler core logic** — Lexer, parser, AST manipulation, type system in Zyl
3. **ICNF + codegen in Zyl** — SSA IR generation, x86_64 codegen in Zyl
4. **Boot build** — Use Rust compiler to compile Zyl compiler → Zyl binary
5. **Self-compile + determinism check** — Zyl compiler compiles its own source, verify identical binary

- [x] Phase 1: Compiler IR in Zyl (provisional — see below)
- [x] Phase 2a: Lexer in Zyl (`stdlib/compiler/lexer.zyl`) — complete token set, all 15 token kinds, float-marker scanning, string literal handling, keyword disambiguation
- [x] Phase 2b: Parser in Zyl (`stdlib/compiler/parser.zyl`) — full paren-balanced, all PostProcessor special forms (set!, while, for, cond, try, deftype, adt-variant, defstruct, defmacro, read-line, with-resource, send-closure, trait, impl, ffi-pin, ffi-unpin, exit, close, match), ~1485 lines, compiles and links clean
- [x] Phase 2c: Parser verification + AST manipulation helpers — **done** (commit 17196f2): `tests/integration/parser-verify.zyl` lexes/parses/post-processes real programs and verifies pool-AST structure (defn/let/if/while/set!/call shapes, node counting, ident collection); `stdlib/compiler/ast-helpers.zyl` accessors corrected to match actual parser layouts (str/a/b/c field model), plus new `ast-fields-of`/`ast-walk`/`ast-count-kind-deep`. Compiler fixes required: zyl_mem_write returns written value; Rem codegen saved divisor before cqo.
- [x] Phase 3 (core subset): ICNF + codegen in Zyl — **done** (first working end-to-end):
      `stdlib/compiler/icnf.zyl` lowers the pool-AST to a flat instruction IR
      (const/load/assign/binop/call/if/print; two-pool design: AST pool
      read-only, all ICNF records appended to a code pool) and
      `stdlib/compiler/codegen.zyl` emits GAS .intel_syntax x86_64 text
      (stack slots per instruction id + named var slots, SysV register
      calls <=6 args, printf-based print, if via labels).
      Verified by `tests/integration/selfhost-codegen.zyl`: parses
      "(defn main () (begin (print (+ 1 2)) (print (* 10 4)) 0))" with the
      Zyl parser, lowers + generates + writes /tmp/zyl_selfhost.s;
      `cc` that file and running prints 3 / 40.
      Remaining for full Phase 3: strings/floats/bools, while/for/match,
      comparison-driven control flow beyond if, structs/ADTs, FFI.
- [ ] Phase 4: Boot build
- [ ] Phase 5: Determinism verification

### Low Priority
- [x] `try`/`catch` (spec §12.2 Result sugar) fixed: post-processor now handles both `(try A B C)` (3+ args) and `(try A (catch n B))` (2 args with catch-list); type_inference.rs updated for both forms
- [ ] ~160 compiler warnings (mostly unused variables, dead code, naming) — down to 1
- [x] Zyl source code emitter (ICNF → Zyl S-expression) — `--emit-zyl` flag
- [ ] Contract injection (Phase 10 — optional overlay per spec §23)
- [x] Hash finalization (Phase 11 — SHA-256 binary fingerprinting via `--hash` flag)
- [x] Full REPL implemented (`src/repl.rs`) — full pipeline (parse → type check → compile → run), supports multi-line expressions, `quit` to exit

### Recent Fixes (REPL Rewrite)

- [x] **REPL rewritten as a first-class component (`src/repl.rs`)** — replaced the naive per-line shell-out with a stateful toplevel. Additions:
  - **Raw terminal input (`termios` crate, correct API)**: `Termios::from_fd` + `tcsetattr(TCSANOW)`, `c_cc[VMIN]/c_cc[VTIME]` controlled on-demand; disables `ICANON|ECHO|ISIG`; restores settings on drop. ESC-vs-arrow disambiguation uses a 0.1 s VMIN=0/VTIME=1 read timeout instead of a blocking `read_exact`.
  - **Line editor**: insert/backspace/delete, Left/Right/Home/End cursor movement, UTF-8 code-point decoding, cursor-column-precise redraw (`\x1b[K`, `\x1b[N G`).
  - **History navigation**: Up/Down recall of submitted forms from a single-line index; `:history` lists every submission flagged `ok`/`FAIL`.
  - **Multi-line input**: forms accumulate across physical lines until parens balance (continuation prompt `.. `); strings and `;` comments respected.
  - **Stateful compile-all model (OCaml-style)**: definitions committed across rounds and re-compiled from scratch each submission; expressions auto-wrapped in an internal `(print ...)` so their value is displayed (avoiding re-prints of earlier expression results in later rounds).
  - **Definition/statement classification**: persistent defs (`defn`/`def`/`deftype`/`defstruct`/`trait`/`impl`/`module`/`use`/`export`/test forms/…) are committed; statement forms (`print`, `assert-*`) run once unwrapped; duplicates of named defs are rejected with a clear message.
  - **Error recovery**: a failed form never corrupts the session (defs staged and only committed on success); failures are marked in history.
  - **Commands**: `:quit`/`:exit`/`quit`/`exit`, `:help`, `:clear`, `:show`, `:history`, `:stats`; `Ctrl-C` cancels the pending input, `Ctrl-D` exits.
  - **Fallback line mode** for non-TTY (piped) input with the same buffer/state semantics (`= value` result lines).
  - Pipeline kept identical to `main.rs` (`with_adt_defs`, closure bodies/captures, `-`→`_` ABI name sanitization).

  **Verification**: `(defn double (x) (* x 2))` + `(double 21)` → `42`; multi-line `defn`; Up-arrow recall/re-execution; `:clear` drops definitions so later uses fail cleanly; failed submissions do not corrupt state; raw-TTY keystroke/redraw/cursor behavior confirmed under `script` (pty). Noted limitations recorded in `:help` (print of Int/Float/Bool/String only; `use` not resolved; `(read-line)` in child has no terminal).

  **Known limitation (not a REPL bug)**: re-loading top-level `(def Name Expr)` bindings across rounds surfaces a pre-existing compiler issue — the same `(def n 100)` + `(print n)` misprints in a plain `.zyl` file compiled with the `zyl` binary (ICNF/codegen emit a Load of a top-level `def` value that is never stored in the slot).

---

### Self-Hosting Migration: pool IR -> recursive deftype AST (WIP, 2026-08-23)

User decision: ALL arena/pool/kids-based IR removed from stdlib/compiler.
Recursive deftype AST only. ir.zyl / ast-helpers.zyl / sym.zyl deleted;
new compiler/ast.zyl defines Token/Ast/Env/VTable (+ toks-head/tail);
lexer/parser/icnf/codegen rewritten on ADTs (List Token -> List Ast ->
Icnf tree -> asm). str-intern/str-eq moved to allocator.zyl.
zyl_cstr_sanitize added to actor_runtime.c.

**Status: compiles, end-to-end run BLOCKED by pre-existing Rust compiler
bugs (not Zyl-source issues):**

1. FIXED this session (src/codegen.rs ~3828): Match dispatch compared tag
   against ARM INDEX (`cmp eax, {i}`) instead of arm.discriminant. Now uses
   arm.discriminant.
2. OPEN (src/icnf.rs): `(let x v BODY)` where BODY nests If chains loses
   nodes — emit-zyl shows conditions as `?` and constructor args as `unit`
   (e.g. lex_loop's `(let c (byte-at ...) (if ...))` chain). Blocks lexer
   self-host path; causes infinite recursion / garbage tokens.
3. OPEN: functions whose type inference partially fails are silently
   DROPPED from emission -> undefined symbol link errors instead of errors
   (e.g. _ZYL_pv_hd).
4. WORKAROUND in place: wildcard `_` patterns miscompile (arm returns
   scrutinee/tag); all patterns now use named binds.
5. WORKAROUND in place: >6-arg calls miscompile register reload offsets;
   all stdlib/compiler calls kept <=6 args (lexer refactored onto state
   cell st[0..40]).

Remaining integration tests fail on these; everything else green (20/24).

## Next Priorities

1. ~~Wire `E_CANNOT_INFER` into `src/monomorphization.rs` fallback~~ — **done**: bounded generic params with no satisfying types now emit `E_CANNOT_INFER`.
2. ~~Error system span reporting~~ — **done**: E_TYPE_MISMATCH, E_ARITY_MISMATCH, E_UNBOUND_VARIABLE now report correct spans.
3. ~~Compiler warnings~~ — **done**: down to 0 warnings.
4. **Higher-order functions** (spec §4.4 `TFun`): `test_simple2.zyl`/`test_hof.zyl` pass clean (exit 0). `test_recursion_v2.zyl` now passes (exit 0, 56 functions including nested `add`/`double`). Remaining HOF issues: (a) `flip`/`compose`/`apply` unused core.zyl HOFs still emitted but no longer break programs (DCE handles them); (b) HOF param `Type::Fun` not yet structurally detected by codegen (relying on `fn_value_names` heuristic instead of type info).
5. Build stdlib data structures on the arena allocator: ~~`Vec<T>` (contiguous, arena-backed), `Map<K,V>` (deterministic sorted-key iteration), arena-backed `StringBuffer`~~ — **all three complete** (`stdlib/collections/vec.zyl`, `stdlib/collections/map.zyl`, `stdlib/collections/set.zyl`, and growable StringBuffer in `stdlib/io/io.zyl`).
- [x] **Test infrastructure reorganization**: Moved 30+ scattered test files into organized `tests/` hierarchy (`regression/`, `smoke/`, `stress/`, `integration/`), rewrote `run_regression_tests.sh` with `--quick`/`--full`/`--filter`/`--depth`/`--timeout`, removed legacy `stdlib_test.zyl` and all debug/probe files, updated `docs/regression-tests.md`, `AGENTS.md`, `PROGRESS.md`. S-expression balance tests added to `tests/stress/balanced-parens.zyl`.
    - [x] **Arena-backed `Map<K,V>`**: `stdlib/collections/map.zyl` — `map-create`, `map-create-default`, `map-len`, `map-cap`, `map-get-at`, `map-get`, `map-put` (with realloc + overwrite), `map-put-inner`, `map-remove` (realloc + copy), `map-find`, `map-has`, `map-free`. Verified: put/overwrite, remove, has. Fixed: paren imbalance in `map-remove` causing `set! j` loss.
    - [x] **Arena-backed `Set<K>`**: `stdlib/collections/set.zyl` — `set-create`, `set-len`, `set-cap`, `set-find`, `set-contains`, `set-add` (grow path with realloc), `set-remove` (compaction). Verified: add/dup-avoid, contains, remove/compact.
    - [x] Combined module compilation (allocator + map + set): `SetBang` nodes present in all for-loop bodies (ICNF verified). No `set! j` drop reproduces.
5. ~~Wire the runtime Heap/Pin regions to arenas~~ — **done**: `zyl_heap_alloc` and `zyl_pin_alloc` in `actor_runtime.c` route codegen allocations (MakeStruct, MakeVariant, closure-env, Spawn states) into per-region bump arenas (`g_heap_arena`, `g_pin_arena`) created in `zyl_ensure_arenas`, invoked from every `main` prologue. Deterministic bulk reclamation via `zyl_runtime_cleanup`. <br/>Also fixed remaining **32-bit pointer truncation** in codegen: (a) Call/FfiCall already-emitted reloads were 32-bit (`mov eax, …`) — now 64-bit `rax`; (b) FFI result to non-rax target used `eax` — now `rax`; (c) match-arm ADT field loads `mov ecx,[r12+off]` — now `rcx` 64-bit; (d) Int-valued BinOp in main emit loop used 32-bit `eax/edx/ebx` + `cdq/idiv` — now `rax/rdx/rbx` + `cqo/idiv`; (e) UnOp and SetBang used 32-bit regs — now 64-bit; (f) for-loop init const/path stores used `eax` — now `rax`; (g) **phi-slot stores/loads** (If/Match/While results) wrote 32-bit `eax` into 8-byte slots, leaving garbage in the upper half that later 64-bit reads picked up — this was the root cause of the `test_stringbuffer_growth.zyl` SIGSEGV (the grow-size passed to `arena-alloc-zeroed` came back as `0x7fff00000080`); all slots now store/load full `rax`. Verified: `test_stringbuffer_growth.zyl` prints `length: 104` exit 0; all struct regression tests (6) + stdlib_test pass; 12 test_*.zyl files exit 0.
6. ~~Hash finalization (Phase 11)~~ — **done**: SHA-256 binary fingerprinting via `--hash` flag.
7. ~~Full REPL~~ — **done**: complete REPL with full pipeline (parse → type check → compile → run).
8. ~~Self-hosting Phase 1: Define compiler IR in Zyl~~ — **done**: IR opcodes, lexer, parser all in Zyl
9. ~~Self-hosting Phase 2a: Lexer in Zyl~~ — **done**
10. ~~Self-hosting Phase 2b: Parser in Zyl~~ — **done**: all PostProcessor special forms, paren-balanced, compiles clean
11. ~~Self-hosting Phase 2c: Parser verification + AST manipulation helpers~~ — **done**
12. Self-hosting Phase 3: ICNF + codegen in Zyl — core pipeline done and verified end-to-end for: arith, if, while, for, cond, set!, defn-with-params, ADT construction, match over field-carrying and nullary variants. **Next bootstrap blockers** (in rough priority): self-hosted codegen lacks calls-with-arg-evaluation robustness for >6 args, string/FFI emission paths are untested, and Rust-codegen statement-emission heuristics still miscompile some value-returning if/let chains in stdlib shapes (symptom: crashes that shift when debug prints are added — e.g. an iterative variant-tag using while+set! inside if/begin miscompiled, fixed by using tail-recursion instead). Prefer recursion and flat begin-sequences in stdlib compiler modules until emission heuristics are replaced with a sound scheme.
13. Contract injection (optional overlay, spec §23)

---

## History

- **Self-hosting: while + set! in self-hosted ICNF/codegen; three Rust codegen result-propagation fixes (60344c8, 8af69f0, 779f73b)** — (1) `src/codegen.rs`: dead Load/Const skip rule now only skips pure statements followed by a non-pure statement, so leaked control-flow supply nodes after the true trailing value no longer suppress the function result (while-in-function returned the stale condition flag). (2) If-branch phi stores: the branch's final value node is re-emitted fresh via `emit_load_into` before the `emitted_ids` check, and Call/FfiCall count as value kinds — nested if-expressions whose branches were calls returned `1` (the comparison flag) instead of the branch value. (3) Self-hosted lexer `str-end` rewritten as pure recursion (`scan-str`); self-hosted icnf gained while/set! lowering and codegen gained loop emission plus setcc-with-al and non-reversed binop operand order. Verified end-to-end: the Zyl-written pipeline compiles a while/accumulator program that prints `10`; suite 24/24.

Detailed phase-by-phase implementation history, debugging notes, and fix documentation are preserved in:
- `docs/implementation-status.md` — current phase details
- `specifications/` — historical specification versions (v1.0 through v4.1)

### Recent Fixes

- **SIGSEGV: nested `if` inside `while` body clobbered a param slot (codegen.rs)** — The `if (> i 0)` inside `emit-children`'s `while` stored its result to `[rbp-16]`, overwriting the `list` param (slot 1). Root cause: `collect_func_phi_slots` / main-path `register_nested_ifs_recursive` only recursed into If/Match branch bodies, not While/For/Begin bodies, so nested If result_vars got no pre-computed phi slot; and the While/For/cond-body emitters passed an empty `phi_slots` map, forcing the If handler's dynamic slot `(0+1+1)*8 = 16`. Fixed by (1) recursing into While/For/Begin bodies in both slot-registration passes, (2) passing the inherited `phi_slots` instead of an empty map in While/For/cond/body emission, and (3) preferring the registered `local_vars` slot in the If handler before the dynamic fallback. Verified: `test_ir.zyl` compiles and the generated binary runs to completion (no SIGSEGV); regression suite still passes.
- **Untyped function param struct binding resolution (type_inference.rs + icnf.rs)** — Functions with untyped params (e.g. `get-x: (defn get-x (p) (struct-get p "x"))`) stored fresh `Type::Var` in `known_functions` during Defn collection. In `handle_apply`, untyped params created a *fresh* `Type::Var` unified with the arg type, but the stored `Var` (from the Defn) was never in the substitution map, so `resolved_func_params` returned unresolved vars. ICNF struct binding fallback (`resolved_func_params`) therefore resolved to wrong field offsets (e.g. `get-x`/`get-y` both returned field 0). Fix: in `handle_apply`, untyped params now use the inferred arg type directly (no fresh var) and update `known_functions` entries in-place, so the substitution map resolves them to the concrete struct type. Scales to multiple call sites and multiple struct types with same accessor names (e.g. `Point.y` vs `CMYK.y`) without flat-map collision. All tests pass: T1–T6, NESTED (7, 11), stdlib_test.zyl, multi-struct/multi-call stress tests.
