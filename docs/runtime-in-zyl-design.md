# The Runtime in Zyl: Design

Status: done (2026-09-28). The runtime is Zyl, `runtime/rt/*.zyl`; the
C runtime (`runtime/actor_runtime.c`, 5.5k lines) is deleted, and the
runtime it left behind exports 385 entries (the top-level `zyl_*`
definitions). Programs without foreign calls are static
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
- The end state has no C in it. No C source is left in the runtime or the
  compiler (the tree's remaining `.c` files are the `bench/` microbenchmarks
  a Zyl run is compared against, and one native-dependency fixture under
  `tests/packages-build/`), and no libc sits under Zyl programs. The
  runtime talks to Linux through `%syscall`, starts at its own `_start`,
  allocates with `mmap`, starts threads with `clone` and blocks on
  `futex`. It also sets up thread-local storage itself and does its own
  number formatting and parsing. Binaries are static. Only a program that
  `ffi-call`s a foreign C library links the system's libc and dynamic
  loader, because that library needs them. (During the port, the
  remaining C and libc were used as a bridge.)

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
   `E_FFI_RESTRICTED` in any other compile. That includes user programs,
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
- Integer `+ - *` are checked, like every package's by default —
  `runtime/rt/rt.zyl` says `(numeric checked)` explicitly — so an overflow
  traps with `E_OVERFLOW` rather than wrapping. The seed is full of
  `jo zyl_rt_trap_ovf` sites.

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

## Panic backtrace

An uncaught panic names where it happened. Under the `PANIC:` line the
runtime prints the call chain to stderr, innermost first, one function
per line, 32 lines at most, names only:

```
PANIC: E_INDEX_OUT_OF_BOUNDS: vec-get! index 9 is outside a Vec of 0 elements
  = help: use `(vec-get? v i)` and match its Option, or check the index against `vec-len` first
  in vec-get!
  in parse-line
  in parse-file
  in main
```

The `= help:` line is part of the panic's own text, so it comes before the
frames; `vec-get!` is listed because it is a call, not an inlined body. A
function that was inlined into its caller, or that tail-called its way
out of its frame, does not appear at all.

It is printed only on the path that ends the process (`pn-panic-text`):
a panic caught by `try`/`catch` or by the test harness prints nothing,
the JSON diagnostic mode prints the object it always printed, and a
panic whose text is a rendered diagnostic (`error[CODE]: ...`, the
compiler reporting on the program it is compiling) gets no backtrace,
since it reports a fault in another program. `zyl eval` and `zyl repl` switch it off
(`zyl_backtrace_set false`), since an interpreted program's frames are
the interpreter's. Nothing runs until a panic
happens, so the walk costs nothing in a run that does not panic (the
frame pointers below are a cost every run pays). Before the PANIC line
stdout is flushed, so a program's output comes first.

An actor's panic ends only the actor: its thread's try frame catches it,
and the message is re-raised by `actor-wait` on the joining thread. The
backtrace printed is therefore the joiner's (`in main` for a `main` that
waits), not the actor's own frames, which are gone by then. Keeping the
actor's frames would mean capturing them on a caught path, which this
does not do.

**The walk.** `zyl_rt_frame_addr` (an assembler stub, `mov rax, rbp`)
gives the walker its own frame; from there each frame holds the caller's
rbp at `[fp]` and a return address at `[fp+8]`. Every emitted function
keeps rbp: the stack machine's prologue always has, the native backend's
framed functions have, and a push-only MIR function that makes a call
now pushes rbp as well (`mf-leaf`; a leaf, which cannot be on any chain,
stays frameless). A tail call replaces its caller's frame and an inlined
call has none, so neither appears -- the backtrace is of the frames that
exist, as with any optimizing compiler. The walk stops at a saved rbp of
0 (`_start` and the child side of `zyl_rt_clone` zero it, as glibc's
clone does for a hosted thread, so a thread's chain ends at its entry),
at a frame that is not above the current one or not 8-aligned, at a
frame whose page `mincore` reports unmapped (so a corrupt chain stops
the walk rather than faulting inside the panic), and after 4096 frames.
Each return address is looked up at `ra - 1`, the byte inside the call.

**The table.** Codegen writes `zyl_syms` into `.rodata` of every
program (not of a runtime module): a count, then one pair per function
in emission order -- which is address order -- of the function's offset
from the pair (`.long sym - .`) and its name's offset from the table,
an end pair at the entry stub `main`, then the names, NUL-terminated.
A lookup is a binary search for the greatest start not above the
address; an address outside `[first, main)` -- the runtime's own
functions, libc, the entry stub -- is skipped, which is why runtime
frames (`zyl_panic`, `zyl_vec_get`) are not listed. The name is the
symbol after the last `::` of the canonical key, so a specialization
is cut at its `~` (`parse-line`, not `parse-line~Vec<Int>,Int`) and a
method keeps its `Trait.method` spelling. The
runtime reaches the table through `%fn-weak "zyl_syms"`, 0 when the
image has none. The Zyl assembler reads `.long sym - .` as a kind-1
(pc-relative) relocation, the same it emits for a `[rip+sym]` operand
with addend 0, and GNU as reads it natively, so the hosted and the
freestanding link carry the same table. The table depends only on the
functions and their order, so two compiles of one source stay
byte-identical (the determinism gate checks this); its label is
indented so that `verify.zyl`'s census does not count it as a function.
It is 8 bytes plus the name per function: in `zyl-self` it is 5783
functions, 123,040 bytes (45 KB of pairs, 75 KB of names), 3.1% of the
3.8 MB binary.

**Cost of the frames.** Giving every calling push-only function a frame
pointer costs `push rbp; mov rbp, rsp; pop rbp` per call. Measured on
`bench/` (best of 3, which is what `bench/matrix.py` reports): fib +3%,
trees +2%, vec +2%, loop and list within noise. The first version framed
those functions fully (`sub rsp` and reloads from slots), which cost fib
11% and loop 14%; the light frame is what made it affordable.

**Source lines** are not printed. The frame table planned for
provenance (`PROGRESS.md`, open work) would not give them either: lines
need a second table keyed by call site, not by function -- a label after
each emitted `call` and a pair of (site offset, span) per label, where
the span is what `zyl_span_file`/`zyl_span_off` already hold for the
ICNF node being lowered. The walker would look up each return address
in that table exactly as it does in `zyl_syms`. The mechanism is the
one built here; the cost is one entry per call site rather than per
function, which for the compiler is about 110k sites.

`tests/scripts/panic-backtrace.sh` checks the exact lines, the cap, the
two link modes, an actor's re-raise, the caught paths (`try`/`catch`
and the test harness) and the byte identity of two compiles.

## Performance

Perf is the project's top priority (see `docs/native-backend-design.md`).
Each ported section was measured against the `-O2` C before the C was
deleted; where it fell behind (strings, byte microbenchmarks), the fix
went into the backend. The runtime's hot loops use the SIMD family.
