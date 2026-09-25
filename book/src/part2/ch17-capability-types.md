# Chapter 17: Capability Types and Aliasing

This chapter is the reference for Zyl's capability types (`TCap`, `TMut`,
`TAtomic`, `TBox`, `TPin` and `Secret`) and the aliasing invariant they
protect. The normative text is `zyl_specification.txt` §4.3 (capability
types), §7.2 and §7.4 (closure capture), §10 (mutability and aliasing),
§15 (actors) and §16 (FFI). The implementation is
`stdlib/compiler/mutability_check.zyl` (aliasing and actor transfer) and
`stdlib/compiler/secret_check.zyl` (the Secret capability); FFI argument
types come from `extern` declarations, checked by the type pass
(`type_annotate.zyl`).

Capabilities are never written in source, except `Secret`. The
specification infers them (§0 P7). The compiler has no capability types:
the type checker (Chapter 15) sees a `let-mut` variable or a pinned
value as the plain type of its value. It enforces the parts of the
invariant that can be decided from the syntax, in passes of their own,
and this chapter says which parts those are.

## 17.1 The Aliasing Invariant

§10:

> For any memory location: either exactly one TMut reference OR any
> number of TCap references.

A violation is the compile-time error `E_MUT_CONFLICT`.

The implementation decides this from bindings, not from memory
locations. A `let` binding is `TCap`; a `let-mut` binding is `TMut`; and
`set!` is the only way to mutate. The check is `mutability_check.zyl`, a
pass over the program before lowering that tracks which names are
in-scope `let-mut` bindings:

- `set!` on a name that is not an in-scope `let-mut` binding is
  `E_MUT_CONFLICT`.
- `set!` on anything other than a plain name, such as a struct field, is
  rejected by the parser with `E_MUT_CONFLICT`.

```lisp
(defn main ()
  (let x 1
    (begin
      (set! x 2)      ; E_MUT_CONFLICT: `x` is not a let-mut binding
      0)))
```

Every value is one word and `let` copies that word, so binding a second
name to a `let-mut` value creates an independent copy, not an alias:

```lisp
(defn main ()
  (let-mut x 1
    (let y x
      (begin
        (set! x 2)
        (print y)     ; 1
        (print x)     ; 2
        0))))
```

## 17.2 Capability Kinds

§4.3 defines five capability types. None of them exists as a type in the
compiler; each is met, where it is met at all, by a rule on the syntax.

| Spec | Meaning (spec) | What the compiler does |
|------|----------------|------------------------|
| `TCap<T>` | shared, immutable | the default for every binding |
| `TMut<T>` | exclusive, mutable | `let-mut`, checked by name (17.1) |
| `TAtomic<T>` | atomic shared mutation | not produced by any source construct |
| `TBox<T>` | heap-managed allocation | not produced by any source construct |
| `TPin<T>` | FFI-pinned, non-moving | `ffi-pin` copies the value into the pin arena; the result has type `(Pin a)` |
| `Secret` (17.8) | key material | a `Secret` annotation, tracked by `secret_check.zyl` |

Notes on the kinds that have no source form:

- **Atomics** are operations, not a type. `atomic/atomic` provides
  `atomic-load`, `atomic-store`, `atomic-add`, `atomic-cas` and friends
  on raw addresses, and the byte primitives provide `bytebuf-atomic-load`
  and friends on a `ByteBuf`. Neither produces a `TAtomic` value, and
  there is no `atomic-new`.
- **`TBox`** has no source form. Recursive ADT fields are already
  pointers to separately allocated blocks (Chapter 18), so nothing needs
  one.

## 17.3 Capability Operations

The specification's model:

| Operation | TCap | TMut | TAtomic | TBox | TPin |
|-----------|------|------|---------|------|------|
| Read | yes | yes | yes | yes | yes |
| `set!` rebind | no | yes | no | no | no |
| Atomic ops | no | no | yes | no | no |
| Send to actor (§7.4) | yes | no | yes | no | no |
| Pass to FFI (§16) | FFI_Pinnable only | no | no | no | via `ffi-pin` |

What is enforced: the `set!` row (17.1), the send row for `let-mut`
variables (17.6), and the FFI row's FFI_Pinnable check (17.7).

## 17.4 Coercion Rules

The canonical specification states no coercion rules. `spec/06` derives
two from the invariant: a `TMut` may be downgraded to `TCap`, and a `TCap`
may never be upgraded to `TMut`.

The implementation has no capability types to coerce between, so neither
rule has a dedicated check. In practice, reading a `let-mut` variable is
always allowed, and nothing can turn a `let` binding into a mutable one.

There is no syntax for annotating a parameter with a capability. To write
a function that takes a value read-only, leave the parameter as it is:
parameters are `TCap`, and `set!` on a parameter is `E_MUT_CONFLICT`.

