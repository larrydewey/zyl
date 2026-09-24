# Chapter 30: Compiler Internals — Writing Compiler Passes in Zyl

This chapter explains how the self-hosted compiler's passes are put
together and how to write one, using the real modules in
`stdlib/compiler/` as the reference.

## 30.1 Compiler Pass Architecture

Each pass is an ordinary Zyl function from one tree to another, or a
check that walks a tree and calls `zyl_panic` with an `E_*` message on
the first problem. Passes communicate only through ADT values; there is
no shared mutable compiler state.

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

(defn lower-exprs (arena exprs)
  (let inferer (collect-definitions (inferer-new) exprs)          ; type inference
    (let mono-ctx (mono-context-populate-adt-order (mono-context-new inferer) inferer)
      (let mono-exprs (monomorphize mono-ctx exprs)               ; monomorphization
        (lower-after-mono arena (td-expand-program mono-exprs)))))) ; trait dispatch

;; lower-after-mono: closure inlining -> assert lowering -> ICNF
;;                   -> optimization -> region inference
;; compile-to-fns  = compile-to-exprs + lower-exprs   (stops at ICNF)
;; compile-to-asm  = compile-to-fns + codegen
```

Two things differ from the phase list in the specification. Region
inference runs on ICNF, after optimization, because what it produces is
an ICNF rewrite (Chapter 28, §28.5). And contract injection is not
wired in: `contract_injection.zyl` does not match the current
`ExprInner` shapes, so nothing imports it.

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
(deftype Param (P String (Option String)))       ; name, declared type
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

### Type ADT (`type_system.zyl`)

```lisp
(deftype Type
  (TInt) (TFloat) (TBool) (TString) (TUnit)
  (TByte)
  (TByteSlice Region)
  (TByteBuf Region)
  (TFun (List Type))
  (TList (List Type))
  (TArray Type Int)
  (TCap CapKind Type)                   ; capability wrapper
  (TStruct String (List Type))
  (TVar Int Type)                       ; type variable
  (TMap Type Type)
  (TResult Type Type))

(deftype CapKind
  (TCCap) (TCMut) (TCAtomic) (TCBox) (TCPin)
  (TCByte) (TCAtomicByte) (TCSecret))
```

Capabilities are one constructor, `TCap`, parameterized by a `CapKind`,
rather than a constructor per capability.

### Substitution and environment

```lisp
(deftype TypeBind (TB Int Type))
(deftype Subst (SBindings (List TypeBind)))
(deftype EnvBind (EB String Type))
(deftype TypeEnv (TEBindings (List EnvBind)))
```

`unify` (`type_system.zyl`) takes a substitution and two types and
returns an extended substitution or a failure (`UnifyResult`).

### The inferer

All inference state is one immutable record, `TypeInferer`, with twenty
fields — the environment, the substitution, the next fresh variable,
known functions and their return types, ADT definitions, struct
definitions, the trait context, observed argument types for later
monomorphization, and so on — each with an accessor
(`ti-env`, `ti-subst`, ...). `collect-definitions` walks the program's
top-level forms and infers each `defn` body with `infer-expr`, a large
`match` over `ExprInner`:

```lisp
(defn infer-expr (inferer expr)
  (match (Expr.inner expr)
    (EAtom atom
      (match atom
        (AInt _ (inferer-return-int inferer))
        (AFloat _ (inferer-return-float inferer))
        (ABool _ (inferer-return-bool inferer))
        (AStr _ (inferer-return-string inferer))
        ...))
    ...))
```

Two properties to know before touching it:

- **It degrades rather than rejects.** A unification failure generally
  produces a fresh type variable, not an error. The hard errors a user
  sees come from the check passes in §30.1, not from inference.
- **Some of its name lookups compare strings with `=`**, which on two
  dynamically built strings is pointer comparison, so a builtin
  operator is not always recognized by name. The REPL's `:type` reports
  such expressions as *unresolved*. Fixing it changes control flow deep
  in generic-instantiation tracking; `stdlib/lsp/compiler_bridge.zyl`'s
  header records why it has not been done yet.

The Secret capability is enforced by `secret_check.zyl`, a syntactic
taint pass, not by the unifier (Chapter 33).

## 30.4 Writing a Pass: Region Inference

Region inference (`region_inference.zyl`) is a rewrite on ICNF, and it
is small enough to show the whole idea:

```lisp
(defn ri-transform-let (name val body)
  (let val2 (ri-transform-expr val)
    (let body2 (ri-transform-expr body)
      (match val2
        ;; A let-bound variant whose name is only ever matched or
        ;; printed cannot outlive the frame: build it on the stack.
        (IVariant _ _ _
          (if (> (ri-name-safe-in body2 name) 0)
            (ILet name (ri-to-stack-variant val2) body2)
            (ILet name val2 body2)))
        (_ (ILet name val2 body2))))))
