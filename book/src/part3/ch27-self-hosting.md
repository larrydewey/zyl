# Chapter 27: Self-Hosting and the Compiler

Zyl's compiler is written in Zyl and compiles itself. This chapter explains the self-hosting architecture, the bootstrapping process, and the fixed point verification.

## 27.1 Self-Hosting Overview

**Self-hosting**: The Zyl compiler (`stdlib/compiler/*.zyl`, `selfhost/`) is written in Zyl and compiles itself end-to-end.

```
build/boot/stage2.s (committed seed)
   │  cc
   ▼
stage1.bin ──compiles──▶ stage2_gen.s   (must equal the committed stage2.s)
                                  │
stage2.bin (cc of stage2.s) ──compiles──▶ stage3.s
                                  │
                   stage2.s == stage3.s   (fixed point)
```

The build uses nothing but `cc`. `./boot.sh` (default, no arguments)
builds and verifies the whole compiler starting from the committed
seed `build/boot/stage2.s`. The Rust bootstrap that produced the very
first seed is archived at `archive/rust-bootstrap-2026/`, is not part
of any normal build, and is kept only as a fallback for reseeding
across a language change so large that the previous seed's compiler
cannot even parse the new source (§27.9).

## 27.2 Compiler Architecture

### The Zyl Compiler (`stdlib/compiler/`)

Thirty-seven modules. The phase order is the one
`stdlib/compiler/pipeline.zyl` runs (see Chapter 30 for the exact
sequence); the table groups them by what they do.

| Group | Modules |
|-------|---------|
| Front end | `lexer.zyl`, `parser.zyl`, `ast.zyl` (Token/Ast/Env/VTable ADTs), `expr_inner.zyl` (the `Expr`/`ExprInner` tree and the Ast-to-ExprInner converter), `sexp_balance.zyl` (delimiter balance with line/column) |
| Modules and packages (spec §31) | `module_resolver.zyl`, `qualify.zyl` (canonical symbol keys), `package.zyl`, `store.zyl`, `workspace.zyl`, `lock.zyl`, `index.zyl`, `mvs.zyl`, `cli.zyl`, `capability_check.zyl`, `resolver.zyl` (now only a small helper) |
| Macro expansion | `macro_expand.zyl` |
| Checks | `duplicate_check.zyl`, `arity_check.zyl`, `mutability_check.zyl`, `exhaustiveness_check.zyl`, `unused_check.zyl`, `secret_check.zyl` |
| Types | `type_system.zyl` (Type, Subst, TypeEnv, TraitContext, TypeInferer), `type_inference.zyl` (HM inference) |
| Middle | `monomorphization.zyl`, `trait_dispatch.zyl`, `closure_inline.zyl`, `assert_lowering.zyl` |
| ICNF and after | `icnf.zyl` (lowering), `optimization.zyl`, `region_inference.zyl` (escape analysis on ICNF), `codegen.zyl` (x86_64) |
| Driver support | `pipeline.zyl` (the phase sequence shared by the CLI and the REPL), `error_codes.zyl`, `error_report.zyl` |
| Not wired in | `contract_injection.zyl` — its accessors do not match the current `ExprInner` shapes, so it is not part of the bundle and the pipeline passes programs through unchanged (see the comment above `lower-exprs` in `pipeline.zyl`) |

### Self-Host Driver (`selfhost/`)

| File | Purpose |
|------|---------|
| `driver.zyl` | The `zyl` command line: argument handling, the package subcommands, `repl`, `eval`, linking |
| `lsp_main.zyl` | Entry point of the `zyl-lsp` language server (Chapter 35) |
| `assemble.py` | Bundles the compiler, the stdlib modules it needs, the REPL and `driver.zyl` into one source file |
| `zyl_selfhost_compiler.zyl` | That bundle: the file every boot stage compiles |

`assemble.py` strips `(use ...)` lines, converts each file to a
one-paren-per-line structural form so it can verify paren depth,
removes every `main` except `driver.zyl`'s, drops duplicate `defn`s
(first occurrence wins), and finally collapses all whitespace runs to a
single space. The committed bundle is therefore a single ~680 KB line.

### Rust Bootstrap (archived: `archive/rust-bootstrap-2026/`)

Frozen, not built by anything in the normal workflow. See
`archive/rust-bootstrap-2026/README.md`.

## 27.3 Bootstrapping Process (`boot.sh`)

