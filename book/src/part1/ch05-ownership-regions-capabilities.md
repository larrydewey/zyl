# Chapter 5: Ownership, Regions, and Capability Types

This chapter explains Zyl's memory model: where values live (regions)
and who may change them (capabilities). The specification describes a
complete static system for both. The current compiler implements most
of the region side (escape analysis with per-call regions, explicit
`with-region` scopes, the Pin region) and decides capabilities from the
binding form, so this chapter shows the rules you write code against
and, alongside them, what the compiler actually checks today.
Chapters 16 and 17 are the full reference.

## 5.1 The Problem Zyl Solves

Every systems language must answer: **who owns this memory, and when is it freed?**

| Language | Approach |
|----------|----------|
| C/C++ | Manual `malloc`/`free` — programmer responsible, errors common |
| Rust | Ownership + borrow checker — compile-time, with lifetime annotations |
| Go/Java/Python | Garbage collector — runtime overhead, non-deterministic pauses |
| Zyl | **Region inference + binding-form checks** — compile-time, inferred, deterministic |

Zyl's design goal is that the compiler proves where every value lives
and who can modify it, without annotations in your source. You never
write a region — the compiler infers it — and the capability is
implied by the binding form you already write: `let` or `let-mut`.

## 5.2 Regions — Where Values Live

The specification assigns every value to one of five **regions**:

| Region | Purpose (spec) | Today |
|--------|----------------|-------|
| **Stack** | Values that do not escape | Parameters and `let` locals live in registers or the function's frame. An ADT value that does not outlive its call goes in the frame itself or in the call's own region, released when the call returns (§5.5) |
| **Heap** | Escaped values, captured closure variables | A value the compiler cannot prove short-lived: stored in a global, sent to an actor, handed to foreign code, or passed to a closure called through an unknown function value. Heap values live until the program exits |
| **Global** | Top-level immutable constants | A top-level `def`: immutable, evaluated once, in source order, before `main` or the tests run |
| **Circular** | Cyclic structures | Not implemented |
| **Pin** | Non-moving memory for FFI | `ffi-pin` copies a value into a separate pin arena (§5.8) |

### Region Rules (Spec §9.1)

```
R1. Local stack allocation: If variable does not escape → Stack.
R2. Escape allocation: If returned, captured by escaping closure, or sent to actor → Heap.
R3. Actor transfer: spawn and chan-send require a Send-capable type.
R4. FFI rule: ffi-call requires Pin region AND FFI_Pinnable type, and a timeout, at the call or as its extern's :timeout default (§16).
R5. Closure capture promotion: Escaping closure captures promoted to Heap.
R6. Cyclic structures: Cyclic references detected among heap values → Circular region.
R7. Global Region: Immutable constants only. Eager initialization. No mutation allowed.
R8. Pin Region: Non-moving arena. Values physically copied here for FFI. Never compacted.
```

The compiler meets R1, R2 and R5 with region inference (§5.5): a value
that does not outlive its call is allocated in the call's region and
reclaimed on return, and anything it cannot prove short-lived goes to the
heap, which is always safe. R3 and R4 are checked in the specific forms
described in §5.7 and §5.8. R6 and R7 are not implemented.

## 5.3 Capabilities — Who Can Access

Regions say *where*; capabilities say *how*. Zyl has **no in-place
mutation**: a struct field can never change (§5.4), so a "mutated"
struct is a new value bound to the same name. Every binding is therefore
immutable, and the question a capability answers is which *name* may be
rebound. That is decided by the binding form:

| You write | The binding is | `set!` allowed? |
|-----------|----------------|-----------------|
| `(let x 42 body)` | immutable — any number of names may read it, and nothing can change it under them | No |
| `(let-mut y 10 body)` | mutable — the only assignable binding; `set!` rebinds it | Yes |

**The invariant:**
> Zyl has no in-place mutation: every `let` binding is immutable, `set!`
> on a `let-mut` binding rebinds it, and `set!` on anything else is
> `E_MUT_CONFLICT`.

That is a stronger claim than the aliasing invariant the specification
states, and it is the one Zyl can keep: a reader cannot see a value
change underneath it, because there is no in-place write to see. A
`set!` that breaks the rule is `E_MUT_CONFLICT`.

The specification also defines `TAtomic<T>` (atomic shared mutation),
`TBox<T>` (heap ownership) and `TPin<T>` (FFI-pinned). No source
construct produces `TAtomic` or `TBox` today; `TPin` is the type of an
`ffi-pin` result, written `(Pin a)`.

