# Appendix D: Glossary

Definitions of key Zyl terms and concepts. Section numbers (§) refer to
`zyl_specification.txt` v5.0. Where the implementation does not yet do
what the specification says, the entry says so.

## A

**Actor**: Isolated concurrent entity with private state and a FIFO
mailbox, created with `(spawn (fn () ...))` and addressed with `send`
(§15). Its id has type `Actor`, the type of `spawn` and `actor-self`
and the first argument of `send`. What `receive` returns is not yet
type-checked.

**ADT (Algebraic Data Type)**: Sum type declared with `deftype`. One of
several variants, each with an optional payload (§8).

**Alias**: Transparent type wrapper, `(alias Name Type)`. Zero-cost and
fully interchangeable with its target (§4.7, §10).

**Arity**: Number of parameters a function takes. A call with the wrong
number of arguments is `E_ARITY_MISMATCH`.

**Assertion**: A check that panics when it fails. The test assertions
(`assert-equal`, `assert-true`, `assert-false`) and the general
`assert` form all work; `assert` panics with its message when that is a
string literal, else with `assert failed` (Appendix C.7).

**Audit**: `zyl audit` — reports the capabilities each package in the
graph declares and uses.

## B

**Balance check**: The pass in `sexp_balance.zyl` that rejects source
whose parentheses, brackets or braces do not balance, with the
position of the offending delimiter. It runs before parsing, and it is
what an editor reports while you type.

**Binding**: Association of a name with a value. Immutable (`let`) or
mutable (`let-mut`).

**Bitwise operators**: `bit-and`, `bit-or`, `bit-xor`, `bit-not`,
`shl`, `shr`, `ashr` — one machine instruction each, with defined
behaviour for out-of-range shift counts (Chapter 32).

**Block**: A sequence of expressions (`begin`).

**Bootstrap**: Building the compiler with itself. Today: committed
seed → stage 1 → stage 2 → stage 3, with `stage2.s == stage3.s` as the
fixed point. The original Rust bootstrap is archived and not in the
build path.

**Builtin**: A compiler-recognised operation (e.g. `+`, `if`, `print`).
Appendix C lists them all.

**Bundle directory**: The directory holding the compiler binary, its
`stdlib/` and the C runtime — `build/boot/` in a build tree,
`~/.zyl/` once installed. The compiler resolves stdlib modules there.
(Not to be confused with the single-file compiler source that
`selfhost/assemble.py` used to produce; that was retired on 2026-09-24.)

**ByteBuf**: A fixed-capacity, zero-initialised block of bytes in a
named region, allocated with `(bytebuf Region capacity)`.

**ByteSlice**: A bounds-checked, zero-copy view of part of a ByteBuf.

## C

**Canonical archive**: The normalised `.tar.zst` form of a package
(sorted paths, fixed modes, zeroed timestamps and owners) whose
uncompressed BLAKE3 hash identifies it in the lock and the store
(§31.7).

**Canonical key**: The identity of a top-level definition,
`<package>@<major>::<module-path>::<symbol>` — for example
`acme/json@1::json/parser::parse` (§31.2). Two packages, or two modules
of one package, may define the same name because their keys differ.

**Capability (package)**: A permission a package declares in its
manifest — `io`, `ffi`, `actor`, `secret`, `native` or `unsafe`. Absent
means none. Using a construct or stdlib module that needs an
undeclared capability is `E_PKG_CAPABILITY_VIOLATION` (§31.9). The
implicit standard library is never capability-checked.

**Capability closure**: The union of every capability granted anywhere
in a resolved graph, recorded in the lock. Growth under `--locked` is
`E_PKG_CAPABILITY_GROWTH`.

**Capability declaration**: The `(capabilities ...)` field of `zyl.pkg`.
A declared set is a ceiling on the declaring package; it is not
re-granted to its dependencies.

**Capability type**: A type annotation describing access permissions
(§4.3). The specification names `TCap`, `TMut`, `TAtomic`, `TBox` and
`TPin`; the compiler also treats `Secret` as a capability (Chapter 33).

**Capture**: A closure's reference to a variable of an enclosing scope.

**Closure**: First-class function with a captured environment:
`(fn (params) body)` or `(lambda (params) body)`.

**Coherence**: Trait system property — one impl per (Trait, Type) pair
(§5.3).

**Compile time**: The phases of §22 that run before the program does.

**Constant folding**: Optimisation that evaluates constant expressions
at compile time. It deliberately skips the bitwise operators.

