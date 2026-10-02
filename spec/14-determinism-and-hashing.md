# Zyl Specification — Determinism and Hashing

**Canonical authority:** `zyl_specification.txt` §20, §22 (step 11), §27, §31.12
**Related:** `docs/architecture-decisions.md` §A3, `docs/design-rationale.md` §D10, `spec/16-package-system.md`
**Implementation:** all phases; `selfhost/driver.zyl` (`drv-write-buildinfo`), `stdlib/compiler/lock.zyl` (graph hash), BLAKE3 in `runtime/rt/blake3.zyl`

---

## 20.4 Determinism

Bit-level reproducibility guaranteed.

## 27. Determinism Contract

### Observable Behavior Includes ONLY

- Return values
- Explicit IO
- Actor outputs
- FFI results
- Runtime errors

### NOT Observable

- Timing
- Memory layout
- Scheduling
- Register allocation

### Guarantee

Same program + same inputs → identical observable outputs and binaries.

### Package Builds

For a package build, "same program" means the same resolved graph. Version
selection (§31.5) is a pure function of the manifests in the graph, and hash
finalization takes the graph hash as an input (§31.12), so two machines with
the same `zyl.pkg`, the same `zyl.lock` and the same compiler produce
identical binaries. Network access is confined to `zyl fetch`; builds are
offline.

---

## Hash Finalization (§22 step 11, §31.12)

Hash finalization takes, in this canonical order:

1. the compiler's own hash
2. `graph-hash` from the lock
3. the canonical native-object hashes
4. the ICNF hash

`zyl build` writes `zyl.buildinfo` beside the binary recording all four plus
the resolved graph in canonical form.

---

## 20. Numeric Model

The principle behind this section: **a runtime failure may only happen
where the source explicitly asked for it.** Integer arithmetic therefore
never fails silently (no wrap-around the author did not choose) and never
fails where the author could not see it coming (no division whose divisor
the source did not vouch for).

### 20.1 Integers

Int64 signed. Every package chooses what `+`, `-` and `*` on Int do when
the mathematical result does not fit, with one declaration:

```zyl
(numeric checked)      ; the result does not exist: E_OVERFLOW stops the program
(numeric wrapping)     ; modulo 2^64, as the hardware does
(numeric saturating)   ; clamped to INT_MAX or INT_MIN, by the sign the true result would have
```

The form is written once, among the top-level forms of a lone file, or
as a line of `zyl.pkg` for a package (`spec/16-package-system.md`). It
is a property of the package: every module of the package compiles under
it, and a `(numeric P)` form inside a module file, or in the root file of
a manifested package, is `E_MALFORMED_FORM`, as is a name other than the
three or two forms that disagree. The implicit standard library (§25) is
checked. The REPL is checked until a `(numeric P)` entry changes it.

A package that declares nothing is checked: overflow is never silent
unless the source says `(numeric wrapping)` or `(numeric saturating)`.
Arithmetic on literals is decided at compile time, and a literal result that
does not fit is itself `E_OVERFLOW` when the program runs under
`checked` (the folder keeps the operation rather than inventing a
value). Unary minus is `(- 0 x)` and follows the policy; `(- INT_MIN)`
is therefore `E_OVERFLOW`, `INT_MIN` or `INT_MAX` by policy.

Whatever the policy, the explicit operators `wrapping+`, `wrapping-`,
`wrapping*`, `saturating+`, `saturating-` and `saturating*` name one
behaviour for one operation. They take Int operands only. A hash, a
cipher or a lane-wise SIMD helper, which wraps by construction, is
written with them inside checked code; a derived `Hash` impl uses
`wrapping*`.

Float `+ - * /` are IEEE-754 and outside the policy: a Float operand
makes the operation a Float one.

Checked arithmetic is checked in the emitted code: the add, subtract or
multiply is followed by a test of the overflow flag that jumps to the
runtime's trap, so a `checked` program pays one never-taken branch per
operation. The optimizer may not move, merge or reassociate a checked or
saturating operation (the result of `a + (b + c)` and `(a + b) + c` can
differ in *where* they fail), and may not delete one whose result is
unused. A wrapping operation is associative and may be reassociated and
deleted like any pure operation.

### 20.2 Floats

IEEE-754 binary64. Overflow is ±Infinity, as the standard says; there is
no float overflow error.

### 20.3 Division

Int division is total only when its divisor is known: `/` and `%`
accept a divisor that is a nonzero integer literal (`(/ n 8)`, `(% i
60)`), and anything else, a variable, a call, a literal `0`, is refused
at that operand with `E_PARTIAL_OPERATION`. No guard is recognised: an
`if` around the division does not make `/` total. The author says what
a zero divisor means:

| form | zero divisor | result |
|---|---|---|
| `(/ a 8)`, `(% a 8)` | impossible, the literal is nonzero | Int |
| `(div! a b)`, `(rem! a b)` | the program stops with `E_DIVISION_BY_ZERO` | Int |
| `(div? a b)`, `(rem? a b)` | `None` | `(Option Int)` |

