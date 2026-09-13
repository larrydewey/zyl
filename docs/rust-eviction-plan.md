# Rust Eviction Plan (2026-09-12)

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

### Phase B — Pipeline parity
8. Wire region inference: fix link-broken `stdlib/compiler/region_inference.zyl`
   or re-implement an AST-level region pass mirroring `src/region_inference.rs`;
   add to driver pipeline; verify suite + fixed point.
9. Write `stdlib/compiler/optimization.zyl` (safe constant-folding + DCE
   over ICNF); add to driver pipeline; verify.

### Phase C — REPL
10. `tools/repl.zyl` (or stdlib): read stdin, write snippet file, invoke
    self-compile via argv CLI, run, print result.

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
  see stage2==stage3 before committing each batch.
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