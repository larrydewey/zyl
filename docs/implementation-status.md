# Implementation Status

## Current state

**Self-hosting is complete and there is no Rust in the active path.**
The compiler written in Zyl (`stdlib/compiler/*.zyl` plus
`selfhost/driver.zyl`, assembled by `selfhost/assemble.py`) compiles
itself to a byte-identical fixed point, verified by `./boot.sh`.
Building Zyl needs `cc` and `pthread` and nothing else.

| | |
|---|---|
| Specification | `zyl_specification.txt` v5.0 (§0–§31) |
| Compiler | ~21,200 lines of Zyl across 37 files in `stdlib/compiler/` |
| Standard library | `core`, `collections`, `allocator`, `actor`, `ffi`, `io`, `atomic`, `testing`, `math` |
| Cryptography | `stdlib/math/`, ~7,600 lines of Zyl |
| REPL | `stdlib/repl/`, ~4,000 lines of Zyl, with an ICNF interpreter; `zyl repl` and `zyl eval` |
| Language server | `stdlib/lsp/`, ~5,400 lines of Zyl, built by `boot.sh` as `zyl-lsp` |
| Package system | Spec §31, implemented (see below) |
| Runtime | `runtime/actor_runtime.c` |
| Tests | 121/121 passing on `./run_regression_tests.sh --full` (regression 52, interpreter 34, compile-fail 12, integration 7, packages-fail 7, stress 4, packages 2, packages-build 1, lsp 1, unit test 1) |

### Language features

Status as of this writing, checked against the compiler. "Works" means
it compiles and runs correctly; the notes say where it stops.

| Feature | Status |
|---|---|
| S-expression syntax, dispatch-free reader | Works |
| `let`, `let-mut`/`set!`, `if`, `cond`, `while`, `for`, `begin` | Works. `set!` on a plain `let` binding or on a field is `E_MUT_CONFLICT` |
| Functions, recursion | Works. Direct calls with the wrong argument count are `E_ARITY_MISMATCH` |
| Integers, 64-bit | Works, including bitwise `bit-and`/`bit-or`/`bit-xor`/`shl`/`shr`/`ashr` |
| Float64 | Works: literals, arithmetic, comparisons, printing |
| Structs | Works: `defstruct`, `make-<Name>`, `struct-get`, rebinding with `let-mut` |
| ADTs and `match` | Works, including literal patterns, OR-patterns, range patterns and guards. A non-exhaustive ADT match is `E_NON_EXHAUSTIVE_MATCH`; a literal match needs a trailing `_` |
| Generics | Works through monomorphization with sorted canonical names |
| Traits and `impl` | Works: `(Trait.method recv ...)` dispatches on the receiver's runtime tag |
| `derive` | `Eq`, `Ord` and `Debug` are accepted. `==` compares structs and ADTs by content, deeply, and `<` lexicographically over raw field words (with or without a `derive`). `Show` is not implemented, and printing a struct or ADT prints an address |
| Closures | Works, including closures that capture and escape (heap `[tag, code, env]` values) |
| `try`/`catch` | Works: `(try body (catch e handler))`; `error` and `zyl_panic` unwind to the nearest `try` |
| Macros | `defmacro` expansion works in every form, with gensym hygiene, arity, duplicate and termination checks; parameters are plain names (no patterns) |
| Modules and packages | Works: `use`, canonical keys, `pub` visibility, capabilities |
| Actors | `spawn` (bodies may capture immutable values), `send`, `(receive)`, `(actor-self)`, `actor-wait`; structured messages and replies to `main` work |
| FFI | `ffi-call` works. The trailing timeout argument is dropped by lowering and never enforced, and pinning is enforced only for `Secret` values (`E_FFI_PIN_REQUIRED`) |
| Regions | Escape analysis puts a non-escaping variant on the stack; everything else is heap. Circular and Global regions are not inferred |
| Capability types | `TCap`/`TMut` are enforced syntactically (`let` vs `let-mut`) by `mutability_check.zyl` |
| `Secret` capability | Enforced by `secret_check.zyl` (branch, index, divide, print, escape, unpinned FFI) |
| Byte primitives | 8-, 16-, 32- and 64-bit loads and stores (le/be), byte buffers (`ByteBuf`), slices (`ByteSlice`), atomics and alignment work |
| Test harness | Works: `test`, `run-tests`, `assert-equal`, `assert-true`, `assert-false` |
| Type inference | Best-effort. It feeds monomorphization and codegen, and rejects only an argument to a top-level function or constructor that definitely clashes with its annotation (`E_TYPE_MISMATCH`): `(+ 1 "a")` compiles |
| Contracts | `requires`, `ensures` (with `result`) and `invariant` are checked at run time (`E_CONTRACT_VIOLATION`); `recover` falls back on error; `(contracts off ...)` strips them. No profiles; `checkpoint` does not roll back |

