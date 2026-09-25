# Chapter 18: Algebraic Data Types and Exhaustive Matching

This chapter is the reference for ADTs: declaration, construction,
pattern matching, exhaustiveness and representation. The normative text
is `zyl_specification.txt` §8 (ADTs), §12.3 (match) and §6.5 (generic
ADTs). The implementation is `stdlib/compiler/expr_inner.zyl` (parsing,
including literal patterns), `stdlib/compiler/exhaustiveness_check.zyl`,
and `stdlib/compiler/icnf.zyl` and `codegen.zyl` (lowering).

## 18.1 ADT Declaration

```
deftype ::= "(" "deftype" Identifier Variant+ ")"
Variant ::= "(" Identifier TypeExpr* ")"      ; variant with fields
          | Identifier                         ; nullary variant, bare
```

§8.1 writes a declaration as `(deftype Name (Variant1 TypeExpr*) ...)`. A
nullary variant may be written `(Red)` or bare `Red`.

```lisp
;; Enum-like
(deftype Color (Red) (Green) (Blue))

;; Payloads
(deftype Shape (Circle Int) (Rect Int Int))

;; Generic, one parameter (the same shape as the prelude's Option)
(deftype Maybe (Just T) Nothing)

;; Generic, two parameters
(deftype Either (Left L) (Right R))

;; Recursive and generic
(deftype Tree (Node T (Tree T) (Tree T)) (Leaf))
```

The prelude (`core/core`, injected into every program) already defines
`Option` (`Some`/`None`), `Result` (`Ok`/`Err`) and `List` (`Cons`/`Nil`),
so those names are taken: declaring another type called `Option` is
`E_DUPLICATE_DEFINITION`, as is a second top-level `defn` with the same
name as one in the prelude. The prelude's constructor names are taken
too: a program type with a variant called `Some`, `None`, `Ok`, `Err`,
`Cons` or `Nil` is `E_DUPLICATE_VARIANT`, because the standard library's
own unqualified uses of those names would resolve to it. Use the prelude
`List` instead of declaring a list type, or pick other names.

### Rules

