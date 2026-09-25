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
| Compiler | ~22,600 lines of Zyl across 39 files in `stdlib/compiler/` |
| Standard library | `core`, `collections`, `allocator`, `actor`, `ffi`, `io`, `atomic`, `testing`, `math` |
| Cryptography | `stdlib/math/`, ~7,600 lines of Zyl |
| REPL | `stdlib/repl/`, ~4,100 lines of Zyl, with an ICNF interpreter; `zyl repl` and `zyl eval` |
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
| Generics | Works. Top-level functions are generalized per strongly connected component of the call graph (Hindley–Milner); generic ADTs and structs take their type parameters from uppercase field types, and an untyped field is an implicit type parameter. A function that calls a trait method, prints, or applies an operator at a type variable is specialized per concrete argument types into an instance named `f~T1,T2` (argument order, spec §6.4), at every call and every use as a value; the generic original is dropped. More than 256 instances of one function is `E_CANNOT_INFER`. The §6.1 bound spelling `((T : Ord) x)` does not work: the lexer reads `:Ord` as a keyword, so `T` becomes an ordinary parameter and the arity grows by one |
| Traits and `impl` | Works. `(Trait.method recv ...)` is resolved at compile time from the receiver's inferred type to `Trait.method_Type`; a method's `Self` is its receiver's type. There is no run-time dispatch: a call whose receiver type stays unknown is `E_CANNOT_INFER`, and a concrete receiver with no impl is `E_TRAIT_NOT_FOUND`. Two written impls of one trait for one type are `E_DUPLICATE_IMPL` |
| `derive` | Show, Debug, Eq, Ord, Hash and Clone generate impls (`derive.zyl`); anything else, or a field whose type lacks the trait, is `E_TRAIT_NOT_DERIVABLE`. `print` of a value whose type has a Show impl prints `Show.show` of it; without one, a struct or ADT prints an address. `==` compares structs and ADTs by content, deeply, with or without a `derive` (a generated `T.==` per type). `<`, `>`, `<=`, `>=` take Int, Float and String only; an ADT is ordered with `Ord.compare` |
| Closures | Works, including closures that capture and escape (heap `[tag, code, env]` values) |
| `try`/`catch` | Works: `(try body (catch e handler))`; `error` and `zyl_panic` unwind to the nearest `try` |
| Macros | `defmacro` expansion works in every form, with gensym hygiene, arity, duplicate and termination checks; parameters are plain names (no patterns) |
| Modules and packages | Works: `use`, canonical keys, `pub` visibility, capabilities |
| Actors | `spawn` (bodies may capture immutable values), `send`, `(receive)`, `(actor-self)`, `actor-wait`; structured messages and replies to `main` work |
| FFI | `ffi-call` works. The trailing timeout must be a positive integer literal (`E_FFI_TIMEOUT_REQUIRED`) and is enforced: a foreign call runs on a worker thread and raises `E_FFI_TIMEOUT` when it overruns, the C function being abandoned rather than killed (`zyl_*` runtime symbols are called directly). A foreign symbol needs an `(extern "sym" (T ...) R)` declaration, whose types must be concrete and fit a machine word (no Float); a runtime symbol is typed by `ffi_sigs.zyl`, and the raw entries there (`ffi-raw-p`) are `E_FFI_RESTRICTED` outside the standard library. Pinning is enforced only for `Secret` values (`E_FFI_PIN_REQUIRED`) |
| Regions | Real (`docs/regions-design.md`). Region inference places every allocation and call site in the frame's own region (released on return, before a tail jump, or when a caught panic unwinds it), the caller's result region, or the heap; a non-escaping `let`-bound variant still goes on the stack. `with-region` gives explicit `arena`/`fixed` regions (`E_REGION_SPEC`, `E_REGION_EXHAUSTED`); `E_REGION_ESCAPE` is raised for an escaping Stack bytebuf or `with-region` value. Heap values that escape live until exit. `ZYL_REGIONS=0` turns inference off. Circular and Global regions are not inferred |
| Capability types | `TCap`/`TMut` are enforced syntactically (`let` vs `let-mut`) by `mutability_check.zyl` |
| `Secret` capability | Enforced by `secret_check.zyl` (branch, index, divide, print, escape, unpinned FFI) |
| Byte primitives | 8-, 16-, 32- and 64-bit loads and stores (le/be), byte buffers (`ByteBuf`), slices (`ByteSlice`), atomics and alignment work |
| Test harness | Works: `test`, `run-tests`, `assert-equal`, `assert-true`, `assert-false` |
| Type inference | Strict Hindley–Milner (`type_annotate.zyl`, spec §4.8–§4.10). Every unification failure is `E_TYPE_MISMATCH`, an occurs-check failure `E_INFINITE_TYPE`, a type the program does not determine `E_CANNOT_INFER`, a name defined nowhere `E_UNBOUND_VARIABLE`; all are reported, then the compile fails. Conditions are Bool, arithmetic is Int or Float with no mixing, statements are Unit, `main` is `() -> Int`. `ZYL_STRICT_TYPES=report` prints them as `W_TYPE_STRICT` warnings instead. The compiler, the REPL and the language server type-check clean. The one known hole (`receive`) and the remaining gaps are listed below |
| Contracts | `requires`, `ensures` (with `result`) and `invariant` are checked at run time (`E_CONTRACT_VIOLATION`); `recover` arms match error codes; `checkpoint` rolls back `let-mut` state; profiles by `--contracts=P` or `(contracts P)` |

