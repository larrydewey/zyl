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
  | (let* ((Name Expr)*) Body)          ; desugared to nested let
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
  | (chan-send Expr Expr)
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
  | (panic String)
  | (tuple Expr*)                     ; element types are part of the type
  | (tuple-get Expr Int)
  | (len Expr)                      ; String, List, Vec, or Map
  | (int? Expr) (float? Expr) (bool? Expr) (string? Expr)
  | (struct? Expr) (alias? Expr)    ; type predicates
  | (vec Expr...)                   ; element literal
  | (map Expr Expr ...)             ; key/value literal, even count
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
  | (Name.Field Expr) ; Auto-generated field accessor (e.g., Point.x)

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

**Field accessors.** `(defstruct Point (x) (y))` also defines one accessor per field,
`Point.x` and `Point.y`: each is `(defn Point.x ((p Point)) (struct-get p "x"))`,
an ordinary typed function generated before type checking, so it is a
value like any other function and has the field's type. `defstruct+`
generates them too. A program definition of the same name is
`E_DUPLICATE_DEFINITION`, reported at the program's definition and naming
the `defstruct`. In a package an accessor is visible as its struct is.
`struct-get` and dot syntax are unchanged.

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
`derive`, `extern`, `let`, `let-mut`, `if`, `when`, `unless`, `while`, `for`, `cond`, `and`,
`or`, `not`, `match`, `try` (with a nested `catch`), `begin`, `fn`,
`lambda`, `set!`, `print`, `assert`, `assert-equal`, `assert-true`,
`assert-false`, `assert-fail`, `spawn`, `chan-send`, `ffi-pin`, `ffi-unpin`,
`exit`, `close`, `read-line`, `file-open`, `file-read`, `file-write`,
`file-close`, `struct-get`, `make-struct`, `make-variant`, `unwrap`,
`with-resource`, `with-region`, `module`, `use`, `pub`, `export`,
`feature-gate`, `defmacro` (and its synonym `macro`), `test`,
`test-suite`, `run-tests`, `setup`, `teardown`, `test-property`,
`test-compile`, `contracts`, `requires`, `ensures`, `invariant`,
`checkpoint` and `recover`, plus the byte primitives
(`byte-form-dispatch`). `ffi-call` is not a dedicated node; it stays an
application of the reserved name and is recognised during ICNF lowering.
`div?` and `rem?` (§20.3) are rewritten in `desugar.zyl`, as the reader
reads each file, into `let`/`if`/`Some`/`None` around `div!`/`rem!`, so
the type checker and the interpreter see only
ordinary forms. A top-level `(numeric checked|wrapping|saturating)`
(§20.1) is read by the module resolver, which checks its shape and
records the package's policy, and converts to nothing here; one that is
not at the top level is `E_MALFORMED_FORM`.

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
- **`alias`** is a transparent type alias (`spec/10-structs-and-data-types.md`); it takes no type parameters.
- **`trait`** declares method signatures, `(trait Name (method (params)
  RetType) ...)`, which type calls to the methods
  (`spec/05-types-and-inference.md`); a method whose parameters are not a
  list, `(area self)`, is `E_MALFORMED_FORM`. There is no `where` clause.
- **`extern`**, `(extern "sym" (T ...) R)`, declares a foreign symbol's C
  signature (§16, `spec/09-ffi-contracts.md`). It is a top-level form of
  type Unit that emits no code.
- **`with-resource`, `assert-fail`, `test-suite` (with `setup` and
  `teardown`) and `test-property` are rewritten on the parse tree**
  (`compiler/desugar.zyl`) into ordinary forms before module resolution;
  `test-compile` is decided after macro expansion
  (`spec/04-evaluation-semantics.md`).
- **`contracts`, `requires`, `ensures`, `invariant`, `checkpoint` and
  `recover`** are lowered to ordinary code while the tree is converted;
  see `spec/09-ffi-contracts.md`.