### How Capabilities Are Decided

You never write a capability: `let` versus `let-mut` is all of it. A
function parameter and a `for` loop variable follow the same two rules as
`let` and `let-mut` respectively, and `set!` is the only way to change
anything — checked by name, so a `set!` whose target is not a `let-mut`
(or `for`) variable in scope is rejected.

```lisp
(defn main ()
  (let x 1
    (begin
      (set! x 2)      ; compile error
      0)))
```

```
error[E_MUT_CONFLICT]: set! target `x` is not a let-mut binding in scope
  --> main.zyl:4:7
   |
 4 |       (set! x 2)      ; compile error
   |       ^
 2 |   (let x 1
   |   - bound here by `let`, which is immutable (TCap)
   = help: only a let-mut binding is TMut and may be assigned; declare it with `let-mut`
```

The diagnostic names the specification's `TCap`/`TMut` types because its
message was written against them; what it enforces is the rule above.

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
          (set! sum (+ sum (vec-get! v i)))
          (set! i (+ i 1))))
      sum)))

(defn main ()
  (let-mut v (vec-new)
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
an old version of a Vec or IntMap as used up once you have derived a new
one from it.

A byte buffer (Chapter 32) is a mutable location, and there the rule is
checked on the location itself: a name becomes the buffer's writer by
writing through it (`store-u8` and the other storing forms), and **at
most one name may write to one location**. Reading through any number of
names is fine. Writing through two is `E_MUT_CONFLICT`:

```lisp
(defn main ()
  (let b (bytebuf Stack 16)
    (let second b
      (begin
        (store-u8 :le second 0 65)
        (store-u8 :le b 0 66)      ; compile error: second already writes here
        0))))
```

```
error[E_MUT_CONFLICT]: one mutable location is written through both second and the name used here; a location may have exactly one TMut reference, so only one name may write to it
  --> main.zyl:6:9
   |
 6 |         (store-u8 :le b 0 66)      ; compile error: second already writes here
   |         ^
   = help: write through a single name, or read the bytes you need and copy them into a buffer of your own
```

This message also names the specification's `TMut`; the rule it enforces
is the one above it.

A `byteslice` of a buffer is the same location as its base, so writing
through the slice and the base is the same error. The check keys its
alias classes on the allocation rather than the name, which is why two
buffers bound to one name do not inherit each other's writer.

### Resources are released once

A file descriptor is an `Int`, and an `Int` is copied freely — which
would let a program close a file and then write through the stale
number into whatever the operating system opened next with it. The
compiler prevents that: a value that owns a resource is **consumed by
its release**, and any use after the release is `E_MOVE_VALUE`:

```lisp
(capabilities io)

(defn main ()
  (let fd (file-open "a.txt" "w")
    (begin
      (file-close fd)
      (file-write fd "leaked")     ; compile error: fd is closed
      0)))
```

```
error[E_MOVE_VALUE]: the binding fd was released by an earlier call, so it cannot be used again
  --> main.zyl:7:19
   |
 7 |       (file-write fd "leaked")     ; compile error: fd is closed
   |                   ^
   = help: a resource is released exactly once; if you need it again, open a second handle rather than reusing a released one
```

The rule covers file descriptors, `StringBuffer`, and any type your
program gives a `Drop` impl. It follows copies — `(let other fd)` is
the same resource — and a release inside a `catch` handler is
conditional, so it does not consume.

`with-resource` binds a resource for its body and releases it on the
way out, normally or before a panic propagates, by calling its `Drop`
impl (for a file descriptor, `file-close`):

```lisp
(capabilities io)

(defn main ()
  (begin
    (with-resource (fd (file-open "notes.txt" "w"))
      (file-write fd "hello\n"))
    0))
```

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
error[E_MUT_CONFLICT]: set! target must be a plain variable name bound via let-mut -- direct field/expression mutation is forbidden, rebind the whole variable instead
  --> main.zyl:5:13
   |
 5 |       (set! (struct-get p "x") 5)
   |             ^
```

**Why?** Mutability is a property of the binding, not of each field.
Allowing field mutation would need field-level rules and field-level
aliasing to reason about. Zyl chooses simplicity: **whole-value
rebinding only**. It is also what makes the §5.3 invariant hold for
every type at once — nothing a reader holds can change underneath it.

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

The compiler runs region inference over the whole program and gives
every allocation one of three levels:

- **Frame** — the value does not outlive the call. It goes in the call's
  own region, which is released when the call returns (or makes a tail
  call, or is unwound by a caught panic).
- **Result** — the value may be part of the call's result but goes no
  further. It goes in the region the *caller* chose for the result, so a
  list built by a helper and consumed by its caller is reclaimed when the
  caller returns.
- **Heap** — the value escapes in a way the compiler does not track:
  stored in a global, sent to an actor, handed to foreign code, or passed
  to a closure called through an unknown function value.

A `(let x (Variant ...) body)` where every use of `x` is the subject of a
`match` or an argument to `print` is placed directly in the function's
stack frame.

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

;; Region: `s` is passed to `area`, which does not keep it.
(defn passed-area ()
  (let s (Square 4)
    (area s)))

(defn main ()
  (begin
    (print (local-area))     ; 16
    (print (passed-area))    ; 16
    0))
```

Both functions print the same thing; only the allocation differs. In the
output of `--emit-asm`, `local-area` builds its `Square` in a block of
its own stack frame and calls no allocator, and `passed-area` allocates
in the region its caller chose (`zyl_cur_region`): an inline bump of
that region's pointer, with a call to `zyl_ralloc` only when the
current block is full. The call to `area` is a tail call, so
`passed-area`'s own frame is gone by the time `area` runs. Neither
calls `zyl_heap_alloc`. A missed case costs one heap
allocation, never a dangling pointer.

Values that do reach the heap are not reclaimed while the program runs;
the heap is released when the process exits. A long-running program whose
data escapes in bulk can bound it explicitly with `with-region` (below).
A program cannot obtain a raw arena: the `allocator/allocator` entries
(`arena-create`, `arena-alloc`) are for the compiler, the language server
and the REPL, and calling one from a program is `E_FFI_RESTRICTED`.
`ZYL_REGIONS=0` at compile time turns region inference off (everything
goes to the heap), which is useful for bisecting a suspected region bug.

### Explicit regions: `with-region`

`with-region` runs a body with its allocations in a region of an audited
kind, released when the body ends:

```lisp
(with-region (arena :block B :align A :limit L) body)
(with-region (fixed :size S :align A) body)
```

An `arena` grows in blocks of `B` bytes (a multiple of 4096, at most
64 MiB) up to `L` bytes (0, the default, means no limit). A `fixed` region
holds exactly `S` bytes. `A` is a power of two from 8 to 4096, default 8.

```lisp
(deftype Nums (End) (Link Int Nums))

(defn build (n acc)
  (if (= n 0) acc (build (- n 1) (Link n acc))))

(defn total (l)
  (match l
    (End 0)
    (Link h t (+ h (total t)))))

;; The list lives in an arena that is released when the body ends;
;; only the Int result leaves it.
(defn arena-total (n)
  (with-region (arena :block 65536 :limit 1048576)
    (total (build n (End)))))

;; A fixed region holds exactly 4096 bytes.
(defn small-total (n)
  (with-region (fixed :size 4096)
    (total (build n (End)))))

(defn live-bytes () (ffi-call "zyl_region_live_bytes" 1000))

(defn main ()
  (begin
    (print (arena-total 1000))                  ; 500500
    (print (live-bytes))                        ; 0: the arena is gone
    (print (small-total 10))                    ; 55
    (print (try (small-total 1000) (catch _ -1))) ; -1: E_REGION_EXHAUSTED
    0))
```

Output:

```
500500
0
55
-1
```

`Nums` names its constructors `End` and `Link` because `Nil` and `Cons`
belong to the prelude's `List`, and a program type may not reuse a
prelude constructor name (`E_DUPLICATE_VARIANT`).

Three errors belong to `with-region`:

- `E_REGION_SPEC` (compile time): a malformed spec, such as an unknown
  kind (`pool`), a block size that is not a multiple of 4096, or an
  alignment that is not a power of two.
- `E_REGION_EXHAUSTED` (run time, catchable): the region is full. It is
  deterministic: it depends only on the sequence of allocation requests,
  and blocks are page-aligned, so padding is the same on every run.
- `E_REGION_ESCAPE` (compile time): a value allocated inside the region
  outlives it. Returning the list itself instead of its total is rejected:

```lisp
(defn leak ()
  (with-region (arena :block 4096)
    (build 10 (End))))            ; the list is the body's value
```

```
error[E_REGION_ESCAPE]: a value allocated inside with-region outlives it
  --> leak.zyl:3:15
   |
 3 |     (build 10 (End))))            ; the list is the body's value
   |               ^
 2 |   (with-region (arena :block 4096)
   |   - escapes here: returned from the function
   = help: compute a result that does not point into the region (a number, or data built outside it)
```

The error points at the allocation that escapes — here the empty list
that becomes the tail of the returned list — and a second label says
where it escapes.

The REPL's interpreter ignores regions and allocates in its own arenas,
so it does not enforce a region's byte limit; compiled code does.

## 5.6 Closure Capture

A closure captures **by value**. The specification models a read-only
capture as shared and a mutated capture as exclusive, and promotes an
escaping closure's captures to the heap.

In the implementation, a closure copies the values it captures into an
environment block when it is created (allocated like any other value:
in the caller's result region when the closure is returned). It sees the value each variable had at
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

```
error[E_MUT_CONFLICT]: set! target `n` is a let-mut of an enclosing scope, captured by value by this closure
  --> main.zyl:3:22
   |
 3 |     (let bump (fn () (set! n (+ n 1)))   ; error[E_MUT_CONFLICT]
   |                      ^
   = help: closures capture by value (spec 7); return the new value from the closure and set! it at the binding's own scope
```

Keep mutable state in the function that owns it, and have closures
return new values instead.

## 5.7 Send Capability — Actor Safety

Actors communicate over channels (Chapter 9). The specification
requires everything that crosses an actor boundary to be
**Send-capable**:

| Binding or value | Send? | Why |
|------------------|-------|-----|
| an immutable (`let`) binding | Yes | Nothing can change it, so sharing is safe |
| an atomic value (`TAtomic<T>`) | Yes | Thread-safe by design |
| a mutable (`let-mut`) binding | No | It can be rebound — cannot be shared across actors |
| a `TBox<T>` | No | Owned — would violate exclusivity |
| a `(Pin a)` | No | FFI-pinned — not for actor transfer |

The compiler checks the case you can actually write: a `spawn` closure
or a `chan-send` value that refers to a `let-mut` variable in scope is
`E_CAPABILITY_LEAK`.

```lisp
(capabilities actor)

(use actor/actor)

(defn main ()
  (let c (chan 4)
    (let tx (chan-tx c)
      (let-mut x 10
        (begin
          (chan-send tx 42)      ; OK
          (chan-send tx x)       ; compile error: x is let-mut
          0)))))
```

```
error[E_CAPABILITY_LEAK]: value sent on a channel references let-mut (TMut) variable `x` from the enclosing scope
  --> main.zyl:11:11
    |
 11 |           (chan-send tx x)       ; compile error: x is let-mut
    |           ^
  8 |       (let-mut x 10
    |       - declared `let-mut` here
    = help: channel values must be Send-capable; send a copy bound with plain `let`
```

The `(capabilities actor)` line is what lets the file use channels at
all: a program declares the capabilities it uses, and has none it did
not declare (Chapter 25, §25.7).

The error is located at the `chan-send`, with a second label at the
`let-mut`. A `spawn` whose closure captures a `let-mut` variable gets
the matching message, "spawned closure captures let-mut (TMut)
variable `x` from the enclosing scope". Both messages name the
specification's `TMut` type; the rule enforced is the `let-mut` row of
the table above. To send the current value of a mutable variable, bind
it with `let` first: `(let snapshot x (chan-send tx snapshot))`.

## 5.8 FFI Safety — The Pin Region

A foreign call takes the C function's name, its arguments, and a timeout
in milliseconds as the last argument. The C function's signature is
declared first with `extern`, so the type checker knows what the call
takes and returns:

```lisp
(capabilities ffi)

(extern "abs" (Int) Int)

(defn main ()
  (begin
    (print (ffi-call "abs" -5 1000))   ; 5
    0))
```

Calling foreign code needs the `ffi` capability, declared with
`(capabilities ffi)`; without it the call is
`E_PKG_CAPABILITY_VIOLATION`. An `ffi-call` to a foreign function with no
`extern` is `E_CANNOT_INFER`. The runtime's own `zyl_*` functions are
already declared, and calling them needs no capability.

The specification requires FFI arguments to be **FFI_Pinnable** and to
live in the Pin region. FFI_Pinnable types (spec §16) are:
- `Int`, `Float`, `Bool`, `String`
- `Vec<T>` where `T` is FFI_Pinnable
- structs and ADTs composed solely of FFI_Pinnable types

What the compiler enforces today:

- **Types** come from the `extern` declaration: each argument must
  have the declared type, and the result has the declared result type.
- **Pinnability** is checked on `ffi-call` arguments. A closure literal,
  for example, is rejected:

  ```lisp
  (extern "apply_cb" ((Fn (Int) Int)) Int)
  (ffi-call "apply_cb" (fn (x) (+ x 1)) 1000)
  ```

  ```
  error[E_INVALID_CAPABILITY]: ffi-call argument is a closure, which is not FFI_Pinnable (Int/Float/Bool/String/composed only) -- pin its result data explicitly instead of passing the closure itself
  ```

  A named top-level function can be passed as a C callback, typed
  `(Fn (A ...) R)` in the `extern` (Chapter 12).

- **The Pin region** is not required for ordinary values: an `Int` or a
  `String` may be passed straight to `ffi-call`, as above. Only a
  `Secret` must go through `ffi-pin` (§5.9).
- **The timeout** must be a positive integer literal — at the call, or
  once on the `extern` as `:timeout N` — or the call is rejected with
  `E_FFI_TIMEOUT_REQUIRED`. It is enforced at run time: a
  foreign call that has not returned in time raises `E_FFI_TIMEOUT`,
  and the C function is abandoned (Chapter 12, §12.7).

`ffi-pin` copies a one-word value into the pin arena and returns a
stable pointer to it. For a value of type `a` the pointer has type
`(Pin a)`, which is not an `a`: C receives the address, and an `extern`
parameter that takes it is declared `(Pin a)`. `ffi-unpin` checks that
the pointer came from the pin arena and returns the `a` in the slot,
which C may have written. A function cannot be pinned
(`E_FFI_TYPE_NOT_PINNABLE`):

```lisp
(capabilities ffi)

(defn main ()
  (let p (ffi-pin 42)
    (begin
      (print (ffi-unpin p))           ; 42
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
error[E_CT_VIOLATION]: in `leak`: secret-dependent branch -- an `if` condition is derived from a Secret value; ...
  --> leak.zyl:2:7
   |
  2 |   (if (= k 0) 1 2))
   |       ^
```

`Secret` also carries an erasure obligation: a function that takes or
binds a secret has its whole frame zeroed on return (`rep stosq` over
the frame) and makes no tail calls, so no copy of a secret word outlives
the call in its own frame. A *released region block* is a different
thing and is **not** wiped — it goes back to the allocator with its
contents, so a secret the source never erased is one allocation away
from being read back. `zeroize` is the explicit answer, and a function
that takes a `Secret`, returns a public value and never mentions
`zeroize` gets the `E_ZEROIZE_MISSING` warning.

Chapter 17 (§17.8) is the reference for the Secret rules, and Chapter 33
the tutorial.

## 5.10 What Is Not Implemented

- **Global region.** A top-level `(def PI 3)` is an immutable global
  (Chapter 2, §2.5), allocated on the heap; there is no separate global
  region.
- **Circular region.** There is no cycle detection. With immutable
  fields a program cannot build a cycle out of structs and ADT values
  anyway: a constructor can only point at values that already exist.
- **Heap reclamation.** A value that escapes to the heap lives until the
  process exits; only frame and result regions, and `with-region` scopes,
  are reclaimed while the program runs. The analysis is field-insensitive,
  so a local list of strings and its strings share one level.

## 5.11 Error Messages You'll See

| Error | Cause | Fix |
|-------|-------|-----|
| `E_MUT_CONFLICT` | `set!` on a `let` binding, a parameter or a struct field; a byte buffer written through two names | Use `let-mut`, or rebind the whole value; write through one name |
| `E_MOVE_VALUE` | A resource (a file descriptor, a `StringBuffer`, a `Drop` type) used after its release | Open a second handle; release once |
| `E_PKG_CAPABILITY_VIOLATION` | `spawn`, a channel, file IO, foreign code or `math/secret` in a file that did not declare the capability | Add `(capabilities actor)` (or `io`, `ffi`, `secret`) at the top of the file |
| `E_CAPABILITY_LEAK` | A `let-mut` variable in a `spawn` closure or a `chan-send` value | Send a `let`-bound copy |
| `E_INVALID_CAPABILITY` | A closure written inline as an `ffi-call` argument | Pass a named top-level function, typed `(Fn ...)` in the `extern` |
| `E_FFI_TYPE_NOT_PINNABLE` | A function given to `ffi-pin` | Pin data, not code |
| `E_REGION_ESCAPE` | A value allocated inside `with-region`, or a `(bytebuf Stack N)`, outlives its region | Return data that does not point into the region |
| `E_REGION_SPEC` | A malformed `with-region` spec | Use `arena` or `fixed` with valid sizes and alignment |
| `E_REGION_EXHAUSTED` | A `with-region` scope ran out of space (run time) | Raise the limit, or catch it with `try` |
| `E_CT_VIOLATION`, `E_SECRET_DEBUG`, `E_SECRET_ESCAPE`, `E_FFI_PIN_REQUIRED` | Misuse of a `Secret` | See Chapter 17 |

`E_MUT_CONFLICT` and `E_CAPABILITY_LEAK` are located: they point at the
`set!`, `spawn` or `chan-send`, and a second label points at the binding
involved. The Secret diagnostics, `E_INVALID_CAPABILITY`,
`E_FFI_TYPE_NOT_PINNABLE`, `E_MOVE_VALUE` and the region errors are
located too.

## 5.12 Mental Model: Regions + Capabilities

Think of it as two independent questions the compiler answers for every
value:

```
                      BINDING FORM
                ┌──────────────┬──────────────┐
                │    let       │   let-mut    │
                │ (also param) │ (also `for`) │
REGION  ┌───────┼──────────────┼──────────────┤
Stack   │       │ immutable    │ may be       │
        │       │              │ rebound      │
        ├───────┼──────────────┼──────────────┤
Heap    │       │ shareable,   │ shareable,   │
        │       │ may be sent  │ may not be   │
        │       │              │ sent         │
        ├───────┼──────────────┼──────────────┤
Pin     │       │ via ffi-pin  │ no           │
        └───────┴──────────────┴──────────────┘
```

The binding-form column is enforced by name (`let` versus `let-mut`),
and the region row is chosen by region inference (the call's region
unless the value escapes, heap otherwise). The checks are designed to
reject only what they are sure about, so some violations of the full
specification go unreported (Chapter 17, §17.11).

---

## For Experts: Under the Hood

### Region Inference

The specification places region inference in Phase 4, before
monomorphization, but prescribes no algorithm. The implementation runs
on ICNF after optimization (which has already inlined small functions),
just before in-place reuse and code generation, in
`stdlib/compiler/region_inference.zyl`. First `ri-transform-fns` rewrites
a qualifying `let`-bound variant construction (§5.5) into a stack
allocation; then `rg-regions` groups values that may point to each other
into union-find classes and gives each class a level (frame, result or
heap), using per-function parameter summaries computed to a fixpoint over
the whole program. The levels are recorded per allocation and call site,
and code generation turns them into region pushes, pops and
`zyl_ralloc` calls. The design is `docs/regions-design.md`; see Chapter 16.

### Capability Checking

`stdlib/compiler/mutability_check.zyl` runs before lowering, as a
syntactic walk over the pre-lowering tree. It tracks which names are
in-scope `let-mut` bindings, rejects a `set!` of anything else
(`E_MUT_CONFLICT`) and a `set!` of a captured outer `let-mut` from
inside a closure (the closure holds a by-value copy, so the assignment
could only ever change the copy), and rejects a `spawn` or `chan-send`
that mentions one (`E_CAPABILITY_LEAK`). The field-mutation form
`(set! (struct-get ...) ...)` is rejected earlier, by the parser.
The same pass rejects a closure written inline as an `ffi-call` argument
(`E_INVALID_CAPABILITY`); the type pass rejects a pinned function
(`E_FFI_TYPE_NOT_PINNABLE`), and `stdlib/compiler/secret_check.zyl`
checks the Secret rules and marks the functions whose frame code
generation zeroes on return.

`stdlib/compiler/linearity.zyl` is the second pass here. It checks that a
resource is released once (`E_MOVE_VALUE`), and it owns the mutable-location
rule: a byte buffer is one location, a name becomes its writer by writing
through it, alias classes are keyed per allocation, and a second writer is
`E_MUT_CONFLICT`.

The unifier is not involved. There is no capability type to infer —
`type_annotate.zyl`'s `TaTy` is `TaV | TaC | TaF`, with no capability
dimension — which is why these checks need no type information and can
undershoot deliberately.

### Determinism

Region and capability decisions are pure functions of the program: no
hashing, heuristics or randomness. The self-hosting fixed point
(Chapter 31) checks this on the compiler's own source on every build.

---

**Next:** [Chapter 6: Pattern Matching and Error Handling](ch06-pattern-matching-error-handling.md) — exhaustive `match`, literal and range patterns, `Result`, `Option`, and `error`/`try`.