Default flow — verifies the fixed point, no Rust anywhere:

```bash
./boot.sh
# 1. cc links the committed seed build/boot/stage2.s -> stage1.bin
# 2. stage1 compiles selfhost/zyl_selfhost_compiler.zyl -> stage2_gen.s
#    (must byte-match the committed seed); stage2.s is linked -> stage2.bin
# 3. stage2 compiles the same source -> stage3.s
# 4. stage3.s must be byte-identical to stage2.s (fixed point)
# 5. smoke test: stage2 compiles, links and runs a small program
# 6. copies stdlib/ and the runtime into build/boot/, writes the
#    build/boot/zyl-self wrapper, and builds build/boot/zyl-lsp
```

Each link is `cc -no-pie <asm> runtime/actor_runtime.c -o <bin> -lpthread`.
The script exports `ZYL_HOME=build/boot` so the build resolves the
standard library from this checkout rather than from an installed
`~/.zyl`. Each stage runs under a timeout (`ZYL_STAGE_TIMEOUT`, default
2400 seconds); the whole two-stage verification currently takes on the
order of half a minute.

Reseeding — needed only when a compiler source change moves the fixed
point (`FIXED POINT BROKEN` or "reproduced asm differs from committed
seed"):

```bash
python3 selfhost/assemble.py     # re-bundle stdlib/compiler/*.zyl
./boot.sh --bootstrap-from-self  # reseed via the self-hosted compiler
./boot.sh                        # verify the new seed is clean
git add -f build/boot/stage2.s build/boot/stage2.bin && git commit
```

`--bootstrap-from-self` links the *current* committed seed and repeats
the stage1-compiles-source step, but instead of requiring the result to
match the old seed, it iterates — compiling its own output again and
again — until two consecutive rounds agree, up to 10 rounds. This works
because a compiler that just compiled a behavior change doesn't yet
exhibit that behavior itself (it was built by logic that predates the
change); the *next* round, compiled by a binary that has the change
baked in, does. Starting from a seed many commits stale, it was
verified to converge to the same fixed point the Rust bootstrap
produced for the same source.

### Stages Explained

| Stage | Compiler | Compiles | Output |
|-------|----------|----------|--------|
| 1 | `cc` links the committed seed | — | `stage1.bin` |
| 2 | `stage1.bin` | `selfhost/zyl_selfhost_compiler.zyl` | `stage2_gen.s` (checked against the seed); `stage2.bin` |
| 3 | `stage2.bin` | same source | `stage3.s` |

**Fixed point**: `stage2.s == stage3.s` (byte-identical assembly)

## 27.4 Why Self-Hosting Matters

1. **Compiler correctness**: If the compiler compiles itself correctly, it is likely correct for other code
2. **Language completeness**: Self-hosting exercises a large part of the language
3. **Determinism proof**: The fixed point verifies determinism end-to-end
4. **Dogfooding**: Compiler authors use their own language daily
5. **Bootstrapping trust**: No hidden dependency on another compiler

The fixed point proves the compiler can compile *itself*; it says
nothing about programs the compiler never sees. That is what the
regression suite is for (`./run_regression_tests.sh --full`, which also
runs every regression and smoke test through the REPL's ICNF
interpreter and diffs the two outputs).

## 27.5 Constraints for Self-Hosted Code

Code in `stdlib/compiler/` and `selfhost/` is compiled by the previous
generation of itself, so it has to avoid constructs that generation
miscompiles. The current list (the full, annotated version is
`rules/boot-lifted-constraints.md` in the separate zyl-skill repository):

```
1. Function arity > 6 works (lifted 2026-08-25: stack-passed args)
2. match in value position works (lifted 2026-08-25)
3. Parens must balance per top-level form -- and per FILE, since the
   bundle concatenates files and a deficit in one can be masked by
   another
4. One deftype per name
5. buf-append appends at strlen(dst); use fresh zeroed buffers
6. Do not combine two calls directly in one binop, (+ (f x) (g y));
   bind each call with let first. In a match arm, the shape
   "constant plus several calls" is rejected with E_MATCH_ARM_COMPLEX
7. A library module meant to be `use`d must not define `main`
8. `use` every module whose types you construct, even when the bundle
   happens to make them visible
```

Two items that older lists carried no longer apply: `_` is now the
discard everywhere (the `d1`, `d2` dummies were renamed away), and
wildcard match arms are used throughout the compiler source.

Rule 6 is a caution, not a reproduced bug: a direct test of
`(+ (f 3) (g 4))`, inside and outside a match arm, compiles correctly
with the current compiler. The compiler source still follows it, and it
is cheap to keep.

## 27.6 Source Layout and Paren Balance

Hand-written compiler source uses ordinary Lisp layout. Balance is
enforced mechanically rather than visually, in two places:

- `stdlib/compiler/sexp_balance.zyl` runs before parsing on every
  compile and reports an unclosed opener, an unexpected closer, a
  mismatched bracket or an unterminated string with file, line, column
  and a fix-it hint.
- `selfhost/assemble.py` re-renders every file in structural form
  (each paren on its own line, indented by depth) and checks the depth
  of the whole bundle before collapsing it back to one line.

Neither catches a per-file deficit that another file in the bundle
cancels out, which is why rule 3 above says "per file".

## 27.7 Boot Fixed Point History

| Milestone | Date | Notes |
|-----------|------|-------|
| Stage 1 compiles own source | 2026-08-24 | First boot build |
| Self-hosting fixed point | 2026-08-25 | Stage1→Stage2→Stage3 deterministic |
| Type inference ported to Zyl | 2026-09-10 | HM + capabilities + traits |
| Monomorphization ported to Zyl | 2026-09-10 | Full mono using type inference |
| P3.5 complete | 2026-09-10 | Zyl self-hosts all phases |
| Fixed point solid, cargo-free `./boot.sh` | 2026-09-16 | `stage2.s == stage3.s`, no cargo in the default flow |
| Full regression parity, Rust evicted | 2026-09-17 | 43/43 via self-hosted compiler; `src/` archived; reseeding self-hosted too (`--bootstrap-from-self`) |
| Package system (spec v5.0 §31) in the bundle | 2026-09-23 | Bundle grows by half, including the Ed25519 stack index verification needs |
| Type-inference exponential removed | 2026-09-23 | A boot stage drops from about ten minutes to seconds |
| REPL and ICNF interpreter in the bundle | 2026-09-23 | `zyl repl`, `zyl eval`; C calls get an aligned stack (Chapter 29) |

## 27.8 Debugging the Bootstrap

### Common Failure Modes

| Symptom | Likely Cause |
|---------|--------------|
| "reproduced asm differs from committed seed" | The compiler source changed its own output: reseed (§27.3). The script's message still suggests `--bootstrap-from-rust`; `--bootstrap-from-self` is the normal path |
| `FIXED POINT BROKEN` | Stage 2 and stage 3 disagree: non-determinism, or a behavior change that needs a reseed |
| Stage 2 crashes | Miscompilation of the compiler by stage 1 |
| A later file's definitions vanish | Paren imbalance in an earlier file (§27.6) |
| Undefined `_ZYL_...` symbol only when a module is compiled standalone | A missing `use` hidden by the bundle (rule 8) |

### Debugging Commands

```bash
# Compare assembly
diff build/boot/stage2.s build/boot/stage3.s

# Run stage2 on the compiler source again, outside the repo
build/boot/stage2.bin selfhost/zyl_selfhost_compiler.zyl \
    -o /tmp/test-stage3.s --emit-asm
diff build/boot/stage2.s /tmp/test-stage3.s

# Trace which phase a compile reaches (appends to /tmp/dbg)
ZYL_DEBUG_STAGES=1 build/boot/zyl-self prog.zyl -o /tmp/prog
```

## 27.9 Rust Eviction: Done

This was tracked as future work in earlier drafts of this chapter; as
of `docs/rust-eviction-plan.md`'s latest survey, it's complete:

1. ✅ Every compiler phase ported to Zyl (`stdlib/compiler/*.zyl`)
2. ✅ Full regression suite passes through the self-hosted compiler
   (43/43 at eviction; the suite has since grown to 121 tests)
3. ✅ `./boot.sh` builds and verifies with nothing but `cc`
4. ✅ Reseeding no longer needs Rust either (`--bootstrap-from-self`, §27.3)
5. ✅ `src/` archived to `archive/rust-bootstrap-2026/`, `Cargo.toml`/
   `Cargo.lock`/`target/` removed from the active tree

The archived Rust bootstrap remains available as a fallback for the one
case self-hosted reseeding can't solve on its own: a language change so
large the previous seed's compiler can't even *parse* the new source
(new syntax, not just new behavior). See
`archive/rust-bootstrap-2026/README.md`.