```

`ri-name-safe-in` is a total `match` over every `Icnf` constructor that
answers "is every occurrence of this name either a `match` scrutinee or
a `print` argument?" Any other use — a call argument, a field of
another variant, a reference inside a nested `fn` — answers no, and the
value stays on the heap. The shape generalizes: a conservative pass
proves a narrow property and falls back to the always-correct path on
anything it does not recognize.

## 30.5 Writing a Pass: Monomorphization

`monomorphization.zyl` keeps its tables in one record:

```lisp
(deftype MonoKV (MK String A))

(deftype MonoCtx
  (MC
    (MCGenFns ...)          ; generic function -> its type parameters
    (MCKnownFns ...)        ; function -> (parameter, Type) pairs
    (MCReturns ...)         ; function -> return Type
    (MCKTypes ...)
    (MCStructs ...)
    (MCAdtDefs ...)
    (MCAdtInsts ...)
    (MCTImpls ...)          ; trait -> implementing types
    (MCAdtParamOrder ...)))
```

`mono-context-new` seeds it from the `TypeInferer`, and
`(monomorphize ctx exprs)` returns the program with each generic
function replaced by specializations for the concrete argument types
inference observed. Specialized names are built from
`type-to-string`, so that function's output is part of the fixed point:
changing how a type prints changes every specialized symbol in the
compiler's own output.

## 30.6 Writing a Pass: ICNF Lowering

`icnf.zyl`'s `ic-program` turns the post-assert-lowering `(List Expr)`
into a `(List Icnf)` of `IFn`s; Chapter 28 documents the node types and
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
  runner counts a test as passing when compilation fails (it does not
  check which error code was raised).

```lisp
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

There is no `--emit-icnf` flag and no ICNF printer. Two practical
routes: write a small program like the one in §30.7 that `use`s the
modules and prints what you need, or read the generated assembly
(`--emit-asm`).

### The REPL

```
zyl> :type "hi"
"hi" : String
zyl> :type (+ 1 2)
(+ 1 2) : unresolved — inference had no evidence for this expression
```

`:type` runs the front end and type inference and reports what
inference knows (§30.3 explains *unresolved*). There is no `:region`
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
(defn opt-expr (e)
  (match e
    (IConst _ e)
    (IBinop op l r (opt-binop op (opt-expr l) (opt-expr r)))
    (IIf c t eb (opt-if (opt-expr c) t eb))
    (ILet name val body (ILet name (opt-expr val) (opt-expr body)))
    ...))                   ; one arm per Icnf constructor
```

### State threading

Passes that accumulate state thread an immutable record and return a
new one. Codegen's emitter state is the clearest case:

```lisp
(deftype CGState (CGS Int Int Int Int (List REntry) (List FnName)))
;; arena, text buffer, next label, next slot, rodata, known functions

(deftype CGR (CGR CGState Int String))   ; state + a label or slot

(defn cg-label-new (st) ...)             ; => CGR with the advanced state
```

When a function must return a value *and* the new state, it returns a
small wrapper ADT (`CGR`, `CGE`, `CGP`) and the caller destructures it.

## 30.11 Performance Considerations

- **Deep recursion is normal.** There is no tail-call elimination; the
  compiler recurses over lists and trees freely and relies on the big
  worker stack every generated program runs on (Chapter 29, §29.9).
- **Watch for repeated work.** Type inference once inferred the last
  statement of every body twice; with bodies nested to the right that
  doubled the cost per statement, and a boot stage took about ten
  minutes. Removing the duplicate made the whole fixed-point check take
  seconds. A pass that walks a subtree more than once per visit is the
  first thing to suspect when compile time grows with nesting depth.
- **Allocate from the arena.** Compiler memory comes from one arena per
  compile (1 GiB reserved by the driver) and is never freed during the
  compile. An allocation failure reports `E_OUT_OF_MEMORY`, and a memory
  budget (`ZYL_MAX_MEMORY`, else 80% of available memory) stops a
  runaway compile before the kernel kills it.
- **Keep the output under the codegen buffer.** Generated assembly is
  built in a fixed 64 MiB buffer and a compile that exceeds it fails
  with `E_CODEGEN_BUFFER_FULL`.