1. **Variant names.**
   - A name used twice within one `deftype` is `E_DUPLICATE_VARIANT`.
   - A variant name may be reused by a different `deftype` (type names may
     not, and the prelude's constructor names may not; see above). For construction, the declaration that comes later
     in the program wins.
   - The exhaustiveness check skips any `match` whose arms use a name
     claimed by two types, rather than guess which type is meant.
2. **Type parameters** are the uppercase names that appear as field types
   (§6.5). A name that repeats is one parameter.
3. **Recursive references** are allowed. Every field is one word, so a
   recursive field is simply a pointer.
4. **Field types are checked.** A constructor argument whose type
   clashes with the declared field type is `E_TYPE_MISMATCH`:
   `(Circle "x")` is rejected. Every use of one type parameter within a
   value must have the same type (Chapter 15, §15.6).
5. **Bounds.** §2's grammar shows an optional bound after the variants,
   but neither the specification nor the compiler defines one. Write
   bounds in Chapter 19's terms, not on the `deftype`.

## 18.2 Variant Construction

```
Construction ::= "(" VariantName Arg* ")"
               | VariantName            ; nullary only
```

```lisp
(Some 42)
None                ; or (None)
(Ok "success")
(Err "failed")
(Cons 1 (Cons 2 Nil))
(Red)
(Rect 3 4)
```

- Arguments are evaluated left to right, then the variant is allocated
  (Chapter 16 says where).
- Types are inferred from the arguments. An argument that clashes with
  its declared field type is `E_TYPE_MISMATCH` (rule 4 above).
- A `defstruct` is a one-variant ADT named after the struct, so
  `(make-Point 1 2)` and `(Point 1 2)` build the same value.

## 18.3 Constructor Patterns

§8.3:

```
MatchExpr ::= "(" "match" Expression Arm+ ")"
Arm       ::= "(" VariantName FieldPat* Body ")"       ; flat
            | "(" "(" VariantName FieldPat* ")" Body ")" ; grouped
            | "(" "_" Body ")"                          ; catch-all
FieldPat  ::= Identifier | "_"
```

Both arm shapes mean the same thing: `(Some x body)` and
`((Some x) body)` are equivalent.

| Arm | Matches | Binds |
|-----|---------|-------|
| `(Some x ...)` | the `Some` variant | `x` to its field |
| `(None ...)` | the `None` variant | nothing |
| `(Cons h t ...)` | `Cons` | `h` and `t` |
| `(Cons _ t ...)` | `Cons` | only `t`; `_` discards |
| `(_ ...)` | anything | nothing |

- **Field positions** hold a name or `_`, one per field. `_` may repeat
  within an arm.
- **Match as expression.** All arms produce the value of the `match`.
  Arms are tried in source order (§12.3).
- **Catch-all arms.** `_` is the catch-all. The compiler treats *any*
  identifier that is not a known constructor as a catch-all, and such an
  arm binds nothing. A misspelled constructor in the last arm is
  therefore a silent catch-all. A misspelled one earlier is caught,
  because a catch-all followed by more arms is `E_UNREACHABLE_MATCH_ARM`.

```lisp
(defn to-result (opt)
  (match opt
    (Some x (Ok x))
    (None (Err "empty"))))

(defn len (xs)
  (match xs
    (Cons _ t (+ 1 (len t)))
    (Nil 0)))

(defn main ()
  (begin
    (print (len (Cons 1 (Cons 2 (Cons 3 Nil)))))   ; 3
    (print (match (to-result (Some 7))
             (Ok v v)
             (Err _ 0)))                          ; 7
    0))
```

### Nested patterns are not supported

§8.3 leaves the pattern grammar open, and the book's earlier editions
showed nested constructor patterns such as `(Cons (Cons x _) rest ...)`.
The compiler does not implement them, and rejects one with
`E_NESTED_PATTERN`:

```lisp
(deftype L (N) (C Int L))

(defn f (xs)
  (match xs
    (C a (C b _) (+ a b))     ; E_NESTED_PATTERN
    (_ 77)))
```

Bind the field to a name and match it in the arm body:
`(C a rest (match rest (C b _ (+ a b)) (N 77)))`.

## 18.4 Literal Patterns, OR-Patterns, Ranges and Guards

These are an implementation extension; §8.3 covers constructor patterns
only. A `match` becomes a literal match when any arm starts with a
literal or a range.

```
LitArm  ::= "(" Alt+ Guard? Body ")"
          | "(" "_" Body ")"                 ; required last arm
Alt     ::= Integer | Float | String | Boolean
          | "(" "range" Lo Hi ")"            ; inclusive at both ends
Guard   ::= "(" "when" Expression ")"
```

- **Literals**: integer, float, string (compared by content) and boolean.
- **OR-patterns**: several alternatives before the body. `(1 2 3 "small")`
  matches any of them.
- **Ranges**: `(range lo hi)` matches `lo <= x <= hi`.
- **Guards**: `(when cond)` as the last element before the body, where
  `cond` is a `Bool`. The arm matches only when the pattern matches and
  `cond` is true; otherwise
  matching continues with the next arm. Literal patterns bind nothing, so
  a guard can only refer to names already in scope.
- **Exhaustiveness**: a literal match must end with a `_` arm. Otherwise
  it is `E_MATCH_NONEXHAUSTIVE`, which is raised when the match is parsed.

```lisp
(defn classify (n verbose)
  (match n
    (0 (when verbose) "zero (verbose)")
    (0 "zero")
    (1 2 3 "small")
    ((range 4 9) "medium")
    (_ "large")))

(defn command (s)
  (match s
    ("start" 1)
    ("stop" 2)
    (_ 0)))

(defn main ()
  (begin
    (print (classify 0 true))    ; zero (verbose)
    (print (classify 0 false))   ; zero
    (print (classify 2 false))   ; small
    (print (classify 7 false))   ; medium
    (print (classify 99 false))  ; large
    (print (command "stop"))     ; 2
    0))
```

Limits:

- **No mixing.** One `match` cannot combine literal arms and constructor
  arms. The two lower through different mechanisms: a literal match
  becomes an `if` chain, while a constructor match tests tags.
- **Guards on `_`.** A guard on the trailing `_` arm is ignored.
- **Guards on constructor arms** are not supported. The `(when ...)` is
  read as a field pattern and rejected as `E_NESTED_PATTERN`.
- **Guards after ranges.** A guard following a `range` alternative
  currently fails to compile (the guard is mistaken for a call to the
  prelude's two-argument `when`, giving `E_ARITY_MISMATCH`). Guards after
  plain literals work.

## 18.5 Exhaustiveness

§8.3 and §26 require every `match` to be exhaustive, with missing cases a
compile-time error. It matters for safety, not only style: a constructor
match that no arm catches evaluates to 0.

For constructor matches, `exhaustiveness_check.zyl` enforces:

| Situation | Code |
|-----------|------|
| a variant of the scrutinee's type has no arm, and there is no catch-all | `E_NON_EXHAUSTIVE_MATCH` |
| a catch-all arm is followed by more arms, or an arm repeats a constructor | `E_UNREACHABLE_MATCH_ARM` |

```
error[E_NON_EXHAUSTIVE_MATCH]: match over `Color` does not cover variant `Blue`
  --> colors.zyl:2:13
   |
 2 | (defn f (c) (match c (Red 1) (Green 2)))
   |             ^
   = help: add an arm for that variant, or a `_` catch-all
```

- **Spelling.** The specification spells the code `E_MATCH_NONEXHAUSTIVE`
  (§8.3, §28). The constructor check prints `E_NON_EXHAUSTIVE_MATCH`,
  while the literal-pattern check (18.4) prints `E_MATCH_NONEXHAUSTIVE`.
- **How the type is found.** The check determines the scrutinee's type
  from the constructors named in the arms, not from type inference. A
  match whose arms name a constructor claimed by two types is skipped
  (18.1, rule 1).
- **Repeated arms.** An arm that repeats a constructor already matched
  is `E_UNREACHABLE_MATCH_ARM`: in
  `(match c (Red 1) (Red 2) (Green 3) (Blue 4))` the second `Red` arm can
  never run.

## 18.6 Generic ADTs

Type parameters are collected from uppercase field names (§6.5):

```lisp
(deftype Outcome (Success T) (Failure E))   ; two parameters, T and E
(deftype Pair (Make T T))                   ; one parameter, T
(deftype Triple (Make3 T U V))              ; three parameters
```

- **Separate instantiations.** One generic ADT can be used at several
  concrete types in the same program, and the instances do not interfere
  (`tests/regression/generics-multi-type.zyl`).
- **Same-type constraint.** §6.2 requires every use of one parameter to
  have the same type, so `(Make 1 "x")` is `E_TYPE_MISMATCH`.

Chapter 19 covers monomorphization and naming.

```lisp
(deftype Opt (Sm T) (Nn))

(defn opt-or (o d)
  (match o
    (Sm x x)
    (Nn d)))

(defn main ()
  (begin
    (print (opt-or (Sm 4) 0))               ; 4
    (print (opt-or (Sm "hi") "none"))       ; hi
    (print (opt-or (Nn) "default"))         ; default
    0))
```

A generic function's result has the type of its instantiation, so a
plain `print` formats each one correctly (Chapter 15).

## 18.7 ADTs and Capabilities

§7.4 and §15 require an actor message to be Send-capable. The spec-level
rule for an ADT is that it is Send when all of its fields are.

There is no type predicate that decides this. What is enforced is the
syntactic rule from Chapter 17: a `send` whose
message mentions a `let-mut` variable, or a `Secret`, is rejected.

```lisp
(defn main ()
  (let a (spawn (fn () 0))
    (begin
      (send a (Some "hello"))      ; accepted
      0)))
```

## 18.8 Equality, Ordering and Derivation

§5.6 lets `Eq`, `Ord`, `Debug`, `Show`, `Clone` and `Hash` be derived:

```lisp
(derive Shape Show)
(print (Rect 2 3))        ; Rect(2, 3)
```

All six are generated (Chapter 20, §20.6); any other trait, or a field
whose type lacks the trait, is `E_TRAIT_NOT_DERIVABLE`. `Show` prints
each variant as its name and its fields' `Show` text, `Circle(1.500000)`,
and a struct as `Point { x: 1, y: 2 }`; `Debug` is the same with strings
quoted: `P(1, a)` shows as `P(1, "a")`. Without a `Show` impl, `print` of an ADT value
prints its address. Equality exists with or without a derive, and
ordering needs one:

- `==` and `!=` on two ADT values compare by content: different
  variants are unequal, and otherwise each field pair is compared with
  `==`, so nested ADT values, strings and floats compare by value and
  recursive types such as lists compare element by element. The
  type-annotation pass generates this per type as a function `T.==`; a
  generic ADT such as `(List T)` gets one instance per element type.
  A type with a `Secret` field gets no such function and falls back to
  the runtime's shallow comparison (tag, then each field word, pointers
  by address).
- `<`, `>`, `<=` and `>=` do not take ADT values: `(< (P 1 5) (P 2 0))`
  is `E_TYPE_MISMATCH` ("ordering on P"). Derive `Ord` and use
  `Ord.compare`, which orders variants in declaration order and then the
  fields lexicographically, comparing strings and nested values by
  content (Chapter 20, §20.6).

## 18.9 Representation

A variant value is a pointer to a block of words:

```
            hidden        tag      field 0   field 1
          ┌──────────┬─────────┬─────────┬─────────┐
          │ size (n) │ variant │  word   │  word   │   ...
          └──────────┴─────────┴─────────┴─────────┘
                       ^ the value points here
```

- Every slot is 8 bytes. The tag is a whole word, and each field is one
  word: an integer, a float's bits, a boolean, or a pointer.
- **Blocks are sized per variant.** Each variant gets a block exactly as
  large as its own fields; blocks are not padded to the largest variant.
  A nullary variant is still a block, holding just the tag. Where a
  block lives (the frame, a region or the heap) is region inference's
  choice (Chapter 16).
- **The hidden size word** sits before the tag and records the block's
  size in words. The runtime's shallow `==` fallback reads it (Chapter
  15), and in-place reuse checks it before writing a new record into an
  old block (Chapter 16). A variant placed directly in the stack frame
  (16.3) has no size word; nothing that reads one ever sees it.