- **`numeric`**, `div!`, `rem!`, `div?`, `rem?`, `wrapping+`, `wrapping-`,
  `wrapping*`, `saturating+`, `saturating-`, `saturating*` are the
  numeric-model forms of §20 (`spec/14-determinism-and-hashing.md`). The
  operators are Int-only; `div!`/`rem!` and the six policy operators are
  recognised by name in ICNF lowering like `+` is.
- **`tuple` / `tuple-get`** (§21.5, §4.2). `(tuple e...)` builds a
  generated single-variant ADT — one per element type list, so the element
  types are part of the type and `(tuple 1 2)` and `(tuple "a" "b")` cannot
  be mixed. `(tuple-get t i)` reads element `i` from 0; an index past the
  end is `E_INDEX_OUT_OF_BOUNDS` naming the arity, and a receiver the
  checker knows to be a `defstruct` is `E_TYPE_MISMATCH` listing its
  fields. A builtin receiver (`Int`, `String`) is not caught: the read
  compiles and yields a word. The generated type name is an
  implementation detail. A type parameter cannot be shown to be a tuple, so
  `tuple-get` on one is `E_CANNOT_INFER`; there are no trait bounds to
  write (§6.1).
- **`len`** (§21, §4.2). `(len x)` is one name for the length of the four
  types that have one: String, List, Vec, Map. It is resolved during type
  checking, on the argument's type, to that type's own length function, so
  `str-length`, `list-length`, `vec-len` and `map-size` remain and mean the
  same thing; `len` is the uniform spelling, not a replacement. Anything
  else — an `Int`, a tuple — is `E_TYPE_MISMATCH` naming the type. A tuple
  is excluded on purpose: its length is in the type, so `tuple-get` already
  reports a read past the end as `E_INDEX_OUT_OF_BOUNDS`. `IntMap` is
  accepted alongside `Map` since it also has a length.
- **`vec` / `map` literals** (§21.5). `(vec e...)` and `(map k v ...)` are
  desugared, in `desugar.zyl`, to the collections' own build calls: a chain
  of `vec-push` from `vec-create-default n`, and a chain of `map-insert`
  from `map-new`. Neither adds stdlib API, and `len` and the ordinary
  accessors read the results like any other `Vec` or `Map`. A chain of
  pushes rather than one call taking the elements, because a function
  cannot be generic over an element type (§11), so there is no single
  signature to desugar into. The `Vec` takes its element type from the
  first push, so a mixed literal is `E_TYPE_MISMATCH` at the push that
  disagrees; an odd `map` argument count is `E_MALFORMED_FORM`. Like
  `(list ...)`, these are literal constructors and a `defn` of the same
  name does not shadow them.
