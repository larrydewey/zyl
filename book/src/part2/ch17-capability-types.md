# Chapter 17: Capability Types and Aliasing

This chapter is the reference for Zyl's capability rules and the
aliasing invariant they protect. The normative text is
`zyl_specification.txt` §4.3 (capability types), §7.2 and §7.4 (closure
capture), §10 (mutability and aliasing), §15 (actors) and §16 (FFI).
The implementation is
`stdlib/compiler/mutability_check.zyl` (`set!`, closure capture and actor
transfer), `stdlib/compiler/linearity.zyl` (moves, and the mutable-location
rule) and `stdlib/compiler/secret_check.zyl` (the `Secret` capability);
FFI argument types come from `extern` declarations, checked by the type
pass (`type_annotate.zyl`).

Capabilities are never written in source, except `Secret`. Zyl has no
in-place mutation, so every `let` binding is immutable and rebinding is
the only update; what a binding may be used for is decided by its
binding form. The type checker (Chapter 15) sees a `let-mut` variable or a
pinned value as the plain type of its value: `TaTy` is `TaV | TaC | TaF`,
with no capability dimension. The compiler enforces the parts of the
invariant that can be decided from the syntax, in passes of their own,
and this chapter says which parts those are.

## 17.1 The Aliasing Invariant

§10 states it as an aliasing invariant — one exclusive-mutable reference
to a memory location, or any number of shared-immutable ones — with
`E_MUT_CONFLICT` as the violation. Zyl keeps the guarantee and drops the
aliasing, because Zyl has no in-place mutation: a struct field can never
change, and a "mutated" struct is a new value bound to the same name.
There is therefore no in-place write for a reader to observe, which is a
stronger property than exclusivity and needs no type to state.

What is enforced is the binding form:

> Zyl has no in-place mutation: every `let` binding is immutable, `set!`
> on a `let-mut` binding rebinds it, and `set!` on anything else is
> `E_MUT_CONFLICT`.

The implementation decides this from bindings, not from memory
locations. A `let` binding is immutable; a `let-mut` binding is the only
assignable one; and `set!` is the only way to change anything. The check
is `mutability_check.zyl`, a pass over the program before lowering that
tracks which names are in-scope `let-mut` bindings:

- `set!` on a name that is not an in-scope `let-mut` binding is
  `E_MUT_CONFLICT`.
- `set!` on a `let-mut` of an *enclosing* scope, from inside a closure, is
  `E_MUT_CONFLICT`: the closure captured it by value.
- `set!` on anything other than a plain name, such as a struct field, is
  rejected by the parser with `E_MUT_CONFLICT`.
- A byte buffer is a mutable location, and there the rule is checked on
  the location itself, by `linearity.zyl`: a name becomes the buffer's
  writer by writing through it (`store-u8`, the other stores, the
  atomics, `bytebuf-append`), and a second name writing to the same
  buffer is `E_MUT_CONFLICT`. Any number of names may read it. A
  `byteslice` belongs to its base buffer's location, and alias classes
  are kept per allocation, not per name.

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
`TCap` and `TMut` are retired as type names: what they stood for is the
binding form, and a `Secret` (17.8) is still a real capability.

| Spec | Meaning (spec) | What the compiler does |
|------|----------------|------------------------|
| `TCap<T>` | shared, immutable | a `let` binding — immutable, any number of readers |
| `TMut<T>` | exclusive, mutable | a `let-mut` binding — the only assignable binding; `set!` rebinds it (17.1) |
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

The specification's model, with the first two columns named for what
they now mean:

| Operation | `let` binding | `let-mut` binding | TAtomic | TBox | TPin |
|-----------|---------------|-------------------|---------|------|------|
| Read | yes | yes | yes | yes | yes |
| `set!` rebind | no | yes | no | no | no |
| Atomic ops | no | no | yes | no | no |
| Send to actor (§7.4) | yes | no | yes | no | no |
| Pass to FFI (§16) | FFI_Pinnable only | no | no | no | via `ffi-pin` |

What is enforced: the `set!` row (17.1), the send row for `let-mut`
variables (17.6), and the FFI row's FFI_Pinnable check (17.7).

## 17.4 Coercion Rules

The canonical specification states no coercion rules. `spec/06` derives
two from the invariant: a mutable binding may be read through an
immutable one, and an immutable binding may never be made mutable.

The implementation has no capability types to coerce between, so neither
rule has a dedicated check. In practice, reading a `let-mut` variable is
always allowed, and nothing can turn a `let` binding into a mutable one.

There is no syntax for annotating a parameter with a capability. To write
a function that takes a value read-only, leave the parameter as it is:
a parameter is immutable, and `set!` on a parameter is `E_MUT_CONFLICT`.

## 17.5 Struct Fields

Struct fields are immutable (§10). Mutability belongs to the binding,
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

§7.2 models a read-only capture as shared, a mutated capture as
exclusive, and promotes an escaping capture to the heap. The compiler's
mechanism is simpler: capture is by value.

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

A spawned closure may capture only Send-capable values, and a value sent
on a channel must be Send-capable. The compiler checks one concrete
shape: if the closure passed to `spawn`, or the value passed to
`chan-send`, refers to any `let-mut` variable in scope, it is
`E_CAPABILITY_LEAK`.

```lisp
(capabilities actor)

(use actor/actor)

(defn main ()
  (let c (chan 4)
    (let tx (chan-tx c)
      (let-mut x 10
        (begin
          (chan-send tx 42)      ; ok
          (chan-send tx x)       ; E_CAPABILITY_LEAK: x is let-mut
          0)))))
```

