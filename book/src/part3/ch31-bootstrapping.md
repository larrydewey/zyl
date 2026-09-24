# Chapter 31: Bootstrapping and the Fixed Point

Deep dive into Zyl's bootstrapping process, the fixed point verification, and the journey to a fully self-hosted compiler.

## 31.1 What is Bootstrapping?

**Bootstrapping**: Building a compiler using the compiler itself.

```
Stage 0: committed seed build/boot/stage2.s exists (no Rust — see §31.10)
         ↓
Stage 1: cc links the seed → stage1.bin
         ↓
Stage 2: stage1.bin compiles the Zyl compiler → stage2_gen.s
         (must equal the seed); the seed is linked → stage2.bin
         ↓
Stage 3: stage2.bin compiles the Zyl compiler → stage3.s
         ↓
Verify: stage2.s == stage3.s (fixed point)
```

## 31.2 The Fixed Point Property

**Fixed point**: A function `f` where `f(x) = x`.

For the Zyl compiler with source `S`, let `C_s` be the compiler built
from seed `s`. The fixed point is the statement that the seed
reproduces itself:

- `C_seed(S) = seed` (stage 2: stage1 reproduces the committed assembly)
- `C_{C_seed(S)}(S) = C_seed(S)` (stage 3: the rebuilt compiler agrees)

**What the fixed point proves**:
1. **Determinism**: The same compiler on the same input produces the same bytes, across separate processes
2. **Self-consistency**: The compiler's source, compiled by itself, yields a compiler with the same behavior on that source
3. **Coverage**: Every construct the compiler's own source uses compiles correctly enough to reproduce itself

It does not prove the compiler correct for programs unlike its own
source. That is the regression suite's job.

## 31.3 Boot Process Details (`boot.sh`)

The real script is `boot.sh` at the repo root. Its default flow,
without the reporting, is:

```bash
SRC="selfhost/driver.zyl"     # the entry file; its (use ...) tree is resolved
OUT="build/boot"
export ZYL_HOME="$OUT"        # resolve stdlib from this checkout, not ~/.zyl
export ZYL_MAX_MEMORY="${ZYL_STAGE_MEMORY:-2147483648}"   # per-stage ceiling

# First: stdlib/ and the runtime are copied into build/boot/, so every
# stage compiles this checkout's compiler source
rm -rf "$OUT/stdlib"; cp -R stdlib "$OUT/stdlib"

link_cc() { cc -no-pie "$1" runtime/actor_runtime.c -o "$2" -lpthread; }

# Stage 1: cc links the committed seed
link_cc "$OUT/stage2.s" "$OUT/stage1.bin"

# Stage 2: stage1 compiles the Zyl compiler -- must reproduce the seed exactly
timeout "$STAGE_TIMEOUT" "$OUT/stage1.bin" "$SRC" -o "$OUT/stage2_gen.s" --emit-asm
cmp -s "$OUT/stage2_gen.s" "$OUT/stage2.s" ||
    die "reproduced asm differs from committed seed -- compiler source changed; ..."
link_cc "$OUT/stage2.s" "$OUT/stage2.bin"

# Stage 3: stage2 compiles the Zyl compiler again
timeout "$STAGE_TIMEOUT" "$OUT/stage2.bin" "$SRC" -o "$OUT/stage3.s" --emit-asm

# Fixed point verification
if cmp -s "$OUT/stage2.s" "$OUT/stage3.s"; then
    ok "deterministic (sha256 <first 16 hex digits>)"
else
    diff "$OUT/stage2.s" "$OUT/stage3.s" | head -20
    die "FIXED POINT BROKEN: stage2 and stage3 outputs differ"
fi

# Then: a smoke program compiled by stage2 must print 42 and 3; the
# build/boot/zyl-self wrapper is written; build/boot/zyl-lsp is built.
```

`STAGE_TIMEOUT` defaults to 2400 seconds (`ZYL_STAGE_TIMEOUT`). The
memory ceiling defaults to 2 GB; a self-compile needs about 1.4 GB. The
remedy for a stage-2 mismatch is `--bootstrap-from-self` (§31.10).

## 31.4 Why the Fixed Point Is Hard

### Non-determinism sources, and how each was removed

