# Zyl Specification — Syntax and Forms

**Canonical authority:** `zyl_specification.txt` §2, §1.3
**Related:** `spec/01-lexing-and-tokens.md`, `spec/03-macros-and-hygiene.md`
**Implementation:** `stdlib/compiler/parser.zyl` (reader), `stdlib/compiler/expr_inner.zyl` (post-processor)

---

## 2. Abstract Syntax (AST)

```
Expr :=
    Atom
  | (Op Expr*)
  | (def Name Expr)
  | (defn Name (Params*) Body)   ; also 'defun'
  | (let (Name Expr) Body)
  | (let-mut (Name Expr) Body)
  | (if Expr Expr Expr)

  ;; Error Handling (Result-based)
  | (try Expr (catch Name Expr))
  | (match Expr (Variant Pattern Body)*)

  ;; Concurrency & FFI
  | (spawn Expr)
  | (send Expr Expr)
  | (ffi-call String Expr* Integer)
  | (ffi-pin Expr)
  | (ffi-unpin Expr)

  ;; Control & Flow
  | (assert Expr String)
  | (while Expr Expr)
  | (for (Name [Expr]*) Expr Expr)
  | (cond Clause*)
  | (begin Expr+)
  | (error String)
  | (unwrap Expr)

  ;; Trait & Type System
  | (trait Name (TraitMethod*) TraitBound?)
  | (impl TraitName TypeName (ImplBody*))
  | (deftype Name (Variant*) VariantBound?)

  ;; Structs & Aliases
  | (defstruct Name (Field*) (:derive [Trait*])?)
  | (defstruct+ Name (Field*) (:derive [Trait*])?)
  | (alias Name TypeExpr)
  | (derive Name [Trait*])
  | (struct-get Expr FieldName)
  | (make-Name Expr*) ; Auto-generated constructor (e.g., make-Point)

  ;; Resource Management
  | (with-resource (Name Expr) Body)

  ;; Testing
  | (test-suite String (TestOrSuite*) (:keyword Value*)*)
  | (test String Body (:keyword Value*)*)
  | (assert-equal Expr Expr)
  | (assert-fail Expr String?)
  | (assert-true Expr String?)
  | (assert-false Expr String?)
  | (test-property String Generator PropertyFn)
  | (setup Body+)
  | (teardown Body+)
  | (run-tests (:keyword Value*)*)
  | (test-compile Expr (:expect-error Bool)?)
```

### Sub-form Definitions

```
Field := (Name TypeExpr)
Generator := gen-int | gen-bool | gen-string | gen-float
PropertyFn := (fn (Param+) Expr)
Param := Name | (Name Type)
Clause := (Expr Expr)
TraitMethod := (Name (Param*) TypeExpr)
ImplBody := (defn Name (Params*) Body)
Variant := (Name TypeExpr*)
BaseType := Int | Float | Bool | String | Unit | Name
```

### Evaluation

Strict left-to-right.

---

## Parsing Philosophy: No-Dispatch

All S-expressions are parsed as raw list nodes by the parser.
A post-processor phase converts them into specialized `ExprInner` variants.

This eliminates dispatch complexity in the parser: the parser handles
exactly one grammatical form (S-expression → list of expressions), and
all specialization is deferred to PostProcessor.

**See also:** `docs/architecture-decisions.md` §A1 (No-Dispatch S-Expression Parsing)

In the self-hosted compiler the reader (`read-form`/`read-dispatch` in
`parser.zyl`) produces only identifiers, integer, float, string and boolean
atoms, and lists. `convert-ast` in `expr_inner.zyl` is the post-processor:
a list whose head is an identifier goes through `dispatch-special`, then
the byte-primitive forms (`byte-form-dispatch`), and otherwise becomes an
ordinary application (`EApply`); a list with a non-identifier head is a
call (`ECall`).

---

## Implementation Notes

Not normative. Where the implementation differs from §2, the difference is
recorded here rather than silently corrected in the grammar above.

### Forms the post-processor recognises

`def`, `defn`, `deftype`, `defstruct`, `defstruct+`, `impl`, `derive`,
`let`, `let-mut`, `if`, `while`, `for`, `cond`, `and`, `or`, `not`,
`match`, `try` (with a nested `catch`), `begin`, `fn`, `lambda`, `set!`,
`print`, `assert`, `assert-equal`, `assert-true`, `assert-false`,
`assert-fail`, `spawn`, `send`, `ffi-pin`, `ffi-unpin`, `exit`, `close`,
`read-line`, `file-open`, `file-read`, `file-write`, `file-close`,
`struct-get`, `make-struct`, `make-variant`, `unwrap`, `with-resource`,
`module`, `use`, `pub`, `export`, `feature-gate`, `defmacro` (and its
synonym `macro`), `test`, `test-suite`, `run-tests`, `setup`, `teardown`,
`test-property`, `test-compile`, `contracts`, `requires`, `ensures`,
`checkpoint` and `recover`. `ffi-call` is not a dedicated node; it stays
an application of the reserved name and is recognised during ICNF
lowering.

### Differences from §2

- **`defun` is not recognised.** It is parsed as an ordinary application,
  so a function defined with `defun` is never defined and a call to it
  fails at link time. Use `defn`.
- **`trait` and `alias` are not recognised** as definition forms. A
  `trait` declaration is accepted syntactically but has no effect;
  `impl` blocks work without one (see `spec/05-types-and-inference.md`).
- **`test-suite`, `test-property` and `test-compile` are parsed but
  discard their arguments** (placeholder nodes). `setup` and `teardown`
  are parsed.
- **`contracts`, `requires`, `ensures`, `checkpoint` and `recover`** are
  parsed and pass their first argument through unchanged; see
  `spec/09-ffi-contracts.md`.
- **`let` accepts two shapes:** `(let x v body...)`, where several body
  forms are sequenced, and `(let (x v) body)`. `(let x v)` with no body
  evaluates to Unit. `let-mut` is the same.
- **`if` may omit the else branch.** `(if c t)` evaluates to Unit when `c`
  is false.
- **`for`** accepts the single-binding shorthand `(for (i 0) cond body...)`
  and a list of bindings `(for ((i 0) (j 1)) cond body...)`.
- **`cond`** is lowered to nested `if`; an `else` test is always true.
- **`match` arms** may be written flat, `(Variant field... body)`, or with
  the pattern grouped, `((Variant field...) body)`. Pattern kinds are
  described in `spec/10-structs-and-data-types.md`.
- **Definition parameters** are a bare name or `(name Type)`; anything
  else is `E_MALFORMED_PARAMETER`.
- **`_` is the discard name.** `_` and any name beginning with `_` are
  exempt from the unused-binding and shadowing warnings and from
  `E_DUPLICATE_PARAMETER`, so `(defn f (_ _) ...)` is legal. A binding
  named exactly `_` gets no stack slot.
- `pub` and `feature-gate` wrap a top-level definition and are consumed by
  the module resolver (§24.4, §31.10); `export` is still accepted but
  deprecated (§24.3).
