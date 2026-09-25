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
- **Type inference, trait resolution and monomorphization are one
  pass**, `type_annotate.zyl`, run on the whole program just before ICNF
  lowering, after derive expansion and impl lifting. It is sound: every
  type error is reported and then the compile fails (spec §4.8).
- **Region inference** runs on the lowered IR after optimization, not
  on the AST before type inference.
- **Contract injection** happens during parsing (`convert-ast`), and
  **hash finalization** happens only for package builds, as a `zyl.buildinfo` file.

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
| 2 | `duplicate_check.zyl` | `E_DUPLICATE_DEFINITION`: two top-level `defn`s or `deftype`s with one name. `E_DUPLICATE_VARIANT`: a program type (outside the standard library) declaring a prelude constructor name (`Some`, `None`, `Ok`, `Err`, `Cons`, `Nil`) |
| 3 | `arity_check.zyl` | `E_ARITY_MISMATCH`: a direct call to a known, unshadowed top-level function with the wrong argument count. `E_MALFORMED_FORM`: a special form whose shape its parser rejected (an `EUnknown` node, which used to lower to the constant 0). The `ffi-call` shape checks (`E_FFI_SYMBOL_REQUIRED`, `E_FFI_TIMEOUT_REQUIRED`, more than 16 arguments) and `E_FFI_RESTRICTED`: an `ffi-call` naming a raw runtime entry (`ffi-raw-p`, `ffi_sigs.zyl`) outside the standard library |
| 4 | `mutability_check.zyl` | `E_MUT_CONFLICT`: `set!` on a name that is not a `let-mut` binding in scope |
| 5 | `exhaustiveness_check.zyl` | `E_NON_EXHAUSTIVE_MATCH`, `E_UNREACHABLE_MATCH_ARM` for ADT matches; skipped for a match whose constructor names are ambiguous across deftypes |
| 6 | `unused_check.zyl` | `W_UNUSED_FUNCTION`, `W_UNUSED_PARAMETER`, `W_UNUSED_VARIABLE`, `W_SHADOWED_BINDING` (warnings); `E_DUPLICATE_PARAMETER` (error). `_` and `_`-prefixed names are exempt |
| 7 | `secret_check.zyl` | Taint from `Secret` parameters: `E_CT_VIOLATION` (branch, index, divide), `E_SECRET_DEBUG` (`print`), `E_SECRET_ESCAPE` (`spawn`, `send`, `file-write`), `E_FFI_PIN_REQUIRED`. `declassify`, `ct-eq-bool` and `ct-eq-words-bool` remove taint |

Literal-pattern matches never reach the exhaustiveness check: the
parser requires a trailing `_` arm for them and lowers them to an `if`
chain.

## Phase 6: Derive expansion

**Implementation:** `derive.zyl` (`dv-expand-program`)

`(derive T Trait...)` becomes one `(impl Trait T ...)` block per trait,
for all six §5.6 traits: `Show` and `Debug` render `Variant(a, b)` or
`Struct { f: a }` through the trait on each field; `Eq.eq` is `==`;
`Clone.clone` returns the value; `Hash.hash` folds the fields' hashes;
`Ord.compare` orders variants by declaration, then fields
lexicographically. A field type without the trait, a `Secret` field for
a value trait, or a trait outside the six is `E_TRAIT_NOT_DERIVABLE`;
two written impls of one trait for one type are `E_DUPLICATE_IMPL`.

## Phase 7: Impl lifting

**Implementation:** `lift_impls.zyl` (`lift-impls`)

Each impl method becomes a top-level function named `Trait.method_Type`
(for example `OutputStream.write_Stdout`) whose first parameter is
annotated with the impl's type; the impl block stays for the type pass's
trait tables. This replaced `monomorphization.zyl` and
`type_inference.zyl`, which with an empty inference context did only
this. `closure_inline.zyl` (`ci-expand-program`) then runs as an
identity pass: beta-reducing a lambda into its callers is not hygienic,
and closures are real values (Phase 9).

## Phase 8: Type checking, trait resolution, specialization

