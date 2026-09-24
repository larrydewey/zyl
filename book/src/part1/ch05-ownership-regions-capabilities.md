# Chapter 5: Ownership, Regions, and Capability Types

This chapter explains Zyl's memory model: where values live (regions)
and who may change them (capabilities). The specification describes a
complete static system for both. The current compiler implements a
small, safe part of it, so this chapter shows the rules you write code
against and, alongside them, what the compiler actually checks today.
Chapters 16 and 17 are the full reference.

## 5.1 The Problem Zyl Solves

Every systems language must answer: **who owns this memory, and when is it freed?**

| Language | Approach |
|----------|----------|
| C/C++ | Manual `malloc`/`free` — programmer responsible, errors common |
| Rust | Ownership + borrow checker — compile-time, with lifetime annotations |
| Go/Java/Python | Garbage collector — runtime overhead, non-deterministic pauses |
| Zyl | **Region inference + capability types** — compile-time, inferred, deterministic |

Zyl's design goal is that the compiler proves where every value lives
and who can modify it, without annotations in your source. You never
write a region or a capability; the compiler infers them.

## 5.2 Regions — Where Values Live

The specification assigns every value to one of five **regions**:

| Region | Purpose (spec) | Today |
|--------|----------------|-------|
| **Stack** | Values that do not escape | Parameters and `let` locals live in the function's frame, and so does one kind of ADT value (§5.5) |
| **Heap** | Escaped values, captured closure variables | Every other struct, ADT value and capturing closure, from one bump-allocated arena that lives until the program exits |
| **Global** | Top-level immutable constants | A top-level `def`: immutable, evaluated once, in source order, before `main` or the tests run |
| **Circular** | Cyclic structures | Not implemented |
| **Pin** | Non-moving memory for FFI | `ffi-pin` copies a value into a separate pin arena (§5.8) |

### Region Rules (Spec §9.1)

```
R1. Local stack allocation: If variable does not escape → Stack.
R2. Escape allocation: If returned, captured by escaping closure, or sent to actor → Heap.
R3. Actor transfer: spawn/send requires Send-capable type (TCap/TAtomic).
R4. FFI rule: ffi-call requires Pin region AND FFI_Pinnable type.
R5. Closure capture promotion: Escaping closure captures promoted to Heap.
R6. Cyclic structures: Cyclic references detected among heap values → Circular region.
R7. Global Region: Immutable constants only. Eager initialization. No mutation allowed.
R8. Pin Region: Non-moving arena. Values physically copied here for FFI. Never compacted.
```

The compiler meets R1, R2 and R5 conservatively: anything it cannot
prove stays local goes to the heap, which is always safe. R3 and R4 are
checked in the specific forms described in §5.7 and §5.8. R6 and R7 are
not implemented.

## 5.3 Capability Types — Who Can Access

Regions say *where*; capabilities say *how*. The two fundamental
capabilities are:

| Capability | Notation | Meaning | Aliasing |
|------------|----------|---------|----------|
| **Shared immutable** | `TCap<T>` | Read-only | Any number of references |
| **Exclusive mutable** | `TMut<T>` | Read-write | Exactly one reference |

**The invariant (spec §10):**
> For any memory location: either exactly one `TMut` reference OR any number of `TCap` references. Never both.

A violation is the compile-time error `E_MUT_CONFLICT`.

The specification also defines `TAtomic<T>` (atomic shared mutation),
`TBox<T>` (heap ownership) and `TPin<T>` (FFI-pinned). No source
construct produces `TAtomic` or `TBox` today; `TPin` is the type of an
`ffi-pin` result.

### How Capabilities Are Decided

You never write a capability. The compiler decides it from the binding
form:

| You write | Capability | `set!` allowed? |
|-----------|------------|-----------------|
| `(let x 42 body)` | `TCap` | No |
| `(let-mut y 10 body)` | `TMut` | Yes |
| a function parameter | `TCap` | No |
| a `for` loop variable | `TMut` | Yes |

`set!` is the only way to mutate anything, and it is checked by name: a
`set!` whose target is not a `let-mut` (or `for`) variable in scope is
rejected.

```lisp
(defn main ()
  (let x 1
    (begin
      (set! x 2)      ; compile error
      0)))
```

