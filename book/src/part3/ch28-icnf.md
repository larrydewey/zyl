# Chapter 28: ICNF — The Intermediate Representation

ICNF (Intermediate Canonical Normal Form) is Zyl's own intermediate
representation: the output of lowering, the input of optimization,
region inference, code generation and the REPL's interpreter. This
chapter documents what ICNF actually is in the self-hosted compiler
(`stdlib/compiler/icnf.zyl`), how the typed expression tree is lowered
into it, and what the passes that run on it do.

## 28.1 ICNF Overview

The specification describes ICNF as an SSA IR with region annotations
on every value. The implementation is simpler than that, and it is
worth being exact about the difference:

- **A tree, not SSA.** ICNF is an ordinary recursive ADT, `Icnf`. There
  are no SSA ids, no basic blocks, no phi nodes and no terminators;
  control flow is structured (`IIf`, `IWhile`, `IMatch`, `ITryCatch`)
  and values are named by `ILet` bindings.
- **Untyped.** Types are gone by the time ICNF exists. What survives is
  a small *representation kind* per function parameter (0 for a machine
  word, 1 for a String, 2 for a Float), because those three are emitted
  differently.
- **Regions are a side-table annotation, plus one rewrite.** No node has
  a region field. Region inference runs on ICNF and records, for every
  allocation and call site, which region its result goes into (the
  frame's own region, the caller's result region, the heap, or an
  enclosing `with-region` scope) in attribute table 4, keyed by the
  node. A variant that is only matched or printed is instead rewritten
  from `IVariant` to `IStackVariant`, and an explicit `with-region`
  scope is its own node, `IRegion` (§28.5).
- **Phase position.** ICNF is produced after monomorphization, trait
  dispatch, closure inlining and assert lowering, and consumed by the
  optimizer, region inference and codegen, in that order (§28.6).
- **Textual form.** `compiler/icnf_print.zyl` (`icnf-text`) writes the
  lowered program as canonical s-expressions, one function per line,
  with each node's codegen kind as a `:k` suffix and its region
  annotation as an `@r` suffix. Package builds hash it for
  `zyl.buildinfo`'s `icnf-hash`, so the hash covers region decisions.

## 28.2 ICNF Structure

The whole representation is two ADTs:

```lisp
(deftype Icnf
  (IConst Int)                          ; integer (also Bool, byte literals)
  (IStr String)                         ; string literal
  (IFlt String)                         ; float literal, as its source text
  (ILoad String)                        ; read a local, parameter or function
  (IBinop Int Icnf Icnf)                ; opcode, left, right
  (ICall String (List Icnf))            ; call a Zyl function by name
  (IFfi String (List Icnf))             ; call a C symbol by name
  (IPrint Icnf)
  (IIf Icnf Icnf Icnf)
  (IWhile Icnf Icnf)
  (ISet String Icnf)                    ; set! of a local
  (ILet String Icnf Icnf)               ; name, value, body
  (ISeq (List Icnf))                    ; begin
  (IVariant String Int (List Icnf))     ; constructor name, tag, fields
  (IMatch Icnf (List IArm))
  (IFn String (List String) Icnf (List Int))  ; name, params, body, param kinds
  (ICallClosure String (List Icnf))     ; no longer produced; codegen treats it as ICall
  (ITryCatch Icnf String Icnf)          ; try body, catch variable, handler
  (IStackVariant String Int (List Icnf))
  (ISymAddr String)                     ; address of a C symbol (FFI bridge only)
  (IRegion Int Int Int Int Icnf))       ; with-region: kind (1 arena, 2 fixed), block, align, limit, body

(deftype IArm (IArm String Int (List String) Icnf))  ; variant, tag, binds, body
```

A program is a `(List Icnf)` of `IFn` nodes, one per function,
including every lambda lifted out of a body and every synthesized test
function.

### Binary opcodes

`IBinop`'s first field is a number, not a node kind:

