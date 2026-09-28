# The Runtime in Zyl: Design

Status (2026-09-28): the runtime is Zyl (runtime/actor_runtime.c deleted) and libc-free: programs without foreign calls link static with no libc; foreign-calling programs link hosted. Freestanding programs now assemble and link with a Zyl assembler + static ELF linker (compiler/asm_x86 + compiler/elf_link) — no cc/as/ld (port order item 11 below). This document covers how
`runtime/actor_runtime.c` (5.5k lines of C, about 400 entry points) is
replaced by a runtime written in Zyl, `runtime/rt/*.zyl`, without adding
any unsafe construct to the language.

## Goal and constraint

- The runtime is Zyl source, compiled by the self-hosted compiler and
  covered by the fixed point, just like the compiler.
- Zyl gets no `unsafe` form, capability or flag that a program can use.
  The raw machine operations the runtime needs are compiler builtins,
  and they exist only inside the runtime's own compile.
- The model is the one Resid used to retire its C runtime (Resid
  PROGRESS.md §0zg–§0zl). Raw primitives are compiler-only builtins
  that a runtime-module compile lowers directly.
- The end state has no C at all. No C source is left in the repo, and
  no libc sits under Zyl programs. The runtime talks to Linux through
  `%syscall`, starts at its own `_start`, allocates with `mmap`, starts
  threads with `clone` and blocks on `futex`. It also sets up
  thread-local storage itself and does its own number formatting and
  parsing. Binaries are static. Only a program that `ffi-call`s a
  foreign C library links the system's libc and dynamic loader, because
  that library needs them. While the port is under way, the remaining
  C and libc are used as a bridge.

## The lock

1. `zyl-self <entry> --runtime-module -o out.s` compiles a runtime
   module. The driver refuses the flag unless `<entry>` is the bundle's
   own `runtime/rt/rt.zyl` (the checkout or `$ZYL_HOME`). The flag is
   not listed in the usage text.
2. In a runtime module, `(use m)` may name only modules in
   `runtime/rt/` next to the entry: `base`, `cpu`, `cstr`, `text` and so
   on. A standard-library module is refused at every level, so a file
   outside the runtime is never compiled with the privilege.
3. The raw primitives (all named `%...`, listed below) are
   `E_RT_INTERNAL` in any other compile. That includes user programs,
   the standard library and the compiler itself.
4. Only the runtime's exported entries are visible to programs.
   These are the top-level `defn`s named `zyl_*`. Programs reach them
   the way they reach the C runtime today: codegen calls them, and
   `ffi-call "zyl_..."` calls are typed by `ffi_sigs.zyl`, with the raw
   ones restricted to the standard library (`E_FFI_RESTRICTED`). Every
   other runtime function is a module-local label.

A program therefore cannot load or store an arbitrary address, make a
syscall, or reinterpret a word. It can only call the typed runtime API.

## Primitives (runtime-module only)

Addresses and machine words are `Int`. The primitives bypass bounds and
type checks by design, which is why they are locked.

| Form | Meaning |
|------|---------|
| `(%load8 a)` `(%load16 a)` `(%load32 a)` `(%load64 a)` | zero-extended load |
| `(%store8 a v)` ... `(%store64 a v)` | store; result is `v` |
| `(%word x)` | any value as its machine word |
| `(%str w)` | a word as a `String` (NUL-terminated bytes) |
| `(%cas a expect new)`, `(%fetch-add a v)` | seq-cst atomics |
| `(%global "name" size)`, `(%tls "name" size)` | zeroed static / thread-local storage, per name |
| `(%fn "sym")`, `(%call f args...)` | a code address; an indirect call |
| `(%syscall n a1..a6)` | Linux x86-64 syscall |

In a runtime module, `(ffi-call "sym" ... t)` to a C symbol is a direct
call, without the timeout worker. That is the libc bridge used during
the port. The timeout literal is still required, but it is ignored.
Primitive failures are `E_FFI_RESTRICTED`: a `%` symbol outside the
runtime module is refused with that code, and no new code is added.

