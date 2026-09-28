# The Runtime in Zyl: Design

Status: done (2026-09-28). The runtime is Zyl, `runtime/rt/*.zyl`; the
C runtime (`runtime/actor_runtime.c`, 5.5k lines, about 400 entry
points) is deleted. Programs without foreign calls are static
executables with no libc, assembled and linked by the compiler itself;
foreign-calling programs link hosted over libc. No unsafe construct was
added to the language. This document records the design.

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
  that library needs them. (During the port, the remaining C and libc
  were used as a bridge.)

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
   the way they reached the C runtime: codegen calls them, and
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
| `(%cas a expect new)`, `(%fetch-add a v)`, `(%xchg a v)`, `(%fence)` | seq-cst atomics |
| `(%global "name" size)`, `(%tls "name" size)`, `%tls-get`, `%tls-set` | zeroed static / thread-local storage, per name |
| `(%fn "sym")`, `(%fn-weak "sym")`, `(%call0 f)` .. `(%call16 f args...)` | a code address (0 for a missing weak one); an indirect call |
| `(%syscall0 n)` .. `(%syscall6 n a1..a6)` | Linux x86-64 syscall |
| `%f64`, `%f64-bits`, `%f64-of-int`, `%f64-to-int` | Float/word casts and conversions |
| `%udiv`, `%urem`, `%mul`, `%mulhi`, `%mulhi-s` | unsigned division, full products |
| `%popcnt`, `%clz`, `%ctz`, `%bswap`, `%rotl`, `%rotr` (and 32-bit forms), `%crc32c-u8`, `%crc32c-u64` | bit operations; the language's bit intrinsics lower to these |
| `%cpuid-eax` .. `%cpuid-edx`, `%xgetbv` | CPU feature probes |
| `%aes-enc`, `%aes-enclast`, `%aes-expand-128`, `%aes-expand-256` | AES-NI rounds |
| `%v128-*`, `%v256-*`, `%fill` | the SIMD family (below) and a block fill |

In a runtime module, `(ffi-call "sym" ... t)` to a C symbol is a direct
call, without the timeout worker (the hosted flavour's weak libc
references). The timeout literal is still required, but it is ignored.
Primitive failures are `E_FFI_RESTRICTED`: a `%` symbol outside the
runtime module is refused with that code, and no new code is added.

`try` needs no primitive: the runtime emits `zyl_rt_setjmp`,
`zyl_rt_longjmp` and `zyl_rt_try_call`, generated code saves its frame
inline, and the saved rbp, rsp and rip are mangled with a per-process
getrandom guard (XOR, then rotate left 17).

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
  round, with the same compiler as that round's compiler, so generated
  code and the runtime agree on shared formats. `boot.sh` fails when a
  `zyl_*` defn is not emitted.
- `rt.s` is assembled into `rt.o` (every compiler stage links with it)
  and, with `start.s`, into the cache `rt.zo` for the Zyl linker.
  `install.sh` ships `rt.s`, `start.s`, `rt.zo`, `rt.o` and `start.o`.
- The interpreter's symbol table (`ffitab.zyl`, `zyl_ffi_lookup`) maps
  every runtime entry the REPL may call to its address (`%fn`).

## How it was ported

Leaf-first, one section per commit, each passing `./boot.sh`, the full
suite and `bench/matrix.py` against the C before that C was deleted:
C-string leaves; the SIMD family and vector string scans; strings,
number text and BLAKE3; the compiler's data structures; the allocator
and frame regions; try frames and panics (replacing setjmp/longjmp);
files, processes, environment and the terminal; FFI pinning, timed
calls, actors and threads; deleting `actor_runtime.c`; the libc-free
phase below; and last, the Zyl assembler (`compiler/asm_x86`) and static
ELF linker (`compiler/elf_link`), so no external tool is left for a
freestanding program.

The linker lays out a r-x text segment (headers, `.text`, `.rodata`, a
synthesized GOT), a rw data/bss segment, a PT_TLS for `.tbss` (tpoff =
offset − aligned block size, as `zyl_rt_start` expects) and a non-exec
PT_GNU_STACK, resolves every relocation against a fixed load base
(weak-undefined → 0, strong-undefined → error), and writes a static
ET_EXEC. `rt.zo` holds the bytes of rt.s + start.s with their
relocations pre-resolved (same-section pc refs patched, the rest kept as
section + offset), the exported globals, weak names and thread-locals;
it is keyed by the BLAKE3 of rt.s and start.s and carries its own
length, so a stale or torn cache is rebuilt in memory, and a hit and a
miss give byte-identical binaries. A hello-world links in about 26 ms.

## Link modes

- **Freestanding (default):** a program with no `ffi-call` to foreign
  code. The runtime's `_start` reads argc, argv, envp and auxv from the
  initial stack, allocates the static TLS block from PT_TLS (found
  through AT_PHDR), and sets fs with arch_prctl, including the x86-64
  TCB self pointer at fs:0, which `%tls` relies on. It then calls main.
  In place of libc:
  - malloc: mmap-backed size classes (`heap.zyl`);
  - threads: clone with CLONE_SETTLS and CLONE_CHILD_CLEARTID, a TLS
    block per thread, and futex-based mutexes, condition variables and
    joins (`thread.zyl`);
  - stdio: one buffered stdout writer, which generated code's print
    calls too, flushed at exit and before reads and execs (`out.zyl`);
  - the environment: getenv scans envp (`env.zyl`);
  - process spawning: clone(CLONE_VM|CLONE_VFORK) plus execve, with
    glibc's PATH search (`proc.zyl`);
  - exit: the runtime's own exit registry, then exit_group.
- **Hosted:** a program that calls foreign C code. That code needs
  libc's own start-up and TLS, so the program keeps libc's crt and links
  with `cc`. `rt.o` references libc only weakly: pthreads (so a foreign
  callback on an FFI worker works), `dlsym`, `__cxa_atexit`, and
  malloc/free for `alloc-malloc` memory, so foreign C may free it. The
  observable behaviour is the same in both modes; on the runtime's own
  exit paths a foreign library's `atexit` handlers do not run.

The `stdout` ordering rule holds in both: every write to fd 1 goes
through one buffer.

## Performance

Perf is the project's top priority (see `docs/native-backend-design.md`).
Each ported section was measured against the `-O2` C before the C was
deleted; where it fell behind (strings, byte microbenchmarks), the fix
went into the backend. The runtime's hot loops use the SIMD family.