| Code | Op | Code | Op |
|------|----|------|----|
| 0 | `+` | 9 | `=` / `==` |
| 1 | `-` | 10 | `!=` |
| 2 | `*` | 11 | `bit-and` |
| 3 | `/` | 12 | `bit-or` |
| 4 | `%` | 13 | `bit-xor` |
| 5 | `<` | 14 | `shl` |
| 6 | `>` | 15 | `shr` (logical) |
| 7 | `<=` | 16 | `ashr` |
| 8 | `>=` | | |

`bit-not` has no two-operand form: `(bit-not x)` lowers to
`(IBinop 13 x (IConst -1))`. N-ary arithmetic folds left-associatively,
so `(+ a b c)` becomes `(IBinop 0 (IBinop 0 a b) c)`.

## 28.3 What Lowers to What

| Source form | ICNF |
|-------------|------|
| integer, `true`/`false`, byte literal | `IConst` |
| string / float literal | `IStr` / `IFlt` |
| variable reference | `ILoad name` |
| `let`, `let-mut`, `with-resource` | `ILet` (mutability is gone below source level) |
| `set!` | `ISet` |
| `begin` | `ISeq` |
| `if`, `while` | `IIf`, `IWhile` |
| `for` | nested `ILet`s around an `IWhile` |
| call of a known function | `ICall` |
| `ffi-call` | a `zyl_*` runtime symbol: `IFfi sym args`, the timeout dropped; any other symbol: `IFfi "zyl_ffi_timed"` with `ISymAddr sym`, the name, the timeout and the argument count ahead of the arguments (Chapter 29, §29.10) |
| string builtins, file I/O, byte buffers, atomics, `spawn`, `send`, `ffi-pin` | `IFfi` to a named runtime function (`zyl_cstr_concat`, `zyl_file_open_c`, `zyl_bytebuf_new`, `zyl_actor_spawn`, ...) |
| constructor application, struct construction | `IVariant` with the constructor's tag |
| `match` | `IMatch` of `IArm`s |
| `struct-get` | an `IMatch` with one arm per struct type that has the field |
| `try` / `catch` | `ITryCatch` |
| `with-region` | `IRegion` with the kind, block size, alignment and limit, validated by `parse-with-region` in `expr_inner.zyl` |
| `fn` | an `IFn` lifted to the top level, referenced by `ILoad`; or, when it captures, a closure value (§28.4) |
| `assert-equal`, `assert-true`, `assert-false` | an `IIf` that calls `zyl_panic` on failure |
| a top-level `(test "name" body)` | a function `_test_<name>` plus a `zyl_register_test` call in an implicit `main` |

A form the lowering does not recognize becomes `(IConst 0)`. That is a
deliberate fail-soft default, and it has hidden real bugs in the past
(`for`, `spawn` and `with-resource` all silently lowered to 0 at one
point), so a new special form must be given its own case in
`ic-expr-node`.

### Tags

Variant tags come from a variant table (`VTable`, `ast.zyl`) built by a
walk over the program's `deftype` forms. A regular ADT numbers its
variants from 0 in declaration order. Every struct is a single-variant
type, and structs draw their tags from a separate global counter, so
two unrelated structs never share a tag — `struct-get` depends on that,
because it has no static type to tell it which struct it is looking at.
A later `deftype` that reuses a variant name shadows the earlier one.

## 28.4 Lambdas and Closures

A `(fn ...)` becomes an `IFn` embedded in the expression, and a pass
called `ic-hoist` then walks the finished tree, moves every embedded
`IFn` to the top-level function list, and leaves an `ILoad` of its
generated name behind. Lifted names come from `zyl_fresh_id`, a
process-lifetime counter: deterministic for a fresh process compiling
a fixed source (so the fixed point holds), and never repeated within a
REPL session.