**Implementation:** `type_annotate.zyl` (`ta-annotate`); runtime
signatures in `ffi_sigs.zyl`, `extern` declarations in `expr_inner.zyl`
**Rules:** spec §4.8–§4.10; `spec/05-types-and-inference.md`

Hindley–Milner inference (union-find, Tarjan SCCs, generalization of
top-level functions per component; local bindings monomorphic) over the
final `ExprInner` program. Each node's type goes to the node table
`node-types` (`node_tables.zyl`).

- **Every failure is an error.** A unification failure is a located
  `E_TYPE_MISMATCH`, a failed occurs check `E_INFINITE_TYPE`, a type the
  program does not determine `E_CANNOT_INFER`, an unknown name
  `E_UNBOUND_VARIABLE`. An argument that clashes with a parameter
  annotation or declared field type gets a `mismatched types` message
  labelled at the declaration. The pass types the whole program,
  printing every error, and then fails with the first error's code. The
  classes involved in a failure are poisoned only so one mistake is not
  reported repeatedly. `ZYL_STRICT_TYPES=report` prints the errors as
  `W_TYPE_STRICT` warnings and lets the compile continue.
- **Rules the pass enforces** beyond plain unification: conditions are
  Bool; `+ - * / %` take two Ints or two Floats, ordering two Ints,
  Floats or Strings (checked once the program is typed); statement forms
  are Unit; `main` is `() -> Int`; a `spawn` entry is `() -> a` and
  `send` needs an `Actor`; `file-open`'s mode is a literal fopen mode.
- **FFI.** An `ffi-call` to a `zyl_*` runtime symbol is typed by its
  signature in `ffi_sigs.zyl`; one to a foreign symbol by its `(extern
  "sym" (T ...) R)` declaration, whose types must be concrete and not
  Float. An undeclared foreign symbol, or a runtime symbol with no
  signature (except eleven string-producing ones), is `E_CANNOT_INFER`;
  an `extern` for a symbol the runtime exports is `E_FFI_RESTRICTED`.
  `ffi-pin` gives a `(Pin a)`, `ffi-unpin` takes it back to `a`, and
  pinning a function is `E_FFI_TYPE_NOT_PINNABLE`.
- **`def` and `struct-get`.** A top-level `def` is typed as its getter but not
  generalized. A `struct-get` whose record type is still unknown when
  several structs have the field is `E_CANNOT_INFER`.

At each SCC's close:

- A trait call `(Trait.method recv ...)`, or a method call `(recv.m
  ...)`, whose receiver type is known is renamed to `Trait.method_Type`
  (`node-calls`). A receiver that stays unknown is `E_CANNOT_INFER`; a
  missing impl or an unknown method is `E_TRAIT_NOT_FOUND`.
- A function that applies a trait method, `print`, an arithmetic or
  comparison operator or an equality to a value of type-variable type is
  trait-generic. Every call and every use as a value with concrete
  argument types gets its own instance `f~T1,T2` (argument types in
  order), typed and checked at those types; instances are appended to
  the program and the generic original is dropped, so no unspecialized
  body runs. More than 256 instances of one function is
  `E_CANNOT_INFER`.
- `print` of a value whose type has a `Show` impl prints `Show.show` of
  it (`node-shows`).
- `==`, `=`, `!=` and `assert-equal` on a known ADT or struct type become
  a call to a generated `(defn T.== (a b) ...)` (negated for `!=`),
  which is false for different variants and otherwise compares each
  field pair with `==`, so nested ADTs, Strings and Floats compare by
  content and recursive types work. A generic field makes it
  trait-generic, so `(List T)` gets an instance per element type. A type
  with a `Secret` field gets no equality function and keeps codegen's
  shallow comparison. `assert-equal`'s two sides have one type; a Float
  type selects its epsilon comparison.

There is no run-time trait dispatch: a trait call still unresolved at
lowering is `E_CANNOT_INFER` (`ic-trait-unresolved`, `icnf.zyl`).
`ZYL_DEBUG_TYPES=1` prints every function's scheme.

## Phase 9: ICNF lowering