### Known gaps

- **Type inference compares names with `=`.** In `type_inference.zyl`
  that lowers to a pointer comparison when the operand kinds are not
  known to be String, so those comparisons are always false and a
  builtin operator is never recognized by name (REPL `:type (+ 1 2)`
  answers *unresolved*). The module system works around it by copying
  each qualified name per occurrence (`qualify.zyl`'s `qf-ident`); the
  dormant path behind those comparisons dereferences a null parameter
  list the moment they start returning true. Fixing it is a
  type-inference change; see the header of
  `stdlib/lsp/compiler_bridge.zyl`.
- **No return-type inference in codegen.** `print` of a String a
  function computes at run time (for example, a generic function
  returning its String argument) can print an address, and `==` on
  Strings built at run time compares addresses in compiled code.
- **Call targets are resolved only in codegen.** A call to an undefined
  function, such as the unimplemented `(list ...)` literal or an
  implicit-lambda form `((x) body)`, is a located `E_UNBOUND_VARIABLE`
  from `cg-call-user`, but no earlier phase reports it.
- **Contracts** (§23): no profiles (`strict`, `debug`, `warn`,
  `production`), no `checkpoint` rollback, and `recover` ignores its arms'
  error types (the first arm's fallback always applies).
- **Hash finalization** (§31.12): `zyl build` and `zyl test` write
  `zyl.buildinfo` with the compiler, graph, native-object and assembly
  hashes, but the graph hash is not mixed into the binary's own hash,
  and a single-file compile writes no buildinfo.
- **Unlocated diagnostics:** `mutability_check`, `capability_check`,
  `unused_check`, `secret_check` and the remaining errors in
  `expr_inner` still print a bare `PANIC:` message with no location.
- **Partial tail-call optimization:** a direct call to a top-level function in tail position (an `if` branch, a `let` body, the last form of a `begin`, a `match` arm body) with at most six arguments reuses the caller's frame and becomes a jump. Calls through a function value, calls with more than six arguments, and calls inside `try`/`catch` or `while` still push a frame. The REPL interpreter does none.
- **Package system:** no index repository exists yet (the index URL in
  the examples is a placeholder), there is no build cache (§31.4), and
  capability enforcement applies only to packages with a manifest.
  `PROGRESS.md` has the full list, including the deliberate deviations.
- **REPL:** actors are compile-only (the interpreter reports
  `E_UNSUPPORTED_INTERPRETED`), and a definition entered at the prompt
  cannot refer to a `def` binding. See `docs/repl.md`.
- **Language server:** does not run `unused_check` or type inference and
  reports one diagnostic at a time.

Design, rationale and the original phased plan for the package system:
`docs/package-management-design.md`.

### Where to look

- `PROGRESS.md` — what changed, session by session, and what is open.
- `docs/rust-eviction-plan.md` — the self-hosting story and the
  fixed-point invariant.
- `docs/codebase-map.md` — where things live.
- `docs/compiler-pipeline.md` — the phase order as the code runs it.
- `book/` — the language book, including the standard library and
  tooling.

---

## Historical note

Earlier versions of this file recorded the phase-by-phase build-out of
the Rust bootstrap (lexer, parser, PostProcessor, region inference,
SSA-form ICNF, a register-allocating code generator). That
implementation is frozen in `archive/rust-bootstrap-2026/` and none of
it describes the active compiler; the detail is preserved in version
control history and in `specifications/`.