`ic-lambda` lowers the lambda body first and reads its free names off
the lowered tree (`ic-lambda-free`): every `ILoad` or call head that is
not a parameter, not bound inside the body (`ILet`, match-arm binds,
the catch variable) and not a top-level function. A lambda with none
lifts to a plain function. One that captures becomes a closure value: a
block `[tag, code, env]` whose tag is `ic-closure-magic`, where `env` is
a second block holding one captured value per field, captured by value
when the closure is built. The lifted function takes the environment as
one extra trailing parameter (`_clos_env`) and reads each capture back
with `zyl_variant_field`.

A call through a local is an ordinary `ICall`; codegen sees the name
bound to a slot and emits an indirect call that handles both kinds of
function value (Chapter 29). A call whose head is itself an expression,
`((make-adder 10) 5)`, binds the head to a fresh `_callee_N` local
first. `ICallClosure` is no longer produced. `closure_inline.zyl`,
which used to beta-reduce let-bound capturing lambdas before closures
were values, is now an identity pass.

## 28.5 Regions in ICNF

Region inference (`stdlib/compiler/region_inference.zyl`) runs after
optimization in two steps.

**The stack-variant rewrite.** `ri-transform-fns` moves a let-bound
variant into the frame when every use of the name is the scrutinee of a
`match` or the argument of `print`, and the name is not referenced inside
a nested `fn`:

```lisp
;; Before
(ILet "p" (IVariant "Point" 7 (list (IConst 1) (IConst 2)))
  (IMatch (ILoad "p") arms))

;; After: p is only ever matched or printed, so it cannot outlive the frame
(ILet "p" (IStackVariant "Point" 7 (list (IConst 1) (IConst 2)))
  (IMatch (ILoad "p") arms))
```

**Region annotation.** `rg-regions` then classifies every remaining
allocation site (an `IVariant`, or an `IFfi` to a region-aware runtime
function) and every call site. Values that may point to each other share
a union-find object class; each class gets a level — frame (the value
does not outlive the call), result (it may reach the call's result, so it
goes in the region the caller chose), or heap (it escapes in a way the
analysis does not track). Per-function parameter summaries are joined to
a fixpoint over the whole program. The decisions go into attribute
table 4:

| Node | Attribute 4 |
|------|-------------|
| allocation or call site | 1 frame region, 2 result region, 3 heap, `4 + k` the `k`th enclosing `with-region` scope |
| `IFn` | 4 plus flags: bit 0, the function has a frame region; bit 1, it keeps its caller's result region |

`icnf-text` prints a nonzero annotation as ` @r` before the node's closing
parenthesis, after any ` :k`. Chapter 29 (§29.7) shows how codegen uses
the annotations. `ZYL_REGIONS=0` at compile time leaves every site at 3
(heap). The interpreter ignores the annotations and allocates in its own
arenas.

**Explicit regions.** `(with-region (arena ...) body)` and
`(with-region (fixed ...) body)` lower to `IRegion kind block align limit
body`. Allocations in `body` that the analysis places in the scope are
annotated `4 + k`; one whose class reaches the body's result or anything
longer-lived is `E_REGION_ESCAPE`, as is a `(bytebuf Stack N)` that
escapes its frame.

The pass is conservative on purpose: undershooting costs a heap
allocation, overshooting would be silent memory corruption. The Global
and Circular regions of the specification are not represented; the
`Region` ADT in `type_system.zyl` survives as the parameter of the
byte-buffer types.

## 28.6 Lowering and the Passes Around It

`stdlib/compiler/pipeline.zyl`'s middle section is the exact order:

```
type inference (collect-definitions)
  → monomorphization
  → trait dispatch        (td-expand-program)
  → closure inlining      (ci-expand-program)
  → assert lowering       (al-expand-program)
  → ICNF lowering         (ic-program)
  → optimization          (opt-optimize-fns)
  → region inference      (ri-transform-fns, then rg-regions)
```

`compile-to-fns` returns the result of the last step. The compiler hands
it to codegen; the REPL and `zyl eval` hand it to the interpreter in
`stdlib/repl/interp.zyl`, which evaluates the same `IFn` list directly.