Later stages add `%f64-bits`/`%bits-f64`, `%cpuid`, AES-NI rounds and the
unwind primitive that replaces `setjmp`/`longjmp` for `try`.

## SIMD

The runtime's hot loops (`strlen`, `memchr`, `memcmp`, `memcpy`, BLAKE3,
AES-GCM) need vector code to match glibc and the C versions.

- Stage 2 (done) adds memory-operand forms whose result is an `Int`.
  They use `xmm0`/`xmm1` and `ymm0`/`ymm1` as scratch, which is free
  because MIR keeps Floats in general registers:
  - `%v128-zero-mask a` gives the `pmovmskb` mask of the bytes at `a`
    that are 0;
  - `%v128-byte-mask a b` does the same for bytes equal to `b`;
  - `%v128-eq-mask a b` compares 16 bytes at `a` with 16 at `b`;
  - `%v128-copy dst src` copies 16 bytes;
  - `%v256-*` are the AVX2 twins, each ending in `vzeroupper`.

  They sit beside `%ctz` (64 for 0), `%cpuid-eax`/`ebx`/`ecx`/`edx`
  (leaf, subleaf), `%xgetbv` and `%global "name" size` (a zeroed,
  64-byte-aligned `.bss` block).
- AVX2 is probed once, through `cpuid` leaves 1 and 7 and XCR0, and
  cached in `%global "cpu_avx2"`. Every vector routine has an SSE2 path
  and both give identical results, so SIMD changes speed, never output.
- Aligned loads may read past the end of a string, but never past its
  page, the same bound glibc relies on. `strcmp` falls back to bytes
  near a page end, and `memcmp` reads only within the given length.
- Vector values in registers (a MIR register class) come with the
  BLAKE3/AES-GCM port, which keeps state across rounds.
- User-facing SIMD is a separate, safe API: typed fixed-width lane
  vectors in `stdlib/simd`, with a scalar fallback and no raw addresses.
  It lowers to the same MIR vector instructions.

## Runtime-module compile rules

- No `main`, and the core prelude is not loaded.
- Region inference is off. There are no frame regions and no
  `zyl_cur_region` traffic. An allocating form goes to the heap through
  the runtime's own allocator entry.
- A top-level `defn` named `zyl_*` is emitted under that exact label with
  `.globl`, using the ordinary Zyl/SysV ABI.
  Everything else keeps its mangled local label.
- Integer `+ - *` wrap, as they already do in generated code.

## Build

- `boot.sh` compiles `runtime/rt/rt.zyl` with each stage compiler and
  requires the result to match the committed `build/boot/rt.s`, just as
  it does for `stage2.s`. `--bootstrap-from-self` regenerates it every
  round. `rt.s` is assembled once into `rt.o` and linked into every stage
  and every program, next to what is left of `actor_runtime.o`.
- `install.sh` ships `rt.o`. The driver's link line adds it.
- The C runtime's symbol table for the interpreter (`zyl_ffi_lookup`)
  keeps its entries. The names are declared `extern` in
  `actor_runtime.h`, and the ported entries resolve to `rt.o`.

## Port order

Leaf-first, one section per commit. Each commit passes `./boot.sh`,
`./run_regression_tests.sh --full --no-boot`, and `bench/matrix.py` with
no regression against the C version before that C code is deleted.

1. Infrastructure (done): the flag, the lock, the primitives, exports, the
   build. First entries: the C-string leaf functions (`zyl_cstr_len`,
   `_eq`, `_cmp`, `_byte_at`, `_key_matches`).
2. The SIMD family (SSE2, then AVX2 dispatch) and vector string scans (done).
3. Strings and formatting: concat/substr/int text/sanitize/mangle,
   spans, BLAKE3.
4. Data structures: smap, wvec, typed arrays, attr tables, refs, cells.
5. The allocator and regions (it may not allocate itself).
6. `try`/panic through the unwind primitive, contracts, the test runner.
7. Files, processes, environment, the terminal (REPL line editor).
8. FFI pinning and timed calls, actors and threads, the big-stack entry.
9. Delete `actor_runtime.c`.
10. Go libc-free: `_start`, syscalls in place of every libc call
    (mmap, write, clone, futex, execve, ioctl), and Zyl number
    formatting and parsing, which must be correctly rounded. Link
    statically with `ld`, or dynamically only for `ffi-call` programs.
