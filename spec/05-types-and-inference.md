# Zyl Specification — Types and Inference

**Canonical authority:** `zyl_specification.txt` §4, §5, §6, §17
**Related:** `spec/06-capability-types.md`, `spec/10-structs-and-data-types.md`
**Implementation:** `stdlib/compiler/type_annotate.zyl` (the type checker), `stdlib/compiler/ffi_sigs.zyl` (runtime signatures), `stdlib/compiler/expr_inner.zyl` (`extern`, field types), `stdlib/compiler/lift_impls.zyl`, `stdlib/compiler/derive.zyl`

---

## 4. Type System

### 4.1 Primitive Types

```
Int | Float | Bool | String | Unit
```

### 4.2 Composite Types

```
Vec<T>     — contiguous array (O(1) access, deterministic iteration if sorted)
Map<K,V>   — hash map (deterministic iteration by sorted key hash)
Result<T, E> — error handling type
Struct     — named collection of fields (immutable by default)
Alias      — transparent wrapper (zero-cost)
```

### 4.3 Capability Types

`TCap<T>`, `TMut<T>`, `TAtomic<T>`, `TBox<T>`, `TPin<T>` — see
`spec/06-capability-types.md`.

### 4.4 Function Types

```
TFun([T*], TReturn)
```

### 4.5 Trait Bounds

```
T : TraitName
```

### 4.6 Inference

Hindley-Milner with region/capability constraints.
Monomorphization during Phase 5.

### 4.7 Type Equality

- Structural for primitives/collections.
- Nominal for Structs/ADTs/Aliases.
- Aliases are transparent: A is coerced to B (and vice versa) without runtime cost.

### 4.8 Soundness (normative)

A program the compiler accepts never uses a value at the wrong
representation: no Int used as a pointer, no Float through integer
arithmetic, no String compared by address, no call with the wrong number
of arguments. The checker is sound, not best effort: every unification
failure, occurs-check failure and type it cannot determine is a compile
error, all of a program's type errors are reported, and then the compile
fails.

There is no cast form. The trusted base is the compiler, the C runtime,
the runtime-signature table (`stdlib/compiler/ffi_sigs.zyl`) and a
program's own `extern` declarations (§16).

**Known exception:** `receive` returns a value of any type, because an
actor mailbox holds whatever any sender put there (§15). Typed
single-sender channels are to replace mailboxes and remove it.

`ZYL_STRICT_TYPES=report` prints the errors as `W_TYPE_STRICT` warnings
and continues; it is a tool for counting, never a way to run an ill-typed
program.

### 4.9 Typing Rules (normative)

Judgements are `Γ ⊢ e : τ`. Top-level functions are generalized per
strongly connected component of the call graph; local `let` bindings and
top-level `def` values are monomorphic (the value restriction). A type variable left unconstrained is a type parameter.

