#ifndef ZYL_ACTOR_RUNTIME_H
#define ZYL_ACTOR_RUNTIME_H

#include <stddef.h>
#include <stdint.h>
#include <pthread.h>

#define ZYL_MAX_ACTORS 1024
#define ZYL_MAX_MAILBOX 256

typedef enum {
    ZYL_MSG_DATA = 0,
    ZYL_MSG_CLOSURE = 1
} ZylMessageKind;

typedef struct ZylClosureMsg {
    void (*fn)(void*);
    void* state;
} ZylClosureMsg;

typedef struct ZylMessage {
    ZylMessageKind kind;
    void* data;
    struct ZylMessage* next;
} ZylMessage;

typedef struct ZylActor {
    void (*entry)(void*);
    void* state;
    ZylMessage* mailbox_head;
    ZylMessage* mailbox_tail;
    uint32_t mailbox_count;
    pthread_t thread;
    pthread_mutex_t lock;
    pthread_cond_t cond;
    int alive;
    int running;
    int joined;
    int parked;
} ZylActor;

typedef struct {
    ZylActor actors[ZYL_MAX_ACTORS];
    uint32_t next_id;
    int initialized;
} ZylActorSystem;

void zyl_actor_init(void);
uint32_t zyl_actor_spawn(void (*entry)(void*), void* state);
void zyl_actor_send(uint32_t actor_id, void* msg);
long long zyl_actor_self(void);
long long zyl_actor_receive(void);
void zyl_actor_send_data(uint32_t actor_id, void* data);
void zyl_actor_send_closure(uint32_t actor_id, void (*fn)(void*), void* state);
void zyl_actor_wait_all(void);
void* zyl_actor_thread_entry(void* arg);
long long zyl_actor_is_alive(long long actor_id);
long long zyl_actor_terminate(long long actor_id);
long long zyl_actor_wait(long long actor_id);

/* FFI pinning. */
void* ffi_pin(long long value);
long long ffi_unpin(long long ptr);

/* Raw memory arena. */
long long zyl_mem_alloc(long long size);
long long zyl_mem_free(long long ptr);
long long zyl_mem_read(long long ptr);
long long zyl_mem_write(long long ptr, long long value);
long long zyl_cstr_len(long long ptr);
long long zyl_cstr_concat(long long a, long long b);
long long zyl_cstr_substr(long long src, long long start, long long len);
long long zyl_cstr_eq(long long p1, long long p2);
long long zyl_variant_eq(long long a, long long b);
long long zyl_call0(long long);
long long zyl_call1(long long, long long);
long long zyl_call2(long long, long long, long long);
long long zyl_call3(long long, long long, long long, long long);
long long zyl_call4(long long, long long, long long, long long, long long);
long long zyl_call5(long long, long long, long long, long long, long long, long long);
long long zyl_call6(long long, long long, long long, long long, long long, long long, long long);
void* zyl_try_push(void);
void zyl_try_pop(void);
const char* zyl_try_last_msg(void);
void zyl_panic(const char* msg);
/* Character-level string access (self-hosting lexer substrate). */
long long zyl_cstr_byte_at(long long ptr, long long i);
void zyl_cstr_byte_set(long long ptr, long long i, long long b);
long long zyl_cstr_sub(long long arena, long long src, long long start, long long len);
long long zyl_cstr_to_int(long long ptr);
long long zyl_cstr_from_int(long long arena, long long value);
long long zyl_cstr_decode(long long arena, long long src, long long start, long long end);
long long zyl_cstr_count_newlines(long long src, long long end);
long long zyl_cstr_last_newline(long long src, long long end);

/* Region-based arena allocator.
   Deterministic reclamation: arena-reset frees every block at once; the
   handle stays valid for reuse. Arenas are single-threaded by design
   (consistent with actor isolation — one arena per actor/scope). */
long long zyl_arena_create(long long block_size);
long long zyl_arena_alloc(long long arena, long long size);
long long zyl_arena_alloc_zeroed(long long arena, long long size);
long long zyl_arena_reset(long long arena);
long long zyl_arena_destroy(long long arena);
long long zyl_arena_used(long long arena);
long long zyl_arena_capacity(long long arena);

/* Region-specific arena allocation wrappers for codegen. */
void zyl_ensure_arenas(void);
long long zyl_heap_alloc(long long size);
long long zyl_pin_alloc(long long size);
long long zyl_mlock(long long addr, long long len);
long long zyl_zeroize(long long addr, long long len);
long long zyl_random_fill(long long addr, long long len);
long long zyl_random_words(long long base, long long n);
long long zyl_cpuid_features(void);
long long zyl_aesni_available(void);
long long zyl_aes_encrypt_block(long long keybase, long long keybytes,
                                long long inbase, long long outbase);

