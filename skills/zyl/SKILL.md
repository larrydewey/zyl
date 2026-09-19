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
(for ((i 0)) (< i 10) body)                ; 3-arg form: (for (bindings) cond body)
(begin e1 e2 ... en)                       ; sequence, value = last expr
(match scrutinee                           ; exhaustive by construction
  (Variant pat1 pat2 body)
  (Other d1 fallback-body))

(deftype Name (VariantA field-type...)     ; field types are type NAMES
            (VariantB)                     ; nullary variant
            (ListLike T (Listlike-rest)))  ; recursive = pointer fields

(defstruct Point x y)                      ; struct (immutable fields)
(struct-get p "x")                         ; field access (string key!)
(make-Point 5 7)                           ; constructor

(trait Show (show self))
(impl Show Int (defn show (self) ...))
(Show.show receiver args...)               ; trait dispatch by receiver type

(test "name" body)                         ; top-level test (no explicit main
(run-tests)                                ;  needed — see §3 test idiom)

(ffi-call "c_function_name" arg1 arg2 timeout)   ; timeout literal LAST
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
3. **Enumerate every constructor** in every match. Unknown arm names map
   to discriminant 0 silently. Wildcards must be NAMED dummies (`d1`,
   `d2`, ...), never bare `_`.
4. **Parens must balance per top-level form.** A missing closer silently
   nests every following defn inside the broken one (they vanish from
   compiled output) — a real instance of this shipped in error_codes.zyl
   for a while (14-paren deficit in its catalog, only caught once
   something finally called into it; see PROGRESS.md 2026-09-19). The
   compiler now catches this for real SOURCE at compile time
   (`stdlib/compiler/sexp_balance.zyl`, wired into `zyl-parse` and
   `compile-to-asm` — reports exact line/col + a fix-it hint, not just a
   count). It does NOT (yet) catch a per-file deficit inside a file that
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
8. **No binop may directly combine TWO calls.** `(+ (f x) (g y))` — even
   outside match arms — silently computes 0 in stage>=2 binaries. Bind
   each call to a `let`, then combine the bindings:
   `(let a (f x) (let b (g y) (+ a b)))`. In match arms keep it to ONE
   call total and nest sums through helpers: `(icnf-add2 1 (icnf-add2
   (f x) (g y)))`. Both compilers reject the arm-level shape with
   E_MATCH_ARM_COMPLEX; the general shape is NOT caught — it just
   miscompiles. N-ary binops fold left-associatively (`ic-binop-fold`),
   matching Rust. The same "no inline call operand" caution applies to
   `str-concat`'s arguments specifically — see `error_report.zyl`'s
   header comment: every `str-concat` call anywhere in the compiler
   stdlib takes only literals or pre-bound `let` variables, never a
   nested call, in either argument position.
9. **';' inside strings is safe** (lexer is string-aware as of
   2026-08-25), but older stage binaries truncate there.
10. Keep function arities/bodies moderate; frame size scales with
   `16*(64+icnf-size)` bytes (~11KB typical) so deep recursion needs the
   big-stack worker (generated entry stubs already route main through it).
11. **A record type embedded as a constructor argument to ANOTHER
    constructor call wants an EVEN field count.** `cg-variant`'s
    alignment padding for a nested variant-construction argument is
    computed from the CURRENT call's own field count only, not the
    caller's already-pushed argument count — an odd field count can trip
    a stack-alignment bug there (confirmed root cause of a real segfault
    in `sexp_balance.zyl`'s `CheckState`, see its own header comment).
    The general codegen defect is not fixed; matching field count parity
    on any such type sidesteps it. Not yet known to bite records that are
    never themselves passed as a nested constructor argument.
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
Int/String.

### Output emission (codegen.zyl style)
Emit into a CGState text buffer via `cg-emit` / `cg-emit-line` /
`cg-emit-int`; labels via `cg-label-new`; rodata via `cg-with-rodata`.
Alignment discipline for calls: pad BEFORE pushes when arg count is odd;
pop into SysV regs in reverse; cleanup pad after the call.

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
formatting helpers (`err-header`, `int-to-str`, `loc-string`). Wired into
`zyl-parse` (parser.zyl) and `compile-to-asm` (driver.zyl) via
`report-unbalanced`. Still open: colorized output, multi-line source
snippets, "did you mean?" suggestions, LSP JSON — see
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
   Match-arm body with constant + multiple calls — see constraint 8.
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
- **Symptom: works via the archived Rust bootstrap, breaks via
  stage2.** Violation of a section-2 constraint. Diff which construct
  differs; bisect by compiling prefixes of the input plus a canary
  program.
- **Logs:** dbg-log/cg-dbg write via file-open "a" (O_APPEND after the
  fix — logs accumulate reliably now). Log integers via
  `(ffi-call "zyl_cstr_from_int" arena n 1000)`.

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
concatenation of stdlib/core/*, stdlib/collections/*,
stdlib/allocator/allocator.zyl, stdlib/compiler/{ast,expr_inner,lexer,
parser,module_resolver,macro_expand,mutability_check,resolver,
type_system,type_inference,monomorphization,icnf,trait_dispatch,
closure_inline,assert_lowering,codegen,region_inference,optimization,
sexp_balance,error_codes,error_report}.zyl, selfhost/driver.zyl (in that
order — see the file for the authoritative, occasionally-changing list).

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
main program — auto-injecting `core/core` unless already `use`d. This
runs for real, standalone `zyl <file.zyl>` compiles (not just inside the
one giant bundle file, where `use` lines are simply regex-stripped by
`assemble.py` since everything's already concatenated). Constraints 12
and 13 above are specifically about this real resolution path.

**Archived fallback only** (`./boot.sh --bootstrap-from-rust`, needs
`archive/rust-bootstrap-2026/Cargo.toml`): rebuilds a first/fresh
`stage2.s` seed via the old Rust compiler. Not part of the normal
workflow — only needed if `--bootstrap-from-self` fails to converge
(a genuinely new construct the old seed can't even parse, not just new
behavior).

Key naming: lowering functions prefix `ic-`, codegen `cg-`; module
resolver `mr-`; sexp_balance `sb-`; state records CGS/CGE/CGR/CGP; env
chain EnvBind/EnvNil; token variants Tk*; AST A*.

## 6. When constraints get lifted

Track PROGRESS.md roadmap. When stack-passed args land, constraint 1 goes;
when match-in-value-position lands, rewrite rule 2's workarounds. Update
this skill whenever a constraint changes, a module moves, or the pipeline
map goes stale — a stale skill causes wrong code with high confidence,
since it reads as authoritative.