| Form | Rule |
|------|------|
| Literals | integer : Int; float : Float; `true`, `false` : Bool; `"..."` : String; `unit` : Unit |
| Variable | Γ(x) = ∀ā.τ ⊢ x : τ[ā := fresh] |
| `let` | e1 : τ1, Γ,x:τ1 ⊢ e2 : τ2 ⊢ `(let x e1 e2)` : τ2 (`let-mut` the same) |
| `set!` | x bound by `let-mut` at τ, e : τ ⊢ `(set! x e)` : Unit |
| `begin` | `(begin e1 ... en)` : the type of en; `(begin)` : Unit |
| `if` | c : Bool, a : τ, b : τ ⊢ `(if c a b)` : τ; c : Bool, a : Unit ⊢ `(if c a)` : Unit |
| `cond` | Every test : Bool, every body : τ. A clause whose test is the literal `true` or `else` ends the cond, and the cond is τ; with no such clause, τ = Unit |
| `while`, `for` | condition : Bool ⊢ the loop : Unit |
| `fn` | Γ,x1:T1..xn:Tn ⊢ body : R ⊢ `(fn (x1..xn) body)` : (T1..Tn) -> R |
| Application | f : (T1..Tn) -> R, ai : Ti ⊢ `(f a1..an)` : R (the argument count must equal the parameter count) |
| Arithmetic | `+ - * / %`: both operands Int -> Int, or both Float -> Float (a closed class; no implicit conversion). `(- x)` negates; `(+ x)` and `(* x)` are x |
| Ordering | `< > <= >=`: two operands of one type, Int, Float or String -> Bool. An ADT is ordered with `Ord.compare` (derivable, §5.6) |
| Equality | `= == !=`: two operands of one type -> Bool (structural for ADTs and Strings) |
| Bits | `bit-and bit-or bit-xor shl shr ashr bit-not`: Int |
| Constructor | For `(deftype T (C F1..Fn) ...)`: C : ∀ā. (F1..Fn) -> (T ā), ā the type parameters. An untyped struct field is an implicit type parameter of its struct |
| `match` | Scrutinee : T ā; an arm `(C x1..xn body)` binds xi at C's i-th field type; every body : τ ⊢ match : τ. Patterns are flat (`E_NESTED_PATTERN`); exhaustiveness is §12 |
| `struct-get` | p : S ā, f a field of S ⊢ `(struct-get p "f")` : its type. When p's type is not otherwise determined, the one struct with a field f is taken; if several have it, `E_CANNOT_INFER` |
| `try` | b : τ, x : String ⊢ h : τ ⊢ `(try b (catch x h))` : τ |
| Assertions | `assert-true`, `assert-false`, `assert`: a Bool -> Unit; `assert-equal l r`: l and r of one type -> Unit |
| `print` | Any value -> Unit |
| Traits | A method's `Self` is its receiver's type: `(trait Ord (compare (self (other Self)) Int))`. In `(Tr.m r a..)`, r's type selects the impl at compile time; a trait-generic function is specialized per type at every call and every use as a value; a call whose receiver type stays unknown is `E_CANNOT_INFER` |
| `exit`, `error` | Do not return: any type |
| `main` | () -> Int |
| `spawn` | The entry is () -> a |
| Actors | `spawn` : Actor; `actor-self` : Actor; `send` : Actor a -> Unit; `receive` : a (§4.8) |
| FFI | A runtime symbol (`zyl_*`) has the type in the signature table; a foreign symbol the type of its `(extern "sym" (T1..Tn) R)` declaration (§16); `(ffi-pin v)` : `(Pin a)` for v : a; `(ffi-unpin p)` : a for p : `(Pin a)`; pinning a function is `E_FFI_TYPE_NOT_PINNABLE` |
| List literal | `(list e1 .. en)` and `[e1 .. en]` are `(Cons e1 (Cons .. (Cons en Nil)))`: e1..en are evaluated left to right, every ei : τ ⊢ `(List τ)`. `(list)`, `[]` : `(List a)`. Mixed element types are `E_TYPE_MISMATCH` |
| `quote` | `(quote d)`, `'d`: an Int, Float, String or Bool datum is itself; a list datum is the list literal of its quoted elements, so `'((1 2) (3))` : `(List (List Int))` and `'()` : `(List a)`. A name inside d, or a `quote` without exactly one operand, is `E_MALFORMED_FORM` (there is no symbol type) |
| Byte operations | Offsets, lengths and stored values are Int, and so is every result but the handles. `(bytebuf R N)` : ByteBuf; `(byteslice b off len)` : ByteSlice for b : ByteBuf; `(byteslice-sub s off len)` : ByteSlice for s : ByteSlice; `(bytebuf-append b s)` : Int for b : ByteBuf, s : ByteSlice; `bytebuf-len`, `bytebuf-cap`, `bytebuf-ptr` and the atomic operations take a ByteBuf. A load or store (`load-u8` .. `store-i64`) takes a ByteBuf or a ByteSlice; a handle whose type is still unknown when its function group is typed is `E_CANNOT_INFER` (annotate it: `((b ByteBuf))`) |
| `file-open` | path : String, mode a literal fopen mode -> Int |
| `file-read` | `(file-read fd n)`: fd, n : Int -> String |
| `file-write` | `(file-write fd s)`: fd : Int, s : String -> Int |
| `file-close` | `(file-close fd)`: fd : Int -> Int |