**Constant-time**: Code whose execution time and memory access pattern
do not depend on secret data. Enforced for `Secret` values by
`secret_check` (Chapter 33).

**Content store**: `~/.zyl/store/blake3/<hash>/`, where `zyl fetch`
places verified package archives. `zyl build` reads only the store and
never uses the network; a missing entry is `E_PKG_NOT_IN_STORE`.

**Contract**: The optional overlay of preconditions, postconditions,
invariants and recovery (§23). `requires`, `ensures` and `invariant`
are checked at run time and raise `E_CONTRACT_VIOLATION`; `recover`
and `checkpoint` handle the failure. The profile decides whether a
failed check panics, warns or is compiled out (Chapter 24).

## D

**Data race**: Concurrent access to shared mutable state — excluded by
design, since actors share no memory.

**Dead code elimination (DCE)**: Optimisation that removes unreachable
code.

**Declassify**: The explicit, greppable way to drop the `Secret`
capability — `declassify`, `ct-eq-bool`, `ct-eq-words-bool`.

**Derivation**: Automatic trait implementation for structs and ADTs,
written `(derive Type Trait ...)` (§5.6, §5.7).

**Determinism**: Same source + same inputs → identical outputs and
binaries (§27). For a package build, "same source" means the same
resolved graph.

**Diagnostic**: A reported error or warning. A located diagnostic
prints `error[CODE]: message` (or `warning[CODE]`), a
`--> file:line:col` line, the source line with a caret under the
problem, any labelled secondary spans, and a `= help:` hint.
`--error-format=json` prints the same content as one JSON object per
line (Appendix A).

**Discard**: `_`. As a parameter, binding or pattern it means "not
used"; it may repeat, and any `_`-prefixed name is likewise exempt from
the unused, shadowing and duplicate-parameter checks.

**Dispatch**: How a trait method call is resolved. A call
`(Trait.method receiver ...)` is redirected to the per-type
implementation for the receiver's inferred type (`type_annotate.zyl`);
a receiver whose type never resolves is `E_CANNOT_INFER`. There is no
dynamic dispatch through trait objects.

## E

**Edition**: The syntax era a package is written in, `(edition "2026")`
in its manifest. v5.0 defines exactly one edition, `2026`; an unknown
one is `E_PKG_UNKNOWN_EDITION` (§31.11).

**Effect**: An observable side effect (I/O, mutation, FFI, actor
send).

**Escape analysis**: Determining whether a value outlives its defining
scope. Region inference uses it to place each allocation in the
current call's region, its caller's result region, or the heap.

**Evaluation order**: Strictly left to right (§11).

**Exhaustiveness**: A `match` must cover every variant; a missing case
is a compile error (§8.3).

**ExprInner**: The post-processed AST, with a dedicated node for each
special form, produced from raw S-expressions by `expr_inner.zyl`.

## F

**Feature**: An optional, additive part of a package, declared in its
manifest and enabled by a dependent. Features are unified across the
graph (§31.10).

**Feature gate**: `(feature-gate feature definition)` — a top-level
definition included only when `feature` is enabled. A gated
definition may add to a package but never replace a base definition
(`E_PKG_FEATURE_COLLISION`).

**Extern**: `(extern "sym" (T ...) R)`, the declaration of a foreign C
function's signature. An `ffi-call` to a foreign symbol needs one; its
types are concrete machine-word types (no `Float`, no type variables).

**FFI (Foreign Function Interface)**: Calling C functions from Zyl with
`ffi-call`, which requires an `extern` declaration for a foreign
symbol, pinning for pointer arguments and a timeout argument (§16).

**Fixed point**: `f(x) = x`. For Zyl: the stage-2 compiler, compiling
its own source, emits exactly the assembly it was built from
(`stage2.s == stage3.s`).

**Float**: IEEE-754 binary64. Never mixed with `Int` in arithmetic, and
never converted implicitly.

**Free variable**: A variable used in a closure but not bound inside it.

**Function**: Named (`defn`) or anonymous (`fn`/`lambda`) computation.

## G

**GC (garbage collection)**: Not used — memory is region- and
arena-based.

**Generic**: Parameterised by type (`(T)`, `(U)`), and monomorphised at
call sites (§6).

**Gensym**: A generated unique symbol. §19.2 requires macro hygiene by
gensym renaming; the expander renames every name a template binds to a
fresh `name__hygN`, numbered in source order.

**Global region**: Immutable constants with program lifetime (§9, R7).