```
PANIC: error[E_MUT_CONFLICT]: set! target `x` is not a let-mut binding in scope
  --> main.zyl:4:7
   |
 4 |       (set! x 2)      ; compile error
   |       ^
 2 |   (let x 1
   |   - bound here by `let`, which is immutable (TCap)
   = help: only a let-mut binding is TMut and may be assigned; declare it with `let-mut`
```

The same error appears for a `set!` on a parameter. A function never
changes its caller's variables; it returns a new value, and the caller
rebinds:

```lisp
(use collections/vec)

(defn add-two (v)
  (vec-push (vec-push v 1) 2))

(defn total (v)
  (let-mut sum 0
    (begin
      (for (i 0) (< i (vec-len v))
        (begin
          (set! sum (+ sum (vec-get v i)))
          (set! i (+ i 1))))
      sum)))

(defn main ()
  (let-mut v (vec-create 0 4)
    (begin
      (set! v (add-two v))
      (set! v (add-two v))
      (print (vec-len v))     ; 4
      (print (total v))       ; 6
      0)))
```

Every value is one machine word, and `let` copies that word. Binding a
second name to a `let-mut` variable therefore gives an independent
copy, not an alias:

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

The word for a struct, ADT value or collection is a pointer, so two
names can refer to the same block. That is safe for structs and ADT
values because their fields can never change (§5.4). The collections of
Chapter 4 do write into shared buffers, which is why you should treat
an old version of a Vec or Map as used up once you have derived a new
one from it.

## 5.4 Struct Mutability: Rebind, Don't Mutate

This is a **key difference from Rust and C++**:

```lisp
(defstruct Point (x) (y))

(defn main ()
  (let-mut p (make-Point 1 2)
    (begin
      (set! p (make-Point 3 4))        ; rebind the whole struct: allowed
      (print (struct-get p "x"))       ; 3
      0)))
```

```lisp
(set! (struct-get p "x") 5)            ; compile error
```

```
PANIC: E_MUT_CONFLICT: set! target must be a plain variable name bound via let-mut -- direct field/expression mutation is forbidden, rebind the whole variable instead
```

**Why?** A capability belongs to a binding, not to each field. Allowing
field mutation would need field-level capabilities and field-level
aliasing rules. Zyl chooses simplicity: **whole-value rebinding only**.

This means:
- `let-mut` + `set!` replaces the entire struct
- the old struct is simply no longer referenced by that name
- no partial mutation, and no field-level aliasing to reason about

## 5.5 Escape Analysis — When Stack Becomes Heap

In the specification, a value **escapes** if it is:
1. **returned** from its function,
2. **captured** by a closure that escapes,
3. **sent** to an actor, or
4. **passed to FFI** (which requires the Pin region instead).

The current compiler proves non-escape for exactly one shape: a
`(let x (Variant ...) body)` where every use of `x` in `body` is the
subject of a `match` or an argument to `print`. That construction is
placed in the function's stack frame. Every other struct or ADT value is
heap-allocated.

```lisp
(deftype Shape (Circle Int) (Square Int))

(defn area (s)
  (match s
    (Circle r (* 3 (* r r)))
    (Square n (* n n))))

;; Stack: `s` is only ever the subject of a match.
(defn local-area ()
  (let s (Square 4)
    (match s
      (Circle r r)
      (Square n (* n n)))))

;; Heap: `s` is passed to a function.
(defn passed-area ()
  (let s (Square 4)
    (area s)))

(defn main ()
  (begin
    (print (local-area))     ; 16
    (print (passed-area))    ; 16
    0))
```

Both functions print the same thing; only the allocation differs. You
can see it in the output of `--emit-asm`: `local-area` makes no call to
`zyl_heap_alloc`. A missed case costs one allocation, never a dangling
pointer.

Heap values are not reclaimed while the program runs; the arena is
released when the process exits. A long-running program that allocates
without bound should manage its own arena from `allocator/allocator`
(`arena-create`, `arena-alloc`), as the compiler itself does.

## 5.6 Closure Capture

The specification makes a read-only capture `TCap`, a mutated capture
`TMut`, and promotes an escaping closure's captures to the heap.

In the implementation, a closure copies the values it captures into a
heap block when it is created. It sees the value each variable had at
that moment:

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

