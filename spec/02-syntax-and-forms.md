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
  | (list Expr*)                 ; reader: [Expr*]
  | (quote Datum)                ; reader: 'Datum
  | (quasiquote QDatum)          ; reader: `QDatum
  | (defmacro Name (MacroParams) Expr)   ; §19

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
Datum := INTEGER | FLOAT | STRING | BOOLEAN | (Datum*)
QDatum := INTEGER | FLOAT | STRING | BOOLEAN | (QElem*)
        | (unquote Expr)                          ; reader: ,Expr
QElem := QDatum
       | (unquote-splicing Expr)                  ; reader: ,@Expr
MacroParams := Name* | Name* &rest Name
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

`list`, `quote`, `quasiquote`, `def`, `defn`, `deftype`, `defstruct`, `defstruct+`, `trait`, `impl`,
`derive`, `extern`, `let`, `let-mut`, `if`, `while`, `for`, `cond`, `and`,
`or`, `not`, `match`, `try` (with a nested `catch`), `begin`, `fn`,
`lambda`, `set!`, `print`, `assert`, `assert-equal`, `assert-true`,
`assert-false`, `assert-fail`, `spawn`, `send`, `ffi-pin`, `ffi-unpin`,
`exit`, `close`, `read-line`, `file-open`, `file-read`, `file-write`,
`file-close`, `struct-get`, `make-struct`, `make-variant`, `unwrap`,
`with-resource`, `with-region`, `module`, `use`, `pub`, `export`,
`feature-gate`, `defmacro` (and its synonym `macro`), `test`,
`test-suite`, `run-tests`, `setup`, `teardown`, `test-property`,
`test-compile`, `contracts`, `requires`, `ensures`, `invariant`,
`checkpoint` and `recover`, plus the byte primitives
(`byte-form-dispatch`). `ffi-call` is not a dedicated node; it stays an
application of the reserved name and is recognised during ICNF lowering.

`list` and `quote` produce no node of their own. `(list a b c)` becomes
the constructor chain `(Cons a (Cons b (Cons c Nil)))`
(`ast-list-literal`, `ast.zyl`); `qualify.zyl` rewrites the form the same
way before names are qualified, so `Cons` and `Nil` resolve like
hand-written ones. `(quote d)` checks that `d` holds no name (a name is
`E_MALFORMED_FORM`, since there is no symbol type), then turns every list
in `d` into a list literal of its elements (`ast-quote-data`); an atom is
itself. `(quote)` or `(quote a b)` is `E_MALFORMED_FORM`.

`quasiquote` produces no node either. `(quasiquote d)` with valid data
(`ast-qq-problem` returns `""`) is rewritten by `ast-qq-data`: `(unquote
e)` becomes `e`, and a list becomes a `Cons` chain whose element
`(unquote-splicing e)` becomes `(zyl-qq-append e rest)`, so
`` `(1 ,x ,@ys) `` is `(Cons 1 (Cons x (zyl-qq-append ys Nil)))`.
`qualify.zyl` does this before names are qualified (`qf-quasi-data-p`),
and leaves a malformed quasiquote as written so that `parse-quasiquote`
reports it in the program's own names: a name outside an unquote, a
`,@e` that is not a list element, a nested quasiquote, or an unquote or
splice without exactly one operand is `E_MALFORMED_FORM`. An `unquote`
or `unquote-splicing` left after macro expansion, that is, one written
outside a quasiquote and outside a macro template, is `E_MALFORMED_FORM`
from the arity pass (`arity_check.zyl`).

A recognised form whose arguments do not have the shape its parser
requires becomes an `EUnknown` node, which the arity pass reports as
`E_MALFORMED_FORM` (it used to lower silently to the constant 0).

### Differences from §2

- **`defun` is not recognised.** It is parsed as an ordinary application,
  so a function defined with `defun` is never defined, and a call to it
  is `E_UNBOUND_VARIABLE`. Use `defn`.
- **`alias` is not recognised** as a definition form.
- **`trait`** declares method signatures, `(trait Name (method (params)
  RetType) ...)`, which type calls to the methods
  (`spec/05-types-and-inference.md`); a method whose parameters are not a
  list, `(area self)`, is `E_MALFORMED_FORM`. There is no `where` clause.
- **`extern`**, `(extern "sym" (T ...) R)`, declares a foreign symbol's C
  signature (§16, `spec/09-ffi-contracts.md`). It is a top-level form of
  type Unit that emits no code.
- **`test-suite`, `test-property` and `test-compile` are parsed but
  discard their arguments** (placeholder nodes). `setup` and `teardown`
  are parsed.
- **`contracts`, `requires`, `ensures`, `invariant`, `checkpoint` and
  `recover`** are lowered to ordinary code while the tree is converted;
  see `spec/09-ffi-contracts.md`.
- **Bodies.** Where a form has a body, several body forms are an implicit
  `begin` whose value is the last: `defn`, `fn` and `lambda` bodies, both
  shapes of `let` and `let-mut`, a `try`'s `catch` handler, a `cond`
  clause, `while`, `for` and `with-resource`. `test` and `defmacro` take exactly
  one body (a name and one expression, a name, parameters and one
  template); extra forms are `E_MALFORMED_FORM`, where they used to be
  dropped.
- **`let` accepts two shapes:** `(let x v body...)` and
  `(let (x v) body...)`. A `let` without a body is `E_MALFORMED_FORM`.
  `let-mut` is the same.
- **`if` may omit the else branch.** `(if c t)` is Unit, and `t` must be
  Unit.
- **`for`** accepts the single-binding shorthand `(for (i 0) cond body...)`
  and a list of bindings `(for ((i 0) (j 1)) cond body...)`.
- **`cond`** is lowered to nested `if`. A clause whose test is the literal
  `true` or `else` ends the cond: clauses after it are never reached and
  are dropped, and the cond has that clause's body type. A cond with no
  such clause is Unit when no test holds.
- **`file-open`'s mode** must be a string literal: `"r"`, `"w"`, `"a"`,
  `"r+"`, `"w+"`, `"a+"`, `"rb"`, `"wb"` or `"ab"` (`E_TYPE_MISMATCH`
  otherwise). An Int mode such as `0` used to open the file for writing.
- **`match` arms** may be written flat, `(Variant field... body)`, or with
  the pattern grouped, `((Variant field...) body)`. A field position
  holds a plain name; a nested pattern, or a prelude constructor name
  such as `Nil` in that position, is `E_NESTED_PATTERN`. Pattern kinds
  are described in `spec/10-structs-and-data-types.md`.
- **Definition parameters** are a bare name or `(name Type)`; anything
  else is `E_MALFORMED_PARAMETER`.
- **`_` is the discard name.** `_` and any name beginning with `_` are
  exempt from the unused-binding and shadowing warnings and from
  `E_DUPLICATE_PARAMETER`, so `(defn f (_ _) ...)` is legal. A binding
  named exactly `_` gets no stack slot.
- `pub` and `feature-gate` wrap a top-level definition and are consumed by
  the module resolver (§24.4, §31.10); `export` is still accepted but
  deprecated (§24.3).
