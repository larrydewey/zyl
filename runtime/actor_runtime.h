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
long long zyl_cstr_eq(long long p1, long long p2);
long long zyl_cstr_cmp(long long p1, long long p2);
long long zyl_cstr_key_matches(long long key, long long name);
long long zyl_cpuid_features(void);
long long zyl_aesni_available(void);
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

/* Region-based arena allocator.
   Deterministic reclamation: arena-reset frees every block at once; the
   handle stays valid for reuse. Arenas are single-threaded by design
   (consistent with actor isolation — one arena per actor/scope). */

/* Region-specific arena allocation wrappers for codegen. */
void zyl_ensure_arenas(void);
long long zyl_zeroize(long long addr, long long len);
long long zyl_random_fill(long long addr, long long len);
long long zyl_random_words(long long base, long long n);
long long zyl_cpuid_features(void);
long long zyl_aesni_available(void);
long long zyl_aes_encrypt_block(long long keybase, long long keybytes,
                                long long inbase, long long outbase);

/* CLI helpers. */
long long zyl_system_cmd(long long cmd);
long long zyl_exec_cmd(long long cmd);

/* Interactive terminal primitives (REPL line editor). */
long long zyl_term_flush(void);
long long zyl_term_atexit(void);
long long zyl_cc_compile_log(long long path, long long logpath);

/* Interpreter support (stdlib/repl/interp.zyl). */
long long zyl_word_of_cstr(long long s);
long long zyl_itest_start(long long name);
long long zyl_itest_outcome(long long ok);
long long zyl_itest_summary(long long passed, long long failed);
long long zyl_now_ms(void);
long long zyl_ffi_lookup(long long name);
long long zyl_call_argv(long long fn, long long argc, long long argv);
long long zyl_ffi_timed(long long fn, long long name, long long ms, long long argc, ...);
long long zyl_ffi_timed_argv(long long fn, long long name, long long ms, long long argc, long long argv);
long long zyl_array_new(long long arena, long long cap);
long long zyl_array_cap(long long h);
long long zyl_array_filled(long long h);
long long zyl_array_get(long long h, long long i);
long long zyl_array_set(long long h, long long i, long long v);
long long zyl_strbuf_new(long long arena, long long n);
long long zyl_strbuf_str(long long b);
long long zyl_uf_id(long long a);
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
long long zyl_smap_has(long long mh, long long key);
long long zyl_smap_get_or(long long mh, long long key, long long dflt);
long long zyl_iglobal_clear(void);
long long zyl_iglobal_ready(long long key);
long long zyl_iglobal_get(long long key);
long long zyl_iglobal_put(long long key, long long val);
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

