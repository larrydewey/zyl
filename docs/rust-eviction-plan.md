# Rust Eviction Plan (2026-09-12)

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

**Next up**: Phase B (region inference + `optimization.zyl`) is
unstarted. Phase C (REPL) is unblocked now that Phase A.8 is real.
Phase D (archive `src/`, delete Cargo files) has not been touched —
Rust is still fully present and still what builds the seed via
`./boot.sh --bootstrap-from-rust`. That reseed step is the *only*
remaining place Rust is actually invoked in the normal `./boot.sh` flow
(default `./boot.sh` with no args is already cargo-free); eviction
still requires it to not be needed for reseeding either, which is
Phase D/E territory, not started.


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