### Known gaps

- **The type checker's one hole** is the one spec §4.8 names: `receive`
  returns any type, because a mailbox holds whatever any sender put
  there. Holes found while porting and since closed: a `struct-get` whose
  record type stays unresolved when several structs have the field is
  `E_CANNOT_INFER` (with exactly one such struct the receiver is taken to
  be it); a top-level `def` is not generalized (value restriction); an
  `extern` for a symbol the runtime exports is `E_FFI_RESTRICTED`, so
  runtime entries are typed only by `ffi_sigs.zyl`; `(ffi-pin v)` is
  `(Pin a)` and `ffi-unpin` takes a `(Pin a)` back to `a`.
- **Type-checker gaps that are not holes:**
  - An unknown type name in an annotation, such as a misspelled
    `Strng`, silently becomes a type parameter instead of an error.
  - A type variable in a use that no function signature mentions (the
    error type of `(Ok "yes")`, say) is defaulted to Int.
  - Match guards on range arms and guards naming a top-level `def` are
    mis-handled (`E_ARITY_MISMATCH` / `E_UNBOUND_VARIABLE`).
  - Byte-buffer regions are not part of the type:
    `(if c (bytebuf Stack 4) (bytebuf Heap 4))` type-checks.
- **Contracts** (§23): `checkpoint` rolls back `let-mut` variables only
  (byte-buffer writes are not undone); errors carry no type beyond their
  message, so `recover` arms match an error-code prefix.
- **Hash finalization** (§31.12): only package builds (`zyl build`, `zyl
  test`) write `zyl.buildinfo` and embed `zyl_build_hash`; a single-file
  compile writes neither.
- **Unlocated diagnostics:** `mutability_check`, `capability_check`,
  `unused_check` and the remaining errors in
  `expr_inner` still print a bare `PANIC:` message with no location.
- **Tail-call optimization:** a call in tail position (an `if` branch, a `let` body, the last form of a `begin`, a `match` arm body), direct or through a function value, is a jump, provided its stack arguments (beyond six) fit in the caller's own incoming ones. Calls inside `try`/`catch` or `while`, and in frame-wiping (secret) functions, still push a frame. The REPL interpreter runs tail calls in constant stack unless the result is a String or Float.
- **Package system:** the default index URL is not hosted yet (use
  `ZYL_INDEX` and `zyl publish --index`), and
  capability enforcement applies only to packages with a manifest.
  `PROGRESS.md` has the full list, including the deliberate deviations.
- **REPL:** actors are compile-only (the interpreter reports
  `E_UNSUPPORTED_INTERPRETED`). See `docs/repl.md`.
- **Language server:** does not run the type pass or the capability
  check, and reports one error at a time (warnings all together).

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