**Output:** `(List Icnf)`, one `IFn` per function
**Implementation:** `icnf.zyl` (`ic-program`)

ICNF here is a tree-shaped instruction language, not SSA: nodes refer
to variables by name, and `ISet` mutates them. The node set is:

```
IConst IStr IFlt ILoad IBinop ICall IFfi IPrint IIf IWhile ISet ILet
ISeq IVariant IMatch IFn ICallClosure ITryCatch IStackVariant ISymAddr
IRegion
```

- `with-region` (recognised by `parse-with-region` in `expr_inner.zyl`,
  which raises `E_REGION_SPEC` for a malformed spec) lowers to `IRegion
  kind block align limit body` (kind 1 arena, 2 fixed; limit 0 none).

- `for` lowers to `IWhile`; `spawn` and `send` lower to `IFfi` calls to
  `zyl_actor_spawn` and `zyl_actor_send`.
- `ffi-call` is checked by `ffi-check-call` (literal symbol, positive
  literal timeout). A `zyl_*` runtime symbol becomes a direct `IFfi`
  with the timeout dropped; any other symbol becomes `IFfi
  "zyl_ffi_timed"` whose leading arguments are `ISymAddr sym` (the C
  symbol's address, through the GOT), the name, the timeout and the
  argument count, so the runtime can run the call on a worker thread
  and raise `E_FFI_TIMEOUT` when it overruns.
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
  String, Float) so codegen can print and compare it correctly. Every
  node's kind comes from its inferred type (`ta-kind`), and `ta-scalar`
  marks Int, Bool and Float nodes for region inference.
- Arithmetic with one operand: `(- x)` is `0 - x`, with a Float zero for
  a Float `x`; `(+ x)` and `(* x)` are `x`; any other one- or
  zero-operand arithmetic is `E_ARITY_MISMATCH`.
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

**Implementation:** `region_inference.zyl` (`ri-transform-fns`, then
`rg-regions`)
**Design:** `docs/regions-design.md`

Two steps over the optimized ICNF:

1. `ri-transform-fns`: in `(let x (Variant ...) body)`, if every use of
   `x` in `body` is either the scrutinee of a `match` or an argument to
   `print`, the `IVariant` becomes `IStackVariant` and is allocated in
   the function's own frame.
2. `rg-regions`, a whole-program escape analysis. Values belong to
   field-insensitive union-find object classes (runtime `zyl_uf_*`);
   nodes the type pass proves scalar (attribute table 5, `ta-scalar`)
   never join one. Every allocation site (`IVariant`, a call to a
   region-aware runtime function) and every call site gets a level:
   **L**, the frame's own region, released on return, before a tail
   jump, or when a caught panic or failed test unwinds it; **R**, the
   region the caller chose for the result (passed in the thread-local
   `zyl_cur_region`); or **H**, the process heap. Per-function parameter
   summaries (0 does not escape, 1 may reach the result, 2 escapes;
   bit 62 may allocate into the result region) are joined to a fixpoint
   over the program. Tail-call arguments are at least R; calls through a
   function value pass arguments as H; runtime functions not listed in
   `rg-ffi-kind`, and foreign `ffi-call`s, keep their arguments in the
   heap. The levels are stored in attribute table 4 (sites: 1 frame,
   2 result, 3 heap, `4 + k` `with-region` scope `k`; functions: flags
   plus 4) and printed by `icnf_print` as ` @r`, so the package-build
   ICNF hash covers them.

This phase raises `E_REGION_ESCAPE` (located) for a `(bytebuf Stack N)`
that is returned, stored, sent or passed to code that may keep it, and
for a value allocated inside `with-region` that outlives it.
`ZYL_REGIONS=0` at compile time makes every site H. Global and Circular
regions are not inferred; Pin allocation comes from `ffi-pin` and the
Pin arena in the runtime.

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
- **Regions:** a function flagged in attribute table 4 keeps six words
  above its parameters (`[rbp-8]` saved `rax`, `[rbp-16]` result region,
  `[rbp-48]` the region header `prev, bump, end, blocks`; parameters from
  `[rbp-56]`). Entry pushes the header on the thread-local
  `zyl_region_top` chain inline; exit and tail jumps pop it and call
  `zyl_region_free` only if a block was taken. Before each call the
  site's region is stored in `zyl_cur_region` (`fs`-relative). A
  variant at a region site is allocated with `zyl_ralloc(size, region)`;
  a string-producing runtime call at an annotated site goes to its `_r`
  entry point. `IRegion` pushes a scope header of the same layout.
