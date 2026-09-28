#include "actor_runtime.h"
long long zyl_ralloc(long long size, long long rp);
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>

/* Lowest address the kernel will ever map on Linux by default
 * (/proc/sys/vm/mmap_min_addr, 0x10000 on most distros; 0x1000 is the
 * conservative floor even on the most permissive configs). Used to reject
 * small bogus integers misused as pointers before dereferencing them. */
#define ZYL_MIN_CALL_ADDR 0x1000LL

#include <sys/mman.h>
#include <sys/syscall.h>
#include <pthread.h>

/* ==========================================================================
   try/catch — panic handler stack. Generated code allocates a frame, links
   it, calls setjmp on its buffer, and branches to its catch path when
   siglongjmp returns nonzero. zyl_panic unwinds to the innermost frame.
   ========================================================================== */

#include <setjmp.h>
#include <stdlib.h>

struct ZylTryFrame {
    jmp_buf buf;
    struct ZylTryFrame* prev;
    const char* msg;
    void* region_mark;   /* zyl_region_top when the handler was installed */
};

/* Thread-local: each actor runs its own thread with independent try/catch
 * nesting. A process-global here would let one actor's zyl_try_pop/
 * zyl_panic unlink or longjmp into another actor's frame/stack. */
static _Thread_local struct ZylTryFrame* g_try_top = 0;

void* zyl_try_push(void) {
    struct ZylTryFrame* f = (struct ZylTryFrame*)malloc(sizeof *f);
    f->prev = g_try_top;
    f->msg = 0;
    f->region_mark = zyl_region_mark();
    g_try_top = f;
    return (void*)f;
}

void zyl_try_pop(void) {
    if (g_try_top) g_try_top = g_try_top->prev;
}

const char* zyl_try_last_msg(void) {
    return g_try_top ? g_try_top->msg : 0;
}

/* The `msg` field of a specific frame (the pointer zyl_try_push returned
 * for it) -- unlike zyl_try_last_msg, valid to call AFTER a longjmp has
 * already unlinked that frame from g_try_top (zyl_panic pops before it
 * jumps), which is exactly when generated try/catch code needs it: the
 * frame pointer it saved across the longjmp is the only remaining
 * reference to it. */
long long zyl_try_frame_msg(long long frame) {
    if (!frame) return 0;
    return (long long)(size_t)((struct ZylTryFrame*)(size_t)frame)->msg;
}

/* ==========================================================================
   Raw memory arena — foundation for stdlib/allocator.
   Pointers are passed to/from Zyl as Int (64-bit).
   ========================================================================== */

/* ==========================================================================
   Character-level string access — substrate for the self-hosting lexer.
   ========================================================================== */

/* String views (stdlib text/view): a view is {base, off, len} with
   off + len <= strlen(base), checked once by zyl_view_ok when the view is
   made. The accessors below trust that invariant and never call strlen,
   so they are restricted to the standard library (ffi-raw-p). */

/* Decode a Zyl string literal body (src[start..end], `start` points past the
   opening quote): handle \n \t \" \\ escapes. Returns a NUL-terminated buffer
   in `arena`, or 0 if an escape is unterminated (caller reports a lex error).
   Deterministic: decodes left-to-right in source order. */

/* ==========================================================================
   Source spans.

   Ast nodes (compiler/ast.zyl) carry no position field. Giving them one
   would mean editing every one of the ~470 sites that name an Ast
   constructor -- as a pattern in one place and as a construction in the
   next -- inside a compiler that then has to go on compiling itself, and
   a single miscounted pattern arity there is a silent miscompile rather
   than a build error. So the position lives beside the node instead of
   inside it: the reader records, for each node it builds, the byte offset
   it was read from, keyed by the node's own address.

   That is sound here because a variant value in this implementation IS
   its heap pointer, and arena memory is never freed, moved or reset
   during a compile -- a node's address stays valid for as long as any
   diagnostic can ask about it.

   The table is only ever probed by key, never iterated, so its layout
   cannot reach the output of a compile: determinism is unaffected. A
   miss returns -1 and the diagnostic simply prints without a location.
   ========================================================================== */

/* Node attribute tables, string maps and word vectors for compiler passes.
   Keyed by address or content, probed only (never iterated); a miss reads 0. */

typedef struct { uintptr_t key; long long val; } ZylAttrSlot;

/* Process-wide instances, created on first use. */

#include <sys/stat.h>
long long zyl_heap_alloc(long long size);

/* ==========================================================================
   FFI pinning — copy an 8-byte value to a stable Pin arena location and back.
   ========================================================================== */