### Let binding

```lisp
;; Source
(defn f (x) (let y (+ x 1) (if (> y 2) y 0)))

;; ICNF (the function name is its canonical key in practice)
(IFn "f" ("x")
  (ILet "y" (IBinop 0 (ILoad "x") (IConst 1))
    (IIf (IBinop 6 (ILoad "y") (IConst 2))
         (ILoad "y")
         (IConst 0)))
  (0))
```

### Match

```lisp
;; Source
(match opt
  (Some v (+ v 1))
  (None 0))

;; ICNF: one arm per constructor, carrying its tag and field names
(IMatch (ILoad "opt")
  ((IArm "Some" 0 ("v") (IBinop 0 (ILoad "v") (IConst 1)))
   (IArm "None" 1 () (IConst 0))))
```

A wildcard arm carries tag -1 and matches unconditionally. A nested
constructor pattern in field position is bound to a fresh name and the
arm body is wrapped in an inner `IMatch` on it. Exhaustiveness has
already been checked by `exhaustiveness_check.zyl`, and lowering checks
it again.

## 28.7 ICNF Optimizations

`optimization.zyl` is two passes in one bottom-up walk. Nothing else
is done: there is no dead-code elimination of unused lets, no copy
propagation and no common-subexpression elimination.

### Constant folding

```lisp
;; Before
(IBinop 0 (IBinop 2 (IConst 2) (IConst 3)) (IConst 4))
;; After
(IConst 10)
```

Only integer arithmetic and comparisons (opcodes 0–10) fold. Division
or remainder by a constant zero is left alone so it still fails at run
time. Float literals are not folded (an `IFlt` is source text, not a
value), and neither are the bitwise opcodes.

### Dead-branch elimination

```lisp
;; An if whose condition folded to a constant keeps one branch
(IIf (IConst 1) a b)   ; → a
(IIf (IConst 0) a b)   ; → b

;; A while whose condition is constant false evaluates to 0
(IWhile (IConst 0) body)   ; → (IConst 0)
```

A constant-true `while` is left alone: an infinite loop is a legitimate
program. Neither pass can discard a side effect, because the only thing
that ever folds to an `IConst` is arithmetic on literals.

## 28.8 ICNF Verification

There is no separate ICNF validator. The guarantees come from the
checks that run before lowering (balance, arity, duplicates,
mutability, exhaustiveness, Secret) and from type inference, plus a
few checks lowering and codegen make as they go:

- `E_MATCH_ARM_COMPLEX` — a match-arm body combining a constant with
  two or more calls (a shape older stage binaries miscompiled)
- `E_ARITY_MISMATCH` — for example `bit-not` with other than one argument
- `E_UNBOUND_VARIABLE` — raised by codegen when an `ILoad` names nothing
  in scope, located at the identifier through the span table
- `E_UNDEFINED_FUNCTION` — raised by the interpreter for a call to a
  name that no function defines (compiled code finds this at link time)

## 28.9 ICNF Errors

The `E_ICNF_*` codes that earlier drafts of this chapter listed do not
exist. The errors above are the ones the lowering side of the pipeline
can raise; Appendix A has the full catalogue.

## 28.10 Comparison with LLVM IR

| Feature | LLVM IR | ICNF (as implemented) |
|---------|---------|------|
| Form | SSA, basic blocks | Structured expression tree |
| Types | On every value | Erased; three representation kinds on parameters |
| Regions | ❌ | Per-site annotations (frame, result, heap, scope) in a side table; `IStackVariant`; `IRegion` scopes |
| Capabilities | ❌ | Checked before lowering, not represented |
| Target | Multi-arch | x86_64 only |
| Optimizations | Many | Integer constant folding, dead-branch elimination |
| Consumers | Backends | Codegen, and the REPL's interpreter |
| Determinism | Configurable | Mandatory |