`div?` and `rem?` evaluate both operands once, left to right, and are
`(Some (div! a b))` otherwise. All four take Int operands only.

`INT_MIN` divided by `-1` has no Int result in any policy; it is
`E_OVERFLOW` from `/`, `div!` and `div?` alike (a quotient is a checked
operation whatever the package's policy for `+ - *`, since no wrapping
quotient is meaningful). `(rem! INT_MIN -1)` and `(% INT_MIN -1)` are
`0`. Quotients truncate toward zero and a remainder takes the dividend's
sign, as the hardware's `idiv` does.

Float `/` by zero is ±Infinity or NaN, as the standard says.

---

## Implementation Requirements

These are implementation rules (see `AGENTS.md`), not canonical text.

1. **Ordered data structures:** iteration order never depends on hashing
   or addresses. The self-hosted compiler uses association lists and
   sorted keys; the one hash table (the span table in the runtime) is only
   ever probed by key, never iterated.
2. **Deterministic naming:** generated names come from counters or arena
   offsets, never from raw heap addresses.
3. **No randomness:** no random number generation in compilation.
4. **No timestamp dependence:** compilation does not embed timestamps.
5. **Self-hosting fixed point:** `./boot.sh` checks that the compiler
   reproduces its own assembly byte for byte, which is the standing test
   of determinism.

---

## Determinism Across Phases

Every phase must produce deterministic output from the same input:

| Phase | Determinism Requirement |
|-------|----------------------|
| Parsing | Same tokens, same AST |
| Macro Expansion | Same expansion order (innermost-first) |
| Type Inference | Same type assignments |
| Region Inference | Same stack-promotion and region-placement decisions |
| Monomorphization | Same canonical names (argument types in order, §6.4) |
| ICNF Generation | Same node tree and generated names |
| Optimization | Same inlining, folding, dead-branch and reuse results |
| Code Generation | Same instruction sequence, register assignment and labels |

---

## Implementation Notes

Not normative.

- **`zyl.buildinfo`** is written for package builds only (`zyl build`,
  `zyl test`), as `<output>.buildinfo`. It contains `compiler-hash`
  (BLAKE3 of the running compiler binary), `graph-hash` (from the lock,
  empty when there is none), `native-objects` (each native object's
  package-relative path and BLAKE3 hash, in manifest order), the ICNF
  hash (BLAKE3 of the canonical ICNF text from `icnf_print.zyl`, which
  includes each node's region annotation as ` @r`, so region decisions
  are covered; the tree is the one after inlining and region inference,
  and the in-place reuse marks of `reuse.zyl` are not printed), the
  resolved graph, `asm-hash` (BLAKE3 of the emitted
  assembly) and the final hash of the four spec inputs, which the binary
  carries as `zyl_build_hash`.
- A single-file compile (`zyl file.zyl -o out`) runs no hash-finalization
  step.
- **Register allocation** (`mir.zyl`) depends on instruction order alone:
  virtual registers are numbered in lowering order, live intervals are
  sorted by start and then by register number, and physical registers
  are tried in a fixed order, so a function always gets the same
  assignment.
- There is no SHA-256 in the compiler or runtime; BLAKE3 is implemented in
  the runtime (`zyl_blake3_raw`, `zyl_blake3_hex`, `zyl_blake3_file_hex`).
  SHA-2 exists only as library code in `stdlib/math/hash/`.
- **Numeric model (§20):** implemented as written. `(numeric P)` is read by
  the module resolver (`mr-numeric-root`, keyed per package in
  `node_tables.zyl`'s `numeric-policies`), `numeric_check.zyl` raises
  `E_PARTIAL_OPERATION` after type
  inference, and ICNF lowering picks the operator family (0-2 checked,
  18-20 wrapping, 21-23 saturating; `icnf.zyl`). Checked `+ - *` are
  `add`/`sub`/`imul` followed by `jo` to a runtime trap stub
  (`zyl_rt_trap_ovf_<op>`), saturating ones compute the clamp before the
  operation, and `idiv` is preceded by a zero test and an `INT_MIN / -1`
  test, so no `#DE` can reach the program (`codegen.zyl`,
  `cg-arith-mnem`). The MIR accumulator transformation and the speculative
  evaluation of cheap `if` arms are limited to wrapping arithmetic, and
  `lea` (which sets no flags) is used only for wrapping adds. The REPL
  interpreter uses the same decision procedure (`int_arith.zyl`) and so
  does the constant folder. `div?`/`rem?` are rewritten on the parse tree
  into `let`/`if`/`Some`/`None` around `div!`/`rem!` (`expr_inner.zyl`).
  Floats are IEEE-754 binary64 in SSE registers.
- **Actors** are scheduled by the operating system
  (`spec/08-actors-and-concurrency.md`), so a program whose output depends
  on the interleaving of two actors is not deterministic.
- **Specialization names** (§17): an instance of a trait-generic function
  is named `f~T1,T2`, its argument types in argument order
  (`ta-canon-list` in `type_annotate.zyl`), compound types written in
  full (`List<Int>`, `fn<Int>String`). The name is deterministic and
  distinct type maps get distinct names (§6.4, §17).
