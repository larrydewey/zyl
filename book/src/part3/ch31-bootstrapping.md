# Chapter 31: Bootstrapping and the Fixed Point

Deep dive into Zyl's bootstrapping process, the fixed point verification, and the journey to a fully self-hosted compiler.

## 31.1 What is Bootstrapping?

**Bootstrapping**: Building a compiler using the compiler itself.

```
Stage 0: committed seed build/boot/stage2.s exists (no Rust — see §31.10)
         ↓
Stage 1: cc links the seed → stage1.bin
         ↓
Stage 2: stage1.bin compiles the Zyl compiler → stage2.s
         ↓
Stage 3: stage2.bin compiles the Zyl compiler → stage3.s
         ↓
Verify: stage2.s == stage3.s (fixed point)
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

The real script (`boot.sh` at the repo root; this is its default,
no-Rust flow — see §31.10 for reseeding):

```bash
SRC="selfhost/zyl_selfhost_compiler.zyl"
OUT="build/boot"

# Stage 1: cc links the committed seed
cc -no-pie "$OUT/stage2.s" runtime/actor_runtime.c -o "$OUT/stage1.bin" -lpthread

# Stage 2: stage1 compiles the Zyl compiler — must reproduce the seed exactly
setarch -R "$OUT/stage1.bin" "$SRC" -o "$OUT/stage2_gen.s" --emit-asm
cmp -s "$OUT/stage2_gen.s" "$OUT/stage2.s" || {
    echo "compiler source changed the fixed point — reseed with --bootstrap-from-self"
    exit 1
}
cc -no-pie "$OUT/stage2.s" runtime/actor_runtime.c -o "$OUT/stage2.bin" -lpthread

# Stage 3: stage2 compiles the Zyl compiler again
setarch -R "$OUT/stage2.bin" "$SRC" -o "$OUT/stage3.s" --emit-asm

# Fixed point verification
if cmp -s "$OUT/stage2.s" "$OUT/stage3.s"; then
    echo "✓ FIXED POINT REACHED — stage2.s == stage3.s"
else
    echo "✗ FIXED POINT FAILED"
    diff "$OUT/stage2.s" "$OUT/stage3.s" | head -50
    exit 1
fi
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
**Rust bootstrap**: Archived (`archive/rust-bootstrap-2026/`) — no longer part of the build

## 31.10 Rust Bootstrap: Archived

What was tracked here as future work is done:

1. ✅ All Zyl passes verified through the fixed point, and through the
   full regression suite (43/43 via the self-hosted compiler — see
   `docs/rust-eviction-plan.md`)
2. ✅ `src/` archived to `archive/rust-bootstrap-2026/` (self-contained:
   its own `Cargo.toml`, kept buildable in place)
3. ✅ `boot.sh` (default) starts from the committed Zyl-compiled seed
   only — no Rust, no Cargo, `cc` is the only requirement
4. ✅ Reseeding is also Rust-free now: `./boot.sh --bootstrap-from-self`
   iterates the self-hosted compiler against its own output until it
   converges — no Cargo build in the normal loop at all (§31.3, §27.3)

The archived Rust bootstrap is kept only as a fallback for the one
case self-hosted reseeding can't solve: a language change so large the
previous seed's compiler can't even *parse* the new source. See
`archive/rust-bootstrap-2026/README.md`.

## 31.11 Lessons Learned

1. **Determinism is hard** — every data structure must be ordered
2. **Phase isolation matters** — prevents circular dependencies
3. **Self-hosting exposes bugs** — fixed point is ultimate test
3. **Visual formatting prevents bugs** — C-style paren discipline
4. **Constraints are features** — bootstrap constraints improve code quality
5. **Verification > Testing** — fixed point proves more than tests