# Rust Eviction Plan (2026-09-12)

## Self-hosted compiler feature-parity survey (2026-09-16)

Once `./boot.sh`'s fixed point actually held (see below), switching
`run_regression_tests.sh` to compile through `build/boot/zyl-self`
instead of `target/debug/zyl` (commit `e03be5d`) surfaced 17 real
failures Rust's compiler doesn't have on the exact same test files.
The fixed point holding proves the self-hosted compiler can compile
*itself*; it says nothing about whether it can compile everything Rust
can. This is that gap, measured for the first time, prioritized by
impact (highest first). Fix as you go; strike through or move to
"fixed" as each lands, rather than leaving this stale.

### 1. Cross-deftype variant-name collision — FIXED (commit `4404b29`)

Any file declaring its own ADT reusing a name already used elsewhere
(`Some`/`None` colliding with the stdlib prelude's `Option` being the
single most common case — and generic ADTs hit this constantly, since
`Some`/`None`/`Ok`/`Err`/`Pair` are exactly the vocabulary generic code
reaches for) hard-failed to compile at all with `E_DUPLICATE_VARIANT`.
Root cause: `icnf.zyl`'s variant table has no type-hint disambiguation
like Rust's `find_adt_for_variant_hinted`. Fix: allow a later
declaration to shadow an earlier one under the same name (already
guaranteed consistent, since deftypes are processed in source order and
each one's variants get prepended ahead of what came before) instead of
hard-erroring; a true duplicate *within one deftype's own variant list*
still errors. Not a full type-aware fix — matches Rust's own no-hint
fallback ("first ADT found by iteration order") — but real programs
compile now instead of being rejected outright.

**Impact**: fixed `regression/adts`, `regression/alias`,
`regression/generics`, `regression/generics-multi-type`,
`regression/match-exhaustive` end-to-end. Single highest-leverage fix
found: one collision, five test files, all fixed by removing one error
check. 26/43 → 31/43 on the full suite.

### 2. Closures crash on nesting/higher-order use — FIXED (commit `195c513`)

**Was root-caused as a documented, deliberate architectural gap**
(`icnf.zyl`'s own comment on `ic-lambda`/`ic-hoist`: "No free-variable
capture..."), comparable in scope to Rust's own `closure_inline.rs" —
deferred once (user decision, 2026-09-16), then implemented for real.

Free-variable analysis (`ic-free-vars`, mirroring `ic-safe-expr`'s own
shape coverage) finds every name a `fn` body references that isn't its
own param or a known VT variant. Empty → unchanged (plain top-level
`IFn`, identical codegen to before). Non-empty → a heap `[tag,code,env]`
triple (`IVariant`, reusing `cg-variant`'s codegen as-is) whose code
field is the lifted function (still found and hoisted by `ic-hoist`'s
existing generic field-list walk) and whose env field is a second such
triple holding one captured value per field, evaluated in the enclosing
scope — capture by value. The lifted function gets one extra trailing
`_clos_env` param; its body is wrapped in ordinary `let`s reading
captures back out via a new `zyl_variant_field` runtime helper — no new
codegen needed for the body itself, since a captured name is just a
normal local from every other angle. A new `ICallClosure` Icnf node
(paired with `cg-call-closure-args`/`cg-closure-fire`) unpacks
code/env at the call site and passes env as an extra trailing register
argument, capped at 5 declared params (env needs its own SysV register,
and this compiler's call staging has no path for a register-exhausted
7th argument today).

Two independent VTable marks decide which names need the new call form,
since they answer genuinely different questions: `VTClosureFn` ("this
name's own value is a closure triple") and `VTClosureReturn` ("calling
this name hands one back"). `outer` in `(let outer (fn (x) (fn (y) (+ x
y))) (let add5 (outer 5) ...))` is itself a plain non-capturing lambda
— ordinary bare-pointer calling convention is correct for calling
`outer` itself — but its body's tail is another `fn` that captures `x`,
so *calling* it hands back a real closure; `add5` needs the new call
form, `outer` doesn't. An earlier attempt conflated the two into one
mark, marked `outer` based on its own (empty) free-var set, left `add5`
unmarked, and crashed calling `add5` with the plain bare-pointer
convention on an actual triple.

Two bugs found and fixed during bring-up, worth knowing about if
something in this area breaks again: (1) an early version of the
closure-marking helper matched `EFn`'s fields in the wrong order
(`(EFn fparams fbody _)` instead of the real `(EFn _ params body)`
shape — `EFn` carries an unused name string *first*), silently feeding
a raw string into `param-names` as if it were a param list; the ensuing
memory corruption didn't crash where it happened, surfacing many calls
later as a SIGSEGV in a generic call trampoline with no obvious
connection to the actual bug — found only by bisecting with `dbg2-log`-
style file-based debug prints added at each step of the suspect call
chain, the fast way being direct `target/release/zyl` + the legacy
`/tmp/zyl_boot_in.zyl` protocol against single-line repros rather than
a full `boot.sh --bootstrap-from-rust` per attempt (~1 min vs ~4).
(2) The `outer`/`add5` conflation above, found by reading the actual
generated assembly once compilation itself started succeeding.

**Impact**: `regression/functions`' `hof-closure`, `regression/regions`'
`region-heap-closure`, and `unit_test`'s `nested closures` sub-tests all
pass end-to-end now. 39/43 → 42/43. `./boot.sh` confirms the fixed point
holds.

**Known, deliberate limitation**: a closure passed through an unrelated
higher-order function's own parameter (not a `let`-bound name) is only
correctly handled when it doesn't capture anything — `VTClosureFn`/
`VTClosureReturn` only ever mark `let`-bound locals and `defn`s whose
own body's tail is an `fn` literal, never plain function *parameters*
(no static type info flows into a parameter's own kind anywhere in this
pipeline). A *non-capturing* closure passed as an argument still works
today (falls back to the always-correct bare-pointer convention, since
its own value genuinely is one) — this only matters for a capturing
closure specifically passed through a HOF parameter, which no test in
this corpus currently does.

### 3. Trait-dispatch compiler crash — FIXED (commit `29ef5db`)

`regression/traits` didn't fail at runtime — it crashed the *compiler
itself* (`_ZYL_populate_trait_impls`, actually defined in `stdlib/
compiler/monomorphization.zyl`, not `trait_dispatch.zyl` despite the
name) while compiling ordinary trait/impl declarations, even completely
uncalled ones — the crashing test file's own header comment says
dispatch itself isn't implemented, syntax only. Root cause:
`populate-trait-impls` extracted `trait-ctx`'s `.impls` list once, then
recursed by passing the *remaining list* back in as the `trait-ctx`
parameter — the next call's own `(TC.impls trait-ctx)` ran `.impls`'s
match against a `List`'s `Cons`/`Nil` tag instead of `TraitContext`'s
`TC` tag, which never matches, silently returned the universal
"no arm matched" sentinel (`0`), and matching that `0` as a list
dereferenced a null pointer. Root-caused with a temporary FFI debug
hook (`zyl_debug_ptr`, dumped raw tag/field words to `/tmp/dbg`,
removed once done) that caught the exact moment a valid `TC` tag turned
into a `List` tag through the same accessor. Fixed by splitting the
one-time struct-field extraction from the per-element list recursion
into two functions, so the two shapes can no longer be conflated.

**Impact**: `regression/traits` compiler crash → 4/4 tests pass.
31/43 → 32/43.

### 4. Match exhaustiveness checking is incomplete — FIXED (commit `89124ab`)

Both `compile-fail/match-non-exhaustive` and `compile-fail/
match-nested-non-exhaustive` expected compilation to fail and it
silently succeeded instead. `icnf.zyl`'s `ic-check-exhaustive` only
verified each arm's variant was *some* known variant, never that *all*
variants of the scrutinee's actual type were covered — didn't need full
scrutinee-type tracking (item #1's still-missing gap) after all: added
a `gid` field to `VTEntry` (`ast.zyl`), a per-deftype-DECLARATION-unique
id shared by every variant from one `deftype` call (unlike `tag`, which
restarts at 0 per deftype for codegen's dispatch and can't disambiguate
siblings on its own). Take the first arm's gid, collect every sibling
name sharing it, check each is covered by some arm.

Reseeding the bundle with this in place immediately surfaced a real
false positive from the check itself, caught before it could ever reach
a committed seed: `parse-match-arm`'s "wrapped" arm surface form
`((Variant field*) body)` records the NESTED pattern's own constructor
as `MA.variant` — correct for a real wrapped arm, but the exact same AST
shape is what a 3-part `((Inner field*) tail-name body)` arm parses to
today, which `region_inference.zyl` uses to destructure a `Cons`'s head
inline (`((RB n r esc) rest ...)`) — a currently-dead code path since
region inference's result isn't wired into codegen output (see the
2026-09-16 status update below), not something to fix as a side effect
of this check. `MA.variant` there reports `"RB"` (from `RegionBind`),
unrelated to the outer `List`'s `Cons`/`Nil` siblings, which the naive
gid check flagged as a missing `Cons` arm. Guarded with
`ic-arms-all-gid`: every arm must share one gid before the group is
trusted at all; a mismatch backs off to the pre-existing no-check
behavior rather than risk a false positive on a shape it can't
distinguish from a real bug. Found via the fast iteration loop of
invoking `target/release/zyl` + the legacy `/tmp/zyl_boot_in.zyl`
protocol directly on `selfhost/zyl_selfhost_compiler.zyl`, instead of a
full `boot.sh --bootstrap-from-rust` per attempt.

**Impact**: `compile-fail/match-non-exhaustive` and `compile-fail/
match-nested-non-exhaustive` link failure → both now correctly reject
at compile time. 37/43 → 39/43. `./boot.sh` confirms the fixed point
still holds.

### 5. Missing stdlib piece: `_ct_no_contract` — FIXED (commit `61dfdd2`)

Turned out to be bigger than "quick" once actually opened up, but still
small in the end. `_ct_no_contract` wasn't a missing symbol at all — it
was a user-defined function name wrapped in `(contracts off (defn
_ct-no-contract ...))`, and the self-hosted parser had **no case at
all** for the `contracts`/`requires`/`ensures`/`recover`/`checkpoint`
special forms (Rust's own bootstrap recognizes them via `src/ast.rs`;
the only code that ever unwraps the resulting AST nodes,
`compiler/contract_injection.zyl`, is deliberately excluded from the
self-hosted bundle for an unrelated, already-documented reason — its
accessors don't match the real `DefnNode`/`TestDecl`/`TestSuiteNode`
shapes). With no case for any of them, each parsed as an ordinary call
to a nonexistent function; for `contracts off` specifically, that meant
the wrapped `defn` was never recognized as a `defn` at all, just an
argument to a bogus call, so it silently never got compiled —
surfacing only as a link-time "undefined reference", not a compile
error, which is why grepping for `_ct_no_contract` found nothing.

Since this pipeline never injects or checks contracts in the first
place (same passthrough noted above), all five of these forms already
carry zero runtime semantics here — confirmed by the test file's own
header comment ("a compile-time overlay; core semantics are
preserved"). Fixed by parsing each straight through to its core
expression in `expr_inner.zyl`'s `dispatch-special`, rather than adding
real AST nodes nothing downstream would consume.

**Impact**: `regression/contracts` link failure → 5/5 tests pass.
32/43 → 33/43.

### 6. Individual feature bugs, one file each

Each of these is its own separate, unrelated bug — no shared root
cause found, so no single fix helps more than one:
- `regression/with-resource` — FIXED (commit `ff9b4a2`). Two bugs
  stacked: `parse-with-resource` expected three flat top-level args
  (name, init, body), but every real call site — including this file's
  own header comment — uses `(with-resource (name init) body)`, a
  parenthesized binding pair (same convention as `parse-let`'s
  `(let (name value) body)` form), so parsing always fell through to
  `EUnknown` before `icnf.zyl` ever saw a real `EWithResource` node;
  separately, `ic-expr` had no case for `EWithResource` at all even if
  one had arrived. The tests only exercise `let`-identical semantics
  (bind, evaluate body, return body's value, proper shadowing), so
  fixed by parsing the pair correctly and lowering exactly like `ELet`.
  0/6 → 6/6; 33/43 → 34/43.
- `regression/control-flow-ext` — FIXED (commit `a4aad40`). Not a
  while/compound-condition bug at all: `while-compound`'s own body has
  an outer `let-mut i` whose *second* sibling body statement
  (`assert-equal acc 25`) reads `acc`, bound by an *inner* `let-mut acc`
  that's the outer's *first* sibling body statement — the original
  author clearly intended the inner binding to stay in scope for the
  rest of the sequence. `parse-body-from` (shared by every multi-
  statement `defn`/`while`/`for`/`let`/`let-mut` body) wrapped multiple
  trailing statements as flat, independent siblings, so the inner
  let-mut's own scope for `acc` ended with its own body, and the
  following sibling read `acc` as unbound — silently wrong, not an
  error. Confirmed real, intended semantics (not a test bug) by
  checking that Rust's bootstrap passes this exact test — not from any
  special-casing at parse time (its parser.rs/ast.rs do the identical
  flat wrap) but because `src/icnf.rs`'s entire architecture is
  flat/SSA-style, so a `let` there never creates a disappearing nested
  scope in the first place; this pipeline's own `icnf.zyl` is
  tree-shaped with real lexical nesting, so matching that behavior
  needed an actual fix, not architecture-driven parity. Fixed at the
  AST level: `parse-body-from` now builds the sequence right-to-left,
  and a `let`/`let-mut` element absorbs everything after it into its
  own body instead of leaving it as a sibling — no changes needed to
  `icnf.zyl`'s already-correct `ELet`/`ELetMut` lowering. 4/5 → 5/5;
  34/43 → 35/43.
- `regression/derive` — FIXED (commit `aac297a`). Not a derive-macro
  gap at all — `==`/`!=`/`<`/`>`/`<=`/`>=` on struct/ADT (`IVariant`)
  values fell into `codegen.zyl`'s `kind-of` int-default bucket (only
  3 kinds tracked: int/string/float), so every comparison went through
  a bare `cmp rax, rcx` pointer comparison — the exact same bug already
  fixed for strings, just never extended to structs. `==`/`!=` were
  simply always wrong for two separately-constructed but field-
  identical structs; `<`/`>`/`<=`/`>=` gave an allocation-order-
  dependent answer, which is why `derive-ord-struct` alone happened to
  "pass" (`b1` built before `b2` coincidentally lands at a lower
  address) while `derive-multi-trait`'s own `<` check on two
  *equal*-valued structs failed the moment address order no longer
  lined up with the expected result. `zyl_variant_eq` (real structural
  equality) already existed in `actor_runtime.c` but was never actually
  called from anywhere; added a matching `zyl_variant_cmp` (lexico-
  graphic, -1/0/1) for ordering, added a 4th "struct/variant" kind to
  `kind-of` (propagates through the existing `EnvBind`-carried-kind
  mechanism with no other plumbing), and routed comparisons on
  struct-kind operands through both, mirroring the existing string-kind
  dispatch. 2/5 → 5/5; 35/43 → 36/43.
- `regression/unwrap-error`: the deliberate error in its `try-catch-err`
  sub-test escapes the `try-catch` and kills the process instead of
  being caught — an exception-propagation bug.

### 7. `integration/selfhost-codegen` — FIXED (`boot.sh` sync bug + duplicate defn)

Not a lexer/escape bug at all — the file's own token stream was already
verified balanced by hand (40 `(` / 40 `)`) before finding the real
cause. Two independent bugs stacked, both systemic rather than specific
to this one test:

**1. `boot.sh` was copying `stdlib/` into `build/boot/stdlib/` with a
`cp -R` that only overwrites correctly on a clean target directory.**
Once `build/boot/stdlib/` already exists (i.e. every `boot.sh` run after
the very first one in a checkout), `cp -R src dst` nests a *fresh* copy
inside the existing `dst` (`build/boot/stdlib/stdlib/...`) instead of
updating `dst` itself — well-known `cp` directory-target semantics, not
a Zyl bug. Since `module_resolver.zyl` resolves every `(use module/name)`
in a *user's* file by chdir-ing to the compiler binary's own directory
(`build/boot/`) and reading `stdlib/<name>.zyl` from there, it was
reading the STALE, never-updated outer copy — while a correctly-synced
inner copy sat one level down, at a path nothing ever resolved against.
`diff -rq stdlib/ build/boot/stdlib/` showed 11 stale files and 4 files
missing outright (`error_codes.zyl`, `error_report.zyl`,
`optimization.zyl`, `sexp_balance.zyl` didn't exist in the stale copy at
all). The stale `type_system.zyl` specifically still had a since-removed
duplicate `Region` deftype and a since-fixed broken multi-binding `let`
— genuinely broken source, not just outdated. `integration/
selfhost-codegen` is one of the only tests that `use`s compiler-internal
modules (`compiler/expr_inner` → transitively `compiler/type_system`) at
runtime, which is why nothing else in the suite ever surfaced this.
Fixed: `rm -rf "${OUT}/stdlib"` before the `cp -R` in `boot.sh`. Also
deleted the stray nested `build/boot/stdlib/stdlib/` (untracked, gitignored,
never should have existed).

**2. `compiler/type_inference.zyl` carried its own duplicate copy of
`resolve-nominal`, byte-identical to `compiler/type_system.zyl`'s.**
`assemble.py`'s bundle build (used to compile the self-hosted compiler
itself) has its own Python-level `deduplicate_defns` (first-occurrence-
wins) that silently papered over this for the compiler's own build —
so the fixed point never caught it. But `module_resolver.zyl`'s runtime
`use`-graph splicing has no such dedup: a real program pulling in both
`compiler/expr_inner` (→ `type_system`) and `compiler/icnf` (→
`monomorphization` → `type_inference`) spliced both copies in, producing
a genuine `_ZYL_resolve_nominal` duplicate-symbol assembler error —
only visible once bug #1 above was fixed and module resolution started
reading real, current source. Fixed by adding `(use compiler/
type_system)` to `type_inference.zyl` (its own header comment already
said type_system is "the single owner of all type-system ADTs") and
deleting the duplicate.

**Not fixed, found for free during this investigation, not currently
blocking anything**: `list-nth`/`list-map`/`list-contains` are *also*
independently defined in both `stdlib/collections/collections.zyl` and
`stdlib/compiler/monomorphization.zyl` — but unlike `resolve-nominal`,
these have genuinely different signatures (`list-nth`: `(lst i)` returning
a raw value vs. `(n xs)` returning `Option`; `list-contains`: reversed
argument order) between the two copies, so this isn't a safe delete-and-
`use` fix — it needs an audit of every call site in `monomorphization.zyl`
before merging. Latent landmine: a real program `use`-ing both
`collections/collections` and `compiler/monomorphization` would hit the
same duplicate-symbol class of failure. No current test combination
triggers it.

**Impact**: `integration/selfhost-codegen` link failure → 1/1 test
passes. 36/43 → 37/43. More importantly, this was a systemic module-
resolution bug affecting ANY user `.zyl` file `use`-ing compiler-internal
modules, not specific to this one test — worth re-verifying if further
compiler-introspection tests are added.

### Also noted, not blocking anything specific

Even some *passing* tests have silent, uncaught bugs: `print` on a
float or string argument sometimes prints the raw bit pattern/pointer
instead of the formatted value (seen in `unit_test`'s
`print-float works`/`print-string works` sub-tests), but those
sub-tests don't assert on the printed content, so they still report
"ok". Worth a dedicated look — likely a `print`'s type-dispatch bug in
`codegen.zyl` — but not surfaced by the suite today, so not prioritized
above the failures that are.

## Status update (2026-09-16)

**Phase A.8 (native error system / sexp_balance.zyl) is now actually
done** — not just present, but verified end-to-end for the first time.
`./boot.sh` (cc-only, no cargo) now holds the fixed point: stage1
(cc-linked from the committed seed) reproduces `build/boot/stage2.s`
byte-for-byte, stage2 == stage3, and the CLI smoke test compiles+links+
runs correctly. See commits `68f53cb` (fix(icnf): pass free variables
through nested-pattern-match helper, fix cg-variant alignment) and
`7eb7c2e` (fix(assemble.py): string-aware paren-depth checks).

What was actually wrong, for whoever picks up Phase B next: `sexp_balance
.zyl`'s `sb-close-bracket` has a constructor pattern nested in field
position (`(Pair expected (Pair ol oc))`). `icnf.zyl`'s `ic-wrap-one`
outlined that inner pattern into a separate top-level helper function
taking only the matched field as its parameter — but the helper's body
(the arm's original continuation) freely references outer-scope names
(sibling field bindings, the enclosing function's own parameters, its
own outer match's bindings), none of which were passed in. This
compiler has no free-variable/closure capture anywhere else either, so
every such reference silently resolved via `env-lookup`'s unbound-name
fallback (offset 0 — the helper's own saved rbp) instead of erroring.
It read back as a plausible-looking but wrong pointer, correct by
coincidence often enough (small inputs, shallow recursion) that it
surfaced as a rare, seemingly-unrelated crash deep in
`sb-result-balanced` rather than an obvious, immediate failure. Fixed
by emitting a plain inline `IMatch` for the nested pattern instead of
outlining it — sequential/chained matches (a match nested in another
match's *arm body*) already compile and run correctly at three levels
deep in this codegen (confirmed by tracing `sb-close-bracket`'s own
compiled output); it was only the field-position-nested-pattern
outlining path that was broken. If a similar "outlined helper drops
outer scope" bug shows up elsewhere, `ic-wrap-one`/`ic-wrap-nested-all`
in `icnf.zyl` is the pattern to check first — this compiler has no
general free-variable capture mechanism, so anything that manufactures
a new top-level function on the fly needs the same scrutiny.

Separately, but in the same investigation: `cg-variant` (in
`codegen.zyl`) padded odd field counts with a fixed `sub rsp, 8`
assuming rsp was already 16-aligned on entry — wrong whenever the
construction sat inside an outer field-push (nested variant/call
arguments), since the outer call's already-pushed word count shifts
real parity out from under a check that only looks at this call's own
field count. Fixed by saving rsp, `and`-ing down to 16, and restoring
after the call — correct regardless of what parity rsp arrived with.
This was a real, separate defect, but empirically was not the trigger
for the crash above; not fully ruled out as *a* trigger elsewhere,
worth keeping an eye on.

**Correction to an earlier draft of this note**: it originally said
Phase B was unstarted. That was wrong — checked the actual code, not
just this plan doc. `region_inference.zyl` and `optimization.zyl` are
both fully wired into `driver.zyl`'s pipeline and already exercised by
every self-hosted compile, including the verified fixed point above.
The nuance worth knowing: `region_inference`'s result (`ri2`) is
computed but never used — `driver.zyl` calls `ri-infer` for its own
sake and then codegens straight from the pre-region-inference `fns`,
so region inference currently has zero effect on generated code.
`optimization.zyl`'s `opt-optimize` is not called *at all* in the real
pipeline — `driver.zyl` passes `fns` through unchanged, with a comment
explaining why: `opt-optimize` is written against `src/optimization.rs`'s
SSA-form `ICNFNode`/`IFS` representation, while this pipeline's own
`compiler/icnf.zyl` produces a different, simpler tree-shaped `Icnf`
that `opt-optimize`'s pattern never matches — it would silently return
an empty list (see the 2026-09-16 REPL section below for what that
actually breaks in practice). So: Phase B is "present, compiles
correctly, exercised on every build" but not "functionally doing
anything to the compiled output" — both passes are dead code from the
compiled program's point of view, kept alive only because `tools/
repl.zyl` (Phase C) references them (see assemble.py's comment on why
they're in the bundle's file list at all). Actually wiring either pass
in for real is unstarted, separate work.

**Phase C (REPL), 2026-09-16**: `tools/repl.zyl` existed but had never
been run successfully by anyone — every attempt to compile it failed at
link time. Fixed four real bugs (commit `f31d4a1`): a name collision
between `contract_injection.zyl`'s and `closure_inline.zyl`'s
same-named, different-arity `ci-expand-program` (repl.zyl imported
both; driver.zyl deliberately doesn't, for exactly this reason); the
same `opt-optimize`/ICNF-shape mismatch described above, which silently
dropped every function including `main`; a call to `str-trim`, which
doesn't exist anywhere in the codebase (implemented locally in
repl.zyl); and `repl-is-quit` checking `str-eq ... = 0` (not-equal)
instead of `= 1` (equal), so it quit on the very first line of input
regardless of content. Also implemented the two FFI functions
`repl-codegen` calls (`zyl_cc_compile`, `zyl_run_bin`) — they didn't
exist in `runtime/actor_runtime.c` at all — using `posix_spawn`+
`waitpid` rather than `fork()`/`system()`, both already documented
elsewhere in this file as unsafe from the compiler's 64GB-stack worker
thread.

With all four fixed, the REPL *still* doesn't work end-to-end, and
these remaining issues are not quick:
- A trivial single-function snippet (`(defn main () (print (+ 1 2)))`)
  compiles correctly through Rust's `codegen.rs` directly, but silently
  drops `main` when compiled through this same self-hosted `icnf.zyl`/
  `codegen.zyl` pipeline as executed at runtime by the REPL (i.e. the
  same code path `./boot.sh`'s fixed-point check exercises — but that
  check only ever feeds it the full ~280KB bundle, never a trivial
  single-function program, so this edge case had apparently never been
  hit before now).
- Separately, `repl-read-line`'s own `(arena-create 1048576)` /
  `(arena-alloc-zeroed ... 4096)` call was observed crashing with *both*
  arguments corrupted to the same small integer (`2`, `2`) — a second,
  unrelated-looking miscompilation in the same runtime pipeline.

Two new, distinct, previously-unknown bugs surfacing in one session
strongly suggests `tools/repl.zyl` has never actually been run
end-to-end by anyone before — treat it as an unfinished skeleton that
happens to now *link*, not a nearly-working REPL. Whoever picks this up
next should expect more bugs of the same shape, not just these two.

**Phase D** (archive `src/`, delete Cargo files) has not been touched —
Rust is still fully present and still what builds the seed via
`./boot.sh --bootstrap-from-rust`. That reseed step is the *only*
remaining place Rust is actually invoked in the normal `./boot.sh` flow
(default `./boot.sh` with no args is already cargo-free); eviction
still requires it to not be needed for reseeding either, which is
Phase D/E territory, not started.

**Overall**: the fixed point holding solidly is the *precondition* for
eviction, not the finish line. None of Phase D (archiving Rust) has
started, and Phase B/C are both further along than "unstarted" but
neither is functionally complete. Not close to eviction yet.


Goal: remove the Rust bootstrap compiler entirely from Zyl's build/test/use
path. Zyl is already fully self-hosting (fixed point verified); Rust remains
only as: the stage1 builder, the standalone CLI, the REPL, the debug/CLI
features (`--emit-zyl`, `--emit-icnf`, JSON dumps), and region
inference/optimization/exhaustiveness checks that were never ported to Zyl.

Decisions locked (all "recommended" options):
1. **Seed model** — commit `build/boot/stage2.s` + `stage2.bin` to git;
   boot.sh builds via `cc` from committed asm, never cargo.
2. **CLI** — full production CLI via argv FFI: driver parses `zyl <src>
   [-o out] [--emit-asm]`, real stderr diagnostics, links via `cc`.
3. **Phase parity** — port E_MATCH_NONEXHAUSTIVE to `icnf.zyl`, wire
   region inference into the driver, write `optimization.zyl`.
4. **REPL** — write a Zyl REPL (file-backed loop using the self-hosted
   compiler).
5. **Archive** — move `src/` (Rust) to `archive/rust-bootstrap-2026/` with
   a README; remove `Cargo.toml`/`Cargo.lock`/`target/` from the build path.
6. **Full sweep** — consolidate test runners onto the selfhost binary,
   relocate `src/runtime/*` → `runtime/`, clear junk files, rewrite
   README/AGENTS/PROGRESS/book build instructions cargo-free.

## Sequencing (each step ends verifiable, fixed point preserved)

### Phase A — Foundation (must land together)
1. `git mv src/runtime/actor_runtime.{c,h} runtime/`
2. runtime.c: add `zyl_save_args`, `zyl_argc`, `zyl_arg_str`,
   `zyl_dirname_cstr`, `zyl_chdir`, `zyl_system_cmd`.
3. codegen.zyl `cg-entry-stub`: save `edi`→`zyl_saved_argc`,
   `rsi`→`zyl_saved_argv` in `main`.
4. driver.zyl: real CLI — argv[1]=src, `-o`/positional out, `--emit-asm`;
   chdir to `dirname(argv[0])` (places `stdlib/` and `actor_runtime.c`
   resolution in the bundle dir); emit asm; link via `zyl_system_cmd`.
5. icnf.zyl: port `E_MATCH_NONEXHAUSTIVE` (mirror `src/icnf.rs`
   `check_match_exhaustive`).
6. Rebuild stage2 with the still-present Rust compiler (`./boot.sh`),
   verify fixed point, then commit `build/boot/stage2.{s,bin}` (move from
   gitignore).
7. Rewrite `boot.sh` (`--skip-rust` becomes the default/no option; cc from
   committed stage2.s; argv-based smoke; new `zyl-self` = `exec stage2.bin
   "$@"`).
8. **Error System (native Zyl)**: implement `stdlib/compiler/sexp_balance.zyl`,
   `error_codes.zyl`, `error_report.zyl`; integrate into driver pipeline;
   replace Python balance scripts; verify fixed point.

### Phase B — Pipeline parity
8. Wire region inference: fix link-broken `stdlib/compiler/region_inference.zyl`
   or re-implement an AST-level region pass mirroring `src/region_inference.rs`;
   add to driver pipeline; verify suite + fixed point.
9. Write `stdlib/compiler/optimization.zyl` (safe constant-folding + DCE
   over ICNF); add to driver pipeline; verify.

### Phase C — REPL (BLOCKED by Phase A.8: Error System)
10. `tools/repl.zyl` (or stdlib): read stdin, write snippet file, invoke
    self-compile via argv CLI, run, print result.

**Blocking dependency**: REPL requires native error system (Phase A.8) for:
- Live S-expression balance feedback
- Rich error reporting in interactive mode
- "Did you mean?" suggestions for typo recovery

### Phase D — Eviction & docs
11. `git mv src archive/rust-bootstrap-2026`; write archive README; delete
    `Cargo.toml`/`Cargo.lock`; `rm -rf target`.
12. Merge the two regression runners into one defaulting to the selfhost
    binary; delete the duplicate `_self.sh`.
13. Update README, AGENTS.md, PROGRESS.md, book build instructions,
    `.gitignore`; delete root junk (`a.out*`, `--emit-zyl.s`, `-o.s`,
    `-emit-zyl.s`, `output.zyl`, `larry_test.*`, `test_*.zyl`, `t.s`,
    `*__emit-icnf.s` etc.).

### Phase E — Verify
14. Full regression suite via selfhost compiler; `./boot.sh` fixed point;
    compile-fail tests green; `grep -r cargo` free in scripts/docs;
    REPL smoke; archived Rust never referenced by any script.

## Risk register
- **Fixed point fragility**: every compiler-source edit changes what
  self-compiled binaries look like. Must re-run assemble.py + boot.sh and
  see stage2==stage3 before committing each batch. As of 2026-09-16 this
  also means: after any `.zyl` stdlib edit, re-run
  `./boot.sh --bootstrap-from-rust` (reseed) *and then* a clean
  `./boot.sh` (verify) — reseeding alone proves Rust can still compile
  the source, not that the self-hosted compiler's own output is correct
  when it compiles itself again. See the 2026-09-16 status update above
  for the concrete bug class (`ic-wrap-one`'s dropped free variables)
  that a reseed-only check would have missed indefinitely, since the
  small/trivial inputs used for quick sanity checks don't reliably
  exercise it.
- **argv plumbing**: entry-stub change touches every compiled binary;
  harmless (two mov) but must be in stage2 before CLI works end-to-end.
- **Exhaustiveness in selfhost compiler**: without the port, the two
  compile-fail tests pass-compile and the suite breaks once the runner
  points at stage2. Port must land in the same commit as the runner flip.
- **Region inference**: currently dead, link-broken code; unknown-effort
  item. If wiring proves unstable, fall back to documenting the gap
  (suite passes without it) rather than destabilizing the fixed point.
- **ASLR/big-stack**: compiled binaries and the compiler itself still
  need `setarch -R` on invocation (documented existing issue); the CLI
  `cc` child inherits the parent's setting.