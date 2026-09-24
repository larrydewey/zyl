# Compiler Pipeline

## Overview

The Zyl compiler is a deterministic, multi-phase compiler from
S-expression source to an x86_64 native binary. It is written in Zyl:
the phases live in `stdlib/compiler/*.zyl`, and
`stdlib/compiler/pipeline.zyl` is the one place that fixes their order.
Every front end calls it: the CLI (`selfhost/driver.zyl`), `zyl eval`,
and the REPL. No phase depends on output from a later phase.

**Canonical reference:** `zyl_specification.txt` §22
**Navigation:** `spec/11-icnf-ir.md`, `spec/13-code-generation.md`
**File-level map:** `docs/codebase-map.md`

`pipeline.zyl` exposes three entry points:

| Function | Runs | Used by |
|---|---|---|
| `compile-to-exprs` | Balance check through the checks; returns checked `ExprInner` | `compile-to-fns` |
| `compile-to-fns` | Everything through region inference; returns `(List Icnf)` | `zyl eval`, the REPL |
| `compile-to-asm` | `compile-to-fns` plus code generation; returns assembly text | the CLI, `zyl build`, `zyl test` |

Errors are raised with `zyl_panic` and a located `error[CODE]` message.
The REPL catches them with `try`; the CLI lets them end the process.
Setting `ZYL_DEBUG_STAGES` makes each stage append its name to
`/tmp/dbg` as it starts.

### Where the implementation departs from the spec's phase list

The spec's §22 lists eleven phases. The self-hosted compiler runs them
in a different shape, and this document describes what the code does:

- **Module resolution** is its own step between parsing and macro
  expansion, and it rewrites every name to a canonical key (§31.2).
- **A block of checks** runs after macro expansion and before type
  inference.
- **Type inference** is best-effort. It records function signatures and
  return types that monomorphization consumes, but a type mismatch does
  not stop the compile (see Phase 5).
- **Region inference** runs on the lowered IR after optimization, not
  on the AST before type inference.
- **Trait dispatch, closure inlining and assert lowering** are
  source-to-source rewrites between monomorphization and ICNF lowering.
- **Contract injection** is not wired in, and **hash finalization**
  happens only for package builds, as a `zyl.buildinfo` file.

---

## Phase 1: Balance check

**Input:** source buffer
**Implementation:** `sexp_balance.zyl` (`sb-check-string`), called from
`compile-check-balance`

A single pass tracks a stack of expected closers. The first unexpected
closer, mismatched pair or unclosed opener is reported with its
position before the parser runs, because the parser only knows that it
ran out of input.

## Phase 2: Lexing and parsing

**Output:** a `(List Ast)`
**Implementation:** `lexer.zyl`, `parser.zyl`, `ast.zyl`
(`zyl-parse-file`)

1. The lexer produces a `(List Token)`: identifiers, integers, floats,
   strings, booleans, symbols, keywords, and the three bracket pairs.
   `;` comments are skipped. Every token carries its byte offset.
2. The reader is dispatch-free: every parenthesized form becomes an
   `AList`, and no special form is recognized here.
3. The reader records each node's offset in the runtime's span table,
   keyed by the node's address. Every later rewriting pass copies the
   span onto its replacement (`zyl_span_copy`), which is how a
   codegen-stage error still reports `file:line:col`.

## Phase 3: Module resolution and qualification

**Implementation:** `module_resolver.zyl`
(`mr-resolve-program-full`), `qualify.zyl`, `package.zyl`, `mvs.zyl`,
`lock.zyl`, `store.zyl`

Resolution works on the raw `Ast`, in two passes:

1. **Discovery** walks the `use` graph depth-first from the root
   module, parsing each file once and detecting cycles
   (`E_MODULE_CYCLE` within a package, `E_PKG_CYCLE` across packages).
   `stdlib/` is found relative to the bundle directory the compiler
   runs from.
2. **Qualification** rewrites every top-level name to its canonical key
   `<package>@<major>::<module>::<symbol>`, using a table built from the
   whole discovered graph so the result does not depend on traversal
   order. Visibility is enforced here (`E_PKG_PRIVATE_SYMBOL`).

The result is converted to `ExprInner` by `expr_inner.zyl`'s
`convert-ast`, which is where special forms (`defn`, `let`, `match`,
`for`, `spawn`, ...) are recognized. Resolution also returns the
package's capability grants for Phase 5.