/* === Test Harness === */

#include <setjmp.h>

#define ZYL_MAX_TESTS 256
#define ZYL_TEST_NAME_LEN 128

typedef struct {
    char name[ZYL_TEST_NAME_LEN];
    int (*fn)(void);
} ZylTestEntry;

static ZylTestEntry g_tests[ZYL_MAX_TESTS];
static int g_test_count = 0;

/* Recovery point for panics raised inside a running test. */
static jmp_buf g_test_jmp;
static int g_in_test = 0;
static void* g_test_region_mark = 0;

void zyl_register_test(const char* name, int (*fn)(void)) {
    if (g_test_count < ZYL_MAX_TESTS) {
        strncpy(g_tests[g_test_count].name, name, ZYL_TEST_NAME_LEN - 1);
        g_tests[g_test_count].name[ZYL_TEST_NAME_LEN - 1] = '\0';
        g_tests[g_test_count].fn = fn;
        g_test_count++;
    }
}

long long zyl_diag_json(void);
long long zyl_json_quote(long long s);

/* JSON-mode panic: a message err-diag already rendered as JSON passes
 * through; a bare "E_CODE: text" or "error[E_CODE]: text" is wrapped
 * with its code split off. */
static void zyl_panic_json(const char* msg) {
    if (msg[0] == '{') { fprintf(stderr, "%s\n", msg); return; }
    size_t k = 0;
    if ((msg[0] == 'E' || msg[0] == 'W') && msg[1] == '_') {
        k = 2;
        while ((msg[k] >= 'A' && msg[k] <= 'Z') || (msg[k] >= '0' && msg[k] <= '9') || msg[k] == '_') k++;
        if (msg[k] != ':') k = 0;
    }
    char code[128] = "";
    const char* text = msg;
    if (k && k < sizeof(code)) {
        memcpy(code, msg, k);
        code[k] = 0;
        text = msg + k + 1;
        while (*text == ' ') text++;
    } else if (strncmp(msg, "error[", 6) == 0) {
        /* "error[E_CODE]: text", as the type pass's summary is written. */
        const char* e = strchr(msg + 6, ']');
        if (e && e[1] == ':' && (size_t)(e - msg - 6) < sizeof(code)) {
            memcpy(code, msg + 6, (size_t)(e - msg - 6));
            code[e - msg - 6] = 0;
            text = e + 2;
            while (*text == ' ') text++;
        }
    }
    fprintf(stderr,
        "{\"severity\":\"error\",\"code\":%s,\"message\":%s,\"file\":\"\",\"line\":0,\"column\":0,\"labels\":[],\"help\":\"\"}\n",
        (const char*)(size_t)zyl_json_quote((long long)(size_t)code),
        (const char*)(size_t)zyl_json_quote((long long)(size_t)text));
}

void zyl_panic(const char* msg) {
    if (g_try_top) {
        struct ZylTryFrame* f = g_try_top;
        g_try_top = f->prev;
        f->msg = msg ? msg : "error";
        zyl_region_unwind(f->region_mark);
        longjmp(f->buf, 1);
    }
    if (g_in_test && !zyl_ffi_on_worker()) {
        /* Panic inside a test: unwind to the runner and mark it failed
         * instead of killing the whole process. */
        g_in_test = 0;
        zyl_region_unwind(g_test_region_mark);
        longjmp(g_test_jmp, 1);
    }
    if (zyl_diag_json()) {
        zyl_panic_json(msg ? msg : "assertion failed");
        exit(1);
    }
    fprintf(stderr, "PANIC: %s\n", msg ? msg : "assertion failed");
    exit(1);
}

int zyl_run_tests(void) {
    int passed = 0;
    int failed = 0;

    for (int i = 0; i < g_test_count; i++) {
        const char* name = g_tests[i].name;
        int (*fn)(void) = g_tests[i].fn;

        /* Print test name (as C string via print-int trick — use file-write) */
        printf("test: %s ... ", name);
        fflush(stdout);

        g_test_region_mark = zyl_region_mark();
        if (setjmp(g_test_jmp) == 0) {
            g_in_test = 1;
            int result = fn();
            g_in_test = 0;
            if (result == 0) {
                printf("ok\n");
                passed++;
            } else {
                printf("FAIL\n");
                failed++;
            }
        } else {
            /* Landed here via zyl_panic longjmp. */
            printf("FAIL\n");
            failed++;
        }
    }

    printf("\ntest result: %d passed, %d failed, %d total\n", passed, failed, passed + failed);

    return (failed > 0) ? 1 : 0;
}

