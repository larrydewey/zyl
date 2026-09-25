# Sound Types: Design

Status: planned (2026-09-24). The goal is a guarantee, not a best effort:
**a program the compiler accepts never uses a value at the wrong
representation.** No Int used as a pointer, no Float through the integer
unit, no String compared by address, no call with the wrong arity, no
unhandled type confusion anywhere, in user code, the standard library, or
the compiler itself.

## Where we start

`type_annotate.zyl` is Hindley–Milner with Tarjan-SCC generalization of
top-level functions, but it fails open:

- A unification failure **poisons** both sides instead of reporting; a
  poisoned class then unifies with anything.
- A failed occurs check poisons and returns success.
- About 27 "don't know" sites hand out a fresh type variable (unknown
  identifiers, `nil`, malformed forms, every FFI result but 11).
- Any function wrapping an `ffi-call` generalizes to `forall a b. a -> b`:
  an unsafe coerce. There are 37 such one-line wrappers in the tree.
- Conditions are never checked against Bool; arithmetic is
  `forall a. a a -> a`; statement forms return Int; top-level `def` is not
  typed; a trait call on an unresolved receiver becomes a run-time tag
  dispatch; per-type specialization silently stops after 32 instances.
- Only four checks ever report: an argument clashing with a parameter or
  field annotation, a missing struct field, a primitive where a byte
  handle is required, and a trait with no impl.

`type_inference.zyl` (2,965 lines) is never run; only two helpers and an
empty inferer are used.

## Decisions (with the user, 2026-09-24)

- **No escape hatch.** There is no `unsafe` cast form. The trusted base is
  the compiler and the C runtime; every Zyl line, including the standard
  library and the compiler, type-checks.
- **Unit** is a real type. Statement forms (`print`, `set!`, `while`,
  `assert`, `file-write`, `send`, ...) return Unit. `main` returns Int.
- **Bool-only conditions** for `if`, `cond`, `when`, `while`, guards and
  contract clauses.
- **A closed Num class** {Int, Float} for `+ - * / %` and the ordering
  comparisons (which also accept String, as today). No implicit
  conversion; mixing Int and Float is a type error.

## The checker

One pass, `type_annotate.zyl`, is the only authority.

1. **Every failure is an error.** `ta-unify` takes the node it is checking
   and reports `E_TYPE_MISMATCH` with both types, the expected one first,
   and, where the other type came from a binding or a signature, a label
   at that position. Poisoning is removed. An occurs-check failure is
   `E_INFINITE_TYPE`.
2. **No fresh variable for ignorance.** Each current "don't know" site
   becomes a rule or an error: an unknown identifier is
   `E_UNBOUND_VARIABLE` (located, with suggestions, as codegen does now);
   `nil` is gone; malformed forms (`EUnknown`) are rejected before typing;
   `def` is typed (monomorphic, value restriction).
3. **Generalization** stays at top-level SCCs; local `let` stays
   monomorphic. A variable left unconstrained at generalization is a real
   type parameter; one that is constrained by Num and never resolved is
   specialized per call (as today) or, at a monomorphic use,
   `E_CANNOT_INFER`.
4. **Traits.** A trait call must resolve statically to an impl or to a
   trait-generic function specialized per type. The run-time tag dispatch
   (`ic-trait-dispatch`) is deleted; an unresolved receiver is
   `E_CANNOT_INFER`. The specialization cap becomes an error, not a
   silent fallback.
5. **Structs and ADTs.** Every field has a type (an untyped field is an
   error or a declared type parameter); no constructor can produce an
   existential.

## The primitive surface

Everything the checker cannot see into gets a declared type:

- **Runtime functions.** A signature table in the compiler gives every
  `zyl_*` symbol a type scheme. An `ffi-call` to a runtime symbol with no
  signature is an error.
- **Foreign functions.** `(extern "strlen" (String) Int)` declares a C
  function; `ffi-call` to an undeclared foreign symbol is an error. The
  C-side types are Int, Float, Bool, String, `Ptr` (an opaque address that
  can only be passed back to C) and the byte handle types.
- **`zyl_panic`** is `String -> a` (it never returns).
- **Typed handles instead of words.** The runtime's services used by the
  compiler (string maps, word vectors, attribute tables, union-find) get
  opaque parameterized types, e.g. `(SMap v)`, `(Attr k v)`. The global
  handle-by-index calls (`zyl_smap_global 7`) are replaced by top-level
  `def`s of the right type. Lookups that return 0 for "absent" take a
  default of the value type instead.
- **Raw memory** (`alloc-read-int`/`alloc-write-int`) reads and writes
  Ints only. Generic containers that stored arbitrary words in arena
  memory use a runtime-provided `(Array a)` with typed `array-get` and
  `array-set`.
- **The interpreter** stops forging values from words: interpreted
  strings stay Strings, and its FFI calls go through a typed marshalling
  entry in the runtime.

## Region safety

Region inference trusts the type pass's scalar mark (attr 5): a node typed
Int, Bool or Float joins no object class. The strict checker keeps that
sound: with no casts, no pointer can be typed as a scalar.

## Evidence

- Typing rules for every core form in the specification (a new section),
  and one compile-fail test per rule.
- A type-tagged interpreter mode: every value carries its type tag and
  every primitive checks its operands. The whole suite running clean in
  that mode is an empirical check of preservation; a tag failure is a
  checker bug, located at the expression.
- The compiler type-checks itself under the strict checker.

## Phases

1. **Report mode.** `ZYL_STRICT_TYPES=report` turns every failure and
   every "don't know" into a located diagnostic without stopping, so the
   remaining work can be counted per module.
2. **Primitive surface.** Signature table, `extern`, typed handles, Unit,
   Bool, Num.
3. **Port** the standard library, the REPL, the LSP and the compiler until
   report mode prints nothing.
4. **Strict by default.** Failures are errors; poisoning, the tag dispatch
   and `type_inference.zyl` are deleted.
5. **Evidence.** Spec rules, compile-fail tests, the tagged interpreter.