- **Heap values:** variants and structs at heap sites are allocated with
  `zyl_heap_alloc`, which writes a hidden field-count header that
  `zyl_variant_eq` and `zyl_variant_cmp` read. `zyl_variant_eq` (tag plus
  raw field words) is used only for `==` on a variant-kind operand that
  Phase 8 did not rewrite to a `T.==` call (a type with a `Secret`
  field).
- **Symbols:** user functions get a `_ZYL_` prefix; canonical keys go
  through the runtime's `zyl_mangle_key`.
- **Entry stub:** `main` calls `zyl_save_args` and
  `zyl_ensure_arenas`, then runs `_ZYL_main` through
  `zyl_call_on_big_stack`, whose result becomes the exit code.
- An unbound identifier is reported by Phase 8; codegen's own
  `E_UNBOUND_VARIABLE` remains as a backstop. Output larger than the
  codegen buffer is `E_CODEGEN_BUFFER_FULL`.

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

## Phase 14: Contract injection (during parsing)

**Spec reference:** `zyl_specification.txt` §23

Contract forms are rewritten where every form is recognized,
`convert-ast` in `expr_inner.zyl`, so later phases see ordinary code:

- `(requires C)` and `(invariant C)` become `(assert-true C "E_CONTRACT_VIOLATION: ...")`;
  inside a `defn` body the message names the function.
- `(ensures C)` clauses of a `defn` move after the body, which is bound
  to `result`: `(let result BODY (begin checks... result))`.
- `(recover BODY arm...)` becomes `(try BODY (catch _rc_err CHAIN))`, CHAIN
  testing each arm's error code with `zyl_err_is` and re-raising if none matches.
- `(contracts P FORM)`, and a bare `(contracts P)` before a top-level form,
  convert that form under profile P (`off`/`production` drop every clause;
  `warn` checks become `(if C unit (zyl-contract-warn msg))`; every check
  is Unit); the build's
  profile comes from `--contracts=P` (global map 6).
- `(checkpoint E)` saves the outer `let-mut` variables E `set!`s, and
  restores them before re-raising if E raises.

## Phase 15: Hash finalization (package builds only)

**Spec reference:** `zyl_specification.txt` §31.12

`zyl build` and `zyl test` write `<out>.buildinfo` next to the binary:
the compiler's own hash, the graph hash from `zyl.lock`, the BLAKE3 of
each native object (package-relative path, manifest order), the BLAKE3
of the canonical ICNF text (`icnf_print.zyl`), and the final hash:
BLAKE3 over those four, newline-separated, in that order
(`drv-build-hashes`, `driver.zyl`). It also records the resolved graph
from the lock (`lk-graph-text`) and, for information, the assembly hash.
The final hash is appended to the assembly as `zyl_build_hash` in a
`.zyl_build` section, so the binary names its own inputs. A single-file
compile writes no buildinfo.

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
  -> [6]  Derive expansion              derive
  -> [7]  Impl lifting, closure inlining  lift_impls, closure_inline
  -> [8]  Type checking, trait resolution,
          specialization                type_annotate, ffi_sigs
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
| Checks | expanded `ExprInner` | derive expansion onward |
| Derive expansion | checked `ExprInner` | impl lifting onward |
| Impl lifting, closure inlining | `ExprInner` with derived impls | type checking onward |
| Type checking | lifted `ExprInner` | ICNF onward |
| ICNF lowering | lowered `ExprInner` | optimization onward |
| Optimization | ICNF | region inference onward |
| Region inference | optimized ICNF | codegen |
| Code generation | region-annotated ICNF | linking |

**Rule:** no phase may depend on a later phase. Determinism is required
at every step.