/* Entries implemented in Zyl (runtime/rt/rt.zyl). */
long long zyl_cstr_concat(long long a, long long b);
long long zyl_cstr_substr(long long s, long long start, long long len);
long long zyl_cstr_sub(long long arena, long long s, long long start, long long len);
long long zyl_cstr_from_byte(long long b);
long long zyl_cstr_from_int(long long arena, long long value);
long long zyl_int_text(long long n);
long long zyl_cstr_to_int(long long s);
long long zyl_cstr_to_int_base(long long s);
long long zyl_cstr_sanitize(long long arena, long long s);
long long zyl_cstr_decode(long long arena, long long s, long long start, long long end);
long long zyl_cstr_count_newlines(long long s, long long end);
long long zyl_cstr_last_newline(long long s, long long end);
long long zyl_cstr_escapes_ok(long long s, long long start, long long end);
long long zyl_view_ok(long long s, long long off, long long len);
long long zyl_view_byte(long long s, long long off, long long len, long long i);
long long zyl_view_cmp(long long a, long long aoff, long long alen, long long b, long long boff, long long blen);
long long zyl_view_find(long long s, long long off, long long len, long long from, long long byte);
long long zyl_view_copy(long long s, long long off, long long len);
long long zyl_dirname_cstr(long long path);
long long zyl_variant_eq(long long a, long long b);
long long zyl_variant_cmp(long long a, long long b);
long long zyl_variant_field(long long p, long long idx);
long long zyl_span_set(long long node, long long off, long long fid);
long long zyl_span_off(long long node);
long long zyl_span_file(long long node);
long long zyl_span_copy(long long dst, long long src);
long long zyl_attr_set(long long t, long long node, long long val);
long long zyl_attr_get(long long t, long long node);
long long zyl_attr_clear(long long t);
long long zyl_attr_copy(long long t, long long dst, long long src);
long long zyl_smap_new(void);
long long zyl_smap_put(long long m, long long key, long long val);
long long zyl_smap_get(long long m, long long key);
long long zyl_smap_has(long long m, long long key);
long long zyl_smap_get_or(long long m, long long key, long long dflt);
long long zyl_smap_clear(long long m);
long long zyl_wvec_new(void);
long long zyl_wvec_push(long long v, long long x);
long long zyl_wvec_get(long long v, long long i);
long long zyl_wvec_set(long long v, long long i, long long x);
long long zyl_wvec_len(long long v);
long long zyl_wvec_pop(long long v);
long long zyl_wvec_truncate(long long v, long long n);
long long zyl_wvec_global(long long i);
long long zyl_smap_global(long long i);
long long zyl_contract_warn(long long msg);
long long zyl_err_is(long long msg, long long code);
long long zyl_source_register(long long path, long long text);
long long zyl_source_path(long long fid);
long long zyl_span_line(long long fid, long long off);
long long zyl_span_col(long long fid, long long off);
long long zyl_span_line_text(long long fid, long long off);
long long zyl_span_snippet(long long fid, long long off);
long long zyl_span_snippet_col(long long fid, long long off);
long long zyl_span_offset_at(long long fid, long long line, long long col);
long long zyl_itest_add(long long name, long long fn);
long long zyl_itest_count(void);
long long zyl_itest_name(long long i);
long long zyl_itest_fn(long long i);
long long zyl_itest_reset(void);
long long zyl_fnmap_reset(void);
long long zyl_fnmap_put(long long name, long long value);
long long zyl_fnmap_get(long long name);
long long zyl_val_alloc(long long nwords, long long kinds, long long name);
long long zyl_val_kind(long long p, long long i);
long long zyl_val_name(long long p);
long long zyl_val_arity(long long p);
long long zyl_intern_name(long long s);
long long zyl_fresh_id(void);
long long zyl_cstr_of_word(long long w);
long long zyl_float_bits(long long w);
long long zyl_float_of_bits(long long w);
long long zyl_word_load(long long a);
long long zyl_word_store(long long a, long long w);
long long zyl_ptr_add(long long p, long long n);
long long zyl_ptr_cstr(long long p);
long long zyl_now_ms(void);
long long zyl_global_clear(void);
long long zyl_iglobal_clear(void);
long long zyl_iglobal_ready(long long key);
long long zyl_iglobal_get(long long key);
long long zyl_iglobal_put(long long key, long long val);
long long zyl_repl_global_set(long long name, long long word);
long long zyl_repl_global_get(long long name);
long long zyl_global_ready(long long key);
long long zyl_global_get(long long key);
long long zyl_global_put(long long key, long long val);
long long zyl_blake3_hex(long long arena, long long src, long long len, long long outbytes);
long long zyl_blake3_file_hex(long long arena, long long path, long long outbytes);
long long zyl_sym_escape(long long arena, long long src);
long long zyl_mangle_key(long long arena, long long key);
long long zyl_array_new(long long arena, long long cap);
long long zyl_array_cap(long long h);
long long zyl_array_filled(long long h);
long long zyl_array_get(long long h, long long i);
long long zyl_array_set(long long h, long long i, long long v);
long long zyl_strbuf_new(long long arena, long long n);
long long zyl_strbuf_str(long long b);
long long zyl_uf_id(long long a);
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
long long zyl_array_copy(long long from, long long to, long long n);
long long zyl_str_append(long long dst, long long src);
long long zyl_str_append_capped(long long dst, long long src, long long cap);
long long zyl_load_byte(long long endian, long long offset, long long buf);
long long zyl_load_byte_signed(long long endian, long long offset, long long buf);
long long zyl_store_byte(long long endian, long long offset, long long buf, long long val);
long long zyl_store_byte_signed(long long endian, long long offset, long long buf, long long val);
long long zyl_load_n(long long width, long long endian, long long offset, long long buf);
long long zyl_load_n_signed(long long width, long long endian, long long offset, long long buf);
long long zyl_store_n(long long width, long long endian, long long offset, long long buf, long long val);
long long zyl_byte_slice(long long buf, long long start, long long len);
long long zyl_byte_slice_sub(long long slice, long long start, long long len);
long long zyl_bytebuf_new(long long region, long long cap);
long long zyl_bytebuf_new_r(long long region, long long cap);
long long zyl_bytebuf_append(long long buf, long long slice);
long long zyl_bytebuf_len(long long buf);
long long zyl_bytebuf_cap(long long buf);
long long zyl_bytebuf_ptr(long long buf);
long long zyl_align_check(long long expr, long long align);
long long zyl_bytebuf_atomic_load(long long buf, long long offset);
long long zyl_bytebuf_atomic_store(long long buf, long long offset, long long val);
long long zyl_bytebuf_atomic_add(long long buf, long long offset, long long val);
long long zyl_bytebuf_atomic_sub(long long buf, long long offset, long long val);
long long zyl_bytebuf_atomic_fetch_add(long long buf, long long offset, long long val);
long long zyl_bytebuf_atomic_max(long long buf, long long offset, long long val);
long long zyl_bytebuf_atomic_min(long long buf, long long offset, long long val);
long long zyl_bytebuf_atomic_cas(long long buf, long long offset, long long expected, long long new_value);
long long zyl_atomic_load(long long addr);
long long zyl_atomic_store(long long addr, long long value);
long long zyl_atomic_add(long long addr, long long value);
long long zyl_atomic_sub(long long addr, long long value);
long long zyl_atomic_max(long long addr, long long value);
long long zyl_atomic_min(long long addr, long long value);
long long zyl_atomic_cas(long long addr, long long expected, long long new_value);
long long zyl_atomic_fetch_add(long long addr, long long value);
void zyl_save_args(int argc, char** argv);
long long zyl_argc(void);
long long zyl_arg_str(long long i);
long long zyl_chdir(long long path);
long long zyl_getcwd(void);
long long zyl_path_exists(long long path);
long long zyl_mkdir_p(long long path);
long long zyl_file_open_c(long long path, long long mode);
long long zyl_file_read_c(long long fd, long long count);
long long zyl_file_read_c_r(long long fd, long long count);
long long zyl_file_write_c(long long fd, long long buf);
long long zyl_file_close_c(long long fd);
long long zyl_list_zyl_files(long long dir);
long long zyl_list_files(long long dir, long long suffixes);
long long zyl_term_is_tty(long long fd);
long long zyl_term_raw_on(void);
long long zyl_term_raw_off(void);
void zyl_term_restore_atexit(void);
long long zyl_term_read_byte(void);
long long zyl_term_read_byte_timeout(long long ms);
long long zyl_term_width(void);
long long zyl_term_height(void);
long long zyl_term_write(long long s);