There is no type-level Send predicate. A `Secret` reaching `spawn` or
`chan-send` is rejected separately (17.8).

Channel endpoints are a separate kind of exclusivity, checked at run
time: each `Tx` and `Rx` has one owning actor, and a use by any other
actor is `E_CHANNEL_NOT_OWNER` (Chapter 21, §21.3).

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
| part of a `spawn`, a `chan-send` or a `file-write` | `E_SECRET_ESCAPE` |
| a raw `ffi-call` argument (not through `ffi-pin`) | `E_FFI_PIN_REQUIRED` |
| a `Secret` parameter consumed into a public result without a call to `zeroize` | `E_ZEROIZE_MISSING` (a warning; every `Secret` parameter counts, a `(Secret Int)` scalar included, but not one in a secret-returning function) |

```lisp
(defn leak ((k Secret))
  (if (= k 0) 1 2))            ; E_CT_VIOLATION: branch on a secret
```

`declassify`, from `math/secret/secret`, is the one named way out. So are
the two library functions `ct-eq-bool` and `ct-eq-words-bool`, which
reduce a comparison to its public verdict. `ct-eq` itself returns an
`Int` (1 or 0), not a `Bool`, so a condition compares it with `=`:

```lisp
(capabilities secret)

(use math/secret/secret)

(defn check ((k (Secret Int)))
  (if (= (declassify (ct-eq k 5)) 1) 1 0))

(defn main ()
  (begin
    (print (check 5))          ; 1
    0))
```

`check` also earns the `E_ZEROIZE_MISSING` warning: it takes a `Secret`
parameter, returns a public value and never calls `zeroize` — and a
scalar counts like any other Secret.

Erasure is otherwise the program's job, with one automatic exception.
`zeroize` (and the `Secret` trait's `wipe`) is the explicit answer for a
value the program owns. What the compiler does itself is the **frame
wipe**: a function that takes a secret parameter or binds a
secret-derived value has its whole frame zeroed on return —
`rep stosq` over the frame, with the result parked in a register across
it — and makes no tail calls, so no copy of a secret word outlives the
call in its own frame. That is not the same thing as wiping a *released
region block*, which is **not** done: such a block goes back to the
allocator with its contents, which is why the warning above exists.
`docs/secret-erasure-design.md` has the rest of the picture.

The rules across calls:

- **Secret-returning functions.** A function whose body is tainted under
  its own `Secret` parameters is secret-returning. Its result is tainted
  at every call site, even when the arguments are public literals.
- **Unannotated helpers.** A secret passed to a function whose parameter
  is not annotated `Secret` is `E_SECRET_UNANNOTATED`, so a helper cannot
  launder a secret: annotate the parameter or `declassify` first. A call
  through a function value or a trait method is not checked across.

To the type checker, `(Secret Int)` is an `Int`: the annotation gives the
parameter its inner type, so a key passes through generic helpers. The
taint is tracked by name in `secret_check.zyl`, not by the unifier.

Two different capabilities share the name here:

- A `Secret` **annotation** works in any program.
- **Calling into** `stdlib/math/secret` requires the `secret`
  capability (§31.9, Chapter 25): `(capabilities secret)` at the top of
  a lone file, as in the example above, or the same line in a package's
  `zyl.pkg`.

## 17.9 Capability Inference

What the specification infers, and how each rule is met today:

1. **Read-only use** is the default: every `let` binding is immutable,
   and with no in-place mutation nothing can change it under a reader.
2. **`set!`** is allowed only on a `let-mut` binding. Met by name (17.1).
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
| `E_MUT_CONFLICT` | `set!` on a binding that is not `let-mut`, or on a struct field (`mutability_check.zyl`); a byte buffer written through two names (`linearity.zyl`) |
| `E_MOVE_VALUE` | a resource (file descriptor, `StringBuffer`, a type with a `Drop` impl) used after its release (`linearity.zyl`; Chapter 5, §5.3) |
| `E_CAPABILITY_LEAK` | a `let-mut` variable referenced by a `spawn` closure or a `chan-send` value |
| `E_INVALID_CAPABILITY` | a `fn` written directly as an `ffi-call` argument |
| `E_CT_VIOLATION`, `E_SECRET_DEBUG`, `E_SECRET_ESCAPE`, `E_FFI_PIN_REQUIRED` | Secret misuse (17.8) |
| `E_ZEROIZE_MISSING` | warning: a Secret consumed without `zeroize` |
| `E_REGION_ESCAPE` | a Stack bytebuf, or a value allocated inside `with-region`, that outlives its region (Chapter 16) |

`E_MUT_CONFLICT` and `E_CAPABILITY_LEAK` use the located
`error[CODE] --> file:line:col` form, with a second label at the `let`
or `let-mut` binding involved (Appendix A, §A.1). Their messages name the
specification's `TCap`/`TMut` types; the rule they enforce is the binding
form. The Secret errors are located too, without a second label, and so
are `E_INVALID_CAPABILITY`, the `E_MUT_CONFLICT` for a `set!` on a field,
and the `E_ZEROIZE_MISSING` warning.

## 17.11 Comparison with Rust

| Rust | Zyl (specification) | Zyl (today) |
|------|---------------------|-------------|
| `&T` | `TCap<T>`, inferred | every `let` binding, by default |
| `&mut T` | `TMut<T>`, inferred | a `let-mut` binding + `set!`, checked by name |
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
