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
computed by a fixed-point pass before any checking begins, so the
analysis is linear and terminates whatever the call graph looks like.

A program with no `Secret` annotation anywhere is completely
unaffected: the seed set is empty, the fixpoint settles in one round,
and every taint query answers no.

## 33.2 The Five Prohibitions

| A secret may not… | Because | Error |
|---|---|---|
| steer control flow — an `if`, `while`, `for` or `cond` condition, or a `match` subject | the branch taken is visible in timing and in the branch predictor | `E_CT_VIOLATION` |
| address memory — the index argument of `w-get`, `w-set`, `list-nth`, `alloc-read-int`, or a load/store offset | the address touched is visible in the data cache | `E_CT_VIOLATION` |
| go through `/` or `mod` | the divider's latency depends on its operands | `E_CT_VIOLATION` |
| reach `print` | a debug sink is still a sink | `E_SECRET_DEBUG` |
| leave the process or the actor — `spawn`, `send`, `file-write` | that is the leak the capability exists to prevent | `E_SECRET_ESCAPE` |

And one obligation: a secret reaches C only through `ffi-pin`, in the
Pin region, or the compiler reports `E_FFI_PIN_REQUIRED`.

`Secret` is deliberately **not** `Send`. A secret crossing into another
actor is exactly the escape the capability is for, so the type system
refuses it before the checker even has to look.

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

Erasure is **explicit**. Zyl does not yet zeroize secret-typed values
automatically at scope exit; that needs a codegen epilogue hook which
does not exist. What the compiler does do is notice when you forget: a
function with a `Secret` parameter that never calls `zeroize` or
`zeroize-bytes` gets an `E_ZEROIZE_MISSING` warning.

## 33.6 Why the Check Is Syntactic

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

## 33.7 Current Limits

Worth knowing before you rely on it:

- **Annotations stop at `math/secret/secret`.** Taint crosses a call
  boundary only where the callee's own parameters are annotated, so the
  AEAD, KDF, signature and bignum entry points are not yet under the
  checker. Annotating them is the next step.
- **Erasure is manual**, as described above.
- **`print` of a secret is rejected, not redacted.** There is no
  automatic `<secret>` substitution.
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
  handling a secret never calls it.