/* ── Boot-build file helpers (used by the self-hosted driver) ───────── */
#include <fcntl.h>
#include <sys/stat.h>

/* (exit code): flush buffered output, then end the process. */
long long zyl_exit(long long code) {
    fflush(stdout);
    fflush(stderr);
    exit((int)code);
}

/* (read-line): one line from stdin without its newline; "" at end of input. */
long long zyl_read_line(void) {
    fflush(stdout);
    size_t cap = 128, n = 0;
    char* buf = (char*)malloc(cap);
    if (!buf) return (long long)(size_t)"";
    char c;
    while (read(0, &c, 1) == 1 && c != '\n') {
        if (n + 1 >= cap) { char* nb = (char*)realloc(buf, cap * 2); if (!nb) break; buf = nb; cap *= 2; }
        buf[n++] = c;
    }
    if (n > 0 && buf[n - 1] == '\r') n--;
    char* out = (char*)(size_t)zyl_heap_alloc((long long)n + 1);
    if (out) { memcpy(out, buf, n); out[n] = 0; }
    free(buf);
    return out ? (long long)(size_t)out : (long long)(size_t)"";
}

/* Stub: Zyl-level (error msg) — print and exit(1).
   Named zyl_f_error (not f_error) so the codegen label `f_error` for a
   user Zyl function named `error` cannot shadow/self-recursively bind it. */
long long zyl_f_error(long long msg) {
    if (msg) fprintf(stderr, "error: %s\n", (const char*)(size_t)msg);
    else fprintf(stderr, "error\n");
    exit(1);
}

/* Append src at the end of the NUL-terminated string in dst.
   Used by the Zyl-level buf-append wrapper so repeated appends
   accumulate (matching the Rust bootstrap's StringBuffer backend).

   Codegen re-appends into the same handful of long-lived buffers
   (chiefly the single ~MB-scale asm output buffer) tens of thousands
   of times per compile. Re-scanning from byte 0 on every call makes
   the whole pass O(n^2) in final buffer size -- for a self-hosted
   compile of its own ~3MB output this never finished in practice
   (confirmed via gdb: stuck inside this scan). Small direct-mapped
   cache of (address -> known end pointer) turns the common repeated-
   same-buffer case O(1) amortized; a miss (new/rare address, or hash
   collision) just falls back to the original full scan once. */
/* Thread-local: keyed by hashed address only, so two actors appending to
 * different buffers that hash to the same slot would otherwise race on a
 * shared cache entry and could write through a stale cached end-pointer
 * into memory they don't own. Use SipHash-like mixing for better distribution. */

/* ── CLI helpers (used by the self-hosted driver) ─────────────────────── */
#include <unistd.h>

/* Diagnostic format: 1 = JSON (one object per diagnostic), 0 = text.
 * Set only by the compiler (--error-format=json); programs keep text. */
static int g_diag_json = 0;

long long zyl_diag_json(void) {
    return g_diag_json;
}

long long zyl_diag_json_set(long long on) {
    g_diag_json = on ? 1 : 0;
    return 0;
}

/* Warning sink: stderr by default; a capturing caller (the LSP) collects
 * them instead and drains the buffer with zyl_warn_take. */
static char* g_warn_buf = NULL;
static size_t g_warn_len = 0, g_warn_cap = 0;
static int g_warn_capture = 0;

long long zyl_warn_capture(long long on) {
    g_warn_capture = on ? 1 : 0;
    g_warn_len = 0;
    return 0;
}

long long zyl_warn_emit(long long msg) {
    const char* m = msg ? (const char*)(size_t)msg : "";
    size_t n = strlen(m);
    if (!g_warn_capture) {
        ssize_t w = write(2, m, n);
        w = write(2, "\n", 1);
        (void)w;
        return 0;
    }
    if (g_warn_len + n + 2 > g_warn_cap) {
        size_t nc = g_warn_cap ? g_warn_cap : 1024;
        while (g_warn_len + n + 2 > nc) nc *= 2;
        char* nb = (char*)realloc(g_warn_buf, nc);
        if (!nb) return 0;
        g_warn_buf = nb;
        g_warn_cap = nc;
    }
    memcpy(g_warn_buf + g_warn_len, m, n);
    g_warn_len += n;
    g_warn_buf[g_warn_len++] = '\n';
    g_warn_buf[g_warn_len] = 0;
    return 0;
}

