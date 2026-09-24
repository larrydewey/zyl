# Zyl Specification — ICNF IR

**Canonical authority:** `zyl_specification.txt` §18 (also §22 step 6)
**Related:** `docs/architecture-decisions.md` §A5, `docs/design-rationale.md` §D8, `spec/12-optimization-rules.md`, `spec/13-code-generation.md`
**Implementation:** `stdlib/compiler/icnf.zyl`

---

## 18. ICNF (Intermediate Canonical Normal Form)

### Definition

SSA-based IR with region annotations.
All values: `(SSA_ID, Region)`
Explicit Result types for error handling.

That is the whole of the canonical definition. ICNF is a custom IR rather
than LLVM so that region annotations can flow through it (architecture
decision A5).

---

## Implementation Notes

Not normative. The self-hosted ICNF is **not** the SSA form §18 describes.
An earlier SSA representation (`ICNFNode` with SSA ids and Phi nodes)
belonged to the Rust bootstrap and was dropped; the active IR is a tree.

### Shape

A program is a list of `IFn` nodes. The `Icnf` ADT in `icnf.zyl`:

| Node | Meaning |
|------|---------|
| `IConst Int` | Integer (and Bool) constant |
| `IStr String` | String literal |
| `IFlt String` | Float literal, kept as its source text |
| `ILoad name` | Read a local |
| `IBinop op a b` | Binary operator (opcodes below) |
| `ICall name args` | Call a Zyl function |
| `ICallClosure name args` | No longer produced by lowering; codegen treats it exactly as `ICall` (a call through a local is always the closure-aware indirect call) |
| `IFfi symbol args` | Call a C symbol; also the target of `spawn`, `send`, `ffi-pin`, byte and atomic primitives |
| `IPrint e` | Print a value |
| `IIf c t e` | Conditional with embedded branches |
| `IWhile c body` | Loop with embedded body (`for` lowers to this) |
| `ISet name v` | Assign to a `let-mut` local |
| `ILet name v body` | Bind a local |
| `ISeq list` | Sequence |
| `IVariant name tag fields` | Heap-allocated variant or struct |
| `IStackVariant name tag fields` | Same layout, allocated in the current frame (see region inference) |
| `IMatch subject arms` | Match on the variant tag; each `IArm` holds variant, tag, bound names and body |
| `ITryCatch body var handler` | `try`/`catch` over the runtime's panic frames |
| `IFn name params body kinds` | Top-level function; `kinds` tags each parameter as Int/pointer, String or Float |

Binary opcodes: 0 add, 1 sub, 2 mul, 3 div, 4 rem, 5 lt, 6 gt, 7 le, 8 ge,
9 eq, 10 ne, 11 bit-and, 12 bit-or, 13 bit-xor, 14 shl, 15 shr (logical),
16 ashr.

### Differences from §18

- There are no SSA ids and no Phi nodes: control flow is embedded in
  `IIf`, `IWhile` and `IMatch`, and locals are named and may be reassigned
  (`ISet`).
- Nodes carry no region annotation. The only region decision in the
  pipeline is the `IVariant` to `IStackVariant` rewrite
  (`spec/07-region-memory-model.md`).
- There is no Result-specific node. `Result` is an ordinary ADT, and
  errors travel through `ITryCatch` and the runtime's panic frames.
- The IR has no serialised form, so no ICNF hash exists; see
  `spec/14-determinism-and-hashing.md`.
