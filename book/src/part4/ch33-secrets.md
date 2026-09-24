# Chapter 33: Secrets and Constant-Time Code

A password checker that returns as soon as it finds a wrong character
tells an attacker how much of the password was right. A table lookup
indexed by a key byte tells them, through the data cache, roughly which
byte it was. A division whose divisor is a secret takes a number of
cycles that depends on the secret. None of these is a bug in the usual
sense — each program computes the right answer — and none of them is
caught by a type system that only asks what shape a value is.

Zyl's `Secret` capability asks a different question: *where is this
value allowed to go?* A value marked `Secret` may be added, multiplied,
masked and shifted, but it may not steer a branch, index memory, go
through a divider, be printed, be sent to another actor, be written to
a file, or cross the FFI boundary unpinned. Those are compile-time
errors, not conventions.

## 33.1 Marking a Parameter Secret

`Secret` is a parameter annotation, written like any other:

```lisp
(defn ct-eq ((a Secret) (b Secret))
  (ct-is-zero (bit-xor a b)))
```

Both spellings are accepted — the bare `(k Secret)` above, and the
applied `(k (Secret Int))` when you want to name the underlying type as
well. The capability is on the *binding*, not on the bytes: the same
integer is ordinary in one function and secret in another, and it is
the annotation that decides which.

Taint flows forward from there. A `let` bound to a secret expression is
secret; an arithmetic result with a secret operand is secret; a
constructor holding a secret produces a secret. A function whose body
is secret under its own `Secret` parameters is itself
*secret-returning*, so its callers are tainted too. That set is
computed by a fixed-point pass before any checking begins, capped at
eight rounds, so the analysis terminates whatever the call graph looks
like.

Being secret-returning is a property of the function, not of a
particular call: a call to one is tainted even when every argument is
public. Every function in `math/secret/secret` is secret-returning, so
this is rejected with `E_SECRET_DEBUG`:

```lisp
(use math/secret/secret)

(defn main ()
  (begin
    (print (ct-select 1 10 20))    ; rejected: the result is secret
    0))
```

and this is the way to say you mean it:

```lisp
(print (declassify (ct-select 1 10 20)))   ; 10
```

A program with no `Secret` annotation anywhere is completely
unaffected: the seed set is empty, the fixpoint settles in one round,
and every taint query answers no.

## 33.2 The Five Prohibitions

| A secret may not… | Because | Error |
|---|---|---|
| steer control flow — an `if`, `while`, `for` or `cond` condition, or the subject of a `match` with more than one arm | the branch taken is visible in timing and in the branch predictor | `E_CT_VIOLATION` |
| address memory — the index argument of `w-get`, `w-set`, `list-nth`, `alloc-read-int`, or a load/store offset | the address touched is visible in the data cache | `E_CT_VIOLATION` |
| go through `/` or `mod` | the divider's latency depends on its operands | `E_CT_VIOLATION` |
| reach `print`, an `error` message, or the text a `show` returns | a debug sink is still a sink | `E_SECRET_DEBUG` |
| leave the process or the actor — `spawn`, `send`, `file-write` | that is the leak the capability exists to prevent | `E_SECRET_ESCAPE` |

And one obligation: a secret reaches C only through `ffi-pin`, in the
Pin region, or the compiler reports `E_FFI_PIN_REQUIRED`.

`Secret` is deliberately **not** `Send`. A secret crossing into another
actor is exactly the escape the capability is for. The type layer
records this (`tc-is-send` answers no for a `TCSecret` type), but
nothing in type inference consults it yet; what actually refuses a
secret at `spawn` or `send` is the checker's `E_SECRET_ESCAPE`.

## 33.3 Writing Branchless Code

If you cannot branch on a secret, how do you make a decision about one?
With a mask. `stdlib/math/secret/secret.zyl` is the whole vocabulary,
and it is short enough to read in full:

