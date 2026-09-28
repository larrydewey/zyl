# Self-Hosting and the Fixed Point

The Zyl compiler is written in Zyl: `stdlib/compiler/*.zyl` plus
`selfhost/` (`driver.zyl` for the compiler, `lsp_main.zyl` for the
language server). The runtime is Zyl too (`runtime/rt/`,
`docs/runtime-in-zyl-design.md`). Nothing in the build is Rust or C;
`./boot.sh` needs only `cc` to link the seed.

## The seeds

Three committed files are the bootstrap seeds:

| File | What it is |
|---|---|
| `build/boot/stage2.s` | The compiler's own assembly, emitted by the compiler |
| `build/boot/stage2.bin` | That assembly linked, for tools that want a binary without a build |
| `build/boot/rt.s` | The runtime (`runtime/rt/rt.zyl` compiled with `--runtime-module`) |

## What `./boot.sh` checks

1. `cc` links the committed `stage2.s` with `rt.s` and `start.s` into
   `stage1.bin`.
2. stage1 compiles `selfhost/driver.zyl` (its `(use ...)` tree resolved
   from a fresh copy of `stdlib/` in `build/boot/stdlib`) to
   `stage2.s`, which must be byte-identical to the committed seed. The
   runtime must reproduce `rt.s` the same way.
3. stage2 compiles the same source to `stage3.s`, which must be
   byte-identical to `stage2.s`. That is the fixed point.
4. The runtime cache `rt.zo` is built (`zyl rt-cache`), a CLI smoke test
   compiles, links and runs a program, `zyl-lsp` is built, and an
   existing install (`~/.zyl`, or `$ZYL_INSTALL_HOME`) is refreshed with
   `uninstall.sh` + `install.sh` (`ZYL_NO_INSTALL_REFRESH=1` skips it).

Each stage is capped at `ZYL_STAGE_TIMEOUT` seconds (default 2400) and
`ZYL_STAGE_MEMORY` bytes of allocation (default 4 GB). A full run takes
well under a minute.

## Failure modes

- **`reproduced asm differs from committed seed`**: the compiler's
  source changed what the compiler emits. Expected after any change to
  `stdlib/compiler/`, `selfhost/`, `runtime/rt/`, or a stdlib module the
  compiler uses (the REPL and LSP modules are part of the driver).
  Reseed.
- **`FIXED POINT BROKEN`**: stage2 and stage3 differ, so the compiler's
  output depends on something other than its input. That is a
  determinism bug (an iterated hash table, an address in output, a
  timestamp), never something to reseed past.
- **`runtime entries not emitted`**: a `zyl_*` defn in `runtime/rt/` was
  never instantiated (an uncalled Num-generic function); annotate its
  parameter types.

## Reseeding

```bash
./boot.sh --bootstrap-from-self   # iterate from the old seed until two rounds match
./boot.sh                         # verify the new seed from scratch
git add -f build/boot/stage2.s build/boot/stage2.bin build/boot/rt.s && git commit
```

Each round's compiler and its runtime are emitted by the same compiler,
so generated code and the runtime always agree on shared formats (the
try frame's layout and pointer mangling, for example). A reseed that
has not converged after ten rounds fails.

## Two-step changes

The old seed must be able to compile the new source. Two kinds of
change need two reseeds:

- **New syntax.** Teach the compiler to accept it, reseed, and only
  then use it in the compiler's own source.
- **A new runtime entry the compiler's own source calls.** An
  `ffi-call` is typed by `stdlib/compiler/ffi_sigs.zyl`, and the old
  seed carries the old table (`E_CANNOT_INFER`). Add the entry and its
  signature, reseed, then call it.

There is no fallback compiler. The Rust bootstrap was removed; it is in
git history at commit `b8bc283` (`archive/rust-bootstrap-2026/`) and
cannot lex the current source.
