# Chapter 26: Determinism and Compilation Pipeline

Complete reference for Zyl's determinism guarantees, the compilation pipeline as specified and as implemented, the self-hosting fixed point, and the tools for checking all three.

The normative text is spec v5.0 §0 (P1, P6), §17 (monomorphization), §18 (ICNF), §20.4 (numeric determinism), §22 (pipeline), §27 (determinism contract) and §31.12 (package build determinism). The pipeline itself is `compile-to-asm` in `stdlib/compiler/pipeline.zyl`, driven by `selfhost/driver.zyl`.

## 26.1 Determinism Guarantee (Normative)

> **Same source program + same inputs → identical observable outputs and binaries.** (§0 P1, §27)

### Observable behaviour includes (§27)

- Return values
- Explicit I/O
- Actor outputs
- FFI results
- Runtime errors

### Not observable

- Timing
- Memory layout
- Scheduling
- Register allocation

For a package build, "same program" means the same resolved graph: same `zyl.pkg` + same `zyl.lock` + same compiler ⇒ identical binaries (§27, §31.12). Network access is confined to `zyl fetch`; builds are offline.

### What the implementation delivers today

| Claim | Status |
|-------|--------|
| Same source → same assembly | **holds**: `.s` output is byte-identical across runs, and independent of the working directory and the `-o` path |
| Same source → same binary | **holds** for the same toolchain: two builds, from any directory to any `-o` path, are byte-identical (see §26.10) |
| Same inputs → same program output, single-threaded | holds, unless the program reads the environment through the FFI (§26.2) |
| Same inputs → same actor output | **does not hold**: actors are OS threads (§26.2) |
| Compiler self-application is a fixed point | **holds**: checked by `./boot.sh` (§26.7) |

## 26.2 Sources of Non-Determinism

| Source | Zyl's position | Implementation |
|--------|----------------|----------------|
| Map iteration order | deterministic iteration (§21.5) | `stdlib/core/map.zyl` is an association list, iterated in a fixed order (most recently inserted first); no hashing, no seed |
| Monomorphization naming | alphabetical canonical names (§17) | type names sorted before naming (`canonical-name-from-type-map`) |
| Symbol order | total order over canonical keys (§31.2) | qualification tables are sorted by name |
| Thread scheduling | "not observable" (§27) | each actor is its own pthread, and interleaving of output between actors varies from run to run |
| Heap addresses | not observable | vary per run (ASLR applies to arena memory); code addresses are fixed by `-no-pie` |
| Time, process ID, environment | not provided by the core language | reachable through `ffi-call` (`time`, `getpid`, `zyl_now_ms`, `getenv`) |
| Random numbers | not in the core language | `stdlib/math/rand/deterministic.zyl` is a seedable ChaCha20 generator (reproducible); `stdlib/math/rand/crypto.zyl` draws kernel entropy (not reproducible) |
| Floating point | IEEE-754 binary64 (§20.2), bit-reproducible (§20.4) | codegen emits separate SSE2 multiply and add, never a fused multiply-add, and passes no `-march` flag; this holds by construction, not by a checked rule |

A program that stays out of the FFI and out of actors is deterministic in its output. A program that reads the clock, the environment or kernel entropy, or that prints from more than one actor, is not, and the compiler does not warn about it.

## 26.3 Deterministic Data Structures

The compiler's internal tables are ordered by construction, so the same source yields the same iteration order on every run:

- **Most tables are lists**, built and traversed in source order.
- **Symbol tables** built during qualification (`qualify.zyl`) are sorted by name.
- **`stdlib/core/map.zyl`** is the ordered `Map` offered to programs: an association list whose iteration order is a function of the insertion sequence alone.
- **`stdlib/collections/map.zyl` and `set.zyl`** store keys and values in arena-backed arrays, searched linearly in insertion order.

