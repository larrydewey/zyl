# Chapter 26: Determinism and Compilation Pipeline

Complete reference for Zyl's determinism guarantees and the 11-phase compilation pipeline.

## 26.1 Determinism Guarantee (Normative)

> **Same source program + same inputs → identical observable outputs and binaries.**

### Observable Behavior Includes

- Return values
- Explicit I/O (stdout, stderr, files)
- Actor outputs
- FFI results
- Runtime errors

### NOT Observable

- Timing
- Memory layout
- Thread scheduling
- Register allocation
- Heap addresses

## 26.2 Sources of Non-Determinism (Eliminated)

| Source | Typical Language | Zyl Solution |
|--------|------------------|--------------|
| Hash map iteration | Random seed | FNV-1a + sorted keys |
| Thread scheduling | OS scheduler | Deterministic round-robin |
| Memory allocation | ASLR, heap layout | Region-based, fixed addresses |
| Timestamps | `time()` | Not accessible |
| Random numbers | `rand()` | Not in core language |
| Floating-point non-determinism | FMA, precision | Strict IEEE-754, no FMA |

## 26.3 Deterministic Data Structures

All compiler-internal collections use **ordered, deterministic variants**:

- **Maps**: FNV-1a hashed, sorted by key hash
- **Sets**: Same as maps
- **Symbol tables**: Sorted by symbol name
- **Type environments**: Ordered by insertion (preserved)

Implementation: `src/deterministic.rs` — `DeterministicMap<K,V>`, `DeterministicSet<T>`

## 26.4 Compilation Pipeline (11 Phases, Strict Order)

```
Phase 1: Parsing
  Lexer + Parser → Raw AST (no-dispatch: all S-expr → Call/Apply)

Phase 2: Macro Expansion
  Innermost-first, gensym hygiene → Expanded AST

Phase 3: Type Inference + Trait Resolution
  Hindley-Milner + capability types + trait resolution
  → Typed AST

Phase 4: Region Inference + Capture Analysis
  Two-pass algorithm → Region-annotated AST

Phase 5: Monomorphization
  Canonical naming (alphabetical) → Concrete specialized functions

Phase 6: ICNF Generation
  SSA IR with region annotations → ICNF

Phase 7: Optimization
  Constant folding, DCE (safe only) → Optimized ICNF

Phase 8: Code Generation
  x86_64 assembly, System V AMD64 ABI → .s file

Phase 9: Linking
  cc + actor_runtime.c + pthread → Executable

Phase 10: Contract Injection (Optional)
  Pre/post/invariant checks → Instrumented binary

Phase 11: Hash Finalization
  Binary hash for determinism verification
```

### Phase Isolation Rule

> **No phase may depend on a later phase.**

This is a hard architectural constraint — enables:
- Independent verification of each phase
- Incremental compilation (future)
- Clear error attribution

## 26.5 Phase Details

### Phase 1: Parsing

- **Lexer**: UTF-8 → tokens (no keywords in lexer)
- **Parser**: Recursive descent → Raw AST
- **No-dispatch**: All S-expressions become generic `Call`/`Apply` nodes
- **PostProcessor**: Converts `Call`/`Apply` to specialized `ExprInner`

### Phase 2: Macro Expansion

- **Registration**: Collect all `defmacro` before expansion
- **Algorithm**: Innermost-first (post-order traversal)
- **Hygiene**: Gensym-based (macro-introduced vars renamed)
- **Termination**: Depth limit (`E_MACRO_NON_TERMINATION`)

### Phase 3: Type Inference + Trait Resolution

- **Algorithm**: Hindley-Milner with extensions
  - Capability type variables
  - Region variables
  - Trait constraints
- **Unification**: Occurs-check, subsumption
- **Generalization**: At `defn` boundaries
- **Trait resolution**: Lookup `impl Trait ConcreteType`
- **Derivation**: Validate field constraints

### Phase 4: Region Inference + Capture Analysis

- **Pass 1**: Bottom-up constraint collection
- **Pass 2**: Top-down solve + promote (Stack ≤ Heap ≤ Circular)
- **Escape analysis**: Return, closure capture, actor send, FFI
- **Capture analysis**: Read-only → TCap, Write → TMut, Escape → Heap

### Phase 5: Monomorphization

- **Per call-site**: Infer concrete types for all type params
- **Canonical naming**: Alphabetical sort of type names
- **Caching**: Reuse specializations
- **ADTs**: Monomorphize constructors and match patterns

### Phase 6: ICNF Generation

- **SSA form**: Each value = (SSA_ID, Region)
- **Explicit Result types**: For error handling
- **Region annotations**: On every value
- **Control flow**: Explicit join points

### Phase 7: Optimization

- **Constant folding**: Evaluate compile-time constants
- **Dead code elimination**: Remove unreachable code
- **Safe only**: No reordering, no speculation
- **Preserves**: Evaluation order, region assignments, capabilities

### Phase 8: Code Generation

