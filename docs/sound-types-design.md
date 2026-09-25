# Sound Types: Design

Status: implemented (2026-09-24 to 2026-09-25). Strict checking is the
default since commit d6f4ec2. The guarantee, not a best effort:
**a program the compiler accepts never uses a value at the wrong
representation.** No Int used as a pointer, no Float through the integer
unit, no String compared by address, no call with the wrong arity. This
holds for user code, the standard library, the REPL, the language server
and the compiler itself, with one documented exception (see "Known
hole" below).

The normative rules are in `zyl_specification.txt` §4.8–§4.10 and §16.
This document records the design decisions and how they were reached.

## Where we started

`type_annotate.zyl` was Hindley–Milner with Tarjan-SCC generalization of
top-level functions, but it failed open:

- A unification failure **poisoned** both sides instead of reporting; a
  poisoned class then unified with anything.
- A failed occurs check poisoned and returned success.
- About 27 "don't know" sites handed out a fresh type variable (unknown
  identifiers, `nil`, malformed forms, every FFI result but 11).
- Any function wrapping an `ffi-call` generalized to `forall a b. a -> b`:
  an unsafe coerce. There were 37 such one-line wrappers.
- Conditions were never checked against Bool; arithmetic was
  `forall a. a a -> a`; statement forms returned Int; top-level `def` was
  not typed; a trait call on an unresolved receiver became a run-time tag
  dispatch; per-type specialization silently stopped after 32 instances.
- Only four checks ever reported.

`type_inference.zyl` (2,965 lines) was never run; only two helpers and an
empty inferer were used.

## Decisions (with the user, 2026-09-24)

- **No escape hatch.** There is no `unsafe` cast form. The trusted base is
  the compiler, the C runtime, the runtime-signature table and a program's
  own `extern` declarations.
- **Unit** is a real type. Statement forms (`print`, `set!`, `while`,
  `for`, `if` without else, `assert*`, `send`, ...) return Unit. `main`
  returns Int.
- **Bool-only conditions** for `if`, `cond`, `when`, `while`, guards,
  assertions and contract clauses.
- **A closed Num class** {Int, Float} for `+ - * / %`; ordering also takes
  String. No implicit conversion; mixing Int and Float is a type error.

## What was built

### The checker

`type_annotate.zyl` is the only authority. `type_inference.zyl` and
`monomorphization.zyl` were deleted (impl lifting moved to
`lift_impls.zyl`), and `type_system.zyl` shrank from 925 lines to the
`Pair` and `Region` types.

- **Every failure is an error.** `ta-type-error` reports each failure at
  the innermost expression being typed; after the whole program is typed,
  `ta-fail-if-errors` fails the compile with the first error's code.
  Poisoning remains only to stop one error cascading into many.
  `ZYL_STRICT_TYPES=report` prints the same diagnostics as `W_TYPE_STRICT`
  warnings and continues; it exists for counting what is left and never
  runs an ill-typed program in production.
- **Codes.** `E_TYPE_MISMATCH` (two types that must be equal),
  `E_INFINITE_TYPE` (occurs check), `E_CANNOT_INFER` (a type the program
  does not determine, an unresolved trait receiver, a foreign symbol with
  no `extern`), `E_UNBOUND_VARIABLE` (a name defined nowhere).
- **Generalization** stays at top-level SCCs; local `let` is monomorphic.
- **Traits have `Self`.** A method's `Self` is its receiver's type, so
  `(trait Ord (compare (self (other Self)) Int))` takes two values of one
  type. Before, `other` was unrelated to `self` and the specializer keyed
  on `self` alone, picking the wrong impl for the other argument.
- **No run-time trait dispatch.** A trait call resolves statically to an
  impl; a trait-generic function is specialized per type at every call
  *and every use as a value*, and the generic originals are dropped from
  the program. `ic-trait-dispatch` is gone. It had been a real hole: it
  sent every non-variant type (Int, String, Bool) to the first such impl,
  so `(map show-it (list "a"))` printed an address and a list of Bools
  crashed. More than 256 instances of one function is `E_CANNOT_INFER`.
- **Structs and ADTs.** An untyped struct field is an implicit type
  parameter of its struct (named `'Variant.field`, which no source can
  spell). It used to be existential: `(make-Pt "a" 2)` then `(+ x 1)` was
  accepted. A program type may not reuse a prelude constructor name
  (`E_DUPLICATE_VARIANT`), because the standard library uses `Some`,
  `Cons`, ... unqualified and would resolve to it.
- **Ordering** is on Int, Float and String. An ADT is ordered with
  `Ord.compare`: codegen had compared addresses for `<` on ADTs.

### The primitive surface

- **Runtime functions.** `compiler/ffi_sigs.zyl` gives every `zyl_*`
  symbol the compiler calls a type scheme over Int, Float, Bool, String,
  Unit and opaque handle types: `Arena`, `Ptr`, `Words`, `StrBuf`, `UF`,
  `Actor`, `Fd`, `FileId`, `FnPtr`, `(SMap v)`, `(WVec v)`, `(Attr k v)`,
  `(Array a)`, `(Ref a)`. The global handle-by-index calls became typed
  top-level `def`s (`compiler/node_tables.zyl`). Lookups that returned 0
  for "absent" take a default of the value type.
- **Raw entries.** The entries that read raw memory or reinterpret a
  machine word (`zyl_cstr_of_word`, `zyl_word_load`, `zyl_mem_read`,
  `zyl_call_argv`, the interpreter's `zyl_val_*`, ...) are typed but may
  only be named in an `ffi-call` inside the standard library
  (`E_FFI_RESTRICTED`); in a user program they would be the cast the
  language does not have.
- **Foreign functions.** `(extern "strlen" (String) Int)` declares a C
  signature; an `ffi-call` to an undeclared foreign symbol is an error.
  Extern types are concrete (no type variables) and word-sized: Int,
  Bool, String, `Ptr`, handles, and `(Fn (A ...) R)` for a callback. Float
  is rejected because the timed FFI worker passes machine words.
- **Byte operations.** `ta-walk-int` typed each operand but required
  nothing of it, so a String offset was accepted and its address used as
  the offset. Each offset, length and stored value is now required to be
  Int (`ta-expect`). Each handle is the kind its runtime entry accepts
  (`ta-buf-op`): `byteslice`, `bytebuf-append`, `bytebuf-len`, `-cap`,
  `-ptr` and the atomics a ByteBuf, `byteslice-sub` and
  `bytebuf-append`'s second operand a ByteSlice. A load or store takes
  either; before, it rejected only a primitive, so an unannotated handle
  accepted any value. A load/store handle still a type variable is queued
  like an ambiguous `struct-get` and is `E_CANNOT_INFER` if its function
  group does not settle it (`ta-bytes-ambiguous`).
- **File operations.** A file is its descriptor, an Int. `file-read` is
  `Int Int -> String`, `file-write` `Int String -> Int`, `file-close`
  `Int -> Int`. `file-write` used to accept an Int as its data and pass
  it to `strlen` as an address.
- **List literals.** `(list ...)`, `[...]` and quoted data `'(...)` are
  rewritten to `Cons` chains before typing, so they need no rule of
  their own: the elements share one type. A unification failure inside a
  type (two list elements) is reported there and not again by the
  enclosing unification (`ta-unify` compares the error count).
- **Generated helpers.** A `def` getter's cell operations are named with
  spaces (`zyl global get`), which no source can spell, so their
  `String -> a` read can only come from the getter, whose `if` joins it
  with the stored value's type. The REPL's session read
  (`zyl-repl-global`) is typed only while the REPL compiles its own
  program, and refused in user input.

### Forms that were silently wrong

Porting found many forms that compiled to something other than what was
written. Each is now an error or does what it says:

- A special form whose shape its parser rejected became `EUnknown`, which
  lowered to the constant 0: `E_MALFORMED_FORM`. It found tests that had
  passed vacuously, such as `(assert-equal x)` with one argument.
- `test`, `fn`, `lambda`, `try` handlers, `cond` clauses and the
  binding-list `let` kept only their last (or first) body form; the
  bodies are implicit `begin`s, and `test`/`defmacro` take exactly one.
- Nested patterns, `(Some (LSPObject obj) ...)`, matched on the outer tag
  alone: `E_NESTED_PATTERN`.
- The duplicate-arm check compared pairs as strings and never fired.
- `file-open` with a non-literal mode opened for writing, so every
  `(file-open p 0)` meant to read truncated the file; the mode must be a
  literal fopen mode.
- `assert-equal` did not unify its two sides, `assert-true` took any
  type, and ADT equality inside `assert-equal` was chosen by a syntactic
  "looks like a variant" rewrite (`assert_lowering.zyl`, deleted); the
  type decides now. Unary minus on a Float subtracted from an Int zero.

## Evidence

- **The compiler type-checks itself.** The three program roots (the
  compiler, the language server, the standalone REPL) are clean, and the
  fixed point holds.
- **Per-rule compile-fail tests** in `tests/compile-fail/` (`type-*`,
  `ffi-extern-*`, `ffi-undeclared`, `ffi-raw-restricted`, `malformed-*`,
  `trait-*`, `main-returns-int`, `spawn-entry-arity`, `ordering-on-adt`,
  `prelude-constructor`, `match-*`, `let-without-body`, `bytes-offset-type`,
  `bytes-handle-kind`, `bytes-handle-unknown`, `file-write-data`,
  `list-literal-mixed`, `quote-name`, `view-raw-restricted`).
- **A checking interpreter.** With `ZYL_INTERP_CHECK=1` the interpreter's
  values carry their tags (Int, Float, String, block); every operator
  checks its operands (arithmetic on two Ints or two Floats, comparison
  within one tag, bit operations on Ints) and every condition must be
  exactly 0 or 1. The interpreter-vs-codegen category always runs in this
  mode, so the suite is an empirical check of preservation. Its first run
  found three real gaps (listed above), now fixed.

## Known hole

The byte-operation and `file-write` holes above were found after strict
checking became the default and closed on 2026-09-25; `receive` is again
the only one.

`receive` returns a value of any type: an actor mailbox holds whatever
any sender put there, so no type can be given to what comes out without
effect typing. The deterministic-concurrency work replaces mailboxes with
typed single-sender channels, which removes it. Until then it is the only
unchecked typing a program can reach.

## Not done

- The interpreter's checking mode does not distinguish Bool, Unit and ADT
  values from Int words (ICNF erases those types); it checks
  representations, which is what the soundness claim is about.
- Match guards on range arms and guards naming a top-level `def` are
  mis-handled (E_ARITY_MISMATCH / E_UNBOUND_VARIABLE).
- The type pass does not distinguish byte-buffer regions:
  `(if c (bytebuf Stack 4) (bytebuf Heap 4))` type-checks.