| Source | Solution in the self-hosted compiler |
|--------|--------------------------------------|
| Iteration order of tables | Every table is an association list or ordered structure built in source order; nothing iterates a hash table |
| Generated names from addresses | Lifted lambdas and match helpers are named from `zyl_fresh_id`, a counter, not from a heap pointer |
| Comparisons that depend on allocation | String `=`/`!=` compares contents (`zyl_cstr_eq`) when codegen knows an operand is a String; pointer equality had made results depend on allocation order, which differs between stage 2 and stage 3 |
| Struct and variant tags | Assigned in declaration order; structs from their own counter |
| Monomorphization names | Built from `type-to-string` of the concrete types, so the same instantiation always gets the same name |
| Stack slot allocation | A per-function counter in the immutable emitter state |
| Environment and time | No timestamps, no randomness; the stage tracing file is written only when `ZYL_DEBUG_STAGES` is set |

The span table in the runtime is keyed by node addresses, which do vary
between runs. It is safe because it is only ever probed by key, never
iterated, so no output depends on the addresses themselves.

### Historical bugs fixed

| Bug | Symptom | Fix |
|-----|---------|-----|
| `ic-binop` with 3+ args lowered to 0 | Stage 2 size computations wrong | `ic-binop-fold` (left-associative fold) |
| `icnf-arm-size` with multiple calls | Match arms with 2+ calls computed 0 | One-call-per-arm rule + `icnf-add2`; `E_MATCH_ARM_COMPLEX` guard |
| `ic-fresh-id` returned a heap pointer | The same binary gave different output on two runs | A deterministic id (now `zyl_fresh_id`) |
| String equality compared pointers | Fixed point broke as allocation order shifted between stages | `zyl_cstr_eq` for String-kind operands |
| Wildcard arm compared tag -1 | A catch-all arm never matched and returned 0 | Wildcard arms skip the tag check |
| Unaligned `rsp` at C calls | `movaps` fault in `tcsetattr` on its second call | Save / `and rsp, -16` / restore around every C call of arity ≤ 6 |
| Inference inferred the last statement twice | Cost doubled per statement; a stage took ~10 minutes | Infer it once; the whole check now takes seconds |

## 31.5 Verifying the Fixed Point

### Assembly comparison

```bash
# Byte-for-byte identical
cmp build/boot/stage2.s build/boot/stage3.s

# Or with diff -- no output means identical
diff build/boot/stage2.s build/boot/stage3.s
```

### Hash verification

```bash
sha256sum build/boot/stage2.s build/boot/stage3.s
```

`./boot.sh` prints the first sixteen hex digits of the seed's SHA-256
at both checks.

`boot.sh` does not link `stage3.s`; the comparison is on assembly,
which is the compiler's actual output. The linked `stage2.bin` is
rebuilt by `cc` on every run, and it changes whenever
`runtime/actor_runtime.c` changes even when the assembly does not.

### Regression test verification

```bash
./run_regression_tests.sh --full --no-boot   # every test, through build/boot/zyl-self
./run_regression_tests.sh --quick            # smoke tests + unit test
```

The full run also executes every regression and smoke test through the
REPL's ICNF interpreter (`zyl eval`) and diffs its output against the
compiled program's (`--filter interpreter` for just that section) — a
second, independent check on the lowering.

## 31.6 Debugging Fixed Point Failures

### Step 1: Find the first difference

```bash
diff -u build/boot/stage2.s build/boot/stage3.s | head -100
```

### Step 2: Identify what changed

Look at the differing lines:
- Function labels differ (`zy_...` names, `_lambda_N`) → naming:
  monomorphization, lambda lifting, fresh ids
- Instruction sequences differ inside one function → ICNF lowering,
  optimization or codegen
- `.rodata` differs → string or float constants
- Whole functions appear or disappear → module resolution, macro
  expansion, or a paren imbalance swallowing definitions

### Step 3: Bisect with small inputs

There is no `--emit-icnf`. Compile a minimal program with each binary
and compare the assembly:

```bash
build/boot/stage1.bin small.zyl -o /tmp/s1.s --emit-asm
build/boot/stage2.bin small.zyl -o /tmp/s2.s --emit-asm
diff /tmp/s1.s /tmp/s2.s
```

A difference between two binaries built from the same source is the
behavior change that needs a reseed; a difference between two runs of
the *same* binary is real non-determinism. `ZYL_DEBUG_STAGES=1` traces
which phase a compile reached (appended to `/tmp/dbg`).

### Step 4: Minimal reproduction

Shrink the input until the difference is one construct, and add it to
`tests/regression/`.

## 31.7 The Bootstrap Constraints

