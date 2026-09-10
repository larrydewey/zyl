# Appendix D: Glossary

Definitions of key Zyl terms and concepts.

## A

**Actor**: Isolated concurrent entity with private state and FIFO mailbox. Communicates via message passing.

**ADT (Algebraic Data Type)**: Sum type declared with `deftype`. One of several variants, each with optional payload.

**Alias**: Transparent type wrapper (`alias Name Type`). Zero-cost, fully interchangeable with target type.

**Arity**: Number of parameters a function takes.

**Assertion**: Runtime check via `assert` — aborts on failure.

## B

**Backquote/Quasiquote**: `` `expr `` — template for macro expansion.

**Binding**: Association of name to value. Immutable (`let`) or mutable (`let-mut`).

**Block**: Sequence of expressions (`begin`) or basic block in ICNF.

**Bootstrap**: Building compiler with itself. Zyl: Rust → Stage1 → Stage2 → Stage3.

**Builtin**: Compiler-recognized operation (e.g., `+`, `if`, `print`).

## C

**Capability Type**: Type annotation describing access permissions: `TCap`, `TMut`, `TAtomic`, `TBox`, `TPin`.

**Capture**: Closure referencing variable from enclosing scope.

**Closure**: First-class function with captured environment: `(fn (params) body)`.

**Coherence**: Trait system property — one impl per (Trait, Type) pair.

**Compile-Time**: Phases 1-11 before program execution.

**Contract**: Optional overlay: preconditions, postconditions, invariants, recovery.

**Constant Folding**: Optimization evaluating constant expressions at compile time.

## D

**Data Race**: Concurrent access to shared mutable state — impossible in Zyl by design.

**Dead Code Elimination (DCE)**: Optimization removing unreachable code.

**Defunctionalization**: Not used — Zyl uses closures directly.

**Derivation**: Automatic trait implementation for structs/ADTs.

**Determinism**: Same source + inputs → identical outputs/binaries.

**Dispatch**: Method lookup — static (monomorphized) in Zyl.

## E

**Effect**: Observable side effect (I/O, mutation, FFI, actor send).

**Escape Analysis**: Determines if value outlives its defining scope.

**Evaluation Order**: Strict left-to-right in Zyl.

**Exhaustiveness**: Match must cover all variants — compile error if not.

**ExprInner**: Post-processed AST with specialized nodes (Phase 1-2).

## F

**FFI (Foreign Function Interface)**: Calling C functions from Zyl. Requires pinning + timeout.

**Fixed Point**: `f(x) = x`. Zyl: Stage2.asm == Stage3.asm.

**Float**: IEEE-754 binary64 (64-bit).

**Free Variable**: Variable used in closure but not bound inside.

**Function**: Named (`defn`) or anonymous (`fn`/`lambda`) computation.

## G

**GC (Garbage Collection)**: Not used — Zyl uses region-based memory.

**Generic**: Parameterized by type (`(T)`, `(U)`). Monomorphized at call sites.

**Gensym**: Generated unique symbol for macro hygiene.

**Global Region**: Immutable constants only, program lifetime.

## H

**Heap Region**: Escaped values, closures, collections. Scope-based reclamation.

**Higher-Order Function**: Function taking/returning functions.

**Hygiene**: Macro property — no variable capture. Zyl: gensym-based.

## I

**ICNF (Intermediate Canonical Normal Form)**: Zyl's SSA IR with region annotations.

**Immutability**: Default in Zyl — values never change, only rebind.

**Inference**: Type/region/capability deduction without annotations.

**Inline**: Optimization replacing call with function body.

**Instantiation**: Monomorphization creating concrete type from generic.

**Integer**: Int64 signed (-2^63 to 2^63-1).

## J

**Join Point**: Control flow merge in ICNF (phi nodes).

## K

**Keyword**: Self-evaluating `:identifier` — used for options.

## L

**Lambda**: Anonymous function — synonym for `fn`.

**Lattice**: Region subsumption: `Stack ≤ Heap ≤ Circular`.

**Let**: Immutable local binding.

**Let-Mut**: Mutable local binding (allows `set!`).

**Lifetime**: Region assignment duration.

**Linear Scan**: Deterministic register allocation algorithm.

**Lowering**: Transforming higher-level IR to lower-level (e.g., ExprInner → ICNF).

## M

**Macro**: Compile-time code transformation. Zyl: hygienic, innermost-first.

**Match**: Pattern matching on ADTs. Exhaustive, returns value.

**Monad**: Not a Zyl concept — uses `Result`/`Option` directly.

**Monomorphization**: Generating concrete functions from generics.

**Module**: Compilation unit with imports/exports.

**Mutability**: In Zyl, only via `let-mut` + `set!` (rebinding).

## N

**Namespace**: Module-scoped names.

**Non-Determinism**: Eliminated in Zyl — same input → same output.

**Null**: Does not exist — use `Option` (`None`).

## O

**Optimization**: Phase 7 — constant folding, DCE (safe only).

**Orphan Rule**: Trait impl requires trait or type in current crate.

**Overflow**: Int checked by default — `E_OVERFLOW`.

## P

**Package**: Distribution unit (planned v5.0).

**Param**: Function parameter — immutable.

**Pattern**: Match arm structure — binds variables.

**Phase**: Compilation step (11 phases, strict order).

**Pin Region**: Non-moving memory for FFI.

**Polymorphism**: Parametric (generics) + ad-hoc (traits).

**PostProcessor**: Converts raw Call/Apply AST to ExprInner.

**Primitive**: Int, Float, Bool, String, Unit.

**Profile**: Contract enforcement level: strict/debug/warn/off/production.

## Q

**Qualified Name**: Module-prefixed identifier.

## R

**RAII**: Resource Acquisition Is Initialization — `with-resource`.

**Rebinding**: `set!` on `let-mut` — creates new value, old reclaimed.

**Region**: Memory area with lifetime: Stack, Heap, Global, Circular, Pin.

**Region Inference**: Compile-time region assignment (Phase 4).

**Reification**: Not applicable — no runtime type reflection.

**Result**: Error handling type: `(Ok T)` | `(Err E)`.

## S

**Scope**: Lexical region where binding visible.

**Send**: Capability for actor message passing — `TCap`/`TAtomic`.

**Special Form**: Built-in syntax with custom evaluation (e.g., `if`, `let`).

**SSA (Static Single Assignment)**: Each value assigned once — ICNF form.

**Stack Region**: Local variables, function scope lifetime.

**Struct**: Named product type — immutable fields, `defstruct`.

**Substitution**: Type variable → concrete type mapping.

**Supertrait**: Trait bound on another trait (`: Trait [T]`).

**Symbol**: Quoted identifier `'name` — used as data.

## T

**Tail Call Optimization (TCO)**: Tail calls become jumps — no stack growth.

**Template**: Macro expansion body (with unquotes).

**Trait**: Ad-hoc polymorphism — interface with methods.

**Trait Object**: Dynamic dispatch — not yet supported.

**Tuple**: Anonymous product type: `(tuple a b c)`.

**Type Class**: Haskell term — Zyl uses "trait".

**Type Inference**: Hindley-Milner + capabilities + traits (Phase 3).

**Type Parameter**: Generic placeholder (`T`, `U`) in function/ADT.

## U

**Unquote**: `,expr` in quasiquote — evaluate and splice.

**Unquote-Splicing**: `,@expr` — splice list elements.

**Unit**: No meaningful value — `unit`.

**Unsafe**: Not a Zyl concept — all code safe by construction.

## V

**Variant**: ADT constructor: `(Some 42)`, `None`.

**Visitor Pattern**: AST traversal — used in compiler passes.

## W

**Wildcard Pattern**: Named dummy only (`d1`, `d2`...) — bare `_` forbidden.

**Workspace**: Multi-package project (planned v5.0).