**Graph hash**: The BLAKE3 hash over the canonical serialisation of the
lock, one of the inputs to hash finalisation (§31.6, §31.12).

**Guard**: `(when cond)` placed before an arm's body in a literal-pattern
`match`: the arm is taken only if its pattern matches and `cond` holds.

## H

**Heap region**: Where escaping values, closures and collections live.

**Higher-order function**: A function that takes or returns functions.

**Hygiene**: The macro property that expansion cannot capture a
caller's variables. Specified in §19.2; see *Gensym*.

## I

**ICNF (Intermediate Canonical Normal Form)**: Zyl's intermediate
representation, specified as an SSA IR with region annotations (§18).
The implementation (`icnf.zyl`) is not SSA; region decisions are kept in
a side table and printed with the tree. It is a tree of instructions —
`ILet`, `IIf`, `IWhile`, `IMatch`, `ICall`, `IFfi` and so on — that
code generation lowers to MIR, or walks directly for a function the
native backend does not yet support.

**ICNF interpreter**: The evaluator in `stdlib/repl/interp.zyl` that
runs a REPL entry's ICNF directly instead of compiling it to machine
code. Its results are checked against code generation by the
interpreter regression tests.

**Immutability**: The default — struct fields never change; a
`let-mut` name is rebound instead.

**Implicit standard library**: The stdlib is the package `zyl/std`. It
has no manifest, is visible to every package and is never
capability-enforced (§25).

**Index**: A git repository of S-expression metadata listing every
published version of every package, with its archive URL, hash,
publisher key and signature (§31.8). There is no server component.

**Inference**: Deducing types without annotations (Hindley–Milner,
§4.6).

**Inline**: Optimisation that replaces a call with the function body.
The optimiser does this for small, non-recursive functions before region
inference; `ZYL_INLINE=0` turns it off.

**Instantiation**: Monomorphisation creating a concrete function from a
generic one.

**Integer**: `Int`, 64-bit signed (−2^63 to 2^63−1).

## K

**Key pinning (TOFU)**: Trust on first use. The first resolution of a
package pins its publisher's Ed25519 key in the lock; a later key
change is `E_PKG_KEY_CHANGED` (§31.8).

**Keyword**: A `:name` token, such as the `:le`/`:be` endian selectors
of the byte loads and stores.

## L

**Lambda**: Anonymous function — a synonym for `fn`.

**Language server (`zyl-lsp`)**: The LSP implementation in
`stdlib/lsp/`, built from the self-hosted compiler so that editor
diagnostics and command-line diagnostics are the same diagnostics
(Chapter 35).

**Let**: Immutable local binding, `(let name value body)`.

**Let-mut**: Mutable local binding that `set!` may rebind.

**Lifetime**: How long a value's region lasts.

**List literal**: `(list a b c)`, `[a b c]` or quoted data `'(a b c)`:
the `Cons` chain of the elements in source order, all of one type.

**Lock file (`zyl.lock`)**: The integrity and provenance record of a
resolved graph: each package's version, source, content hash, pinned
key, signature, features and capabilities, plus the capability closure
and graph hash (§31.6). It is not a resolution input: deleting it does
not change which versions are selected.

**Lowering**: Transforming a higher-level representation into a lower
one, e.g. ExprInner → ICNF.

## M

**Macro**: A compile-time code transformation, `(defmacro name (params)
template)`. The template is the body with the parameters replaced by
the unevaluated argument expressions.

**MIR**: The native backend's machine IR (`mir.zyl`): a linear list of
instructions over virtual registers, given machine registers by linear
scan in a fixed order, so the same function always gets the same
assignment.

**Mangling**: The injective encoding of a canonical key into an
assembler symbol, `zy_<package>_<major>__<module>__<symbol>` with
non-alphanumeric bytes escaped (§31.2).

**Manifest (`zyl.pkg`)**: A package's S-expression description: name,
version, minimum compiler, edition, capabilities, dependencies,
features and native sources (§31.3).

**Match**: Pattern matching on ADTs or on literal values. Exhaustive,
and returns a value.

**Module**: A source file within a package. Modules of one package must
form a DAG (`E_MODULE_CYCLE`).

**Monomorphisation**: Generating concrete functions from generic ones,
named canonically (§6.4, §17).

**MVS (Minimal Version Selection)**: The resolution rule of §31.5: each
requirement is a minimum, and the version selected for a package is the
greatest minimum any manifest in the graph asks for, within one major.
No search and no backtracking, so resolution never drifts.

