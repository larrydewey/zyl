# Chapter 30: Compiler Internals — Writing Compiler Passes in Zyl

This chapter explains how the self-hosted compiler's passes are put
together and how to write one, using the real modules in
`stdlib/compiler/` as the reference.

## 30.1 Compiler Pass Architecture

Each pass is an ordinary Zyl function from one tree to another, or a
check that walks a tree and calls `zyl_panic` with an `E_*` message on
the first problem (the type checker is the exception: it reports every
error, then stops). Passes hand each other ADT values, plus a small set
of per-node facts kept in side tables keyed by the node
(`node_tables.zyl`, §30.3): a node's type, its codegen kind, its region,
its reuse mark. Those tables are emptied for every program.

### Pass composition

The whole sequence lives in one file, `stdlib/compiler/pipeline.zyl`,
which the `zyl` CLI, `zyl eval` and the REPL all call. Abridged:

```lisp
(defn compile-to-exprs (arena srcbuf srcpath)
  (begin
    (compile-check-balance srcbuf srcpath)            ; sexp_balance
    (let prog (zyl-parse-file arena srcbuf srcpath)   ; lexer + parser: Ast
      (let resolved (mr-resolve-program-full arena prog srcpath) ; modules, qualify
        (let exprs (me-expand-program (mrr-exprs resolved))      ; macros: Expr
          (begin
            (compile-run-checks exprs resolved)
            exprs))))))

(defn compile-run-checks (exprs resolved)
  (begin
    (cc-check-program exprs (mrr-grants resolved) (mrr-denied resolved)) ; capabilities
    (dc-check-program exprs)      ; duplicate definitions
    (ac-check-program exprs)      ; arity
    (mc-check-program exprs)      ; mutability / aliasing
    (ec-check-program exprs)      ; exhaustiveness
    (uc-check-program exprs)      ; unused bindings (warnings)
    (sc-check-program exprs)      ; Secret
    0))

(defn lower-exprs (arena exprs0)
  (let exprs (dv-expand-program exprs0)                           ; derive
    (lower-after-mono arena (lift-impls exprs))))                 ; lift impl bodies

;; lower-after-mono: closure inlining -> type checking (ta-annotate)
;;                   -> ICNF -> inlining -> optimization
;;                   -> region inference -> in-place reuse
;; compile-to-fns  = compile-to-exprs + lower-exprs   (stops at ICNF)
;; compile-to-asm  = compile-to-fns + codegen (MIR or the stack machine)
```

Two things differ from the phase list in the specification. Region
inference runs on ICNF, after inlining and optimization, because what
it produces is an ICNF rewrite plus per-node region annotations that
codegen consumes (Chapter 28, §28.5); the reuse pass after it depends
on its classes (§28.7). And contract injection has no
phase of its own: `expr_inner.zyl` lowers contract forms to checks while
converting the parse tree.

## 30.2 AST Representation

### Tokens and the raw tree (`ast.zyl`)

```lisp
(deftype Token
  (TkEof Int)
  (TkIdent String Int)
  (TkInt Int Int)
  (TkString String Int)
  ...)                     ; the last field of every token is its byte offset

(deftype Ast
  (AstIdent String)
  (AstInt Int)
  (AstFloat String)
  (AString String)
  (AstBool Bool)
  (AList (List Ast)))
```

The reader produces raw `Ast`: atoms and lists, with no special-form
recognition at all (the "no-dispatch" rule). Recognition happens once,
when `expr_inner.zyl` converts `Ast` to `Expr`.

### The expression tree (`expr_inner.zyl`)