Because the closure holds its own copy, a closure that `set!`s a
captured `let-mut` variable is rejected at compile time with
`E_MUT_CONFLICT`: the assignment could only ever change the copy.

```lisp
(defn main ()
  (let-mut n 0
    (let bump (fn () (set! n (+ n 1)))   ; error[E_MUT_CONFLICT]
      (begin
        (bump)
        (print n)
        0))))
```

Keep mutable state in the function that owns it, and have closures
return new values instead.

## 5.7 Send Capability — Actor Safety

Actors communicate by message passing (Chapter 9). The specification
requires everything that crosses an actor boundary to be
**Send-capable**:

| Capability | Send? | Why |
|------------|-------|-----|
| `TCap<T>` | Yes | Immutable, safe to share |
| `TAtomic<T>` | Yes | Thread-safe by design |
| `TMut<T>` | No | Exclusive — cannot be shared across actors |
| `TBox<T>` | No | Owned — would violate exclusivity |
| `TPin<T>` | No | FFI-pinned — not for actor transfer |

The compiler checks the case you can actually write: a `spawn` closure
or a `send` message that refers to a `let-mut` variable in scope is
`E_CAPABILITY_LEAK`.

```lisp
(defn main ()
  (let a (spawn (fn () 0))
    (let-mut x 10
      (begin
        (send a 42)            ; OK
        (send a (Some "hi"))   ; OK
        (send a x)             ; compile error: x is let-mut
        0))))
```

```
PANIC: error[E_CAPABILITY_LEAK]: message sent to an actor references let-mut (TMut) variable `x` from the enclosing scope
```

The error is located at the `send`, with a second label at the
`let-mut`. A `spawn` whose closure captures a `let-mut` variable gets
the matching message, "spawned closure captures let-mut (TMut)
variable `x` from the enclosing scope". To send the current value of a mutable variable, bind
it with `let` first: `(let snapshot x (send a snapshot))`.

## 5.8 FFI Safety — The Pin Region

A foreign call takes the C function's name, its arguments, and a timeout
in milliseconds as the last argument:

```lisp
(defn main ()
  (begin
    (print (ffi-call "abs" -5 1000))   ; 5
    0))
```

The specification requires FFI arguments to be **FFI_Pinnable** and to
live in the Pin region. FFI_Pinnable types (spec §16) are:
- `Int`, `Float`, `Bool`, `String`
- `Vec<T>` where `T` is FFI_Pinnable
- structs and ADTs composed solely of FFI_Pinnable types

What the compiler enforces today:

- **Pinnability** is checked on every `ffi-call` argument and on
  `ffi-pin`. A function value, for example, is rejected:

  ```lisp
  (ffi-pin (fn (x) x))
  ```

  ```
  PANIC: E_INVALID_CAPABILITY: FFI value has type Fn which is not FFI_Pinnable
  ```

- **The Pin region** is not required for ordinary values: an `Int` or a
  `String` may be passed straight to `ffi-call`, as above. Only a
  `Secret` must go through `ffi-pin` (§5.9).
- **The timeout** is dropped by the compiler and not enforced at run
  time. It must still be written, because the last argument is always
  taken as the timeout.

`ffi-pin` copies a one-word value into the pin arena and returns a
stable pointer to it; `ffi-unpin` checks that the pointer came from the
pin arena and returns the value:

```lisp
(defn main ()
  (let p (ffi-pin 42)
    (begin
      (print (ffi-unpin p))    ; 42
      0)))
```

Chapter 12 covers FFI in practice.

## 5.9 Secrets

One more capability protects key material. A parameter annotated
`Secret` is tracked through the function, and the compiler rejects uses
that could leak it: branching on it, indexing with it, printing it,
sending it to an actor, or passing it to C without `ffi-pin`.

```lisp
(defn leak ((k Secret))
  (if (= k 0) 1 2))
```

```
PANIC: error[E_CT_VIOLATION]: in `leak`: secret-dependent branch -- an `if` condition is derived from a Secret value; ...
  --> leak.zyl:2:7
   |
 2 |   (if (= k 0) 1 2))
   |       ^
```
Chapter 17 (§17.8) is the reference for the Secret rules, and Chapter 33
the tutorial.

