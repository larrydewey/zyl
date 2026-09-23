# stdlib/math — cryptography and number libraries

Everything under `stdlib/math/` is pure Zyl, with two exceptions that
call into `runtime/actor_runtime.c`: AES (hardware AES-NI only) and
system entropy (`getrandom(2)`).

`(use math/math)` imports the whole tree; importing only the modules a
program uses keeps its compile time and binary smaller.

## Representation conventions

Two conventions run through every module, and reading them first makes
the rest obvious:

- **Byte strings are one byte per 8-byte word** (`math/words`). A
  32-byte key is a 32-slot word array whose every slot holds 0..255.
  This costs memory and buys a single uniform representation with no
  packing or endianness handling at every call site. `w-from-hex`,
  `w-from-string`, `w-hex-bytes` convert at the edges.
- **Big numbers are 24-bit limbs, least significant first**
  (`math/bignum`). 24 bits is what lets a limb product (48 bits) and a
  whole column of accumulated products fit in Zyl's signed 64-bit Int
  without overflow, and it divides evenly into bytes.

Argon2 is the one place that breaks the first convention: its blocks
are 128 genuine 64-bit words, because a memory-hard KDF measured in
mebibytes cannot afford an 8x expansion.

## What is here

| Module | Provides |
|---|---|
| `math/bits` | 32/64-bit word ops, rotations, unsigned compare, byte packing |
| `math/words` | fixed-size arena-backed Int arrays, hex and string conversion |
| `math/secret/secret` | `ct-eq`/`ct-ne`/`ct-select`/`ct-mask`, `zeroize` |
| `math/bignum/bignum` | fixed-width naturals: add, sub, mul, shifts, byte conversion |
| `math/bignum/montgomery` | Montgomery multiplication, constant-time `mont-exp` |
| `math/bignum/barrett` | reduction of a wide value by a fixed modulus |
| `math/bignum/modular` | modular add/sub, Fermat inverse, Miller-Rabin |
| `math/rand/crypto` | `getrandom(2)` entropy, fork-safe by construction |
| `math/rand/deterministic` | seeded ChaCha20 generator for tests and simulations |
| `math/hash/sha2` | SHA-256 |
| `math/hash/sha512` | SHA-512 |
| `math/hash/sha3` | SHA3-256, SHA3-512, SHAKE128, SHAKE256 |
| `math/hash/blake2b` | BLAKE2b, keyed or unkeyed |
| `math/hash/blake3` | BLAKE3 with extendable output |
| `math/hash/hmac` | HMAC-SHA256 |
| `math/crypto/symmetric/chacha20` | ChaCha20 |
| `math/crypto/symmetric/poly1305` | Poly1305 |
| `math/crypto/symmetric/chacha20poly` | ChaCha20-Poly1305 AEAD |
| `math/crypto/symmetric/aesgcm` | AES-128/256-GCM (AES-NI only) |
| `math/crypto/asymmetric/x25519` | X25519 |
| `math/crypto/asymmetric/ed25519` | Ed25519 |
| `math/crypto/asymmetric/ecdsa` | ECDSA over P-256, secp256k1, P-384 |
| `math/crypto/asymmetric/rsa` | RSA-PSS, RSA-OAEP |
| `math/crypto/kdf/hkdf` | HKDF-SHA256 |
| `math/crypto/kdf/pbkdf2` | PBKDF2-HMAC-SHA256 |
| `math/crypto/kdf/argon2` | Argon2id |

## Deliberate omissions

These are not gaps to be filled later; each is left out because
shipping it would make the library worse:

- **PKCS#1 v1.5 encryption and signatures.** The padding-oracle
  history is Bleichenbacher's, and a library that offers it invites new
  protocols to keep using it. `rsa.zyl` implements OAEP and PSS only.
- **Software AES.** Every portable AES is a key-indexed table lookup,
  which leaks the key through the data cache. `aesgcm.zyl` reports
  `aes-available` as 0 and refuses rather than falling back.
- **RSA key generation.** Finding 1024-bit primes needs thousands of
  exponentiations at this arithmetic's speed. Keys are loaded, not
  generated.