No part of the compiler iterates a hash table in hash order. (The runtime's interpreter uses an FNV-1a table to look up functions by name, but never iterates it.)

## 26.4 Compilation Pipeline

### As specified (§22)

```
 1. Parsing                     → AST
 2. Macro Expansion             (innermost-first, hygiene)
 3. Type Inference + Trait Resolution  (derive, struct, alias validation)
 4. Region Inference + Capture Analysis
 5. Monomorphization            (alphabetical determinism)
 6. ICNF Generation             (SSA IR)
 7. Optimization                (safe only)
 8. Code Generation
 9. Linking
10. Contract Injection          (optional)
11. Hash Finalization
```

Rule: no phase may depend on a later phase.

### As implemented (`compile-to-asm`, `pipeline.zyl`)

```
 1. Balance check        sb-check-string: every ( [ { closed, with line/col and a fix-it hint
 2. Lex + parse          zyl-lex, parse-program → raw AST (no-dispatch: every form is a call)
 3. Module resolution    mr-resolve-program-full: splice the use graph, qualify names to
                         canonical keys, check the orphan rule, convert to ExprInner
                         (the "PostProcessor")
 4. Macro expansion      me-expand-program
 5. Static checks        capability (§31.9), duplicate definitions, arity, mutability,
                         match exhaustiveness, unused bindings, Secret handling
 6. Definition typing    collect-definitions (type_inference.zyl)
 7. Monomorphization     monomorphize
 8. Trait dispatch       td-expand-program
 9. Closure inlining     ci-expand-program
10. Assert lowering      al-expand-program
11. ICNF lowering        ic-program
12. Optimization         opt-optimize-fns
13. Region inference     ri-transform-fns
14. Code generation      cg-program → x86_64 assembly text
15. Linking              cc -no-pie out.s actor_runtime.c -o out -lpthread
```

`zyl build` adds native-object compilation before the link and writes `<name>.buildinfo` after it (§26.5, Phase 11).

### Where the two differ

- **Module resolution** and the static checks are not phases in §22. They run between parsing and type inference. The capability pass runs after macro expansion, as §31.9 requires ("after module resolution and before type inference").
- **Region inference runs last**, on ICNF after optimization, not as phase 4.
- **Type inference is not a separate phase over the whole program.** Definitions are collected and typed, then monomorphized; `docs/compiler-pipeline.md` describes the current arrangement.
- **Contract injection (phase 10) is not wired in.** See Chapter 24.
- **Hash finalization (phase 11)** exists only for `zyl build` and `zyl test`, as the `.buildinfo` file.

The phase-isolation rule does hold: each pass consumes only the output of earlier passes.

## 26.5 Phase Details

### Parsing

- **Balance check first**: `stdlib/compiler/sexp_balance.zyl` validates bracket structure before parsing, aware of strings and comments, and reports the exact position.
- **Lexer**: UTF-8 bytes → tokens. Keywords are not special in the lexer.
- **Parser**: recursive descent → raw AST. By the no-dispatch rule, every S-expression becomes a generic call node; the conversion to specialised `ExprInner` forms happens later.

### Module resolution

Covered in Chapter 25. It is the only pass that reads files other than the source.

### Macro expansion

`stdlib/compiler/macro_expand.zyl` collects every top-level `defmacro` first, then expands. See Chapter 23 for what it does and does not implement: the §19 hygiene and termination rules are not enforced.

### Static checks

Each check is a separate pass over the expanded program. Each one either stops compilation with a `PANIC: E_...` diagnostic or, for unused bindings and shadowing, prints a `W_...` warning.

### Type inference and monomorphization

- Definitions are collected and typed with Hindley–Milner inference extended with capability types.
- Monomorphization specialises generic functions and ADTs per call site. Specialisation names are canonical: type names are sorted alphabetically (§17).
- The inference is permissive in places: some ill-typed programs, for example `(+ 1 "a")`, are accepted and compile.

### ICNF

ICNF (`icnf.zyl`) is the compiler's intermediate representation. Spec §18 defines it as SSA with a region annotation on every value. The implemented ICNF is a tree-structured IR of let-bound expressions: it has no SSA identifiers and no per-value region field.

### Optimization

`optimization.zyl` performs two safe transformations:

- **Integer constant folding**: `(+ (* 2 3) 4)` compiles to `mov rax, 10`. Floats are not folded, and neither is division by zero.
- **Dead-branch elimination**: an `if` with a constant condition keeps one branch, and a `while` whose condition is constant false disappears.

Nothing is reordered.

### Region inference

`region_inference.zyl` is a narrow ICNF rewrite. A variant value bound by `let` that is only matched or printed is moved to the stack; everything else stays in the heap arena. The general escape analysis of spec §9 is not implemented, and `E_REGION_ESCAPE` is never raised.

### Code generation

- **Target**: x86_64, System V AMD64 ABI, Intel-syntax assembly text.
- **Stack machine**: every value passes through `rax`, with `rcx` for the second operand and `rbp`-relative slots for locals. There is no register allocator.
- **Frames** are sized per function.
- **Calls** are direct for known functions, and indirect through the closure record for closures.
- **No tail-call optimization.** Deep recursion survives because `main` runs on a thread with a very large reserved stack (`zyl_call_on_big_stack` in the runtime), not because calls become jumps. This is how the implementation meets §14's stack-safety guarantee in practice.

### Linking

```bash
cc -no-pie out.s actor_runtime.c -o out -lpthread
```

The runtime is compiled from source on every link. `zyl build` appends the objects and libraries from the package's `native` block.

### Phase 11: hash finalization

`zyl build` and `zyl test` write `<name>.buildinfo` beside the binary:

```lisp
(buildinfo
  (compiler-hash "blake3:...")   ; BLAKE3 of the compiler binary
  (graph-hash "blake3:...")      ; from zyl.lock; empty without a lock
  (native-objects)               ; always empty today
  (asm-hash "blake3:..."))       ; BLAKE3 of the emitted assembly
```

§31.12 specifies four inputs: compiler hash, graph hash, native-object hashes and ICNF hash. It also requires the resolved graph to be recorded in canonical form. The implementation departs from this in four ways:

- It hashes the assembly instead of the ICNF, because the ICNF has no serialised form. The assembly is a deterministic function of it.
- It records no native-object hashes.
- It does not record the resolved graph.
- It does not mix the graph hash into the binary.

A plain `zyl file.zyl` compile writes no buildinfo.

## 26.6 Compiler Flags

```
zyl <file.zyl> [-o out] [--emit-asm]
```

| Flag | Purpose |
|------|---------|
| `-o <file>` | output path; default: the source path without `.zyl` |
| `--emit-asm` | write assembly to the output path instead of linking. The name is used as given, so pass `-o prog.s` |

No other flags exist. In particular there is no `--emit-ast`, `--emit-expanded`, `--emit-typed`, `--emit-regions`, `--emit-mono`, `--emit-icnf` or `--emit-opt`.

The argument parser is strict about order and loose about content:

- **The source file must come first.** In `zyl --emit-asm prog.zyl`, the flag is taken as the source path, and the compile fails with "cannot open source file".
- **An unrecognised word after the source becomes the output path.** `zyl prog.zyl --emit-icnf` builds a binary named `--emit-icnf`.

`zyl help` prints the usage summary, including the package subcommands (Chapter 25).

Two environment variables affect compilation:

- `ZYL_HOME` selects the directory that holds `stdlib/` and `actor_runtime.c`. When it has no `stdlib/`, the compiler tries `~/.zyl`, and then the compiler's own directory.
- `ZYL_DEBUG_STAGES`, when set, appends each stage name to `/tmp/dbg` as the compiler reaches it.

## 26.7 Bootstrapping and the Fixed Point

The compiler is written in Zyl: `stdlib/compiler/*.zyl` plus `selfhost/driver.zyl`, bundled by `selfhost/assemble.py` into `selfhost/zyl_selfhost_compiler.zyl`. No Rust is involved in the default build. The original Rust implementation is frozen in `archive/rust-bootstrap-2026/` as a reseed fallback only.

### What `./boot.sh` does

```
1. cc links the committed seed build/boot/stage2.s        → stage1.bin
2. stage1.bin compiles zyl_selfhost_compiler.zyl --emit-asm → stage2_gen.s
   cmp stage2_gen.s stage2.s     (else: "reproduced asm differs from committed seed")
3. cc links stage2.s                                       → stage2.bin
4. stage2.bin compiles the same source                     → stage3.s
   cmp stage2.s stage3.s         (else: "FIXED POINT BROKEN")
5. smoke test: compile and run a small program
6. install stdlib/, actor_runtime.c, the zyl-self wrapper and zyl-lsp into build/boot/
```

The comparisons are byte comparisons (`cmp`) of assembly text, not of binaries. Short SHA-256 prefixes are printed for display only. Each stage has a timeout, `ZYL_STAGE_TIMEOUT`, which defaults to 2400 seconds.

After a change to compiler source that alters the compiler's own output, re-seed:

```bash
python3 selfhost/assemble.py      # re-bundle the compiler source
./boot.sh --bootstrap-from-self   # iterate stageN → stageN+1 until two outputs match (≤ 10 rounds)
./boot.sh                         # verify a clean fixed point on the new seed
```

`./boot.sh --bootstrap-from-rust` rebuilds a seed through the archived Rust compiler. It is needed only when the old seed cannot parse the new source at all.

### What the fixed point shows

- The compiler is **deterministic on its own source**: compiling the same program twice gives identical assembly.
- The committed seed and the source agree: the seed really is what this source compiles to.
- It is a strong **regression check**: most miscompilations of the compiler itself break it.

It does not prove the compiler correct. A bug that reproduces itself faithfully survives the fixed point, which is why the regression suite (§26.8) also exists.

## 26.8 Regression Testing

```bash
./run_regression_tests.sh              # same as --quick
./run_regression_tests.sh --quick      # unit test, smoke tests, LSP protocol test
./run_regression_tests.sh --full       # every category below, plus ./boot.sh
./run_regression_tests.sh --full --no-boot
./run_regression_tests.sh --full --filter structs
```

| Flag | Effect |
|------|--------|
| `--quick` / `--full` | select the mode (quick is the default) |
| `--filter N` | run only tests whose name contains `N`, case-insensitively |
| `--boot` / `--no-boot` | force or skip the fixed-point check (`--full` turns it on) |
| `--dry-run`, `--verbose`, `--timeout N` | list what would run (honouring the mode and `--filter`), show output, per-test timeout in seconds |

`--filter` narrows the mode it is combined with. The `regression/` and `stress/` categories run only in `--full` mode, so `--filter structs` or `--filter balanced-parens` on its own, in quick mode, selects nothing. Combine it with `--full`.

### Test categories (`tests/`)

| Directory | Contents |
|-----------|----------|
| `smoke/` | basic end-to-end programs |
| `regression/` | feature tests (structs, ADTs, patterns, the package system, compiler internals) using the `test` / `assert-equal` harness |
| (interpreter) | every regression and smoke program also run through the ICNF interpreter, with its output diffed against the compiled binary |
| `stress/` | balanced parens, deep recursion, large structs, long operand chains |
| `integration/` | self-hosting and codegen integration |
| `compile-fail/` | programs that must fail with a specific diagnostic |
| `packages/`, `packages-fail/`, `packages-build/` | multi-package builds, package errors, `zyl build` with native code |
| `lsp/` | the language server protocol test |

See `docs/regression-tests.md` for the full description.

## 26.9 Debugging the Pipeline

The only intermediate output the compiler writes is assembly:

```bash
zyl prog.zyl --emit-asm -o prog.s
```

Other tools:

| Issue | Where to look |
|-------|---------------|
| Unbalanced brackets | the balance check reports line, column and a fix-it hint |
| Resolver, capability or check failure | the `PANIC: E_... :` message names the pass and the definition |
| Which stage fails or hangs | `ZYL_DEBUG_STAGES=1 zyl prog.zyl` appends each stage name to `/tmp/dbg` as it starts |
| Wrong code | read `prog.s`; labels are mangled canonical keys (`zy_local_x2Fmain_0__prog__fact`) |
| Compiled vs intended semantics | `zyl eval prog.zyl` runs the program through the ICNF interpreter; compare its output with the binary's |
| Link errors | `undefined reference to ...` usually means a misspelled function, a private symbol reached through `*`, or a C symbol that is not linked |

## 26.10 Determinism Verification

### Assembly comparison (holds)

```bash
zyl prog.zyl --emit-asm -o a.s
zyl prog.zyl --emit-asm -o b.s
cmp a.s b.s        # identical
```

The assembly depends on the source file's base name, which becomes the module path in every symbol, but not on the directory or the output path.

### Binary comparison

```bash
zyl prog.zyl -o a
zyl prog.zyl -o b
cmp a b            # identical
```

The emitted assembly starts with `.file "prog.zyl"` (the source's basename,
never its full path). Without it the assembler records no file symbol and
the linker substitutes the name of `cc`'s random temporary object file
(`/tmp/ccXXXXXX.o`), which made every link differ by those bytes.
`tests/scripts/deterministic-link.sh` checks this, and a rebuilt
`build/boot/stage2.bin` is identical to the committed one. The binary
still depends on the C compiler and C library that link it.

### Boot verification

```bash
./boot.sh          # stage2_gen.s == stage2.s, then stage2.s == stage3.s
```

## 26.11 Known Non-Determinism Sources

| Source | Status |
|--------|--------|
| Actor output interleaving | varies per run (one pthread per actor) |
| Heap addresses | vary per run; printing a pointer is non-deterministic |
| Clock, PID, environment | reachable through `ffi-call` |
| Kernel entropy | `stdlib/math/rand/crypto.zyl` |
| Standard-library location | `~/.zyl` takes precedence over the compiler's own directory when `ZYL_HOME` is unset, so a stale install changes what is compiled |
| Floating point | deterministic in practice (no FMA emitted), not enforced |

Under §27, anything outside this list is a bug.

## 26.12 Comparison with Other Compilers

| Feature | GCC/Clang | Rustc | Zyl |
|---------|-----------|-------|-----|
| Deterministic compiler output | with care (`-frandom-seed`, path maps) | with care | assembly always; binaries identical after `strip` |
| Phase isolation | ❌ | partial | ✅ (strict ordering, no back edges) |
| Self-hosting | ✅ | ✅ | ✅ (fixed point checked on every boot) |
| Reproducible package builds | external tooling | external tooling | `zyl.lock` + `.buildinfo` (§31.12, partial) |
| Build verification | manual | manual | `./boot.sh` automated |