## 5.10 What Is Not Implemented

- **Global region.** A top-level `(def PI 3)` compiles, but a function
  that refers to `PI` is `E_UNBOUND_VARIABLE`. Use a zero-argument
  function instead: `(defn pi () 3)`. (At the REPL, `def` does bind a
  value.)
- **Circular region.** There is no cycle detection. With immutable
  fields a program cannot build a cycle out of structs and ADT values
  anyway: a constructor can only point at values that already exist.
- **`E_REGION_ESCAPE`** is listed in the specification but never raised,
  because nothing is ever placed in a region it could escape from.

## 5.11 Error Messages You'll See

| Error | Cause | Fix |
|-------|-------|-----|
| `E_MUT_CONFLICT` | `set!` on a `let` binding, a parameter or a struct field | Use `let-mut`, or rebind the whole value |
| `E_CAPABILITY_LEAK` | A `let-mut` variable in a `spawn` closure or a `send` message | Send a `let`-bound copy |
| `E_INVALID_CAPABILITY` | A non-FFI_Pinnable value given to `ffi-call` or `ffi-pin` | Pass primitives, strings or pinnable data |
| `E_CT_VIOLATION`, `E_SECRET_DEBUG`, `E_SECRET_ESCAPE`, `E_FFI_PIN_REQUIRED` | Misuse of a `Secret` | See Chapter 17 |

`E_MUT_CONFLICT` and `E_CAPABILITY_LEAK` are located: they point at the
`set!`, `spawn` or `send`, and a second label points at the binding
involved. `E_INVALID_CAPABILITY` and the Secret diagnostics still print
as a single `PANIC:` line naming the code.

## 5.12 Mental Model: Regions + Capabilities

Think of it as two independent questions the compiler answers for every
value:

```
                    CAPABILITY
              ┌─────────────┬─────────────┐
              │   TCap      │   TMut      │
              │ (let, param)│ (let-mut)   │
REGION  ┌─────┼─────────────┼─────────────┤
Stack   │     │  read-only  │  owner may  │
        │     │             │  set!       │
        ├─────┼─────────────┼─────────────┤
Heap    │     │  shared,    │  single     │
        │     │  may be sent│  owner only │
        ├─────┼─────────────┼─────────────┤
Pin     │     │  via ffi-pin│  no         │
        └─────┴─────────────┴─────────────┘
```

In today's compiler the capability column is enforced by name
(`let` versus `let-mut`), and the region row is chosen conservatively
(heap unless proven local). The checks are designed to reject only what
they are sure about, so some violations of the full specification go
unreported (Chapter 17, §17.11).

---

## For Experts: Under the Hood

### Region Inference

The specification places region inference in Phase 4, before
monomorphization, but prescribes no algorithm. An earlier general
two-pass design that assigned a region to every value was removed,
because nothing downstream used its result. What remains is
`ri-transform-fns` in `stdlib/compiler/region_inference.zyl`. It runs on
ICNF after optimization, just before code generation, and rewrites a
qualifying `let`-bound variant construction (§5.5) into a stack
allocation. See Chapter 16.

### Capability Checking

`stdlib/compiler/mutability_check.zyl` runs before lowering. It walks the
program tracking which names are in-scope `let-mut` bindings, rejects a
`set!` of anything else (`E_MUT_CONFLICT`), and rejects a `spawn` or
`send` that mentions one (`E_CAPABILITY_LEAK`). The field-mutation form
`(set! (struct-get ...) ...)` is rejected earlier, by the parser.
Pinnability (`E_INVALID_CAPABILITY`) is checked during type inference,
and the Secret rules by `stdlib/compiler/secret_check.zyl`.

In the type system, a capability is a `CapKind` inside one type
constructor, `TCap CapKind Type`; `type_system.zyl` also defines a Send
predicate, but no pass calls it yet.

### Determinism

Region and capability decisions are pure functions of the program: no
hashing, heuristics or randomness. The self-hosting fixed point
(Chapter 31) checks this on the compiler's own source on every build.

---

**Next:** [Chapter 6: Pattern Matching and Error Handling](ch06-pattern-matching-error-handling.md) — exhaustive `match`, literal and range patterns, `Result`, `Option`, and `error`/`try`.
