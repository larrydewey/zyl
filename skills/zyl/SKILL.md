---
name: zyl
description: >
  Expert Zyl language knowledge for writing, reviewing, and debugging Zyl
  code — especially the self-hosted compiler (stdlib/compiler, selfhost/).
  Covers syntax, the bootstrap constraint list, ADT/match idioms, FFI and
  arena patterns, codegen pitfalls, module resolution, and debugging
  recipes for the stage1->stage2 pipeline. Use when editing any *.zyl
  file, the assembled boot source, or when diagnosing self-hosting
  regressions.
triggers:
  - .zyl files
  - selfhost, stage1, stage2, stage3, boot build
  - stdlib/compiler, icnf, cg-, ic-
---

# Zyl Expert Guide

Zyl is a deterministic Lisp systems language: S-expressions, Hindley-Milner
inference with capability types (TCap/TMut), region-based memory, actor
concurrency, SSA IR (ICNF), x86_64 codegen. The compiler is written in Zyl
itself and is now self-hosting end to end — no Rust in the default build
path (see §5). Strict left-to-right evaluation everywhere; same input must
produce byte-identical output.

## 1. Syntax essentials

```lisp
; comment to end of line

(defn name (param1 param2) body)          ; function definition
(let name value body)                      ; immutable local (body-scoped)
(let-mut name value body)                  ; mutable local (use with set!)
(set! name new-value)                      ; mutation
(if cond then else)                        ; else required in value position
(while cond body)                          ; statement loop
(for (i 0) (< i 10)                        ; (for (name init) cond body): NO step
  (begin ... (set! i (+ i 1))))            ;  clause -- the body must advance i
(begin e1 e2 ... en)                       ; sequence, value = last expr
(match scrutinee                           ; exhaustiveness checked at compile time
  (Variant pat1 pat2 body)
  (_ fallback-body))                       ; `_` is the catch-all/discard
(match n                                   ; literal, OR, range and guarded arms
  (0 "zero")                               ;  (desugared to an if-chain)
  (1 2 "one or two")
  ((range 3 9) "small")
  (10 (when verbose) "ten, verbose")
  (_ "other"))
(try expr (catch e handler))               ; `error` unwinds to the nearest try

(deftype Name (VariantA field-type...)     ; field types are type NAMES
            (VariantB)                     ; nullary variant
            (ListLike T (Listlike-rest)))  ; recursive = pointer fields

(defstruct Point x y)                      ; struct (immutable fields);
                                           ;  typed: (defstruct P (x Int) (y Int))
(struct-get p "x")                         ; field access (string key!)
(make-Point 5 7)                           ; constructor

(trait Show (show self))
(impl Show Int (defn show (self) ...))
(Show.show receiver args...)               ; trait dispatch by receiver type

(test "name" body)                         ; top-level test (no explicit main
(run-tests)                                ;  needed — see §3 test idiom)

(ffi-call "c_function_name" arg1 arg2 timeout)   ; timeout literal LAST --
                                           ;  lowering drops the last arg
                                           ;  unconditionally (see §3)
(use module/path)                          ; module import (self-hosted
                                            ;  driver resolves this now —
                                            ;  see §5)
```

Gotchas that look like other Lisps but aren't:

- `struct-get` takes a STRING field key, not a symbol.
- `let` requires a body: `(let x v body)` — there is no bare binding.
- Booleans are ints at runtime (0/1); `true`/`false` are literals.
- Strings are pointers to NUL-terminated bytes; string literals are fine,
  built-up strings live in arena buffers referenced as `Int`.
- No implicit truthiness beyond int compare — use `(= x 0)` etc.
- `_` is the only discard: patterns, parameter lists (`(defn f (_ _) ...)`
  is legal) and `(let _ (side-effect) body)`. Any `_`-prefixed name is
  also exempt from the unused/shadowing warnings.
- Top-level `(def name value)` in a compiled file does not create a
  readable global (a reference to it is `E_UNBOUND_VARIABLE`); use a
  zero-argument `defn`. (At the REPL prompt `def`
  does bind a value.)

## 2. THE BOOTSTRAP CONSTRAINT LIST

The self-hosted codegen (stdlib/compiler/codegen.zyl) has restrictions
that must be followed — violations miscompile SILENTLY, in stage>=2
binaries (i.e. anything built by the self-hosted compiler, which is the
default build now, not just some legacy fallback).

1. **(LIFTED 2026-08-25) Function arity.** Stack-passed args >6 now work
   end-to-end (`cg-call-args` scratch-slot staging + `cg-param-spills`
   stack loads). Prefer <=6 params anyway for readability.