/* Atomic operations. */
long long zyl_atomic_load(long long addr);
long long zyl_atomic_store(long long addr, long long value);
long long zyl_atomic_add(long long addr, long long value);
long long zyl_atomic_sub(long long addr, long long value);
long long zyl_atomic_max(long long addr, long long value);
long long zyl_atomic_min(long long addr, long long value);
long long zyl_atomic_cas(long long addr, long long expected, long long new_value);
long long zyl_atomic_fetch_add(long long addr, long long value);

/* CLI helpers. */
void zyl_save_args(int argc, char** argv);
long long zyl_argc(void);
long long zyl_arg_str(long long i);
long long zyl_dirname_cstr(long long path);
long long zyl_chdir(long long path);
long long zyl_getcwd(void);
long long zyl_system_cmd(long long cmd);
long long zyl_exec_cmd(long long cmd);

/* Package system (spec v5.0 §31). */
long long zyl_blake3_hex(long long arena, long long src, long long len, long long outbytes);
long long zyl_blake3_file_hex(long long arena, long long path, long long outbytes);
long long zyl_sym_escape(long long arena, long long src);
long long zyl_mangle_key(long long arena, long long key);

/* Interactive terminal primitives (REPL line editor). */
long long zyl_term_is_tty(long long fd);
long long zyl_term_raw_on(void);
long long zyl_term_raw_off(void);
long long zyl_term_read_byte(void);
long long zyl_term_read_byte_timeout(long long ms);
long long zyl_term_width(void);
long long zyl_term_height(void);
long long zyl_term_write(long long s);
long long zyl_term_flush(void);
long long zyl_mkdir_p(long long path);
long long zyl_cstr_from_byte(long long b);
long long zyl_cc_compile_log(long long path, long long logpath);

/* Interpreter support (stdlib/repl/interp.zyl). */
long long zyl_word_of_cstr(long long s);
long long zyl_fresh_id(void);
long long zyl_heap_swap(long long arena);
long long zyl_session_arena(void);
long long zyl_heap_block_p(long long w);
long long zyl_itest_add(long long name, long long fn);
long long zyl_itest_count(void);
long long zyl_itest_name(long long i);
long long zyl_itest_fn(long long i);
long long zyl_itest_reset(void);
long long zyl_itest_start(long long name);
long long zyl_itest_outcome(long long ok);
long long zyl_itest_summary(long long passed, long long failed);
long long zyl_fnmap_reset(void);
long long zyl_fnmap_put(long long name, long long value);
long long zyl_fnmap_get(long long name);
long long zyl_val_alloc(long long nwords, long long kinds, long long name);
long long zyl_val_name(long long p);
long long zyl_intern_name(long long s);
long long zyl_now_ms(void);
long long zyl_val_arity(long long p);
long long zyl_val_kind(long long p, long long i);
long long zyl_cstr_of_word(long long w);
long long zyl_int_text(long long n);
long long zyl_ffi_lookup(long long name);
long long zyl_call_argv(long long fn, long long argc, long long argv);
long long zyl_ffi_timed(long long fn, long long name, long long ms, long long argc, ...);
long long zyl_ffi_timed_argv(long long fn, long long name, long long ms, long long argc, long long argv);
long long zyl_smap_has(long long mh, long long key);
long long zyl_smap_get_or(long long mh, long long key, long long dflt);
long long zyl_array_new(long long arena, long long cap);
long long zyl_array_cap(long long h);
long long zyl_array_filled(long long h);
long long zyl_array_get(long long h, long long i);
long long zyl_array_set(long long h, long long i, long long v);
long long zyl_iglobal_clear(void);
long long zyl_iglobal_ready(long long key);
long long zyl_iglobal_get(long long key);
long long zyl_iglobal_put(long long key, long long val);
long long zyl_attrh_new(void);
long long zyl_attrh_set(long long th, long long node, long long val);
long long zyl_attrh_get_or(long long th, long long node, long long dflt);
long long zyl_attrh_has(long long th, long long node);
long long zyl_attrh_copy(long long th, long long dst, long long src);
long long zyl_attrh_clear(long long th);
long long zyl_ref_new(long long v);
long long zyl_ref_get(long long r);
long long zyl_ref_set(long long r, long long v);
long long zyl_getenv_str(long long name);
long long zyl_words_new(long long arena, long long n);
long long zyl_words_len(long long h);
long long zyl_words_get(long long h, long long i);
long long zyl_words_set(long long h, long long i, long long v);
long long zyl_words_view(long long arena, long long h, long long off, long long len);
int zyl_ffi_abandoned(void);
int zyl_ffi_on_worker(void);
long long zyl_f_parse(long long text);
long long zyl_f_add(long long a, long long b);
long long zyl_f_sub(long long a, long long b);
long long zyl_f_mul(long long a, long long b);
long long zyl_f_div(long long a, long long b);
long long zyl_f_rem(long long a, long long b);
long long zyl_f_cmp(long long a, long long b);
long long zyl_f_of_int(long long n);
long long zyl_f_to_int(long long bits);
long long zyl_f_text(long long bits);
long long zyl_print_int(long long n);
long long zyl_print_str(long long s);
long long zyl_print_float(long long bits);

#endif