```lisp
(deftype Expr (Expr ExprInner))

(deftype ExprInner
  (EAtom Atom)
  (ECall Expr (List Expr))
  (EApply String (List Expr))           ; a call by name
  (EDefn String (List Param) Expr)
  (ELet String Expr Expr)
  (ELetMut String Expr Expr)
  (EIf Expr Expr Expr)
  (EMatch Expr (List MatchArm))
  (EFn String (List Param) Expr)
  (EStructGet Expr String)
  (EDeftype String (List ADTVariant) (List String) (Option String))
  (ESpawn Expr)
  (ESend Expr Expr)
  (ETryCatch Expr String Expr)
  ...                                   ; 83 variants in all, including
  (ELoadByte Endian Expr Expr)          ; the byte and atomic primitives
  (EAtomicCAS Expr Expr Expr Expr))

(deftype Atom (AInt Int) (AFloat String) (ABool Bool) (AStr String)
              (AIdent String) (ASymbol String) (AKeyword String) (ANil))
(deftype Param (P String (Option Expr)))         ; name, declared type
(deftype MatchArm (MA String (List Expr) Expr))  ; variant, patterns, body
```

`Expr` is a one-field wrapper so a pass can pattern-match
`(Expr.inner e)` and rebuild with `(Expr ...)`.

### Source positions

Nodes do not carry a span field. The reader records each node's byte
offset in a span table inside the runtime, keyed by the node's own
address, and every pass that rebuilds a node copies the original's
entry onto the replacement with one call:

```lisp
(ffi-call "zyl_span_copy" new-node old-node 1000)
```

That is how a codegen-stage error such as `E_UNBOUND_VARIABLE` can
still print `--> file:line:col` with a caret. A pass that rewrites
nodes and skips this line loses the location for everything
downstream.

## 30.3 Writing a Pass: Type Inference

The type checker is `type_annotate.zyl`, and it is the only authority
on types: a program it rejects does not compile. (`type_system.zyl`
keeps a few shared data types; the older inferer,
`type_inference.zyl`, is gone, and `lift_impls.zyl` replaced
`monomorphization.zyl`.) The rationale and the rules are in
`docs/sound-types-design.md`.

### Types and the store

```lisp
(deftype TaTy (TaV Int) (TaC String (List TaTy)) (TaF (List TaTy) TaTy))
```

`TaC` is a named type with arguments (`Int`, `(Vec String)`), `TaF` a
function type, `TaV` a type variable. Variables live in a runtime word
vector (`zyl_wvec_*`): slot `i` holds a `TaBind` — free, poisoned, or
the type it is bound to. Unification is union-find with an occurs check.
A conflict or a failed occurs check is reported at once, as
`E_TYPE_MISMATCH` located at the innermost expression being typed
(`ta-cur-node`), with both types in the message; the variables involved
are then poisoned so that one mistake does not produce a cascade of
follow-on errors. A form the pass has no type for (an `ffi-call` to an
undeclared symbol, a trait call whose receiver never resolves) is
`E_CANNOT_INFER`, and a name defined nowhere is `E_UNBOUND_VARIABLE`.
Every error in the program is reported; at the end
`ta-fail-if-errors` stops the compile if there were any.
`ZYL_STRICT_TYPES=report` emits them as `W_TYPE_STRICT` warnings and
lets the compile go on, for counting what is left in code being
ported. Negative `TaV` ids are template slots, used for generalized
schemes and constructor types.

The primitive surface is typed explicitly. `ffi_sigs.zyl` gives every
`zyl_*` runtime function a type scheme (`"zyl_int_text" "Int -> String"`),
an `(extern "sym" (T ...) R)` declaration types a foreign one, and the
special forms have fixed rules: conditions `Bool`, arithmetic over the
closed class `{Int, Float}` (`ta-check-num` resolves each use after
inference), statement forms `Unit`. There is no cast.

### Order and generalization

Top-level functions are visited depth-first from their references; the
call graph's strongly connected components (Tarjan, state in word
vectors) are closed callees-first. At an SCC's close its struct-gets
with unknown receivers are retried, its recorded *uses* (trait calls,
calls of trait-generic functions, prints and operators on type
variables) are resolved, and its members are generalized. A trait call
must resolve to an impl or to a per-type instance; there is no run-time
dispatch on a variant tag to fall back to. Global lookups
(functions, types, variants, struct fields) go through content-hashed
string maps (`zyl_smap_*`); nothing is iterated, so output stays
deterministic.