/* Captured warnings, newline-separated; the buffer is reset. */
long long zyl_warn_take(void) {
    char* out = (char*)malloc(g_warn_len + 1);
    if (!out) return (long long)(size_t)"";
    if (g_warn_len) memcpy(out, g_warn_buf, g_warn_len);
    out[g_warn_len] = 0;
    g_warn_len = 0;
    return (long long)(size_t)out;
}

/* `s` as a quoted JSON string literal (malloc'd). */
long long zyl_json_quote(long long s) {
    const unsigned char* p = s ? (const unsigned char*)(size_t)s : (const unsigned char*)"";
    size_t n = strlen((const char*)p);
    char* out = (char*)malloc(n * 6 + 3);
    if (!out) return (long long)(size_t)"\"\"";
    size_t j = 0;
    out[j++] = '"';
    for (size_t i = 0; i < n; i++) {
        unsigned char c = p[i];
        if (c == '"' || c == '\\') { out[j++] = '\\'; out[j++] = (char)c; }
        else if (c == '\n') { out[j++] = '\\'; out[j++] = 'n'; }
        else if (c == '\t') { out[j++] = '\\'; out[j++] = 't'; }
        else if (c == '\r') { out[j++] = '\\'; out[j++] = 'r'; }
        else if (c < 0x20) { j += (size_t)sprintf(out + j, "\\u%04x", c); }
        else out[j++] = (char)c;
    }
    out[j++] = '"';
    out[j] = 0;
    return (long long)(size_t)out;
}

/* ── Interpreter support (stdlib/repl/interp.zyl) ───────────────────────
   The REPL evaluates a lowered ICNF program in this process instead of
   generating machine code for it. Three things only C can provide:
   calling an arbitrary FFI symbol by name, doing real double arithmetic
   on values the interpreter carries as bit patterns, and turning a
   String into the machine word every other layer already knows it is. */

/* A String and its address are the same thing at runtime; the type
   system is what distinguishes them. The interpreter stores every value
   as a machine word, so it needs to cross that line explicitly rather
   than by accident. */
long long zyl_word_of_cstr(long long s) { return s; }

/* A fresh id, unique for the life of the process and monotonically
   increasing. icnf.zyl names its lifted match-arm and lambda helpers
   with it, so it has to be deterministic: a fresh process compiling the
   same source asks for ids in the same order and gets the same ones,
   which is what keeps stageN and stage(N+1) byte-identical.

   It used to be the compile arena's byte offset, which is also
   deterministic but restarts whenever the arena does. The REPL compiles
   many programs in one process and reclaims each entry's arena, so two
   entries would name two unrelated lambdas `_lambda_1234` and a closure
   stored from the first would call the second. A counter that never
   resets cannot do that. */

/* The interpreter's test registry. A `(test "name" ...)` form lowers to
   a zyl_register_test call whose second argument is the address of the
   generated test function -- which, under the interpreter, is not an
   address at all but an interpreter value. So the interpreter keeps its
   own registry of those values and runs the tests itself, printing what
   zyl_run_tests prints, character for character, because the regression
   suite compares the two outputs. */

/* The two lines zyl_run_tests writes, so that an interpreted run and a
   compiled run produce the same transcript. */
long long zyl_itest_start(long long name) {
    printf("test: %s ... ", (const char*)(size_t)name);
    fflush(stdout);
    return 0;
}

long long zyl_itest_outcome(long long ok) {
    printf(ok ? "ok\n" : "FAIL\n");
    return 0;
}

long long zyl_itest_summary(long long passed, long long failed) {
    printf("\ntest result: %lld passed, %lld failed, %lld total\n",
           passed, failed, passed + failed);
    return (failed > 0) ? 1 : 0;
}

/* Name-to-value map for the interpreter's function table. Finding the
   callee by walking a list is fine for one expression at a prompt and
   hopeless for a program that makes millions of calls: a lowered
   program has thousands of functions in it, and the walk is per call.
   One map, rebuilt when the table changes, makes the lookup a hash.

   Open addressing, no deletion, contents replaced wholesale -- the
   interpreter rebuilds it for each program it runs. Lookup order never
   affects a result, so nothing here can make a run non-deterministic. */

/* A heap block for the interpreter: the same payload compiled code
   builds -- [tag][field]... with zyl_heap_alloc's qword-count header
   right in front of it, which is what zyl_variant_eq and
   zyl_variant_field read -- plus one more hidden word ahead of that,
   recording what kind each field is (two bits apiece, lowest field
   first: 0 Int, 1 String, 2 Float, 3 pointer).

   Compiled code has no such word: codegen binds every destructured
   field as an Int, so a String pulled out of a variant prints as its
   address. The interpreter can do better for free, and this is where it
   keeps what it needs to. The magic tag is what makes the word safe to
   read: a block that came from anywhere else answers "no kinds", and
   its fields read back as Int exactly as before. */