## 17.5 Struct Fields

Struct fields are immutable (§10). The capability applies to the binding,
so the only way to change a struct is to rebind the whole value:

```lisp
(defstruct Point (x) (y))

(defn main ()
  (let-mut p (make-Point 1 2)
    (begin
      (set! p (make-Point 3 4))        ; rebinding the whole struct: allowed
      (print (struct-get p "x"))       ; 3
      0)))
```

```lisp
(set! (struct-get p "x") 5)            ; E_MUT_CONFLICT: field mutation is forbidden
```

Whole-value rebinding keeps the model simple. There is no per-field
capability tracking, and no partial mutability to reason about.

## 17.6 Closure Capture

§7.2: a read-only capture is `TCap`, a mutated capture is `TMut`, and an
escaping capture is promoted to the heap.

In the implementation a closure copies the values it captures into an
environment block when it is created; region inference places the block
like any other value (Chapter 16), so an escaping closure's environment
lives in its caller's region or the heap. It sees the value a variable had at that
moment:

```lisp
(defn make-adder (n)
  (fn (x) (+ x n)))            ; n captured read-only

(defn main ()
  (let-mut n 5
    (let add (make-adder n)
      (begin
        (set! n 100)
        (print (add 1))        ; 6: the closure holds its own copy of n
        0))))
```

Because the closure holds a copy, a `set!` inside it could not change
the variable outside. It is rejected:

```lisp
(defn main ()
  (let-mut n 0
    (let bump (fn () (set! n (+ n 1)))   ; E_MUT_CONFLICT: `n` is captured by value
      (begin
        (bump)
        (print n)
        0))))
```

Keep mutable state in the function that owns it, and return new values
from closures instead.

## 17.7 Actors and FFI

### Actor transfer (§7.4, §9.1 R3, §15)

A spawned closure may capture only Send-capable values, and a message
must be Send-capable. The compiler checks one concrete shape: if the
closure passed to `spawn`, or the message passed to `send`, refers to any
`let-mut` variable in scope, it is `E_CAPABILITY_LEAK`.

```lisp
(defn main ()
  (let a (spawn (fn () 0))
    (let-mut x 10
      (begin
        (send a 42)          ; ok
        (send a (Some 1))    ; ok
        (send a x)           ; E_CAPABILITY_LEAK: x is let-mut
        0))))
```

There is no type-level Send predicate. A `Secret` reaching `spawn` or
`send` is rejected separately (17.8).

### FFI (§16, §9.1 R4)

FFI_Pinnable types are `Int`, `Float`, `Bool`, `String`, `Vec<T>` of a
pinnable `T`, and types composed only of pinnable types (§16).

The compiler meets this through `extern` declarations. A foreign
function's C signature must be declared before any `ffi-call` to it, and
the declaration's types must be concrete and fit a machine word, so an
argument's type is fixed by the declaration and a struct passed where
the C side takes an `Int` is `E_TYPE_MISMATCH`. The mutability pass also
rejects a `fn` written directly as an `ffi-call` argument with
`E_INVALID_CAPABILITY`; a named top-level function may be passed where
the declaration has an `(Fn (A ...) R)` parameter.

Two gaps in the implementation:

- R4's Pin-region requirement is not enforced for ordinary values. An
  `Int` or `String` may be passed straight to `ffi-call`.
- `ffi-pin` rejects only a function (`E_FFI_TYPE_NOT_PINNABLE`); any
  other value may be pinned, whatever its capability.

Chapter 22 covers FFI in full.

## 17.8 The Secret Capability

The canonical specification names `secret` only as a package capability
(§31.9), covering "the Secret capability type and `stdlib/math/secret`".
The type's behavior is defined by the implementation and documented in
`spec/06-capability-types.md` and `docs/math-crypto.md`. Chapter 33 is
the tutorial treatment.

A parameter annotated `(k Secret)` or `(k (Secret Int))` is key material.
`secret_check.zyl` propagates that taint through `let`, calls,
arithmetic, constructors and byte loads, and rejects the following:

| Tainted value used as | Code |
|-----------------------|------|
| the condition of `if`/`while`/`for`/`cond`, or a `match` subject | `E_CT_VIOLATION` |
| an index, or a byte-load/store offset | `E_CT_VIOLATION` |
| an operand of `/` or `mod` | `E_CT_VIOLATION` |
| an argument to `print` | `E_SECRET_DEBUG` |
| part of a `spawn`, a `send` or a `file-write` | `E_SECRET_ESCAPE` |
| a raw `ffi-call` argument (not through `ffi-pin`) | `E_FFI_PIN_REQUIRED` |
| consumed into a public result without a call to `zeroize` | `E_ZEROIZE_MISSING` (a warning) |