## Phase 4: Macro expansion

**Implementation:** `macro_expand.zyl` (`me-expand-program`)

1. Every top-level `defmacro` (or `macro`) is collected into a table and
   removed from the program.
2. At each call to a known macro, the arguments are rewritten first, so
   a nested macro call inside an argument expands before the outer one.
   The macro body is then rewritten with each formal parameter replaced
   by the unevaluated argument expression. The result is walked again,
   so a macro whose body calls another macro expands fully.
3. **Hygiene.** Every binder the macro body introduces is renamed to a
   fresh `name__hygN`; `N` is a counter threaded through the walk in
   source order, so expansion is deterministic. Arguments keep their
   names. Free body names were already qualified by module resolution;
   one that is a local variable at the call site is
   `E_UNBOUND_VARIABLE` rather than captured.
4. **Checks.** A macro called during its own expansion is
   `E_MACRO_NON_TERMINATION`; a wrong argument count is
   `E_ARITY_MISMATCH`; a repeated macro name (or a macro and function of
   one name in one file) is `E_DUPLICATE_DEFINITION`; a non-top-level
   `defmacro` is `E_MACRO_ILLEGAL_ACCESS`.

The walk covers every `ExprInner` shape, so a macro call expands in any
position, and a parameter is substituted in binder and `set!`-target
positions as well as in value position.

## Phase 5: Checks

**Implementation:** `compile-run-checks` in `pipeline.zyl`

All of these walk the macro-expanded `ExprInner` program, in this
order. Each is conservative: a shape it does not walk misses a
diagnostic rather than rejecting a valid program.

| Order | File | Reports |
|---|---|---|
| 1 | `capability_check.zyl` | A package using `io`, `ffi`, `actor`, `secret`, `native` or `unsafe` without declaring it (§31.9). The implicit stdlib and a lone file with no `zyl.pkg` are not policed |
| 2 | `duplicate_check.zyl` | `E_DUPLICATE_DEFINITION`: two top-level `defn`s or `deftype`s with one name |
| 3 | `arity_check.zyl` | `E_ARITY_MISMATCH`: a direct call to a known, unshadowed top-level function with the wrong argument count |
| 4 | `mutability_check.zyl` | `E_MUT_CONFLICT`: `set!` on a name that is not a `let-mut` binding in scope |
| 5 | `exhaustiveness_check.zyl` | `E_NON_EXHAUSTIVE_MATCH`, `E_UNREACHABLE_MATCH_ARM` for ADT matches; skipped for a match whose constructor names are ambiguous across deftypes |
| 6 | `unused_check.zyl` | `W_UNUSED_FUNCTION`, `W_UNUSED_PARAMETER`, `W_UNUSED_VARIABLE`, `W_SHADOWED_BINDING` (warnings); `E_DUPLICATE_PARAMETER` (error). `_` and `_`-prefixed names are exempt |
| 7 | `secret_check.zyl` | Taint from `Secret` parameters: `E_CT_VIOLATION` (branch, index, divide), `E_SECRET_DEBUG` (`print`), `E_SECRET_ESCAPE` (`spawn`, `send`, `file-write`), `E_FFI_PIN_REQUIRED`. `declassify`, `ct-eq-bool` and `ct-eq-words-bool` remove taint |

Literal-pattern matches never reach the exhaustiveness check: the
parser requires a trailing `_` arm for them and lowers them to an `if`
chain.

## Phase 6: Type inference

**Implementation:** `type_system.zyl`, `type_inference.zyl`
(`collect-definitions`)

`collect-definitions` walks the top-level forms once. For each `defn`
it infers the body's type and records the function's parameter and
return types; it also records deftypes, structs, traits, impl blocks,
aliases and `derive` declarations. The resulting `TypeInferer` is what
monomorphization is built from (`mono-context-new`).

Inference is best-effort. A mismatch such as `(+ 1 "a")` degrades to
`TUnit` rather than failing, so it compiles. The errors this phase does
raise are FFI-related: `E_INVALID_CAPABILITY` for a non-pinnable FFI
argument and `E_BYTEBUF_NOT_PIN`. Several name lookups in this module
compare strings with `=`, which is a pointer comparison, so some
lookups never match; `stdlib/lsp/compiler_bridge.zyl`'s header
documents the problem.