2. **(LIFTED 2026-08-25) Match in value position works**: let bindings,
   binop args, if branches, call args, nested arm-body matches, multiple
   matches per defn — all verified through stage>=2
   (tests/regression/match-value-position.zyl). Prefer flat code anyway;
   deep nesting is where residual codegen bugs live.
3. **Spell every constructor exactly.** An arm head that is not a known
   constructor of any deftype is treated as a catch-all binding — with or
   without fields. Anywhere but the last arm that is rejected
   (`E_UNREACHABLE_MATCH_ARM`); as the LAST arm, a misspelled constructor
   silently matches everything the earlier arms did not. A missing
   variant with no catch-all is `E_NON_EXHAUSTIVE_MATCH`. Use `_` for a
   deliberate wildcard; the old `d1`/`d2` dummy names are gone from the
   tree and should not come back.
4. **Parens must balance per top-level form.** A missing closer silently
   nests every following defn inside the broken one (they vanish from
   compiled output) — a real instance of this shipped in error_codes.zyl
   for a while (14-paren deficit in its catalog, only caught once
   something finally called into it; see PROGRESS.md 2026-09-19). The
   compiler now catches a net imbalance in real SOURCE at compile time
   (`stdlib/compiler/sexp_balance.zyl`, run first by
   `compile-check-balance` in `stdlib/compiler/pipeline.zyl` and by
   `zyl-parse` — exact line/col + a fix-it hint). A misplaced paren that
   leaves the file net-balanced is NOT a balance error; the common shape,
   a `defn` whose parameter list swallows its body, is now
   `E_MALFORMED_PARAMETER`, but other shapes can still silently re-nest
   forms. It also does NOT catch a per-file deficit inside a file that
   still nets to zero once concatenated with others in
   `selfhost/assemble.py`'s bundle — verify a hand-edited compiler-stdlib
   file balances on its own, not just that the whole bundle does.
5. **One deftype per name, ever.** Duplicate deftypes create incompatible
   constructor identities; pattern matches against them silently fail.
6. ~~Cross-module shared list helpers~~ LIFTED (2026-08-25): per-site
   generic inference works; `list-head-or` is shared across element
   types in codegen.zyl (verified via boot fixed point). Prefer flat
   code and short let-chains regardless.
7. **buf-append appends at strlen(dst)** (true append). Fresh zeroed
   buffers only — appending to a non-empty buffer accumulates (this is
   what you want for output buffers; NOT copy semantics).
