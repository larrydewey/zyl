# Zyl Specification — Syntax and Forms

**Canonical authority:** `zyl_specification.txt` §2, §1.3
**Related:** `spec/01-lexing-and-tokens.md`, `spec/03-macros-and-hygiene.md`
**Implementation:** `src/parser.rs`, `src/ast.rs` (PostProcessor)

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

All S-expressions are parsed as raw Call/Apply nodes by the parser.
A PostProcessor phase converts them into specialized ExprInner variants.

This eliminates dispatch complexity in the parser: the parser handles
exactly one grammatical form (S-expression → list of expressions), and
all specialization is deferred to PostProcessor.

**See also:** `docs/architecture-decisions.md` §A1 (No-Dispatch S-Expression Parsing)