```lisp
(use math/secret/secret)

;; All-ones when c is 1, all-zeros when c is 0.
(ct-mask c)

;; 1 when x is zero / non-zero, with no branch.
(ct-is-zero x)
(ct-is-nonzero x)

;; a when c is 1, b when c is 0 -- both operands always evaluated,
;; both always read; only the mask decides which bits survive.
(ct-select c a b)

;; Equality, constant-time in both operands.
(ct-eq a b)
(ct-ne a b)

;; Whole byte strings: the loop runs all n iterations regardless of
;; where a difference appears.
(ct-eq-words a b n)
(ct-ne-words a b n)
```

`ct-select` is the shape every secret-dependent decision takes:

```lisp
;; Not this -- the branch is observable:
;;   (if (= secret-flag 1) a b)

;; This:
(ct-select secret-flag a b)
```

`ct-is-zero` is worth reading closely, because the trick recurs
everywhere:

```lisp
(defn ct-is-zero ((x Secret))
  (- 1 (bit-and (shr (bit-or x (- 0 x)) 63) 1)))
```

`(bit-or x (- 0 x))` has its top bit set for every non-zero `x` —
including the most negative integer, whose negation is itself — so the
logical shift by 63 isolates "non-zero", and the subtraction inverts
it. No comparison, no branch, no table.

Comparing byte strings is the one case where an ordinary
implementation is actively dangerous. `=` on two arrays compares
addresses, not contents; a hand-written loop that stops at the first
difference leaks the length of the matching prefix, which is enough to
forge an authentication tag one byte at a time. `ct-eq-words`
accumulates differences with `bit-or` across the full length and
decides at the end.

## 33.4 Declassifying on Purpose

Some values genuinely have to become public. An AEAD has to act on its
own tag check; a signature is published; a ciphertext is sent. The
escape hatch is explicit and named:

```lisp
(declassify x)
```

`declassify` is the identity function. Its entire job is to be a
greppable place where a program states that a value derived from key
material is deliberately being made public. Two more functions
declassify *by name*, because reducing a secret to one public
accept/reject bit is their whole purpose:

```lisp
(ct-eq-bool a b)            ; one public bit: are these equal?
(ct-eq-words-bool a b n)    ; the same, for byte strings
```

An AEAD's tag check therefore needs no explicit `declassify` call — it
is already a declassifying operation, by construction.

Every deliberate declassification in `stdlib/math` is a call you can
grep for, with a comment saying why that particular verdict is public.
Chapter 34 lists them.

## 33.5 Erasure

A key that stays in memory after you are done with it is a key someone
can read out of a core dump. `zeroize` overwrites it:

```lisp
(zeroize base n)         ; n words at `base`
(zeroize-bytes base n)   ; n bytes at a raw address
```

Both write through a volatile pointer in the runtime, so the C compiler
that builds the runtime cannot delete the stores as dead — the classic
way a `memset` before a `free` silently disappears at `-O2`.

**Stack slots are erased automatically.** A function with a `Secret`
parameter (or one of a Secret type), a secret-returning function, and
any function that binds a secret-derived `let` zeroes its whole frame
when it returns (`rep stosq` over the frame, result kept in a register),
and makes no tail calls, so no copy of a secret word outlives the call
in its own frame. **Heap contents stay explicit**: `zeroize`, or
`(k.wipe)` for a type implementing the `Secret` trait (§33.6). Nothing
is wiped at scope exit automatically, because Zyl does not track moves:
wiping a value that was stored somewhere else would destroy live data.

The compiler also notices when you may have forgotten: a function that takes a `Secret` parameter, returns a
*public* result, is not one of the declassifying functions, and never
mentions `zeroize` or `zeroize-bytes` gets a warning on stderr:

```
E_ZEROIZE_MISSING: warning: `local/main@0::app::check` consumes a Secret parameter into a public result but never calls zeroize/zeroize-bytes on it
```

It is a warning, despite the `E_` prefix: the compile continues. A
function that returns a secret is not warned about, because the secret
is still live in its caller.

## 33.6 Secret Fields, Secret Types and Redaction