### Results

The results live in typed side tables keyed by the node
(`node_tables.zyl`, runtime `zyl_attrh_*`). Each Expr node's type goes
to `node-types`. ICNF lowering reads it (`ta-kind`) and stores a codegen
kind on the new Icnf node (`icnf-kinds`), plus whether the node is a
scalar (`icnf-scalars`) or a program ADT (`icnf-adts`); a call the type
pass redirected to a trait impl or an instance goes to `node-calls`,
and the `Show` function for a `print` argument to `node-shows`.
Instances of trait-generic functions are deep copies of the definition
(`ta-copy-defn`), typed with the call's argument types and appended to
the program. `ZYL_DEBUG_TYPES=1` prints every scheme as it is generalized.

Two properties to know before touching it:

- **Keep kinds across rebuilds.** A pass that rebuilds ICNF nodes must
  call `ic-keep-kind`, or rebuilt nodes lose their String/Float kind.
- **The compiler compiles itself with it.** Its own generic helpers get
  instances; a change that alters inference changes the fixed point.

The Secret capability is enforced by `secret_check.zyl`, a syntactic
taint pass, not by the unifier (Chapter 33).

## 30.4 Writing a Pass: Region Inference

Region inference (`region_inference.zyl`) runs on ICNF in two steps.
The first, `ri-transform-fns`, is a rewrite small enough to show the
whole idea:

```lisp
(defn ri-transform-let (name val body)
  (let val2 (ri-transform-expr val)
    (let body2 (ri-transform-expr body)
      (match val2
        ;; A let-bound variant whose name is only ever matched or
        ;; printed cannot outlive the frame: build it on the stack.
        (IVariant _ _ _
          (if (ri-name-safe-in body2 name)
            (ILet name (ri-to-stack-variant val2) body2)
            (ILet name val2 body2)))
        (_ (ILet name val2 body2))))))
```

`ri-name-safe-in` is a total `match` over every `Icnf` constructor, a
`Bool` predicate that answers "is every occurrence of this name either a `match` scrutinee or
a `print` argument?" Any other use — a call argument, a field of
another variant, a reference inside a nested `fn` — answers no, and the
value stays on the heap. The shape generalizes: a conservative pass
proves a narrow property and falls back to the always-correct path on
anything it does not recognize.