8. **Match arms: no constant combined with two or more calls in one
   binop.** `(A n m (+ 1 (f n m) (g n)))` is rejected at compile time
   with `E_MATCH_ARM_COMPLEX`; nest through a helper instead
   (`(icnf-add2 1 (icnf-add2 (f x) (g y)))`) or bind the calls with
   `let`. The older, broader rule — any binop whose operands are TWO
   calls silently computes 0 in stage>=2 binaries — no longer
   reproduces: as of 2026-09-23, `(+ (f 3) (g 4))`, `(* (f 2 3) (f 4 5))`,
   two-call sums inside match arms and nested `str-concat` calls all
   compute correctly through `zyl-self`. The compiler's own source still
   follows the old discipline (pre-bound `let` operands, and
   `error_report.zyl`'s header asks the same of every `str-concat`);
   keep to it when editing compiler stdlib, where a miscompile breaks
   the fixed point rather than one program. N-ary binops fold
   left-associatively (`ic-binop-fold`).
9. **';' inside strings is safe** (lexer is string-aware as of
   2026-08-25), but older stage binaries truncate there.
10. Keep function bodies moderate. `cg-function` sizes a frame from its
   actual slots (parameters + one per `let`/pattern binding + 8 headroom,
   8 bytes each, rounded to keep alignment) — the old uniform
   `16*(64+icnf-size)` is gone — but deep recursion still relies on the
   big-stack worker (`zyl_call_on_big_stack`; generated entry stubs
   already route `main` through it).
11. **A record type embedded as a constructor argument to ANOTHER
    constructor call wants an EVEN field count.** `cg-variant`'s
    alignment padding for a nested variant-construction argument is
    computed from the CURRENT call's own field count only, not the
    caller's already-pushed argument count — an odd field count can trip
    a stack-alignment bug there (confirmed root cause of a real segfault
    in `sexp_balance.zyl`'s `CheckState`, see its own header comment).
    Since then `cg-variant`'s `zyl_heap_alloc` call, and every other C
    call (`cg-ext-call-aligned`, 2026-09-23), realigns rsp to 16 bytes
    before calling, which addresses the crash mechanism; the even-count
    workaround in `sexp_balance.zyl` has not been removed and re-tested,
    so keep matching field count parity on such types until someone
    does.
12. **A module meant to be `use`d as a library must not define `main`
    (or any other name a caller might reasonably also define).** The
    module resolver splices a `use`d file's top-level forms in verbatim;
    a stray `defn main` collides with the importing program's own `main`
    or trips `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN` for any importer that
    also has top-level `test`/`run-tests` forms. `assemble.py`'s bundle
    path silently strips `main` from every non-driver file for exactly
    this reason (`strip_named_defn`) — but that stripping does NOT apply
    to a standalone `use`, so a library module's own convenience CLI
    entry point (if it needs one) must be named something else and
    wrapped in a real `main` only by whatever actually is the program's
    entry point.
13. **Every type your module directly constructs must be `use`d
    explicitly, even if it "happens to already be visible."** Inside
    `selfhost/assemble.py`'s bundle everything is one flat global
    namespace, so a missing `use` for a type defined elsewhere in the
    bundle compiles fine there — then fails as an undefined-reference
    link error (`_ZYL_<Ctor>`) the moment the same file is resolved
    standalone via the real module resolver, because that file becomes a
    genuine dependency edge for whoever `use`s it. Prefer a small local
    type over reaching across a large, wrong-direction module boundary
    for one shared shape (e.g. `sexp_balance.zyl` has its own `SBPair`
    rather than depending on the entire `compiler/type_system` module
    just for its generic `Pair`).

## 3. Idioms

### ADT + total match (the core pattern)
```lisp
(deftype List2 (Nil2) (Cons2 Int List2))

(defn len2 (xs)
  (match xs
    (Nil2 0)
    (Cons2 h t (+ 1 (len2 t)))))
```
Recursive fields are pointers; construction allocates:
`(Cons2 7 (Cons2 8 (Nil2)))`.

### State threading (functional pipelines)
Codegen-style functions thread an immutable state record through lets:
```lisp
(defn step (st x)
  (match st
    (ST a b (ST (f a) (+ b x)))))
```
Reconstruction MUST list fields in declaration order — a swapped field in
construction vs destructuring silently mislabels every use downstream.

### Arena allocation + FFI
```lisp
(use allocator/allocator)
(let arena (arena-create 1073741824))            ; 1GB handle (Int)
(let buf (arena-alloc-zeroed arena 1024))        ; NUL-zeroed memory
(buf-append buf "text")                          ; APPENDS at strlen(buf)
(str-intern arena s)                             ; fresh copied string
```
FFI rules: `(ffi-call "sym" a b timeout-literal)`; pointer args are plain
`Int`s; strings are NUL-terminated pointers; results come back in rax as
Int/String. `ic-ffi` (icnf.zyl) drops the LAST argument as the timeout
without looking at it, so forgetting the timeout silently drops your
last real argument, and the timeout value is never enforced. A `Secret`
argument must go through `ffi-pin` (`E_FFI_PIN_REQUIRED`), and inside a
package `ffi-call` needs the `ffi` capability.

### Output emission (codegen.zyl style)
Emit into a CGState text buffer via `cg-emit` / `cg-emit-line` /
`cg-emit-int`; labels via `cg-label-new`; rodata via `cg-with-rodata`.
Alignment discipline for calls: pad BEFORE pushes when arg count is odd;
pop into SysV regs in reverse; cleanup pad after the call.
Every C call goes through `cg-ext-call-aligned` (arity 7+ copies its
stack args to an aligned block). Callee-saved registers: `cg-function`
saves and restores only `rbx` and `r12`, the two codegen uses; a new
sequence that needs `r13`-`r15` must be added to
`cg-save-callee-saved` / `cg-restore-callee-saved`, or C callers of Zyl
functions (qsort comparators, test bodies, actor entries) break.

### Tests: the language's own test framework, not ad hoc `main` checks
Top-level `(test "name" body)` forms + a trailing `(run-tests)` compile
to registered test functions; the file needs no explicit `main` (an
implicit one is synthesized — see icnf.zyl's `ic-finish-program`, and
constraint 12 above for why NOT to accidentally introduce an explicit
one via a stray `use`d library `main`). This is the idiom
`tests/regression/*.zyl` uses to unit-test compiler internals directly
(e.g. `tests/regression/compiler.zyl` calls `zyl-lex`/`zyl-parse`/
`sb-check-string` and asserts on their results) — prefer this over only
proving something via a black-box `tests/compile-fail/*.zyl` case, which
just shows the compiler exits nonzero, not that the RIGHT diagnostic
(location, hint text) came out.

### Diagnostics: sexp_balance / error_codes / error_report
`stdlib/compiler/sexp_balance.zyl` is the native, stack-based structural
validator (string/comment-aware, tracks bracket TYPE not just a net
count) — `sb-check-string` returns a `BalanceResult`, `sb-hint` returns
its fix-it text, colocated with the type so every consumer (the fatal
compile-time error path today; an LSP or REPL live-check tomorrow) reads
the same wording from one place. `error_codes.zyl` is the single-source
error-code catalog; `error_report.zyl` has the shared location/header
formatting helpers (`err-header`, `int-to-str`, `loc-string`, and
`err-at`, which renders `error[CODE]: msg`, `--> file:line:col`, the
source line, a caret and a `= help:` line from a node's recorded byte
offset). Balance errors reach it via `report-unbalanced` (parser.zyl,
called from `zyl-parse` and `compile-check-balance` in pipeline.zyl).
Located so far: `E_MALFORMED_PARAMETER`, the balance errors,
`E_ARITY_MISMATCH`, `E_NON_EXHAUSTIVE_MATCH`, `E_UNREACHABLE_MATCH_ARM`,
`E_DUPLICATE_DEFINITION`, `E_UNBOUND_VARIABLE`; the mutability,
capability, unused, secret and most `expr_inner` errors still print a
bare `PANIC:` line. A new diagnostic should thread its node to `err-at`.
Still open: colorized output, "did you mean?" suggestions — see
`docs/error-system-architecture.md`.

## 4. Debugging recipes

- **Symptom: function missing from compiled output.** Check paren balance
  of the forms BEFORE it (a broken opener nests subsequent defns). Also
  check for duplicate deftypes upstream, and check per-FILE balance if
  it's a compiler-stdlib file that's also concatenated into the bundle
  (see constraint 4 — a per-file deficit that nets to zero across the
  whole bundle is invisible to `assemble.py`'s own check).
- **Symptom: garbage where a variable should be.** Slot aliasing — look
  for a constructor reconstruction with fields out of order, or a call
  whose pad/pops disagree.
- **Symptom: a computed count/sum is 0 or too small in stage>=2 output.**
   Historically a binop over two call operands — see constraint 8. That
   shape no longer reproduces in simple cases, so also suspect a
   reconstructed record with fields out of order (below).
- **Symptom: SIGFPE in compiled binaries.** `%` or `/` without cqo before
  idiv (stale rdx).
- **Symptom: output truncated to the last emitted line.** Something used
  copy (strcpy) instead of append (zyl_str_append) for buffer emission.
- **Symptom: `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN` in a file with no
  `defn main` of your own.** A `use`d module defines one — see
  constraint 12. Check every module in the `use` chain (transitively)
  for a stray top-level `main`.
- **Symptom: undefined reference to `_ZYL_<SomeCtor>` at link time, for
  a standalone `use`, in a program that compiles fine as part of the
  self-hosted bundle.** A `use`d compiler-stdlib file constructs a type
  it never declared a dependency on — see constraint 13.
- **Symptom: edited stdlib/compiler code doesn't seem to take effect
  when compiling some file OUTSIDE this checkout (or via a bare `zyl` on
  PATH).** `~/.zyl` (or `$ZYL_HOME`), if it exists from a prior
  `./install.sh`, is checked AHEAD of the repo's own `build/boot/stdlib`
  for module resolution — by design, so an installed `zyl` works from
  any directory (see `install.sh`'s header comment). Re-run
  `./install.sh` after any stdlib/compiler change, or just always test
  against `build/boot/zyl-self` from inside the repo AND make sure
  `~/.zyl` isn't stale before trusting a "still fails" result.
- **Symptom: `zyl eval FILE` (the ICNF interpreter) and the compiled
  binary disagree.** Everything up to ICNF is shared, so the fault is in
  codegen (or in the interpreter). The `interpreter` category of
  `./run_regression_tests.sh --full` runs exactly this comparison over
  the regression and smoke tests; bisect by compiling prefixes of the
  input plus a canary program.
- **Symptom: a `for` loop never terminates.** `for` has no step clause;
  the body must `set!` the loop variable itself.
- **Logs:** `dbg-log` (pipeline.zyl) appends each stage name to
  `/tmp/dbg`, but only when `ZYL_DEBUG_STAGES` is set; `cg-dbg`
  (codegen.zyl) appends to `/tmp/dbg2` and has no callers. Log integers
  via `(ffi-call "zyl_cstr_from_int" arena n 1000)`.

## 5. Pipeline map (what runs where)

Default build (`./boot.sh`, no args) is cargo-free — no Rust anywhere:
```
committed seed build/boot/stage2.s --cc--> stage1.bin
stage1.bin compiles selfhost/zyl_selfhost_compiler.zyl -> stage2_gen.s
  (must byte-match the committed stage2.s seed, or the compiler source
  changed and needs re-seeding)
stage2.bin (relinked from stage2.s) compiles the same source -> stage3.s
  (must byte-match stage2.s: the actual fixed-point check)
```
`selfhost/zyl_selfhost_compiler.zyl` is `selfhost/assemble.py`'s
concatenation (comments stripped, `use` lines removed, every non-driver
`main` stripped) of, roughly: stdlib/core/*, collections, allocator,
the parts of stdlib/math the package index's Ed25519 verification needs
(words, bits, secret, bignum, sha512, ed25519), stdlib/compiler/{ast,
expr_inner,lexer,parser,package,qualify,store,workspace,lock,index,mvs,
cli,capability_check,module_resolver,macro_expand,mutability_check,
arity_check,duplicate_check,exhaustiveness_check,unused_check,
secret_check,resolver,type_system,type_inference,monomorphization,icnf,
trait_dispatch,closure_inline,assert_lowering,codegen,region_inference,
optimization,sexp_balance,error_codes,error_report,pipeline}.zyl,
stdlib/lsp/builtins.zyl, stdlib/repl/*, then selfhost/driver.zyl — see
the file list in `assemble.py` for the authoritative order.
`contract_injection.zyl` is deliberately NOT in the bundle. A full
`./boot.sh` takes well under a minute (it took ~10 minutes per stage
until the type-inference exponential was fixed on 2026-09-23).

**After changing compiler source**: `python3 selfhost/assemble.py`
(regenerates the bundle, verifies whole-bundle paren depth — but see
constraint 4's per-file caveat), then `./boot.sh --bootstrap-from-self`
(iterates stage1->stage2->... to a new fixed point, seeds
`build/boot/stage2.s`/`.bin`), then a clean `./boot.sh` to verify. Run
`./install.sh` too if you'll test any file outside this checkout, or via
a bare `zyl`/`zyl-self` on PATH (see the debugging recipe above).

**Module resolution is self-hosted too now**, not Rust-only:
`stdlib/compiler/module_resolver.zyl` walks a parsed program's top-level
`(use module/path)` forms, recursively resolves+parses each dependency
file under `stdlib/`, and splices dependency bodies in ahead of the
main program — auto-injecting `core/core` unless the program already
`use`s `core/core`, `core/option` or `core/result`. Since the package
system (spec §31) it also qualifies every identifier to a canonical
symbol key (`qualify.zyl`) and enforces `pub` visibility across
packages; the stdlib is the implicit, fully visible package `zyl/std`. This
runs for real, standalone `zyl <file.zyl>` compiles (not just inside the
one giant bundle file, where `use` lines are simply regex-stripped by
`assemble.py` since everything's already concatenated). Constraints 12
and 13 above are specifically about this real resolution path.

**Archived fallback — no longer usable** (`./boot.sh
--bootstrap-from-rust`, needs `archive/rust-bootstrap-2026/Cargo.toml`
and cargo): it would rebuild a seed via the old Rust compiler, but that
compiler's lexer now fails on the current bundle (`unterminated string`
at the REPL's `"\e["` escape), and it predates most of the language.
If `--bootstrap-from-self` fails to converge because of new syntax,
land the syntax in two steps instead: first teach the compiler to
accept it (without using it in the compiler's own source), reseed, then
start using it.

Key naming: lowering functions prefix `ic-`, codegen `cg-`; module
resolver `mr-`; sexp_balance `sb-`; state records CGS/CGE/CGR/CGP; env
chain EnvBind/EnvNil; token variants Tk*; AST A*.

## 6. When constraints get lifted

Track PROGRESS.md. Constraints 1, 2 and 6 are already lifted and 8 is
narrowed to its compile-time-checked shape; 11 is a candidate for removal
once someone deletes the `sexp_balance.zyl` workaround and the suite
still passes. Update this skill whenever a constraint changes, a module
moves, or the pipeline map goes stale — a stale skill causes wrong code
with high confidence, since it reads as authoritative.
