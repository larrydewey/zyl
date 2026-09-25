# Chapter 26: Determinism and Compilation Pipeline

Complete reference for Zyl's determinism guarantees, the compilation pipeline as specified and as implemented, the self-hosting fixed point, and the tools for checking all three.

The normative text is spec v5.0 §0 (P1, P6), §17 (monomorphization), §18 (ICNF), §20.4 (numeric determinism), §22 (pipeline), §27 (determinism contract) and §31.12 (package build determinism). The pipeline itself is `compile-to-asm` in `stdlib/compiler/pipeline.zyl`, driven by `selfhost/driver.zyl`; the REPL runs the same phases up to code generation (`compile-to-fns`) and interprets the ICNF.

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
| Monomorphization naming | alphabetical canonical names (§17) | an instance is named `f~T1,T2` from the canonical text of its argument types, in argument order (§6.4); the name is a function of the types alone |
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

No part of the compiler iterates a hash table in hash order. The hash tables that do exist (the compiler's variant-table index, top-level arities and codegen's function kinds; the runtime's FNV-1a function map for the interpreter and its source-span table) are only probed by key, never iterated.

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
 2. Lex + parse          zyl-parse-file → raw AST (no-dispatch: every form is a call)
 3. Module resolution    mr-resolve-program-full: splice the use graph, qualify names to
                         canonical keys, check the orphan rule and impl-not, convert to
                         ExprInner (convert-ast, which also lowers contracts)
 4. Macro expansion      me-expand-program
 5. Static checks        capability (§31.9), duplicate definitions, arity (with malformed
                         forms and restricted FFI entries), mutability, match
                         exhaustiveness, unused bindings, Secret handling
 6. Derive expansion     dv-expand-program
 7. Impl lifting         lift-impls: impl bodies become Trait.method_Type functions
 8. Closure inlining     ci-expand-program (an identity pass today)
 9. Type checking        ta-annotate: HM, static trait resolution, per-type instances
10. ICNF lowering        ic-program
11. Inlining             opt-inline-fns: small non-recursive functions, copy propagation
12. Optimization         opt-optimize-fns: constant folding, dead-branch elimination
13. Region inference     ri-transform-fns (stack variants), then rg-regions
14. Reuse                ru-reuse: in-place update of a unique, dead value's block
15. Code generation      cg-program-file → x86_64 assembly text (MIR + linear scan,
                         or the stack machine; §26.5)
16. Linking              cc -no-pie out.s actor_runtime.o -o out -lpthread
```

`zyl build` adds native-object compilation before the link and writes `<name>.buildinfo` after it (§26.5, Phase 11).

### Where the two differ

- **Module resolution** and the static checks are not phases in §22. They run between parsing and type inference. The capability pass runs after macro expansion, as §31.9 requires ("after module resolution and before type inference").
- **Monomorphization is part of type checking.** `ta-annotate` types the whole program and, where a generic function needs its argument types (a trait method, `print` or an operator at a type variable), specializes it per concrete argument types; there is no separate monomorphization pass.
- **Region inference runs late**, on ICNF after inlining and optimization, not as phase 4. Inlining runs before it so that inlined code is placed like any other.
- **Contract injection (phase 10) happens at parse time**, not after linking: `convert-ast` rewrites `requires`, `ensures`, `invariant`, `recover` and `checkpoint` into ordinary checks under the active contract profile (Chapter 24).
- **Hash finalization (phase 11)** exists only for `zyl build` and `zyl test`, as the `.buildinfo` file and the `zyl_build_hash` embedded in the binary.

The phase-isolation rule does hold: each pass consumes only the output of earlier passes.

## 26.5 Phase Details

### Parsing

- **Balance check first**: `stdlib/compiler/sexp_balance.zyl` validates bracket structure before parsing, aware of strings and comments, and reports the exact position.
- **Lexer**: UTF-8 bytes → tokens. Keywords are not special in the lexer.
- **Parser**: recursive descent → raw AST. By the no-dispatch rule, every S-expression becomes a generic call node; the conversion to specialised `ExprInner` forms happens later.

### Module resolution

Covered in Chapter 25. It is the only pass that reads files other than the source.

### Macro expansion

`stdlib/compiler/macro_expand.zyl` collects every top-level `defmacro` first, then expands. Hygiene renames template binders to `name__hygN`, where `N` comes from a counter threaded through the walk in source order, so the expanded program is a pure function of the source. See Chapter 23.

### Static checks

Each check is a separate pass over the expanded program. Each one either stops compilation with a `PANIC: E_...` diagnostic or, for unused bindings and shadowing, prints a `W_...` warning.

### Type inference and monomorphization

- The whole program is typed with Hindley–Milner inference (spec §4.8–§4.10); top-level functions are generalized per strongly connected component of the call graph. Capability types (`TCap`/`TMut`) are not part of this pass: `mutability_check.zyl` enforces them from `let` and `let-mut` before it.
- A generic function that calls a trait method, prints, or applies an operator at a type variable is specialized per concrete argument types, at every call and every use as a value, into an instance named `f~T1,T2`; the generic original is dropped. The name is the canonical text of the argument types in argument order, so it depends on nothing but the types.
- Type annotation (`type_annotate.zyl`) is the one authority on types, and it is strict. Every unification failure, occurs-check failure and unknown type is an error (`E_TYPE_MISMATCH`, `E_CANNOT_INFER`, `E_UNBOUND_VARIABLE`). The pass reports all of a program's type errors, each at its source position, and then the compile stops with `the program does not type-check (N errors above)`. `(+ 1 "a")` is rejected. `ZYL_STRICT_TYPES=report` turns the errors into `W_TYPE_STRICT` warnings, for counting them; there is no mode that runs an ill-typed program.

### ICNF

ICNF (`icnf.zyl`) is the compiler's intermediate representation. Spec §18 defines it as SSA with a region annotation on every value. The implemented ICNF is a tree-structured IR of let-bound expressions with no SSA identifiers. Region annotations live in a side table keyed by node; `icnf_print.zyl`'s canonical text prints them as ` @r` (1 frame, 2 result, 3 heap, higher a `with-region` scope), so a package build's ICNF hash covers them.

### Optimization

`optimization.zyl` performs these safe transformations:

- **Inlining** (`opt-inline-fns`, before region inference): a call of a small (6 ICNF nodes, `ZYL_INLINE_LIMIT`), non-recursive function with Int-kind parameters and no `try`, region scope, lambda, closure call or `print` is replaced by its body, the arguments bound by nested `let`s in call order and every binder renamed. Leaf functions of up to 18 nodes are inlined into self-recursive functions (loops) only. A call inside a `try` body is left alone. A `(let n x ...)` that binds a variable to another variable is then copy-propagated. `ZYL_INLINE=0` turns inlining off.
- **Integer constant folding**: `(+ (* 2 3) 4)` compiles to `mov rax, 10`. Floats are not folded, and neither is division by zero.
- **Dead-branch elimination**: an `if` with a constant condition keeps one branch, and a `while` whose condition is constant false disappears.

After region inference, `reuse.zyl` marks an update of an immutable value (`vec-push`, a struct with one field changed, a list rebuilt cell by cell) whose old value is provably unique and dead, so the new record is written into the old one's block instead of a fresh allocation; functions that own such a parameter get an owning clone `f~own`. The decision is an attribute that only the native backend acts on, so it cannot change a result. `ZYL_REUSE=0` turns it off.

Nothing is reordered: arguments bound by inlining are evaluated in call order, and every pass keeps strict left-to-right evaluation.

### Region inference

`region_inference.zyl` runs on ICNF. A variant value bound by `let` that is only matched or printed is moved to the stack; every other allocation and call site is then classified as belonging to the call's own region (released on return), the caller's result region, or the heap. The analysis visits functions in program order and joins per-function summaries to a fixpoint, so its decisions are a pure function of the program; they are printed in the ICNF text, so a package build's ICNF hash covers them. `with-region` limits fail with `E_REGION_EXHAUSTED` at a point that depends only on the sequence of allocation requests: region blocks are page-aligned, so alignment padding is the same on every run. `E_REGION_ESCAPE` is raised for a Stack bytebuf or a `with-region` value that outlives its region.

### Code generation

- **Target**: x86_64, System V AMD64 ABI, Intel-syntax assembly text.
- **Two backends, one ABI.** A function whose ICNF lies in the native backend's supported set is lowered to MIR (`mir.zyl`: basic blocks, virtual registers), allocated by linear scan (over `rsi`, `rdi`, `r8`–`r10` and the callee-saved `rbx`, `r12`–`r15`; a value live across a call gets a callee-saved register, and only used ones are saved) and emitted from there. The supported set covers integers and control, direct and runtime calls with at most six arguments, inline byte and `Array` access, variants and `match`, constants, and frame and result regions, with inline region allocation. Any other function (closures, `try`, `with-region` scopes, `print`, Float arithmetic, more than six parameters, Secret frame wiping) is compiled by the stack machine in `codegen.zyl`, where every value passes through `rax` and locals live in `rbp`-relative slots. The two call each other freely. `ZYL_MIR=0` at compile time sends every function through the stack machine. Every choice the allocator makes is a function of instruction order, so the output stays deterministic; `docs/native-backend-design.md` has the design.
- **Calls** are direct for known functions, and indirect through the closure record for closures.
- **Tail-call optimization.** A tail call is a jump (unless its stack arguments outgrow the caller's, or it is inside `try`/`while`); in the native backend a self tail call is a jump to the loop head, recycling the frame region. Every other call pushes a frame, and deep recursion survives because `main` runs on a thread with a very large reserved stack (`zyl_call_on_big_stack` in the runtime). This is how the implementation meets §14's stack-safety guarantee in practice.

### Linking

```bash
cc -no-pie out.s actor_runtime.o -o out -lpthread
```

`actor_runtime.o` is the runtime compiled once at `-O2` by `./boot.sh` or `install.sh`; when it is missing or older than `actor_runtime.c`, the source is compiled into the link with the same flags. `zyl build` appends the objects and libraries from the package's `native` block.

### Phase 11: hash finalization

`zyl build` and `zyl test` write `<name>.buildinfo` beside the binary:

```lisp
(buildinfo
  (compiler-hash "blake3:...")   ; BLAKE3 of the compiler binary
  (graph-hash "blake3:...")      ; from zyl.lock; empty without a lock
  (graph                         ; the resolved graph, sorted by name
    (package "acme/json" "1.4.0" "blake3:..."))
  (native-objects ("build/native/c_fast.c.o" "blake3:..."))  ; manifest order
  (icnf-hash "blake3:...")       ; BLAKE3 of the canonical ICNF text
  (asm-hash "blake3:...")        ; BLAKE3 of the emitted assembly (informational)
  (final-hash "blake3:..."))     ; BLAKE3 of compiler, graph, native and ICNF hashes
```

The final hash is linked into the binary as the read-only string
`zyl_build_hash` (section `.zyl_build`), so a binary identifies the
inputs it was built from: `objdump -s -j .zyl_build app` shows it.
Native object paths are package-relative, so the same package built in
two directories gives byte-identical binaries.

These are §31.12's four inputs, in its order, plus the resolved graph in canonical form. The ICNF hash is taken over `compiler/icnf_print.zyl`'s canonical text of the lowered program, including each node's codegen kind, so it changes exactly when what codegen sees changes.

A plain `zyl file.zyl` compile writes no buildinfo.

## 26.6 Compiler Flags

```
zyl <file.zyl> [-o out] [--emit-asm] [--contracts=P] [--error-format=json]
```

| Flag | Purpose |
|------|---------|
| `-o <file>` | output path; default: the source path without `.zyl` |
| `--emit-asm` | write assembly to the output path instead of linking. The name is used as given, so pass `-o prog.s` |
| `--contracts=P` | contract profile: `strict` (default), `debug`, `warn`, `off` or `production` (Chapter 24) |
| `--error-format=json` | report diagnostics as JSON lines |

No other flags exist. In particular there is no `--emit-ast`, `--emit-expanded`, `--emit-typed`, `--emit-regions`, `--emit-mono`, `--emit-icnf` or `--emit-opt`.

The argument parser is strict about order and loose about content:

- **The source file must come first.** In `zyl --emit-asm prog.zyl`, the flag is taken as the source path, and the compile fails with "cannot open source file".
- **An unrecognised word after the source becomes the output path.** `zyl prog.zyl --emit-icnf` builds a binary named `--emit-icnf`.

`zyl help` prints the usage summary, including the package subcommands (Chapter 25).

Environment variables that affect compilation:

- `ZYL_HOME` selects the directory that holds `stdlib/` and `actor_runtime.c`. When it has no `stdlib/`, the compiler tries `~/.zyl`, and then the compiler's own directory.
- `ZYL_DEBUG_STAGES`, when set, appends each stage name to `/tmp/dbg` as the compiler reaches it.
- `ZYL_STRICT_TYPES=report` prints type errors as `W_TYPE_STRICT` warnings instead of failing, for counting them.
- `ZYL_REGIONS=0`, `ZYL_INLINE=0`, `ZYL_REUSE=0` and `ZYL_MIR=0` turn off region inference, inlining, reuse and the native backend, for bisecting a suspected miscompilation; `ZYL_INLINE_LIMIT` sets the inlining size limit.
- `ZYL_MAX_MEMORY` caps the compiler's allocation (default 80% of available memory; `E_OUT_OF_MEMORY` beyond it).

Each is a fixed input: the same source under the same settings compiles to the same assembly.

## 26.7 Bootstrapping and the Fixed Point

The compiler is written in Zyl: `stdlib/compiler/*.zyl` plus `selfhost/driver.zyl`, built like any program from the entry file `selfhost/driver.zyl` through module resolution. No Rust is involved in any build. The original Rust implementation is frozen in `archive/rust-bootstrap-2026/` for the record; it cannot lex the current source.

### What `./boot.sh` does

```
0. copy stdlib/ and actor_runtime.c into build/boot/       (the source the stages resolve)
   cc -O2 -c actor_runtime.c                               → actor_runtime.o
1. cc links the committed seed build/boot/stage2.s        → stage1.bin
2. stage1.bin compiles selfhost/driver.zyl --emit-asm      → stage2_gen.s
   cmp stage2_gen.s stage2.s     (else: "reproduced asm differs from committed seed")
3. cc links stage2.s                                       → stage2.bin
4. stage2.bin compiles the same source                     → stage3.s
   cmp stage2.s stage3.s         (else: "FIXED POINT BROKEN")
5. smoke test: compile and run a small program
6. write the zyl-self wrapper and build zyl-lsp in build/boot/
7. refresh an existing install (~/.zyl) with uninstall.sh + install.sh
```

The comparisons are byte comparisons (`cmp`) of assembly text, not of binaries. Short SHA-256 prefixes are printed for display only. Each stage has a timeout, `ZYL_STAGE_TIMEOUT`, which defaults to 2400 seconds, and an allocation ceiling, `ZYL_STAGE_MEMORY`, which defaults to 4 GB. `ZYL_NO_INSTALL_REFRESH=1` skips step 7. The resulting assembly does not depend on where the checkout lives or which directory `boot.sh` runs from.

After a change to compiler source that alters the compiler's own output, re-seed:

```bash
./boot.sh --bootstrap-from-self   # iterate stageN → stageN+1 until two outputs match (≤ 10 rounds)
./boot.sh                         # verify a clean fixed point on the new seed
```

Reseeding fails only when the old seed cannot parse the new source at all. Land new syntax in two steps: teach the compiler to accept it, reseed, then use it in the compiler's own source. (`--bootstrap-from-rust` is retired.)

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
| `scripts/` | shell checks of the repository's own scripts (install, deterministic link, package index) |
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
| Which pass miscompiles | rebuild with `ZYL_MIR=0`, `ZYL_REUSE=0`, `ZYL_INLINE=0` or `ZYL_REGIONS=0` and compare the output |
| Link errors | `undefined reference to ...` means a C symbol that is not linked; an undefined Zyl function, including a private symbol reached through `*`, is `E_UNBOUND_VARIABLE` from the type checker |

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
| Deterministic compiler output | with care (`-frandom-seed`, path maps) | with care | assembly always; binaries identical for the same C toolchain (§26.10) |
| Phase isolation | ❌ | partial | ✅ (strict ordering, no back edges) |
| Self-hosting | ✅ | ✅ | ✅ (fixed point checked on every boot) |
| Reproducible package builds | external tooling | external tooling | `zyl.lock` + `.buildinfo` + embedded `zyl_build_hash` (§31.12; the lock records no native-object hashes) |
| Build verification | manual | manual | `./boot.sh` automated |