## Phase 7: Monomorphization and trait dispatch

**Implementation:** `monomorphization.zyl` (`monomorphize`),
`trait_dispatch.zyl` (`td-expand-program`)

1. Each generic function is instantiated per concrete use. A
   specialization's name is the base name plus its type names, sorted
   and joined with `_` (`canonical-name-from-type-map`), so naming is
   deterministic.
2. Impl method bodies are lifted to top-level functions named
   `Trait.method_Type` (for example `OutputStream.write_Stdout`).
3. Trait dispatch rewrites each call `(Trait.method recv args...)` into
   a `match` on the receiver that calls the `Trait.method_Type` for the
   receiver's runtime tag. No static type information is needed.

## Phase 8: Source-level lowering

**Implementation:** `closure_inline.zyl` (`ci-expand-program`),
`assert_lowering.zyl` (`al-expand-program`)

- **Closure inlining:** retired; `ci-expand-program` is an identity
  pass (beta-reducing a lambda into its callers is not hygienic, and
  closures are real values now, see Phase 9).
- **Assert lowering:** `(assert-equal l r)` where either side looks like
  an ADT or struct value becomes a `zyl_variant_eq` call. That
  comparison is shallow: tag plus each field as a raw word.

## Phase 9: ICNF lowering

**Output:** `(List Icnf)`, one `IFn` per function
**Implementation:** `icnf.zyl` (`ic-program`)

ICNF here is a tree-shaped instruction language, not SSA: nodes refer
to variables by name, and `ISet` mutates them. The node set is:

```
IConst IStr IFlt ILoad IBinop ICall IFfi IPrint IIf IWhile ISet ILet
ISeq IVariant IMatch IFn ICallClosure ITryCatch IStackVariant
```

- `for` lowers to `IWhile`; `spawn` and `send` lower to `IFfi` calls to
  `zyl_actor_spawn` and `zyl_actor_send`.
- A lambda whose body is closed is hoisted to a top-level function. A
  capturing lambda becomes a `[tag, code, env]` value. Every call
  through a local is an indirect call that tells the two apart by the
  tag word and passes the env (or 0) as one extra trailing argument
  (`cg-call-indirect`), so either kind can be passed, stored and
  returned. `ICallClosure` is no longer produced.
- `try`/`catch` lowers to `ITryCatch`, which uses the runtime's
  `zyl_try_push`/`zyl_try_pop` frames and `setjmp`; `zyl_panic` unwinds
  to the nearest one.
- `IFn` carries each parameter's representation kind (Int/pointer,
  String, Float) so codegen can print and compare it correctly.
- Top-level `test` and `run-tests` forms are gathered into a generated
  `main`; mixing them with an explicit `(defn main ...)` is
  `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`.

## Phase 10: Optimization

**Implementation:** `optimization.zyl` (`opt-optimize-fns`)

One bottom-up walk performs two safe rewrites:

1. **Constant folding** of `IBinop` arithmetic (opcodes 0-4) and
   comparisons (5-10) whose operands are both integer constants.
   Bitwise operators, floats, and division or remainder by a constant
   zero are not folded, so a division by zero still fails at run time.
2. **Dead-branch elimination:** an `IIf` whose condition folds to a
   constant keeps only the taken branch.

Nothing is reordered and no side effect is removed.

## Phase 11: Region inference

**Implementation:** `region_inference.zyl` (`ri-transform-fns`)

A narrow escape analysis on ICNF. In `(let x (Variant ...) body)`, if
every use of `x` in `body` is either the scrutinee of a `match` or an
argument to `print`, the `IVariant` becomes `IStackVariant` and is
allocated in the function's own frame. Every other value keeps the
heap path. No other region (Global, Circular, Pin) is inferred here;
Pin allocation comes from `ffi-pin` and the Pin arena in the runtime,
and `E_REGION_ESCAPE` is defined but never raised.

## Phase 12: Code generation

**Output:** GAS assembly, `.intel_syntax noprefix`
**Implementation:** `codegen.zyl` (`cg-program`, via `codegen-fns`)

- **Stack-machine discipline:** every expression leaves its value in
  `rax`; a binary operator pushes its left operand while the right is
  evaluated. There is no register allocator.
- **Calls:** up to six arguments in the SysV registers (`rdi rsi rdx
  rcx r8 r9`), spilled to `[rbp-8*(i+1)]` in the prologue. Arguments
  are evaluated left to right. Every C call of arity six or less aligns
  `rsp` to 16 bytes first.