### 4.10 Type Errors

| Code | Condition |
|------|-----------|
| `E_TYPE_MISMATCH` | Two types that must be equal are not |
| `E_INFINITE_TYPE` | A type would contain itself (occurs check) |
| `E_CANNOT_INFER` | A type the program does not determine |
| `E_UNBOUND_VARIABLE` | A name defined nowhere |

---

## 5. Trait System

### 5.1 Trait Declaration

```
(trait Name (method1 (params1) ReturnType1) ...) [where TypeParam : OtherTrait]
```

### 5.2 Trait Implementation

```
(impl TraitName TypeName (defn methodName (params) body) ...)
```

### 5.3 Coherence Rules

| Rule | Statement |
|------|-----------|
| C1 | One impl per (Trait, Type) pair. |
| C2 | Orphan rule: impl valid only if trait or type defined in current crate (the package, in v5.0; see §24.6). |
| C3 | No conflicting impls. |

Across packages, v5.0 states the orphan rule at the package boundary (§24.6):
a package may implement a trait for a type only if it defines the trait or
defines the type, otherwise `E_PKG_ORPHAN_IMPL`. Coherence is checked over
the whole resolved graph.

### 5.4 Trait Resolution

Resolved in Phase 3. Recursive transitive bounds supported.

### 5.5 Trait Bounds in Generics

```lisp
(defn sort ((T : Ord) xs) body)
```

### 5.6 Derive Mechanism

- Supported: Eq, Ord, Debug, Show, Clone, Hash.
- Constraint: All fields must implement the trait.
- Error: `E_TRAIT_NOT_DERIVABLE` if constraint fails.

### 5.7 Standalone Derive

```lisp
(derive TypeName [TraitA TraitB ...])
```

Must appear in same module as type. Fails if trait not derivable.

---

## 6. Generics

### 6.1 Generic Function Declaration

```lisp
(defn name ((TypeParam : TraitBound*) (param Type) ...) body)
```

- `defun` is a synonym.
- `TypeParam` is an uppercase identifier (convention).
- `TraitBound` is optional; absent = unbounded.
- Multiple bounds: `((T : Ord Eq))` → T must implement both.

Multiple type parameters are declared as multiple parameter groups:

```lisp
(defn pair ((T) (U)) (make-tuple t u))      ; 2 type params
(defn min ((T : Ord) a b) ...)               ; 1 bounded type param
(defn f ((T) (U) x Int) ...)                 ; interleaved with typed params
```

**Scope:** TypeParam is scoped to its own `defn`. Shadowing T in a nested defn is an error.

**Implemented:** type parameters are not declared. An uppercase name in a
parameter or field annotation that is not a declared type is a type
parameter scoped to that declaration, and an unannotated parameter has a
fresh type (§4.9). The group syntax above is not accepted: `((T) x)` is
`E_MALFORMED_PARAMETER`, and so is `((T : Ord) a)`: a parameter's type
is written `(name Type)`, without a colon, and a trait name in type
position (other than `Secret`) is rejected. Trait bounds
are not written; a missing impl is found at each specialized instance
(`E_TRAIT_NOT_FOUND`).

### 6.2 Type Param Semantics

- Type parameters are positional in declaration, and so is monomorphized naming (§6.4).
- A type parameter used multiple times constrains both positions to the SAME concrete type.
- Type parameters appear ONLY in type position (variant field, param type, collection type). Never as runtime values.

### 6.3 Generic Type in Collections