```lisp
(defn leak ((k Secret))
  (if (= k 0) 1 2))            ; E_CT_VIOLATION: branch on a secret
```

`declassify`, from `math/secret/secret`, is the one named way out. So are
the two library functions `ct-eq-bool` and `ct-eq-words-bool`, which
reduce a comparison to its public verdict. `ct-eq` itself returns an
`Int` (1 or 0), not a `Bool`, so a condition compares it with `=`:

```lisp
(use math/secret/secret)

(defn check ((k (Secret Int)))
  (if (= (declassify (ct-eq k 5)) 1) 1 0))

(defn main ()
  (begin
    (print (check 5))          ; 1, with an E_ZEROIZE_MISSING warning
    0))
```

The rules across calls:

- **Secret-returning functions.** A function whose body is tainted under
  its own `Secret` parameters is secret-returning. Its result is tainted
  at every call site, even when the arguments are public literals.
- **Unannotated helpers.** Taint enters a callee only through annotated
  parameters, so a helper without annotations launders a secret.

To the type checker, `(Secret Int)` is an `Int`: the annotation gives the
parameter its inner type, so a key passes through generic helpers. The
taint is tracked by name in `secret_check.zyl`, not by the unifier.

Two different capabilities share the name here:

- A `Secret` **annotation** works in any program.
- **Calling into** `stdlib/math/secret` from a package with a `zyl.pkg`
  requires that package to declare the `secret` package capability
  (§31.9, Chapter 25).

## 17.9 Capability Inference

What the specification infers, and how each rule is met today:

1. **Read-only use** gives `TCap`. This is the default for every binding.
2. **`set!`** requires `TMut`. Met by name, through `let-mut` (17.1).
3. **Atomic use** gives `TAtomic`. No atomic type exists (17.2).
4. **Escape and capture** promote to the heap. Captures are always
   copied into an environment block, which region inference places in
   the frame, the caller's result region or the heap, as far as the
   closure escapes (Chapter 16).
5. **Actor send** requires Send. Met syntactically for `let-mut`
   variables and `Secret`s (17.7, 17.8).
6. **FFI** requires FFI_Pinnable and Pin. Argument types are fixed by
   the `extern` declaration; the Pin region is required only for
   `Secret`s (17.7).

## 17.10 Capability Errors

| Code | Raised for |
|------|------------|
| `E_MUT_CONFLICT` | `set!` on a binding that is not `let-mut`, or on a struct field |
| `E_CAPABILITY_LEAK` | a `let-mut` variable referenced by a `spawn` closure or a `send` message |
| `E_INVALID_CAPABILITY` | a `fn` written directly as an `ffi-call` argument |
| `E_CT_VIOLATION`, `E_SECRET_DEBUG`, `E_SECRET_ESCAPE`, `E_FFI_PIN_REQUIRED` | Secret misuse (17.8) |
| `E_ZEROIZE_MISSING` | warning: a Secret consumed without `zeroize` |
| `E_REGION_ESCAPE` | a Stack bytebuf, or a value allocated inside `with-region`, that outlives its region (Chapter 16) |

`E_MUT_CONFLICT` and `E_CAPABILITY_LEAK` use the located
`error[CODE] --> file:line:col` form, with a second label at the `let`
or `let-mut` binding involved (Appendix A, §A.1). The Secret errors are
located too, without a second label. `E_INVALID_CAPABILITY`, the
`E_MUT_CONFLICT` for a `set!` on a field, and the `E_ZEROIZE_MISSING`
warning still print as bare lines naming the code.

## 17.11 Comparison with Rust

| Rust | Zyl (specification) | Zyl (today) |
|------|---------------------|-------------|
| `&T` | `TCap<T>`, inferred | every binding by default |
| `&mut T` | `TMut<T>`, inferred | `let-mut` + `set!`, checked by name |
| `Box<T>` | `TBox<T>` | no source form; ADT fields are pointers to their blocks |
| `Pin<&mut T>` | `TPin<T>` via `ffi-pin` | `ffi-pin` copies into the pin arena |
| `Arc<Mutex<T>>` | `TAtomic<T>` | atomic operations on addresses and byte buffers |
| borrow checker | region + capability inference | syntactic checks (17.1, 17.7) |
| lifetime parameters | region variables, inferred | none written; region inference gives each value its call's region, its caller's result region or the heap, and heap values live until exit |

The key difference in design is the same in both columns: Zyl code
carries no capability or lifetime annotations. The difference in
practice is that today's checks are syntactic and deliberately
conservative: where a check cannot decide, it is designed to let the
program through rather than reject valid code, so some violations go
unreported.