- **Floats** travel as bit patterns in `rax` and move to `xmm0`/`xmm1`
  for SSE arithmetic. `print` chooses `%lld`, `%f` or `%s` from the
  operand's kind.
- **Heap values:** variants and structs are allocated with
  `zyl_heap_alloc`, which writes a hidden field-count header that
  `zyl_variant_eq` reads.
- **Symbols:** user functions get a `_ZYL_` prefix; canonical keys go
  through the runtime's `zyl_mangle_key`.
- **Entry stub:** `main` calls `zyl_save_args` and
  `zyl_ensure_arenas`, then runs `_ZYL_main` through
  `zyl_call_on_big_stack`, whose result becomes the exit code.
- An unbound identifier is reported here as `E_UNBOUND_VARIABLE`, and
  output larger than the codegen buffer is `E_CODEGEN_BUFFER_FULL`.

## Phase 13: Linking

**Implementation:** `cli-link-command` in `selfhost/driver.zyl`, `cc`

The CLI writes `<out>.s` and runs:

```
cc -no-pie <out>.s actor_runtime.c -o <out> -lpthread
```

from the bundle directory, where `actor_runtime.c` sits. A package
build appends its native objects and libraries (§31.10). With
`--emit-asm`, the assembly is written to the output path and nothing is
linked.

## Phase 14: Contract injection (not wired in)

**Spec reference:** `zyl_specification.txt` §23

`contract_injection.zyl` exists but is not in the bundle and is not
called; its accessors do not match the real `ExprInner` shapes (see the
comment above `lower-exprs` in `pipeline.zyl`). `requires`, `ensures`,
`checkpoint` and `recover` parse and lower to their inner expression,
which is evaluated and not checked.

## Phase 15: Hash finalization (package builds only)

**Spec reference:** `zyl_specification.txt` §31.12

`zyl build` and `zyl test` write `<out>.buildinfo` next to the binary:
the compiler's own hash, the graph hash from `zyl.lock`, a native-object
list, and the BLAKE3 hash of the emitted assembly. The assembly hash
stands in for an ICNF hash because ICNF has no serialized form; this is
a recorded deviation. A single-file compile writes no buildinfo, and
the graph hash is not mixed into the binary.

---

## Pipeline summary

```
Source (.zyl)
  -> [1]  Balance check                 sexp_balance
  -> [2]  Lex, read                     lexer, parser        -> (List Ast)
  -> [3]  Resolve modules, qualify      module_resolver, qualify
          convert-ast                   expr_inner           -> ExprInner
  -> [4]  Macro expansion               macro_expand
  -> [5]  Checks: capability, duplicate, arity, mutability,
          exhaustiveness, unused, secret
  -> [6]  Type inference                type_inference       -> TypeInferer
  -> [7]  Monomorphization, trait dispatch
  -> [8]  Closure inlining, assert lowering
  -> [9]  ICNF lowering                 icnf                 -> (List Icnf)
  -> [10] Optimization                  optimization
  -> [11] Region inference              region_inference
          (compile-to-fns stops here; zyl eval and the REPL interpret this)
  -> [12] Code generation               codegen              -> assembly
  -> [13] Linking                       cc + actor_runtime.c -> binary
  -> [15] zyl.buildinfo                 package builds only
```

---

## Phase ordering constraints

Each step consumes only the output of the steps above it:

| Step | Consumes | Must not depend on |
|---|---|---|
| Balance check | source text | everything after it |
| Parsing | source text | module resolution onward |
| Module resolution | raw `Ast` | macro expansion onward |
| Macro expansion | qualified `ExprInner` | the checks onward |
| Checks | expanded `ExprInner` | type inference onward |
| Type inference | checked `ExprInner` | monomorphization onward |
| Monomorphization, trait dispatch | `ExprInner` + `TypeInferer` | lowering onward |
| Closure inlining, assert lowering | monomorphized `ExprInner` | ICNF onward |
| ICNF lowering | lowered `ExprInner` | optimization onward |
| Optimization | ICNF | region inference onward |
| Region inference | optimized ICNF | codegen |
| Code generation | region-annotated ICNF | linking |

**Rule:** no phase may depend on a later phase. Determinism is required
at every step.