**Mutability**: Only through `let-mut` and `set!` (rebinding).

**Num**: The closed class `{Int, Float}` that `+ - * / %` accept. Both
operands of one form have the same type.

## N

**Native dependency**: C sources a package ships and compiles
declaratively through `(native ...)` in its manifest. It needs the
`native` capability, and build scripts are forbidden (§31.10).

**Non-determinism**: Excluded — same input, same output.

**Null**: Does not exist in the language; use `Option` (`None`).

## O

**Optimisation**: Phase 7 — constant folding, dead-branch elimination
and inlining of small functions; after region inference, in-place reuse
of a dead value's block (*Reuse*). Nothing reorders effects.

**OR-pattern**: Several literal alternatives in one arm,
`(1 2 3 body)`, matching any of them.

**Orphan rule**: A package may implement a trait for a type only if it
defines the trait or the type (§24.6); otherwise `E_PKG_ORPHAN_IMPL`.

**Overflow**: §20.1 makes checked integer overflow the default. Compiled
code does not check it today: `Int` arithmetic wraps, and `E_OVERFLOW`
is never raised.

## P

**Package**: The unit of distribution and versioning (§31): a directory
with a `zyl.pkg`, named by a scoped path such as `acme/json` (or
`acme/json/v2` for major 2 and later).

**Param**: A function parameter — a name or `(name Type)`.

**Pattern**: The head of a match arm, which binds variables.

**Phase**: One compilation step of §22 (11 phases, strict order).

**Pin region**: Non-moving memory for FFI. `ffi-pin` copies a value of type `a` into a slot there and returns the slot, a `(Pin a)`; `ffi-unpin` reads the `a` back.

**Polymorphism**: Parametric (generics) and ad-hoc (traits).

**PostProcessor**: The step that converts raw call/apply S-expressions
into ExprInner nodes (`expr_inner.zyl`).

**Primitive**: `Int`, `Float`, `Bool`, `String`, `Unit`.

**Profile**: A contract enforcement level — `strict`, `debug`, `warn`,
`off`, `production` (§23). `strict` and `debug` panic on a failed check,
`warn` reports it and goes on, `off` and `production` strip the checks.
Chosen with `--contracts=P` or `(contracts P)`; the default is
`strict`.

**`pub`**: The marker that exports a top-level definition from its
package, `(pub defn ...)`. Without it a definition is package-private
(§24.3, §24.4).

## Q

**Quasiquote**: `` `d ``, read as `(quasiquote d)`: quoted data with
holes. `,e` puts the value of `e` in the list and `,@e` every element of
the list `e`, so `` `(1 ,x ,@ys) `` is a `(List Int)` when `x` is an
`Int` and `ys` a `(List Int)` (§4.9).

## R

**RAII**: Resource Acquisition Is Initialisation — `with-resource` in
Zyl (§12.9). Today it binds the resource but runs no release step.

**Range pattern**: `(range lo hi)` in a literal-pattern `match`,
matching `lo` through `hi` inclusive.

**Rebinding**: `set!` on a `let-mut` name.

**Rest parameter**: `&rest name` at the end of a macro's parameter
list. `name` stands for the call's remaining arguments: `,@name` splices
them into the template, and `name` alone is the list of them (§19.1).

**Region**: A memory area with a lifetime: Stack, Heap, Global,
Circular or Pin (§9).

**Region inference**: Compile-time region assignment (phase 4). The
current pass runs on ICNF and places each allocation in the call's frame
region (released on return), the caller's result region, or the heap.

**REPL**: `zyl repl` — the interactive session built from
`stdlib/repl/`, which evaluates each entry with the ICNF interpreter
and keeps a per-directory session file, `.zyl-session`.

**Result**: The error-handling type, `(Ok T)` | `(Err E)`.

**Reuse**: Writing a new value into the block of an old one that is
unique and never used again, instead of allocating (`reuse.zyl`). The
old value cannot be observed, so the program's meaning is unchanged.

## S

**Scope**: The lexical region in which a binding is visible.

**Secret**: A capability marking a value as key material. A secret may
not steer control flow, index memory, be divided, be printed, be sent
to an actor or written to a file, and reaches FFI only through
`ffi-pin` (Chapter 33). A package must declare the `secret` capability
to use it.

**Seed**: The committed `build/boot/stage2.s` from which a build starts;
reseeding replaces it after a change to the compiler's own output.

