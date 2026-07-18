# Zyl Specification — ICNF IR

**Canonical authority:** `zyl_specification.txt` §18
**Related:** `docs/architecture-decisions.md` §A5
**Implementation:** `src/icnf.rs`

---

## 18. ICNF (Intermediate Canonical Normal Form)

### Definition

SSA-based IR with region annotations.
All values: `(SSA_ID, Region)`
Explicit Result types for error handling.

### IR Structure

```
ICNFProgram {
  functions: [ICNFFuncSig, ...]
}

ICNFFuncSig {
  name: String,
  params: [(String, Type, Region)],
  body: [ICNFNode, ...]
}

ICNFNode {
  id: SSA_ID,
  region: Region,
  inner: ICNFInner
}
```

### ICNFInner Operations

| Operation | Description |
|-----------|-------------|
| Constant | Literal values (Int, Float, Bool, String) |
| Load | Load variable from stack/heap |
| Store | Store value to stack slot |
| BinOp | Binary operators (+, -, *, /, ==, !=, <, >, etc.) |
| UnOp | Unary operators (-, not) |
| If | Conditional branch (embedded else body) |
| While | Loop (embedded body) |
| For | For loop (embedded init, condition, body) |
| Call | Function call |
| Return | Return from function |
| MakeStruct | Construct struct (malloc + field store) |
| StructGet | Access struct field |
| Phi | Join point for SSA merge |
| FFI | FFI call |
| Spawn | Create actor |
| Send | Send message to actor |

### SSA Properties

- Each variable is assigned exactly once (SSA form)
- Phi nodes at join points for values with multiple definitions
- Unique SSA IDs for every node
- Region annotations preserved from region inference

### Embedded Control Flow

Control flow structures (If, While, For) have embedded branch bodies
rather than labeled jumps. This simplifies IR traversal and code generation.

### Implementation Notes

- Phi node join point: `mov rax, rax` (not `mov eax, rax`)
- Operand ID tracking: intermediate values not duplicated
- Let statement ordering: Value → Assign → Load → dependent statements