- **Tags** are 0-based in declaration order, per `deftype`:

  ```lisp
  (deftype Color (Red) (Green) (Blue))
  ;; Red = 0, Green = 1, Blue = 2
  ```

  Struct tags are allocated from a separate range (100000 upward) and are
  unique across the program.
- **Recursive fields** are ordinary pointer words. No box type is
  involved.

## 18.10 Match Compilation

The implementation is simpler than a decision-tree compiler.

- **Constructor matches** evaluate the scrutinee once, then test its tag
  against each arm in source order. The first arm whose tag matches binds
  its fields and runs its body. A catch-all arm matches without a test.
  If nothing matches, the result is 0, which is why exhaustiveness is
  enforced (18.5).
- **Literal matches** bind the scrutinee to a hidden variable and lower to
  a nested `if` chain. Each arm's test is its alternatives joined by
  "or", then combined with its guard by "and".

There is no jump table and no merging of arms.

## 18.11 Errors

| Code | Cause | Status |
|------|-------|--------|
| `E_NON_EXHAUSTIVE_MATCH` | constructor match misses a variant | raised (spec spelling `E_MATCH_NONEXHAUSTIVE`) |
| `E_MATCH_NONEXHAUSTIVE` | literal match without a trailing `_` arm | raised |
| `E_UNREACHABLE_MATCH_ARM` | arm after a catch-all | raised |
| `E_DUPLICATE_VARIANT` | variant name repeated within one `deftype`, or a prelude constructor name (`Some`, `None`, `Ok`, `Err`, `Cons`, `Nil`) reused | raised |
| `E_NESTED_PATTERN` | a constructor pattern inside a field position (18.3) | raised |
| `E_MATCH_ARM_COMPLEX` | an arm body that combines a constant with several calls, a shape the code generator is known to miscompile | raised |
| `E_TYPE_MISMATCH` | constructor argument clashes with the declared field type, or arms of one match that produce different types | raised by `type_annotate` |

## 18.12 Comparison with Other Languages

| Feature | Rust `enum` | Haskell `data` | Zyl `deftype` |
|---------|-------------|----------------|---------------|
| Syntax | `enum X { A, B(u32) }` | `data X = A \| B Int` | `(deftype X (A) (B Int))` |
| Exhaustiveness | checked | warning | compile-time error |
| Wildcard | `_` | `_` | `_` |
| Literal / OR / range patterns | yes | yes | yes, not mixed with constructor arms |
| Guards | `if` | `\|` | `(when ...)` on literal arms only |
| Nested patterns | yes | yes | no |
| GADTs | no | yes (extension) | no |
| Deriving | `#[derive(...)]` | `deriving` | `(derive T Show Eq Ord)`: `Show`, `Debug`, `Eq`, `Ord`, `Hash`, `Clone` |