/* A stable copy of a constructor's name, deduplicated by content.

   The name the interpreter gets comes from an ICNF node, which lives in
   the arena that entry compiled into -- and that arena is released when
   the entry finishes, while the value it built may outlive it in a
   session binding. Copying the name per construction would put a
   `strlen` and an allocation on the hot path of every `Cons`; interning
   it puts them on the first one only.

   The table never shrinks, which is what "stable" requires: something
   is still pointing at every entry. Names are few -- one per
   constructor in the program. */

/* Milliseconds on a monotonic clock. The REPL's `:time` uses it; it is
   deliberately not available to a compiled program's determinism-
   sensitive paths through any other name, and nothing in the compiler
   calls it. */
#include <time.h>

/* The other direction, for a word the interpreter knows points at
   NUL-terminated bytes. Also the identity; also there for the type
   system rather than the machine. */

/* The IEEE-754 bit pattern of a Float, as an Int (a Float travels in a
   general register as its bits, so this is the identity too). Typed
   Float -> Int, it is how Hash hashes a Float without a cast. */

/* The Float whose IEEE-754 bit pattern is `w`. Every 64-bit pattern is
   some double (a NaN at worst), so this is total and safe to expose. */

/* Raw word access for the interpreter, which runs word-level ICNF: the
   word at address `a`, and a store to it. Typed Int -> Int and
   Int Int -> Unit; they are raw memory access, so the checker only lets
   the standard library call them (arity_check.zyl, E_FFI_RESTRICTED). */

/* `p` advanced by `n` bytes. */

/* The NUL-terminated bytes at `p`, as a String (the identity). */

/* ==========================================================================
   Timed FFI calls — `(ffi-call "sym" args... timeout-ms)` on foreign code.

   The compiler lowers every ffi-call to a symbol outside this runtime to
   zyl_ffi_timed(address, name, timeout-ms, argc, args...). The call runs
   on a worker thread that belongs to the calling thread (one per actor,
   created on first use and kept, so thread-local state such as errno
   stays consistent from one call to the next). The caller waits on a
   monotonic clock; if the foreign function has not returned when the
   timeout expires, the caller raises E_FFI_TIMEOUT.

   A running C function cannot be stopped safely (it may hold a lock, be
   halfway through a write, or own memory), so an overrunning call is
   abandoned, not killed: its worker finishes on its own and then frees
   itself, and the calling thread gets a fresh worker for its next call.
   Because the abandoned call may still read or write anything it was
   handed, nothing it could reach is reclaimed afterwards: Pin slots are
   never freed individually anyway, and once any call has been abandoned
   the exit-time arena teardown is skipped.

   Determinism: whether a timeout fires depends on how long foreign code
   runs, which the language cannot control. Spec §27 counts FFI results
   as observable external input; a timeout is one such result, exactly
   like a value the C function returns.
   ========================================================================== */

/* Doubles, carried as their bit patterns. The interpreter stores every
   value in one machine word, so a Float is its IEEE-754 bits and every
   operation on it crosses through here. Compiled code uses the SSE unit
   on the same bit patterns, so the results agree bit for bit. */
static double zyl_d_of(long long bits) {
    double d;
    memcpy(&d, &bits, sizeof(d));
    return d;
}

/* print, in each of the three shapes codegen emits, so that interpreted
   output is byte-identical to compiled output. */
long long zyl_print_int(long long n) { printf("%lld\n", n); return 0; }
long long zyl_print_str(long long s) { printf("%s\n", (const char*)(size_t)s); return 0; }
long long zyl_print_float(long long bits) { printf("%f\n", zyl_d_of(bits)); return 0; }

/* Sixteen process-wide word cells for compiler passes (the type pass's
   strict-mode flag and current node). */
static long long g_cells[16];
long long zyl_cell_get(long long i) { return (i >= 0 && i < 16) ? g_cells[i] : 0; }
long long zyl_cell_set(long long i, long long v) { if (i >= 0 && i < 16) g_cells[i] = v; return 0; }

/* ==========================================================================
   Word arrays (math/words): a bounds-checked handle instead of a raw base
   address, so no Zyl code does address arithmetic (docs/sound-types-
   design.md). A handle is {magic, length, data}; a view shares its
   parent's data. Out-of-range access is E_INDEX_OUT_OF_BOUNDS.
   ========================================================================== */