Code in `stdlib/compiler/` and `selfhost/` is compiled by the previous
generation of itself. The current list is in Chapter 27, §27.5, and the
annotated one in `rules/boot-lifted-constraints.md` in the separate zyl-skill repository. In short: balance parens per
top-level form; one `deftype` per name; fresh buffers for
`buf-append`; bind calls with `let` rather than combining two calls in
one binop; no `main` in a library module; `use` every module you call
or whose types you construct. `_` is the discard everywhere, and wildcard arms
are fine.

**A violation usually shows up as a miscompile in stage 2 or later, not
as an error.**

## 31.8 Paren Balance

Balance is checked mechanically, not by formatting convention:
`sexp_balance.zyl` runs on every file before it is parsed and reports
the unclosed or unexpected delimiter with its file, line and column
(Chapter 27, §27.6). Every compiler module is its own file, so a
hand-edited module is checked on its own by any compile that reaches
it, including `./boot.sh`. A balance error is reported before anything
else runs.

## 31.9 Current Status (2026-09-24)

| Component | Language | Status |
|-----------|----------|--------|
| Lexer, parser, balance check | Zyl | ✅ |
| Module resolution, packages (spec §31) | Zyl | ✅ |
| Macro expansion | Zyl | ✅ |
| Checks (capability, duplicate, arity, mutability, exhaustiveness, unused, Secret) | Zyl | ✅ |
| Type inference | Zyl | ✅ (degrades to type variables rather than rejecting; see Chapter 30) |
| Monomorphization, trait dispatch | Zyl | ✅ |
| Closure inlining, assert lowering | Zyl | ✅ |
| ICNF lowering | Zyl | ✅ |
| Optimization | Zyl | ✅ integer constant folding, dead-branch elimination |
| Region inference | Zyl | Partial: stack allocation of non-escaping variants only |
| Code generation | Zyl | ✅ |
| ICNF interpreter (`zyl repl`, `zyl eval`) | Zyl | ✅ (no actors) |
| Contract injection | Zyl | ❌ module exists, not wired into the pipeline |

**Fixed point**: ✅ Holding
**Build input**: `selfhost/driver.zyl` through module resolution (the single-file bundle was retired on 2026-09-24)
**Rust bootstrap**: Archived (`archive/rust-bootstrap-2026/`) — no longer part of the build, and unable to lex the current source

## 31.10 Rust Bootstrap: Archived

What was tracked here as future work is done:

1. ✅ All Zyl passes verified through the fixed point, and through the
   full regression suite (43/43 via the self-hosted compiler at the
   time of eviction — see `docs/rust-eviction-plan.md`; 135 tests now)
2. ✅ `src/` archived to `archive/rust-bootstrap-2026/` (self-contained:
   its own `Cargo.toml`, kept buildable in place)
3. ✅ `boot.sh` (default) starts from the committed Zyl-compiled seed
   only — no Rust, no Cargo, `cc` is the only requirement
4. ✅ Reseeding is also Rust-free now: `./boot.sh --bootstrap-from-self`
   iterates the self-hosted compiler against its own output until two
   consecutive rounds agree (at most 10) — no Cargo build in the normal
   loop at all (§27.3)

The full reseed sequence after a compiler change:

```bash
./boot.sh --bootstrap-from-self
./boot.sh
git add -f build/boot/stage2.s build/boot/stage2.bin && git commit
```

Self-hosted reseeding cannot cross one kind of change: new syntax the
previous seed cannot parse. The archived Rust bootstrap is no answer to
that (it cannot lex the current source, and `--bootstrap-from-rust` now
only prints a pointer to `archive/rust-bootstrap-2026/README.md`).
Land new syntax in two steps: teach the compiler to accept it, reseed,
then use it in the compiler's own source.

## 31.11 Lessons Learned

1. **Determinism is hard** — every table must be ordered, and no output may depend on an address
2. **Phase isolation matters** — prevents circular dependencies
3. **Self-hosting exposes bugs** — the fixed point found bugs no test had
4. **Fail-soft defaults hide bugs** — a lowering that returns 0 for an unknown form compiles wrong programs quietly
5. **Constraints are features** — the bootstrap constraints keep the compiler's own code within what it compiles reliably
6. **Verification and testing complement each other** — the fixed point proves self-consistency; the regression suite and the interpreter comparison cover everything else
7. **Verify the input you think you verify** — while the compiler was built from a committed bundle, a source change that was never re-bundled passed `boot.sh` unseen, and it tripled a self-compile's memory; building straight from the sources removed that gap