```
Vec<T>, Map<K,V>   ; K, V, T inferred from usage context
```

### 6.4 Monomorphization

For each call site of a generic function, the compiler:

1. Infers concrete types for ALL type parameters from argument types.
   - A parameter with no evidence at any call site → `E_CANNOT_INFER`
     (unless a trait bound selects a finite set).
2. Verifies all trait bounds are satisfied (`E_TRAIT_BOUND_NOT_SATISFIED`).
3. Generates a canonical specialization name:
   ```
   functionName~Type1,Type2,...     ; argument types in argument order
   ```
   Compound types are written in full (`List<Int>`, `fn<Int>String`).
   `f<Int, String>` and `f<String, Int>` are different instances. Distinct maps → distinct names.
   Only a function that applies a trait method, `print`, an operator or an
   equality at a type parameter is specialized, at every call and every
   use as a value; any other generic function is compiled once.
4. Caches the monomorphized function for reuse.

Examples:

```
(min 3 5)       → min~Int,Int
(min "a" "b")   → min~String,String
(pair 1 "hi")   → pair~Int,String
(pair 1.0 2.0)  → pair~Float,Float
```

### 6.5 Generic ADTs

```lisp
(deftype Option (Some T) None)
(deftype Result (Ok T) (Err E))       ; 2 type params from uppercase fields
(deftype List (Cons T (List T)) None) ; recursive generic reference
```

- `Option<Int>` and `Option<String>` are distinct types.
- Type params collected from uppercase variant field names; duplicates kept once (same-type constraint).
- Constructors and pattern matching are not specialized: every instance of a generic ADT has one representation.
- Generic structs work the same way: `(defstruct Box (v T))` is `(Box T)`, and an untyped struct field is an implicit type parameter of its struct (§4.9).

### 6.6 Generic ADT Derivation

```lisp
(derive Result [Eq])   ; requires ALL type params to implement Eq
```

Deriving on a multi-param ADT is allowed; the impl is parameterized over the ADT's type params.
`E_TRAIT_NOT_DERIVABLE` if any concrete instantiation fails the field constraint.

### 6.7 Error Cases

| Code | Condition |
|------|-----------|
| `E_CANNOT_INFER` | generic param with no call-site evidence |
| `E_TRAIT_BOUND_NOT_SATISFIED` | concrete type violates a bound |
| `E_UNKNOWN_GENERIC_PARAM` | reference to undeclared type parameter |
| `E_TRAIT_NOT_DERIVABLE` | derive constraint fails |

---

## 17. Monomorphization

```
name the instance by its argument types in argument order (§6.4)
generate canonical specialization name
```

Deterministic output guaranteed. A named type is written by its
canonical symbol key (`<package>@<major>::<module-path>::<symbol>`,
§31.2), so names stay distinct over a multi-package graph.

---


## Implementation Notes

Not normative. These describe the self-hosted compiler and record where it
falls short of §4–§6 and §17.

### The checker

- One pass, `type_annotate.zyl` (`ta-annotate`), is the type checker. It
  runs over the whole program after derive expansion and impl lifting,
  immediately before ICNF lowering (`pipeline.zyl`), and records every
  expression's type in the node table `node-types` (`node_tables.zyl`),
  which lowering reads for codegen kinds (`ta-kind`: String, Float) and
  region inference for scalar marks (`ta-scalar`). There is no other
  inferer: `type_inference.zyl` and `monomorphization.zyl` were deleted,
  and `type_system.zyl` now holds only `Pair` and the `Region` family.
