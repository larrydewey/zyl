# Zyl Specification — Determinism and Hashing

**Canonical authority:** `zyl_specification.txt` §20, §22 (step 11), §27, §31.12
**Related:** `docs/architecture-decisions.md` §A3, `docs/design-rationale.md` §D10, `spec/16-package-system.md`
**Implementation:** all phases; `selfhost/driver.zyl` (`drv-write-buildinfo`), `stdlib/compiler/lock.zyl` (graph hash), BLAKE3 in `runtime/actor_runtime.c`

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

### 20.1 Integers

Int64 signed. Overflow behavior: checked (default), wrapping, saturating.

### 20.2 Floats

IEEE-754 binary64.

### 20.3 Division by Zero

- Int: `E_DIVISION_BY_ZERO`
- Float: ±Infinity/NaN

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
- **Numeric model (§20):** integer arithmetic wraps on overflow (there is
  no checked mode and `E_OVERFLOW` is never raised); integer division by
  zero, and `INT_MIN / -1`, raise SIGFPE rather than
  `E_DIVISION_BY_ZERO`. Floats are IEEE-754 binary64 in SSE registers.
- **Actors** are scheduled by the operating system
  (`spec/08-actors-and-concurrency.md`), so a program whose output depends
  on the interleaving of two actors is not deterministic.
- **Specialization names** (§17): an instance of a trait-generic function
  is named `f~T1,T2`, its argument types in argument order
  (`ta-canon-list` in `type_annotate.zyl`), compound types written in
  full (`List<Int>`, `fn<Int>String`). The name is deterministic and
  distinct type maps get distinct names (§6.4, §17).