**Semantic tokens**: The LSP request that colours a document by
resolved meaning — keyword, function, type, variant — rather than by
regular expression.

**Send**: The property a value needs to cross an actor boundary —
`TCap` or `TAtomic`, never `TMut`.

**Signature (package)**: The publisher's Ed25519 signature over a
package archive's BLAKE3 hash. Verification is mandatory and has no
opt-out (§31.8).

**Slice**: A zero-copy, bounds-checked window on a Vec's storage
(`collections/slice`).

**Special form**: Built-in syntax with its own evaluation rule (e.g.
`if`, `let`).

**Splice**: `,@e`. In a quasiquote, the elements of the list `e`; in a
macro template, the arguments of the rest parameter `e`, placed where a
form takes any number of expressions.

**SSA (Static Single Assignment)**: Each value assigned exactly once —
the form §18 specifies for ICNF.

**Stack region**: Local values with function-scope lifetime.

**StrView**: A zero-copy substring: a string, an offset and a length
(`text/view`). Bounds are checked once, when the view is made.

**Struct**: Named product type with immutable fields, `defstruct`.

**Substitution**: A mapping from type variables to types.

**Symbol**: A `~name` token. There is no symbol value type, so a quoted
name is `E_MALFORMED_FORM`.

**Self**: In a trait's method signatures, the type that implements the
trait: `(trait Ord (compare (self (other Self)) Int))`.

## T

**Tail call optimisation (TCO)**: §14 guarantees that deep recursion
never overflows the stack, "via tail-call optimization or
heap-allocated stack frames". A call in tail position, direct or
through a function value, compiles to a jump when its stack arguments
fit in the caller's own; calls inside `try` or `while`, and in
functions that wipe a `Secret` frame, still push a frame. `main` also
runs on a thread with a very large stack.

**Template**: A macro's body, into which the call's argument
expressions are substituted. A parameter needs no unquote; `,@` splices
a rest parameter.

**Trait**: Ad-hoc polymorphism — an interface of method signatures a
type can implement.

**Trait object**: Dynamic dispatch through a trait — not supported.

**Tuple**: An anonymous product value in the value model (§3). The
`tuple` constructor of §21.5 is not implemented.

**Type inference**: Hindley–Milner with capability and trait
constraints (phase 3). It is strict: every unification failure is an
error, and a program with a type error does not compile.

**Type parameter**: A generic placeholder (`T`, `U`) in a function or
ADT. A struct field written without a type is one.

## U

**Unit**: The type with one value, `unit`: the type of statement forms
(`print`, `set!`, `while`, an `if` without `else`, a `cond` with no
`else` clause).

**Unquote**: `,e`, read as `(unquote e)`. In a quasiquote, the value of
`e`; in a macro template, `,x` is the same as `x`. Anywhere else it is
`E_MALFORMED_FORM`.

**Unsafe**: A capability and a reserved module name. `(use pkg :unsafe
{ ... })` imports need the `unsafe` capability, and no module may be
named `unsafe` (`E_PKG_RESERVED_MODULE`).

## V

**Variant**: An ADT constructor: `(Some 42)`, `None`.

**Vendor**: `zyl vendor` — copies the resolved graph into `./vendor`.

**Visibility**: Two levels (§24.4): package-private by default, `pub`
to export. Importing a non-`pub` symbol is `E_PKG_PRIVATE_SYMBOL`.

## W

**Warning**: A `W_` diagnostic (
`W_UNUSED_PARAMETER`, `W_UNUSED_VARIABLE`, `W_SHADOWED_BINDING`, and
`W_TYPE_STRICT` under `ZYL_STRICT_TYPES=report`) or
`E_ZEROIZE_MISSING`. Warnings never stop a build.

**Wildcard pattern**: `_`, the catch-all arm. It must be the last arm.

**`with-region`**: The form that runs a body with its allocations in an
explicit `arena` or `fixed` region, released when the body ends
(Chapter 16).

**Workspace**: Several packages under one `zyl-workspace.zyl`, sharing
one root lock, one store and one build cache (§31.11).

## Y

**Yank**: An advisory mark on a published version. It affects only new
resolutions (`E_PKG_YANKED`), never an existing lock.

## Z

**Zeroize**: Explicit erasure of key material, `(zeroize base n)`. It
writes through a volatile pointer so the stores cannot be optimised
away. A function that handles a `Secret` zeroes its own stack frame on
return; heap copies are erased only by `zeroize` or the `Secret` trait's
`wipe` (Chapter 33).