- **Randomized ECDSA nonces.** RFC 6979 deterministic nonces are the
  only mode; a repeated nonce reveals the private key, and removing the
  RNG removes the failure class.
- **DER signature encoding.** ECDSA signatures are the fixed-width
  `r || s` form.

## Constant-time discipline

Secret-dependent code uses only operations that compile to a fixed,
branchless instruction sequence: `bit-and`, `bit-or`, `bit-xor`, the
shifts, and `+`/`-`/`*`. A decision that depends on a secret is made
with a mask (`ct-select`, `bn-cond-copy`), never with `if`. Loop counts
come from public parameters (a digest length, a limb count, a declared
bit width), never from a secret's value.

Where a branch on secret-derived data is unavoidable and harmless it is
marked as such in the source — an AEAD's final accept/reject decision
is the main one, and it reveals only the verdict the caller is about to
act on anyway. Since Phase 0 of the plan landed, "marked as such" is
enforced rather than conventional: the parameters of
`math/secret/secret` carry the `Secret` annotation, so
`compiler/secret_check.zyl` rejects any branch, memory index, division,
`print`, actor send or unpinned FFI call reached from one of those
results, and the only way past it is an explicit `declassify` (or
`ct-eq-bool`/`ct-eq-words-bool`, which declassify by name). Every
deliberate declassification in this library is therefore a greppable
call with a comment saying why the verdict is public:

| Site | Why it is public |
|------|------------------|
| `chacha20poly` / `aesgcm` tag check | the AEAD verdict itself (via `ct-eq-words-bool`) |
| `modular`'s Miller-Rabin rounds | a composite candidate is rejected and redrawn |
| `ecdsa` r/s zero tests, RFC 6979 rejection | RFC 6979 3.2's own retry loop |
| `ecdsa` verification | runs entirely on public inputs |
| `ed25519` point decompression | decodes a public key or a signature's R |
| `x25519` all-zero output | RFC 7748 §6.1's published low-order-point rejection |
| `rsa` OAEP extraction | one combined bit, which is what keeps it free of a Manger oracle |

`ct-eq-words` and `ct-eq-words-bool` are what tag and MAC comparison
must use. `=` on two byte arrays compares addresses, and a hand-written
loop that stops at the first difference leaks the length of the
matching prefix, which is enough to forge a tag one byte at a time.

## Testing

```bash
./run_regression_tests.sh --full --no-boot --filter math    # all vectors
./run_regression_tests.sh --full --no-boot --filter timing  # leakage harness
python3 verify/sha2.py                                      # vs hashlib
python3 verify/crypto.py                                    # vs hashlib + pyca
```

- `tests/regression/math-*.zyl` hold published test vectors (NIST, RFC,
  FIPS) embedded as S-expressions.
- `tests/integration/math-protocol.zyl` runs a miniature authenticated
  key exchange across X25519, HKDF, ChaCha20-Poly1305 and Ed25519.
- `verify/crypto.py` cross-checks randomized inputs against Python's
  `hashlib` and `cryptography`, which catches the block-boundary and
  carry bugs a fixed vector list walks past.
- `verify/timing.py` is a dudect-style leakage check. It carries a
  deliberately leaky comparison as a POSITIVE CONTROL and fails if it
  cannot detect it, so a clean result means the measurement worked.

## Not implemented

- Automatic zeroization on scope exit and debug-output redaction
  (`MATH_CRYPTO_IMPLEMENTATION_PLAN.md` Phase 0's codegen half). Erasure
  is still explicit `zeroize`, with an `E_ZEROIZE_MISSING` warning when a
  function consumes a `Secret` into a public result without it; `print`
  of a secret is rejected outright rather than redacted to `<secret>`.
- `Secret` annotations beyond `math/secret/secret` itself. Taint crosses
  a call boundary only where the callee's own parameters are annotated,
  so the AEAD, KDF, signature and bignum entry points are not yet under
  the checker — annotating them is the next step in the plan.
- BLAKE3's SIMD backend (the portable compression function is used).
- ctgrind/valgrind instrumentation; `verify/timing.py` is the
  statistical substitute.