The second step, `rg-regions`, is a whole-program analysis rather than a
rewrite: it gives every allocation and call site a level (the call's
frame region, the caller's result region, or the heap) through
union-find object classes and per-function parameter summaries joined to
a fixpoint, and records the result in a side table (`icnf-regions`)
that codegen and `icnf-text` read. It follows the same rule: a runtime
function missing from its table (`rg-ffi-kind`) keeps its arguments and
result in the heap, the always-correct path. `docs/regions-design.md` is
the design.

## 30.5 Writing a Pass: Monomorphization

There is no separate monomorphization pass any more. What the old
`monomorphization.zyl` did with an empty inference context was lift
impl methods, and `lift_impls.zyl` now does only that: each impl method
becomes a top-level function named `Trait.method_Type` whose first
parameter is annotated with the impl's type.

Every real specialization is the type checker's. When a call reaches a
trait-generic function, `ta-specialize` keys an instance on the
function's name and the canonical text of its argument types
(`name~Int`, from `ta-canon-list`), makes a deep copy of the definition
under that name (`ta-copy-defn`), and types the copy at those argument
types. A function that would need more than 256 instances is
`E_CANNOT_INFER`: that is nearly always polymorphic recursion at an
ever larger type. Instance names are built from the printed types, so
that printer is part of the fixed point: changing how a type prints
changes every specialized symbol in the compiler's own output.

## 30.6 Writing a Pass: ICNF Lowering

`icnf.zyl`'s `ic-program` turns the type-checked `(List Expr)` into a
`(List Icnf)` of `IFn`s; Chapter 28 documents the node types and
the lowering rules. The entry points are:

```lisp
(ic-program arena exprs)   ; => (List Icnf), one IFn per function
(ic-expr arena expr vt)    ; one expression, given the variant table
(ic-hoist node)            ; lift embedded lambdas to the top level
```

## 30.7 Testing Compiler Passes

The compiler's modules are ordinary library modules, so a test can
`use` them and drive a pass directly. Here is a complete, compiling
read-only pass — it counts the binary operations in a lowered program,
before and after optimization:

```lisp
(use allocator/allocator)
(use compiler/lexer)
(use compiler/parser)
(use compiler/ast)
(use compiler/expr_inner)
(use compiler/icnf)
(use compiler/optimization)

(defn count-binops (e)
  (match e
    (IBinop _ l r (+ 1 (+ (count-binops l) (count-binops r))))
    (ICall _ args (count-binops-list args))
    (IFfi _ args (count-binops-list args))
    (IPrint a (count-binops a))
    (IIf c t f (+ (count-binops c) (+ (count-binops t) (count-binops f))))
    (IWhile c b (+ (count-binops c) (count-binops b)))
    (ILet _ v b (+ (count-binops v) (count-binops b)))
    (ISeq es (count-binops-list es))
    (IFn _ _ body _ (count-binops body))
    (_ 0)))                ; the full version walks every constructor

(defn count-binops-list (xs)
  (match xs
    (Nil 0)
    (Cons h t (+ (count-binops h) (count-binops-list t)))))

(defn main ()
  (let arena (arena-create 1048576)
    (let prog (zyl-parse arena "(defn main () (begin (print (+ (* 2 3) 4)) (print (if (< 1 2) 10 20)) 0))")
      (let fns (ic-program arena (convert-ast-list prog))
        (begin
          (print (count-binops-list fns))                     ; 3
          (print (count-binops-list (opt-optimize-fns fns)))  ; 0: all folded
          0)))))
```

The same technique, in the test harness's `(test ...)` form, is what
the repository uses:

- `tests/regression/compiler.zyl` calls `zyl-lex`, `zyl-parse` and
  `sb-check-string` and asserts on their results.
- `tests/integration/selfhost-codegen.zyl` parses, lowers and generates
  assembly for a nested program at run time.
- `tests/compile-fail/*.zyl` are programs that must be rejected; the
  runner counts a test as passing when compilation fails, and a file
  with a `; expect-error: CODE` line passes only when that code appears
  in the output, so an unrelated failure cannot pass it.

```lisp
(use allocator/allocator)
(use compiler/lexer)
(use compiler/parser)

(test "parse-nested-ast"
  (let arena (arena-create 0)
    (let prog (zyl-parse arena "(defn f (x) (* x x))")
      (assert-equal (list-length prog) 1))))

(run-tests)
```

There is no `test-property` over generated programs for the compiler
itself; determinism is tested by the fixed point.

## 30.8 Debugging Compiler Passes

### Stage tracing

```bash
ZYL_DEBUG_STAGES=1 zyl prog.zyl -o prog   # appends each phase name to /tmp/dbg
```

The last name in `/tmp/dbg` is the phase that crashed or hung.

### Looking at intermediate results

There is no `--emit-icnf` flag, but there is an ICNF printer:
`icnf-text` in `compiler/icnf_print.zyl` writes a lowered program as
canonical s-expressions, one function per line, with kinds and region
annotations. A small program like the one in §30.7 that `use`s the
modules can print it at any point, or you can read the generated
assembly (`--emit-asm`). The environment switches in Chapter 29, §29.12
(`ZYL_MIR`, `ZYL_INLINE`, `ZYL_REUSE`, `ZYL_REGIONS`) turn one
transformation off at a time; `ZYL_REUSE_DEBUG=1` prints the reuse
pass's per-function facts on stderr.

### The REPL

```
zyl> :type "hi"
"hi" : String
zyl> :type (+ 1 2)
(+ 1 2) : Int
zyl> :type (fn (x) x)
(fn (x) x) : (a -> a)
```

`:type` runs the front end and the type checker and reports the type it
assigns, without evaluating anything; an entry that does not type-check
is rejected with the checker's own error. There is no `:region`
command.

## 30.9 Adding a New Pass

1. **Write the module** in `stdlib/compiler/`, with a `use` for every
   module whose functions or constructors it touches.
2. **Call it from `stdlib/compiler/pipeline.zyl`** at the right point,
   and add its `(use compiler/...)` line there. That `use` is all it
   takes for the compiler build to include it.
3. **Add tests**: a `tests/regression/*.zyl` file for behavior, a
   `tests/compile-fail/*.zyl` file for each error it raises.
4. **Rebuild and reseed**: `./boot.sh --bootstrap-from-self`, then
   `./boot.sh` to confirm the new fixed point, then
   `./run_regression_tests.sh --full`.

A pass that rebuilds `Expr` nodes should copy spans (§30.2); a pass
that runs in the LSP too must not write to stdout, which is the
server's JSON-RPC channel. Report warnings with `err-warn-at`
(`error_report.zyl`), which goes through the runtime's warning sink
(`zyl_warn_emit`): stderr normally, a buffer when a caller captures it.

## 30.10 Common Patterns

### Total structural match

Every traversal is a `match` over the ADT. The tree-rewriting passes
list every constructor rather than relying on a catch-all, so that a
new constructor cannot pass through one of them unnoticed; checks that
only care about a few forms use a `_` arm for the rest. The optimizer's
walk is a representative rewrite:

```lisp
(defn opt-expr-node (e)
  (match e
    (IConst _ e)
    (IBinop op l r (opt-binop op (opt-expr l) (opt-expr r)))
    (IIf c t eb (opt-if (opt-expr c) t eb))
    (ILet name val body (ILet name (opt-expr val) (opt-expr body)))
    ...))                   ; one arm per Icnf constructor
```

Its caller, `opt-expr`, is `(ic-keep-span (ic-keep-kind (opt-expr-node e) e) e)`,
so every rebuilt node keeps the original's codegen kind and source span.

### State threading

Passes that accumulate state thread an immutable record and return a
new one. Codegen's emitter state is the clearest case:

```lisp
(deftype CGState (CGS Arena StrBuf Int Int (List REntry) (List FnName)))
;; arena, text buffer, next label, next slot, rodata, known functions

(deftype CGR (CGR CGState Int String))   ; state + a label or slot

(defn cg-label-new (st) ...)             ; => CGR with the advanced state
```

When a function must return a value *and* the new state, it returns a
small wrapper ADT (`CGR`, `CGE`, `CGP`) and the caller destructures it.

## 30.11 Performance Considerations

- **Deep recursion is normal.** Direct tail calls are jumps, but most
  of the compiler's recursion over lists and trees is not in tail
  position; it relies on the big worker stack every generated program
  runs on (Chapter 29, §29.9).
- **Watch for repeated work.** Type inference once inferred the last
  statement of every body twice; with bodies nested to the right that
  doubled the cost per statement, and a boot stage took about ten
  minutes. Removing the duplicate made the whole fixed-point check take
  seconds. A pass that walks a subtree more than once per visit is the
  first thing to suspect when compile time grows with nesting depth.
- **Allocate from the arena.** Compiler memory comes from one arena per
  compile (1 GiB reserved by the driver) and is never freed during the
  compile; the native backend's per-function tables are the exception,
  in an arena reset before each function (`mir-reset`). A self-compile
  allocates somewhat over 2 GB in all, which is why `./boot.sh` caps a
  stage at 4 GB. An allocation failure reports `E_OUT_OF_MEMORY`, and a memory
  budget (`ZYL_MAX_MEMORY`, else 80% of available memory) stops a
  runaway compile before the kernel kills it.
- **Keep the output under the codegen buffer.** Generated assembly is
  built in a fixed 64 MiB buffer and a compile that exceeds it fails
  with `E_CODEGEN_BUFFER_FULL`.
