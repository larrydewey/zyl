# Chapter 31: Bootstrapping and the Fixed Point

Deep dive into Zyl's bootstrapping process, the fixed point verification, and the journey to a fully self-hosted compiler.

## 31.1 What is Bootstrapping?

**Bootstrapping**: Building a compiler using the compiler itself.

```
Stage 0: Rust compiler (src/) exists
         ↓
Stage 1: Rust compiles Zyl compiler → stage1
         ↓
Stage 2: stage1 compiles Zyl compiler → stage2
         ↓
Stage 3: stage2 compiles Zyl compiler → stage3
         ↓
Verify: stage2.asm == stage3.asm (fixed point)
```

## 31.2 The Fixed Point Property

**Fixed point**: A function `f` where `f(x) = x`.

For Zyl compiler `C`:
- `C(C(source)) = C(source)` (assembly output)
- `stage2 = C(stage1)`
- `stage3 = C(stage2)`
- Fixed point: `stage2.asm == stage3.asm`

**What fixed point proves**:
1. **Determinism**: Same input → same output at every stage
2. **Correctness**: Compiler semantics preserved through self-application
3. **Completeness**: All language features work in the compiler

## 31.3 Boot Process Details (`boot.sh`)

```bash
#!/bin/bash
set -e

# Configuration
ZYL_SRC="stdlib/compiler/*.zyl"
RUST_BIN="./target/release/zyl"

# Stage 1: Rust → Zyl
echo "=== Stage 1: Rust bootstrap ==="
$RUST_BIN $ZYL_SRC -o stage1

# Stage 2: Zyl → Zyl
echo "=== Stage 2: Self-hosted (stage1) ==="
./stage1 $ZYL_SRC -o stage2

# Stage 3: Zyl → Zyl
echo "=== Stage 3: Self-hosted (stage2) ==="
./stage2 $ZYL_SRC -o stage3

# Fixed point verification
echo "=== Fixed point verification ==="
if cmp -s stage2.asm stage3.asm; then
    echo "✓ FIXED POINT REACHED"
    echo "  stage2.asm == stage3.asm"
else
    echo "✗ FIXED POINT FAILED"
    echo "  Differences:"
    diff stage2.asm stage3.asm | head -50
    exit 1
fi

# Verify executables also identical
if cmp -s stage2 stage3; then
    echo "✓ Executables identical"
else
    echo "✗ Executables differ"
    exit 1
fi

echo "=== Bootstrap successful ==="
```

## 31.4 Why Fixed Point is Hard

### Non-Determinism Sources (All Eliminated)

| Source | Solution |
|--------|----------|
| HashMap iteration | `deterministic.rs` (FNV-1a + sorted) |
| Macro expansion order | Innermost-first, deterministic |
| Monomorphization naming | Alphabetical canonical names |
| Register allocation | Linear scan with deterministic tiebreaker |
| Stack slot allocation | Fixed offsets by SSA ID |
| Symbol ordering | Sorted by name |

### Historical Bugs Fixed

| Bug | Symptom | Fix |
|-----|---------|-----|
| `ic-binop` 3+ args → 0 | Stage2 size computations wrong | `ic-binop-fold` (left-assoc fold) |
| `icnf-arm-size` multi-call | Match arms with 2+ calls → 0 | One-call-per-arm rule + `icnf-add2` |
| `r15` clobber in FFI | Stack corruption | RSP-stash slot per frame |
| `_t_` constructor lowering | ADT variants not recognized | Relax PostProcessor guards |
| Rust HashMap seed | Flaky "unknown variant" | FNV-1a deterministic maps |

## 31.5 Verifying the Fixed Point

### Assembly Comparison

```bash
# Byte-for-byte identical
cmp stage2.asm stage3.asm

# Or with diff
diff stage2.asm stage3.asm
# No output = identical
```

### Executable Comparison

```bash
cmp stage2 stage3
# Identical binaries
```

### Hash Verification

```bash
sha256sum stage2 stage3
# Same hash = same binary
```

### Regression Test Verification

```bash
# Stage2 runs all tests
./stage2 --test stdlib/compiler/*.zyl

# Stage3 runs all tests
./stage3 --test stdlib/compiler/*.zyl

# Both must pass
```

## 31.6 Debugging Fixed Point Failures

### Step 1: Find First Difference

```bash
diff -u stage2.asm stage3.asm | head -100
```

### Step 2: Identify Phase

Look at differing section:
- `.text` → Codegen (Phase 8)
- `.data` / `.rodata` → Constants, strings
- Symbol names → Monomorphization (Phase 5)
- Control flow → ICNF (Phase 6-7)

### Step 3: Bisect

```bash
# Test each phase output
./stage1 --emit-icnf $ZYL_SRC > stage1.icnf
./stage2 --emit-icnf $ZYL_SRC > stage2.icnf
./stage3 --emit-icnf $ZYL_SRC > stage3.icnf

diff stage1.icnf stage2.icnf
diff stage2.icnf stage3.icnf
```

### Step 4: Minimal Reproduction

Create minimal Zyl file that triggers difference.

## 31.7 The Bootstrap Constraints

Code in `stdlib/compiler/` and `selfhost/` must obey:

```
1. Function arities ≤ 6 (LIFTED 2026-08-25)
2. Match as entire body only (LIFTED 2026-08-25)
3. Exhaustive match arms (no wildcard)
4. Named dummy wildcards (d1, d2...)
5. Flat begin + recursion over nesting
6. buf-append = true append (fresh buffers)
7. Paren balance per top-level form
8. NO binop combining TWO calls directly
   → Bind to lets, nest with icnf-add2
```

**Violating these breaks the fixed point.**

## 31.8 C-Style Block Formatting

Required for paren balance:

```lisp
(defn function-name
  (param1 param2)
  (begin
    (statement1)
    (if condition
      (then-branch)
      (else-branch))
    (statement2)))
```

- Each `(` on new line at correct indent
- Each `)` aligned with matching `(`
- Visual paren balance verification

## 31.9 Current Status (2026-09-10)

| Component | Language | Status |
|-----------|----------|--------|
| Lexer | Zyl | ✅ |
| Parser | Zyl | ✅ |
| Macro Expansion | Zyl | ✅ |
| Type Inference | Zyl | ✅ (2026-09-10) |
| Region Inference | Zyl | ✅ |
| Monomorphization | Zyl | ✅ (2026-09-10) |
| ICNF Lowering | Zyl | ✅ |
| Optimization | Zyl | ✅ |
| Code Generation | Zyl | ✅ |
| Contract Injection | Zyl | ✅ |

**Fixed point**: ✅ Holding
**Rust bootstrap**: Only for Stage 1

## 31.10 Future: Removing Rust Bootstrap

### Remaining Work

1. **Verify all Zyl passes** through fixed point
2. **Archive `src/`** — move to `legacy/`
3. **Boot from source** — `boot.sh` starts with Zyl source only
4. **CI integration** — Fixed point check on every commit

### Timeline

- 2026-09-10: Type inference + monomorphization ported
- 2026-Q4: Full verification of all passes
- 2027-Q1: Rust bootstrap archived

## 31.11 Lessons Learned

1. **Determinism is hard** — every data structure must be ordered
2. **Phase isolation matters** — prevents circular dependencies
3. **Self-hosting exposes bugs** — fixed point is ultimate test
3. **Visual formatting prevents bugs** — C-style paren discipline
4. **Constraints are features** — bootstrap constraints improve code quality
5. **Verification > Testing** — fixed point proves more than tests