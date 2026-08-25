---
name: zyl
description: >
  Expert Zyl language knowledge for writing, reviewing, and debugging Zyl
  code — especially the self-hosted compiler (stdlib/compiler, selfhost/).
  Covers syntax, the bootstrap constraint list, ADT/match idioms, FFI and
  arena patterns, codegen pitfalls, and debugging recipes for the
  stage1->stage2 pipeline. Use when editing any *.zyl file, the assembled
  boot source, or when diagnosing self-hosting regressions.
triggers:
  - .zyl files
  - selfhost, stage1, stage2, stage3, boot build
  - stdlib/compiler, icnf, cg-, ic-
---

# Zyl Expert Guide

Zyl is a deterministic Lisp systems language: S-expressions, Hindley-Milner
inference with capability types (TCap/TMut), region-based memory, actor
concurrency, SSA IR (ICNF), x86_64 codegen. The compiler is written in Zyl
itself. Strict left-to-right evaluation everywhere; same input must produce
byte-identical output.

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

(ffi-call "c_function_name" arg1 arg2 timeout)   ; timeout literal LAST
(module ...) / (use path/module)           ; module system (Rust driver only)
```

Gotchas that look like other Lisps but aren't:

- `struct-get` takes a STRING field key, not a symbol.
- `let` requires a body: `(let x v body)` — there is no bare binding.
- Booleans are ints at runtime (0/1); `true`/`false` are literals.
- Strings are pointers to NUL-terminated bytes; string literals are fine,
  built-up strings live in arena buffers referenced as `Int`.
- No implicit truthiness beyond int compare — use `(= x 0)` etc.

## 2. THE BOOTSTRAP CONSTRAINT LIST

The self-hosted codegen (stdlib/compiler/codegen.zyl) has restrictions the
Rust compiler does not. Code that must compile through stage>=2 MUST follow
these. Violations miscompile SILENTLY.

1. **Function arity <= 6.** SysV register args only; no stack-passed args.
   Need more? Bundle into a deftype/record or split the function.
2. **A `match` may appear only as the ENTIRE BODY of its defn.** Nested
   matches in arm bodies or if branches miscompile. Extract inner matches
   to helper functions:
   ```lisp
   ; WRONG: (if c (match x ...) y)
   ; RIGHT:
   (defn inner (x) (match x ...))
   (defn outer (...) (if c (inner x) y))
   ```
3. **Enumerate every constructor** in every match. Unknown arm names map
   to discriminant 0 silently. Wildcards must be NAMED dummies (`d1`,
   `d2`, ...), never bare `_`.
4. **Parens must balance per top-level form.** A missing closer silently
   nests every following defn inside the broken one (they vanish from
   compiled output). After editing, verify balance:
   ```python
   # per-line scanner honoring strings ("...\"...") and ; comments
   ```
5. **One deftype per name, ever.** Duplicate deftypes create incompatible
   constructor identities; pattern matches against them silently fail.
6. **Prefer flat `begin` sequences + recursion** over deep nesting; keep
   let-chains short. Cross-module generic inference can mis-unify shared
   list helpers across element types — modules keep private typed helpers
   (e.g. `ih-ic`, `fh-if`) instead of sharing.
7. **buf-append appends at strlen(dst)** (true append). Fresh zeroed
   buffers only — appending to a non-empty buffer accumulates (this is
   what you want for output buffers; NOT copy semantics).
8. **A match-arm body contains at most ONE call.** An arm body like
   `(+ 3 (f x) (g y))` silently computes 0 in stage>=2 binaries (the
   Zyl lowering's binop handler only folded 1-2 args; nary fold now
   exists but keep arms simple). Nest through helpers:
   `(icnf-add2 1 (icnf-add2 (f x) (g y)))`. The Rust-side compiler
   rejects violating shapes with E_MATCH_ARM_COMPLEX.
9. **';' inside strings is safe** (lexer is string-aware as of
   2026-08-25), but older stage binaries truncate there.
10. **';' inside strings is safe** (lexer is string-aware as of
   2026-08-25), but older stage binaries truncate there.
9. Keep function arities/bodies moderate; frame size scales with
   `16*(64+icnf-size)` bytes (~11KB typical) so deep recursion needs the
   big-stack worker (generated entry stubs already route main through it).

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

## 4. Debugging recipes

- **Symptom: function missing from compiled output.** Check paren balance
  of the forms BEFORE it (a broken opener nests subsequent defns). Also
  check for duplicate deftypes upstream.
- **Symptom: garbage where a variable should be.** Slot aliasing — look
  for a constructor reconstruction with fields out of order, or a call
  whose pad/pops disagree.
- **Symptom: a computed count/sum is 0 or too small in stage>=2 output.**
   Match-arm body with constant + multiple calls — see constraint 8.
- **Symptom: SIGFPE in compiled binaries.** `%` or `/` without cqo before
  idiv (stale rdx).
- **Symptom: output truncated to the last emitted line.** Something used
  copy (strcpy) instead of append (zyl_str_append) for buffer emission.
- **Symptom: works via Rust compiler, breaks via stage2.** Violation of a
  section-2 constraint. Diff which construct differs; bisect by compiling
  prefixes of the input plus a canary program.
- **Logs:** dbg-log/cg-dbg write via file-open "a" (O_APPEND after the
  fix — logs accumulate reliably now). Log integers via
  `(ffi-call "zyl_cstr_from_int" arena n 1000)`.

## 5. Pipeline map (what runs where)

```
Rust bootstrap: src/*.rs (9 phases) -> compiles selfhost/zyl_selfhost_compiler.zyl
  selfhost source = assemble.py concatenation of:
    stdlib/core/{option,list}.zyl, stdlib/allocator/allocator.zyl,
    stdlib/compiler/{ast,lexer,parser,icnf,codegen}.zyl, selfhost/driver.zyl
stage1..N: the compiled compiler reads /tmp/zyl_boot_in.zyl,
  writes /tmp/zyl_boot_out.s (link with src/runtime/actor_runtime.c,
  -lpthread, -no-pie).
Fixed point: stageN output == stage(N+1) input compilation, byte-for-byte.
```

Key naming: lowering functions prefix `ic-`, codegen `cg-`; state records
CGS/CGE/CGR/CGP; env chain EnvBind/EnvNil; token variants Tk*; AST A*.

## 6. When constraints get lifted

Track PROGRESS.md roadmap. When stack-passed args land, constraint 1 goes;
when match-in-value-position lands, rewrite rule 2's workarounds. Update
this skill whenever a constraint changes — stale skills cause wrong code.