- Types are `TaV` (a variable; negative ids are template slots), `TaC name
  args` (a constructor) and `TaF params result`. The built-in constructors
  are `Int`, `Float`, `Bool`, `String`, `Unit`, `ByteBuf`, `ByteSlice`,
  the opaque runtime handles `Arena`, `Ptr`, `Words`, `StrBuf`, `UF`,
  `Actor`, `Fd`, `FileId`, `FnPtr`, and the parameterized handles
  `(SMap v)`, `(WVec v)`, `(Attr k v)`, `(Array a)`, `(Ref a)` and
  `(Pin a)`.
  `(Fn (A ...) R)` is a function type. `(Secret T)` is typed as `T` (the
  secret mark is `secret_check.zyl`'s). There is no `Byte` type: byte
  literals and byte loads are `Int`. The capability wrappers of §4.3 are
  not types; `TCap`/`TMut` are enforced syntactically
  (`spec/06-capability-types.md`).
- Top-level functions are visited in Tarjan order and generalized per
  strongly connected component; `let`, `let-mut`, lambda and `for`
  bindings are monomorphic. `main` must be `() -> Int` (`ta-check-main`).
- Unification has an occurs check. Every failure is reported where the
  innermost expression being typed sits, with both types; a failed
  occurs check is `E_INFINITE_TYPE`; a type the pass cannot determine
  (an FFI result with no signature, an unresolvable trait receiver, a
  function needing more than 256 instances) is `E_CANNOT_INFER`; an
  unknown name is `E_UNBOUND_VARIABLE`. The variables involved in a
  failure are then poisoned, only so that one mistake is not reported
  many times; a poisoned type prints as `!` in messages and `?` in the
  REPL's `:type`.
- These errors are collected: the pass types the whole program, then
  fails with `error[CODE]: the program does not type-check (N errors
  above)`, CODE being the first error's. A `struct-get` of a field a
  known struct does not have (`E_TYPE_MISMATCH`, listing the fields), the
  trait-method errors (`E_TRAIT_NOT_FOUND`, below), `E_FFI_TYPE_NOT_PINNABLE`
  and an `extern` of a runtime entry (`E_FFI_RESTRICTED`) are collected
  the same way.
- `ZYL_STRICT_TYPES=report` (or `=1`) turns every collected error into a
  `W_TYPE_STRICT` warning and lets the compile go on.
- An argument whose type clashes with a parameter annotation or a
  declared field type is reported as `mismatched types: expected T, found
  U`, labelled at the declaration (`ta-check-params`, `ta-check-fields`);
  unification then reports nothing more for it.
- Arithmetic and ordering operands are checked once the whole program is
  typed (`ta-check-num`): an operand that resolves to anything other than
  Int or Float (or String, for ordering) is `E_TYPE_MISMATCH`
  (`arithmetic on T`, `ordering on T`). An operand still a type variable
  is not reported there: its function is specialized per type (see
  Generics), and each instance is checked at its concrete type.
- `file-open`'s mode must be one of the string literals `"r"`, `"w"`,
  `"a"`, `"r+"`, `"w+"`, `"a+"`, `"rb"`, `"wb"`, `"ab"`. A file is its
  descriptor, an Int. `file-read` takes two Ints and returns a String,
  `file-write` an Int and a String and returns an Int, `file-close` an Int
  and returns an Int. (`file-write` used to accept an Int as its data and
  pass it to `strlen` as an address.)
- Byte operations (`ta-bytes`, `ta-buf-op`): every offset, length and
  stored value must be Int (`ta-walk-int` requires each operand, where it
  used to type them and require nothing, so a String offset used the
  string's address). `byteslice`, `bytebuf-append`, `bytebuf-len`,
  `bytebuf-cap`, `bytebuf-ptr` and the atomics require a ByteBuf;
  `byteslice-sub` and `bytebuf-append`'s second operand a ByteSlice. A
  load or store takes either; a handle still a type variable waits for its
  function group, like a `struct-get`, and is `E_CANNOT_INFER` if nothing
  settles it (`ta-bytes-ambiguous`).
- A list literal is typed as the `Cons` chain it becomes, so its type is
  `(List τ)` and mixed elements are `E_TYPE_MISMATCH`, reported once:
  a unification failure inside a type (an element of two lists) is not
  reported again by the enclosing unification.
- A top-level `def` is rewritten by the parse into a zero-argument getter
  function (`def-getter`, `expr_inner.zyl`) and typed as that function,
  but its type is not generalized (`ta-gen-members`): the value
  restriction, so `(def cells (ffi-call "zyl_wvec_new" 1000))` is one
  vector of one element type.
- A `struct-get` whose record type is still unknown when its component
  closes is committed to the one struct that has the field; if several
  do, it is `E_CANNOT_INFER` (`ta-sg-ambiguous`).

### Primitive surface

- `ffi-call` to a runtime symbol (`zyl_*`) is typed by its signature in
  `ffi_sigs.zyl`: the argument count must match and each argument unifies
  with its parameter type. A runtime symbol missing from the table has no
  type (`E_CANNOT_INFER`), except eleven string-producing entries
  (`ta-ffi-str`: `zyl_cstr_concat`, `zyl_int_text`, ...) whose result is
  String and whose arguments are not checked. A runtime symbol is one
  the runtime exports (`zyl_runtime_export_p`); an `extern` declaring
  one is `E_FFI_RESTRICTED` at each call, so an `extern` cannot retype a
  runtime entry.
- A foreign symbol is typed by its `extern` declaration (see
  `spec/09-ffi-contracts.md`); an undeclared one is `E_CANNOT_INFER`.
- A few standard-library functions have fixed signatures in the pass
  (`ta-builtin-sig`): `str-concat`, `str-length`, `str-substring`,
  `str-equal`/`str-eq` (Bool), `print-string` and `print-float` (Unit),
  `receive` (`-> a`), `actor-self` (`-> Actor`), the contract helpers,
  the `def` getters' cell operations (whose names contain spaces, so no
  source can call them) and `collections/vec`'s typed arrays.
  `zyl-repl-global` is typed (`String -> a`) only while the REPL compiles
  its own generated program.
- Statement forms (`print`, `set!`, `while`, `for`, the assertions,
  `send`, `test`) are Unit; `ffi-pin` is `a -> (Pin a)` and
  `ffi-unpin` `(Pin a) -> a` (`Pin` is a handle type, so an `extern` can
  take one for an out-parameter); `exit` takes an Int and, like
  `error`, has any type.

### Generics

- A function that is generic only in values it passes along is compiled
  once: every value is one machine word. A function that applies a trait
  method, `print`, an arithmetic or comparison operator, or an equality
  to a value of type-variable type is *trait-generic*. Each call and each
  use as a value (`(map show-it xs)`) with concrete argument types gets
  its own instance, typed and checked at those types, and the call is
  renamed to it (`node-calls`). The generic original of a trait-generic
  function is then dropped from the program (`ta-drop-generic`), so no
  unspecialized body is ever run.
- An instance is named `f~T1,T2,...`: the canonical text of the argument
  types in argument order, compound types written out in full
  (`List<Int>`, `fn<Int>String`, a named type by its canonical key), as
  §6.4 specifies: `f<Int, String>` and `f<String, Int>` are different
  instances.
- More than 256 instances of one function (in practice polymorphic
  recursion) is `E_CANNOT_INFER`.
- A type variable in a use's type that no signature of the enclosing
  component mentions is defaulted to Int when the component closes
  (`ta-default-locals`), e.g. the error type of `(Ok "yes")`. A trait
  call's receiver is never defaulted: an unknown receiver is
  `E_CANNOT_INFER`.
- Type parameters are not declared: an uppercase name in a field or
  parameter annotation that is not a declared type is a type parameter
  (scoped to the declaration); a lowercase unknown name is a fresh
  variable. So a misspelled type name (`Strng`) silently becomes a type
  parameter. The §6.1 spellings `((T : Ord) x)` and `((T) x)` are
  `E_MALFORMED_PARAMETER`, as are `(a : Int)` (the colon form) and a
  trait name used as a type (`(a Ord)`). Trait bounds are never declared
  or checked as such; a missing impl is found at the instance
  (`E_TRAIT_NOT_FOUND`). `E_TRAIT_BOUND_NOT_SATISFIED` and
  `E_UNKNOWN_GENERIC_PARAM` are catalogued but never raised.
- Generic ADTs and generic structs (§6.5) work: `(defstruct Box (v T))` is `(Box T)`, and an untyped
  struct field is an implicit type parameter of its struct (§4.9), so
  `(defstruct P (x) (y))` has two type parameters and each value's field
  types are inferred where it is built. Constructors and `match` are
  not specialized per type; only functions are.

### Traits

- `trait` declarations (`ETraitDecl`) give each method a type scheme in
  which `Self` is the first parameter's type. A method whose parameters
  are not a list, `(area self)`, is `E_MALFORMED_FORM`. There is no
  `where` clause.
- `lift_impls.zyl` lifts each impl method to a top-level function
  `Trait.method_Type` whose first parameter is annotated with the impl's
  type; a bare generic receiver (`impl Eq Result`) stands for any
  instance.
- `(Trait.method r ...)` is resolved at compile time from r's type to
  that function, or to an instance of it when the impl is itself
  trait-generic. There is no run-time dispatch: a trait call the pass
  leaves unresolved is `E_CANNOT_INFER` (`type_annotate.zyl`, and
  `ic-trait-unresolved` in `icnf.zyl` as a backstop).
- A method call written `(r.m ...)` (rewritten to `zyl-method`) picks the
  only trait declaring `m`, or the one with an impl for r's type. No trait
  declaring `m`, no impl for r's type, a concrete receiver with no impl
  of the trait, or two candidate traits is `E_TRAIT_NOT_FOUND`.
- `print` of a value whose type has a `Show` impl prints its
  `Show.show`; any other non-primitive value prints as a word (an
  address).
- Coherence: two written impls of one trait for one type are
  `E_DUPLICATE_IMPL` (`derive.zyl`); the package-boundary orphan rule
  (§24.6) is enforced by the module resolver (`E_PKG_ORPHAN_IMPL`).

### Derive and equality

- `(derive Type Trait...)` (traits space-separated) generates impls for
  all six §5.6 traits (`derive.zyl`): `Show` and `Debug` print
  `Variant(a, b)` or `Struct { f: a }`; `Eq.eq` is `==`; `Clone.clone`
  returns the value (values are immutable); `Hash.hash` folds the fields'
  hashes FNV-style; `Ord.compare` orders variants by declaration, then
  fields lexicographically. A field type without the trait, a `Secret`
  field for `Eq`, `Ord`, `Hash` or `Clone`, or a trait outside the six is
  `E_TRAIT_NOT_DERIVABLE`.
- `==`, `=`, `!=` and `assert-equal` on an ADT or struct compare by
  content whether or not `Eq` was derived: the pass generates, for each
  compared type, `T.==`, which is false for different variants and
  otherwise compares each field pair with `==`, so nested ADTs, Strings
  and Floats compare by value. A generic field makes it trait-generic.
  A type with a `Secret` field gets no such function and keeps codegen's
  shallow comparison. `assert-equal`'s two sides have one type, and a
  Float type selects the epsilon comparison.
- `<`, `>`, `<=` and `>=` on an ADT are `E_TYPE_MISMATCH`; use
  `Ord.compare`.

### Known holes

`receive` (§4.8) is the only one. Holes found while porting and since
closed: an ambiguous `struct-get` (above), a generalized top-level `def`,
an `extern` retyping a runtime entry (now `E_FFI_RESTRICTED`),
`ffi-pin` typed as its argument although it gives a Pin slot's address,
byte-operation offsets and values that were not required to be Int (a
String offset used its address), and `file-write` accepting an Int as
its data.

Two gaps remain that do not break §4.8: a misspelled type name becomes a
type parameter (above), and a type variable no signature mentions is
defaulted to Int.