- **The type predicates** (§21.4). `int?`, `float?`, `bool?`, `string?`,
  `struct?` and `alias?` are decided in the type pass from the operand's
  static type, because a Zyl value is an untyped word and there is nothing
  at runtime to ask. Lowering emits the operand — so its effects still
  happen — and then the constant, which is why `(int? (print 1))` is
  `false` and still prints. They ask about the *type*: `(bool? false)` is
  `true`. `struct?` is true for a `defstruct` type and false for an ADT;
  the set of struct type names is recorded in `ta-structs` when the fields
  are registered, keyed by short name, so two modules with a struct of one
  name share an answer. `alias?` is false wherever inference has run,
  because aliases are transparent (§4.6) and the type is the target by
  then; it is present because the spec lists it. A receiver whose type is
  not known (a generic function's parameter) is `E_CANNOT_INFER`, not
  `false`. A `defn` of the same name in scope shadows them, as for any
  builtin.
- **`quote` and a bracketed datum** (§4.9, §21.5). `'d` reads constant
  data: an Int, Float, String or Bool is itself, and a list datum is the
  list literal of its quoted elements. The reader rewrites `[e ...]` to
  `(list e ...)`, so a quoted bracket arrived carrying a `list` name and
  was `E_MALFORMED_FORM` for containing one, while `'(1 2)` was accepted —
  two spellings of one datum behaving differently. `ast-quote-unbracket`
  drops the reader's own marker, in `ast.zyl` so the reader (`quote-check`),
  the conversion (`ast-quote-data`) and the qualifier (`qf-quote-data-p`,
  via `ast-quote-ok`) all agree. A name the writer typed is still
  `E_MALFORMED_FORM`: only the marker is removed, not the check. Because the
  reader no longer distinguishes the forms, `'(list 1 2)` is the same datum
  as `'[1 2]`.
- **Operator arity** (§21.1, §21.2, book §2.6). Every binary operator takes
  *any number* of operands and folds left-associatively, so `(- 10 3 2)` is
  `(10-3)-2`. §21.1 writes `-`, `/` and `%` as `(- a b)`, which reads as
  two operands and is not what the language does; the n-ary form is
  implemented, documented in book §2.6 ("Arithmetic (n-ary,
  left-associative)") and pinned by `regression/arithmetic.zyl`
  (`int-modulo-like`: `(- 10 2 2 2 2)` is 2, which is also how you spell
  modulo; `float-sub-3`: `(- 1.0 2.0 3.0)` is -4.0; `float-div-3`:
  `(/ 1.0 2.0 3.0)`). One operand is the unary form where one exists:
  `(- x)` negates, `(+ x)` and `(* x)` are `x`. Zero operands is
  `E_ARITY_MISMATCH`. Left nesting is load-bearing, not cosmetic: `+` and
  `*` associate so their grouping is invisible, but `-`, `/` and `%` do
  not, so `10-(2-3) != (10-2)-3`. Worth knowing when reading code — a
  three-operand `-` is a fold, not a subtraction with a stray argument.
- **Integer literal range** (§4.9). An `Int` is 64-bit signed, so every
  integer literal is range-checked as it is lexed, in every base (decimal,
  `0x`, `0o`, `0b`); one that does not fit is `E_INTEGER_OVERFLOW` at the
  literal, reported from the token stream before parsing, because the lexer
  has no file to name in a diagnostic. Checked rather than assumed:
  `zyl_cstr_to_int_base` answers 0 for a value it cannot hold, so
  `9223372036854775808` used to be the number zero and
  `-9223372036854775809` used to wrap to a positive value of the wrong sign.
  A `TkIntOverflow` token carries the text and offset; nothing consumes it.
  The check works on indices into the literal's own text, because a
  literal's text is a view into the source and `str-length` on a substring
  of a substring of a view does not report the length.
- **Float literal range** (§4.9). A `Float` literal outside binary64 is
  *not* an error: `1e400` is `inf` and `1e-400` is `0.0`, per IEEE 754 and
  as C, Python, JavaScript and Rust all produce. The catalog carried an
  `E_FLOAT_OVERFLOW` code that nothing raised, and a documented code that
  cannot happen implies a check that does not exist, so it is deleted
  rather than implemented. This is the opposite of the integer case: there
  the alternative to an error was a silent `0` or a silent wrap, both
  plausible-looking wrong numbers. `inf` announces itself instead — it
  prints as `inf`, propagates through arithmetic, and compares false
  against anything finite. `regression/float-literal-range.zyl` pins both
  ends.
- **`let*`** (`zyl_specification.txt` §1.3, §2 grammar, §4.9) is sugar
  for nested `let`, with sequential bindings: `(let* ((a 1) (b (+ a 10)))
  body)` is `(let a 1 (let b (+ a 10) body))`, so each binding is in scope
  for the ones after it. It is desugared on the parse tree in
  `desugar.zyl`, before module resolution, so the names it introduces are
  qualified as if hand-written. At least one `(Name Expr)` binding and at
  least one body form; anything else is `E_MALFORMED_FORM`. A desugared
  `let*` type-checks exactly as the nested `let`s it becomes, so it adds
  no typing rule of its own. Added to the spec by this note's commit: the
  form had been implemented and documented in the book but the spec did
  not mention it, not even in the §1.3 keyword list.
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
  and a list of bindings `(for ((i 0) (j 1)) cond body...)`, told apart by
  whether the first element is an identifier. An empty binding list
  `(for () cond body...)` is a plain `while`; a binding written `(name)`
  with no initial value starts at 0.
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