11. Done: a Zyl assembler and static ELF linker, so no external tool is
    left. `compiler/asm_x86` parses exactly the assembly the native
    backend emits (Intel noprefix: the full GPR/SSE/AVX set the compiler
    uses, `sym@GOTPCREL`, `fs:sym@tpoff`, `.tbss`, and the rest of the
    corpus) and encodes it, with placeholder relocations; per-form bytes
    match GNU `as`. `compiler/elf_link` assembles prog.s + rt.s +
    start.s, lays out a r-x text segment (headers, `.text`, `.rodata`, a
    synthesized GOT), a rw data/bss segment, a PT_TLS for `.tbss` (tpoff
    = offset − aligned block size, as `zyl_rt_start` expects) and a
    non-exec PT_GNU_STACK, resolves every relocation against a fixed
    load base (weak-undefined → 0, strong-undefined → error), and writes
    a static ET_EXEC. The driver's freestanding path (single files and
    package builds) uses it by default, with no cc/as/ld;
    `ZYL_EXTERNAL_LD=1` restores the cc link. The runtime is assembled
    once into `rt.zo` in the bundle (`zyl rt-cache`, run by `boot.sh`;
    `install.sh` ships it): the bytes of rt.s + start.s, their relocations
    pre-resolved (same-section pc refs patched, the rest kept as
    section + offset), the exported globals, weak names and thread-locals.
    It is keyed by the BLAKE3 of rt.s and start.s and carries its own
    length, so a stale or torn cache is rebuilt (and rewritten, best
    effort) in memory; a hit and a miss give byte-identical binaries. A
    hello-world links in about 30 ms. Hosted (foreign-calling) programs
    still link over libc's crt with cc. `boot.sh`/`install.sh` ship
    `rt.s`, `start.s` and `rt.zo` beside `rt.o`/`start.o`.

## The libc-free phase

After runtime/actor_runtime.c is gone, the runtime still reaches libc
through `extern`: malloc, pthreads, stdio, dlsym, posix_spawn and
atexit. Removing libc means providing each of
these, and it splits programs into two link modes.

- **Freestanding (default):** a program with no `ffi-call` to foreign
  code. The runtime emits `_start`. It reads argc, argv, envp and auxv
  from the initial stack, allocates the static TLS block from PT_TLS
  (found through AT_PHDR), and sets fs with arch_prctl, including the
  x86-64 TCB self pointer at fs:0, which `%tls` relies on. It then calls
  main. The replacements for the libc pieces:
  - malloc: mmap-backed size classes;
  - threads: clone with CLONE_SETTLS and CLONE_CHILD_CLEARTID, a TLS
    block per thread, and futex-based mutexes, condition variables and
    joins;
  - stdio: a buffered stdout/stderr writer, which generated code's print
    calls too, and which is flushed at exit and before reads and execs;
  - the environment: getenv scans envp;
  - process spawning: fork/execve for spawn;
  - exit: an own atexit registry, then exit_group.

  The binary is linked with `ld -static`, with no libc.
- **Hosted:** a program that calls foreign C code. That code needs
  libc's own start-up and TLS, and needs pthreads if a foreign callback
  runs on an FFI worker. So the program keeps libc's crt, and the
  runtime is built in a hosted flavour whose thread and memory entries
  call libc. The flavour is a link-time choice. The compiler picks it
  from whether the program's graph uses `ffi-call` on a non-runtime
  symbol, and both flavours must give identical observable behaviour.

The `stdout` ordering rule holds in both: every write to fd 1 goes
through one buffer.

## Performance

Perf is the project's top priority (see `docs/native-backend-design.md`).
The C runtime is built with `-O2`. During the port, a section may call
libc for its hot inner loops through the bridge. The finished runtime
uses the SIMD family instead. When a section cannot reach parity, the
fix goes into the backend, and the C version is kept until then.