long long zyl_arena_create(long long block_size);
long long zyl_arena_alloc(long long arena, long long size);
long long zyl_arena_alloc_zeroed(long long arena, long long size);
long long zyl_arena_reset(long long arena);
long long zyl_arena_destroy(long long arena);
long long zyl_arena_used(long long arena);
long long zyl_arena_capacity(long long arena);
long long zyl_arena_oom(long long requested, long long why);
long long zyl_threads_started_mark(void);
long long zyl_arenas_init(void);
long long zyl_arenas_destroy(void);
long long zyl_heap_alloc(long long size);
long long zyl_heap_swap(long long arena);
long long zyl_session_arena(void);
long long zyl_heap_block_p(long long w);
long long zyl_pin_owns(long long ptr);
long long zyl_pin_word(long long value);
long long zyl_mlock(long long addr, long long len);
long long zyl_pin_alloc(long long size);
long long zyl_ralloc(long long size, long long rp);
long long zyl_region_enter(long long rp);
long long zyl_region_scope_enter(long long hp, long long kind, long long block, long long align, long long limit);
long long zyl_region_free(long long rp);
long long zyl_region_recycle(long long rp);
long long zyl_region_exit(long long rp);
long long zyl_region_unwind(void* mark);
void* zyl_region_mark(void);
long long zyl_region_live_bytes(void);

long long zyl_uf_reset(void);
long long zyl_uf_new(long long level);
long long zyl_uf_find(long long a);
long long zyl_uf_union(long long a, long long b);
long long zyl_uf_raise(long long a, long long level);
long long zyl_uf_level(long long a);

#endif