**Fields.** A field declared `Secret` (or `(Secret Int)`) is secret when
read: `(struct-get k "bytes")`, `k.bytes`, or a `match` binder in that
position is tainted, so every rule of §33.2 applies to it.

```lisp
(defstruct Login (user String) (pw Secret))
(derive Login Show)
(print (make-Login "ann" 1234))    ; Login { user: ann, pw: <secret> }
```

**Types.** Implementing the prelude trait `Secret` makes a type key
material everywhere: its constructors produce secret values, a parameter
of that type is secret, a field of that type is a Secret field, and
`wipe` is its erasure method.

```lisp
(deftype Key (KeyW Int))
(impl Secret Key (defn wipe (self) 0))       ; erase any heap words the key owns here
(defstruct Vault (label String) (k Key))
(derive Vault Show)
(print (make-Vault "main" (KeyW 7)))   ; Vault { label: main, k: <secret> }
```

A secret placed in a Secret field does not taint the record around it,
so `Vault` can be printed, while its `k` stays redacted. Destructuring a
record with a single-arm `match` is not a branch and is allowed on a
secret; the binders it produces are secret.

**Redaction cannot be overridden.** The prelude declares
`(impl-not Show Secret)` (Chapter 20): an `impl` or `derive` of `Show`
for a Secret type is `E_IMPL_FORBIDDEN`, and the only `Show` such a type
has is the compiler's, which prints `<secret>`. A wrapper cannot leak
through its own `Show` either: any `show` whose text derives from a
secret, through a field, a binder or a helper call, is `E_SECRET_DEBUG`.
Printing a secret-tainted value directly is still `E_SECRET_DEBUG`;
redaction covers what reaches `print` inside a record.

The one sanctioned way out remains `declassify`, at a point you can grep
for.

## 33.7 Why the Check Is Syntactic

`secret_check.zyl` walks the macro-expanded expression tree at the same
stage as the mutability and exhaustiveness checks, rather than living
in the type system as an effect.

The honest reason is that a real constant-time *effect* would need a
constraint solver the Hindley–Milner inferer does not have —
capability polarity is not something the current unifier can express.
The taint walk sees exactly the same program the type checker does, at
a stage where names are still intact, and its failure direction matches
every other checker in this compiler: a shape it does not walk misses a
diagnostic, it never rejects a valid program.

That direction matters. `Secret` catches the mistakes it can see, and
it never silently rewrites your code to be "safe". Constant-time
programming remains something you do deliberately; the capability is
what stops a deliberate effort from being quietly undone three
refactors later.

## 33.8 Current Limits

Worth knowing before you rely on it:

- **Annotations stop at `math/secret/secret`.** Taint crosses a call
  boundary only where the callee's own parameters are annotated, so the
  AEAD, KDF, signature and bignum entry points are not yet under the
  checker. Annotating them is the next step.
- **Heap erasure is manual**: frames are wiped, heap blocks need
  `zeroize` or `wipe`.
- **`set!` of a secret into an existing `let-mut` variable is not
  tracked**: the variable stays untainted.
- A trait call reached through a function value, or a `try` that unwinds
  past a function, skips that function's frame wipe.
- **The checker is not a proof.** It rejects the operations it knows
  are timing-variable on the shapes it walks. `verify/timing.py`, a
  dudect-style statistical harness with a deliberately leaky comparison
  as its positive control, is what actually measures leakage; see
  Chapter 34.

## Summary

- `Secret` is a parameter annotation that tracks where a value may go,
  not what shape it has.
- Branching on, indexing with, dividing by, printing, sending or
  unpinned-FFI-passing a secret are compile-time errors.
- Decisions about secrets are made with masks: `ct-select`, `ct-eq`,
  `ct-eq-words`.
- `declassify`, `ct-eq-bool` and `ct-eq-words-bool` are the named,
  greppable ways out.
- `zeroize` erases key material, and the compiler warns when a function
  handling a secret never calls it; frames that held secrets are zeroed
  on return.
- `Secret` fields and types implementing the `Secret` trait taint what
  is read from them and print as `<secret>`; that redaction cannot be
  overridden.