- **Target**: x86_64, System V AMD64 ABI
- **Register allocation**: Linear scan (deterministic)
- **Stack frames**: Uniform size for TCO
- **Calls**: Direct (known) / Indirect (closure/actor)
- **Tail calls**: Optimized to jumps

### Phase 9: Linking

- **Assembler**: `cc` (GCC/Clang) → `.o`
- **Runtime**: `actor_runtime.c` (pthread-based actors)
- **Linker**: `cc` → executable
- **Libraries**: `pthread`, `libc`

### Phase 10: Contract Injection

- **Optional**: Only if contracts present
- **Instrumentation**: Pre/post/invariant checks
- **Recovery**: `recover` blocks
- **Checkpoints**: State save/restore

### Phase 11: Hash Finalization

- **Binary hash**: SHA-256 of final executable
- **Verification**: `boot.sh` compares stage2 vs stage3
- **Determinism proof**: Identical hash = identical binary

## 26.6 Compiler Flags

| Flag | Purpose |
|------|---------|
| `--emit-ast` | Output Phase 1 AST |
| `--emit-expanded` | Output Phase 2 expanded AST |
| `--emit-typed` | Output Phase 3 typed AST |
| `--emit-regions` | Output Phase 4 region AST |
| `--emit-mono` | Output Phase 5 monomorphized AST |
| `--emit-icnf` | Output Phase 6 ICNF |
| `--emit-opt` | Output Phase 7 optimized ICNF |
| `--emit-asm` | Output Phase 8 assembly |
| `-o <file>` | Output executable name |

## 26.7 Bootstrapping and Fixed Point

### Self-Hosting

Zyl compiler written in Zyl (`stdlib/compiler/*.zyl`, `selfhost/`):

```
boot.sh:
  Stage 1: Rust compiler (src/) compiles Zyl compiler → stage1
  Stage 2: stage1 compiles Zyl compiler → stage2
  Stage 3: stage2 compiles Zyl compiler → stage3
  Verify: stage2.asm == stage3.asm (byte-identical)
```

### Fixed Point Verification

```bash
./boot.sh
# If stage2.asm == stage3.asm → fixed point reached
```

### What Fixed Point Proves

- Compiler is **deterministic** (same input → same output)
- Compiler is **correct** (compiles itself correctly)
- All phases **preserve semantics** through self-application

## 26.8 Regression Testing

```bash
./run_regression_tests.sh --quick   # Smoke tests
./run_regression_tests.sh --full    # All tests + boot fixed point
./run_regression_tests.sh --filter structs
./run_regression_tests.sh --filter balanced-parens
```

### Test Categories

- `smoke/` — Basic functionality
- `regression/` — Feature-specific (structs, types, adts, etc.)
- `stress/` — Deep recursion, balanced parens
- `integration/` — Self-hosting, codegen

## 26.9 Debugging the Pipeline

### Inspect Intermediate Output

```bash
zyl --emit-ast prog.zyl        # Raw AST
zyl --emit-typed prog.zyl      # Typed AST
zyl --emit-icnf prog.zyl       # ICNF (SSA IR)
zyl --emit-asm prog.zyl        # Assembly
```

### Common Debugging Patterns

| Issue | Phase | Check |
|-------|-------|-------|
| Parse error | 1 | `--emit-ast` |
| Macro wrong | 2 | `--emit-expanded` |
| Type error | 3 | `--emit-typed` |
| Region escape | 4 | `--emit-regions` |
| Wrong monomorph | 5 | `--emit-mono` |
| ICNF bug | 6 | `--emit-icnf` |
| Opt bug | 7 | `--emit-opt` vs `--emit-icnf` |
| Codegen bug | 8 | `--emit-asm` |
| Link error | 9 | Check `actor_runtime.o` |
| Contract bug | 10 | Compare with/without contracts |

## 26.10 Determinism Verification

### Binary Comparison

```bash
zyl prog.zyl
cp prog prog.1
zyl prog.zyl
cmp prog prog.1  # Should be identical
```

### Hash Verification

```bash
zyl prog.zyl
sha256sum prog
# Re-run
sha256sum prog  # Same hash
```

### Boot Verification

```bash
./boot.sh
# stage2.asm == stage3.asm
```

## 26.11 Known Non-Determinism Sources (If Any)

| Source | Status |
|--------|--------|
| File system timestamps | Not used |
| Process ID | Not accessible |
| Random seed | Not in language |
| Thread timing | Deterministic scheduler |
| ASLR | Fixed addresses in regions |
| Floating point | Strict IEEE-754 |

**If you find non-determinism: it's a bug.**

## 26.12 Comparison with Other Compilers

| Feature | GCC/Clang | Rustc | Zyl |
|---------|-----------|-------|-----|
| Deterministic builds | `-frandom-seed` | `-C deterministic` | Always |
| Phase isolation | ❌ | Partial | ✅ (strict) |
| Self-hosting | ✅ | ✅ | ✅ (verified fixed point) |
| Reproducible builds | Configurable | Configurable | Mandatory |
| Binary verification | Manual | Manual | `boot.sh` automated |