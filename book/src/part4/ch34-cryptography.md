# Chapter 34: The Cryptography Library

`stdlib/math` is about 7,600 lines of Zyl implementing the primitives a
real protocol needs: hashes, AEADs, elliptic curves, RSA, key
derivation, big-number arithmetic and a random number generator. All of
it is pure Zyl except two things that cannot be: AES, which uses the
hardware AES-NI instructions, and system entropy, which is
`getrandom(2)`.

`(use math/math)` pulls in the whole tree. Importing only the modules
you actually use keeps compile time and binary size down.

## 34.1 Two Representations to Learn First

Every module in the tree follows two conventions, and the rest of the
library is much easier to read once they are in your head.

**Byte strings are one byte per 8-byte word.** A 32-byte key is a
32-slot word array, each slot holding a value in 0..255. That costs
memory and buys a single uniform representation with no packing,
unpacking or endianness handling at every call site. `math/words` does
the conversions at the edges:

```lisp
(use math/words)

(w-alloc arena n)              ; n zeroed slots
(w-get base i)                 ; read slot i
(w-set base i v)               ; write slot i
(w-from-hex arena "0a0b...")   ; hex string  -> word array
(w-from-string arena "abc")    ; text        -> word array
(w-hex-bytes base n)           ; word array  -> hex string
```

**Big numbers are 24-bit limbs, least significant first.** Twenty-four
bits is the width that lets a limb product (48 bits) *and* a whole
column of accumulated products fit in a signed 64-bit `Int` without
overflowing, and it divides evenly into bytes.

Argon2 is the one deliberate exception to the first rule: its blocks
are 128 genuine 64-bit words, because a memory-hard KDF measured in
mebibytes cannot afford an eightfold expansion.

## 34.2 What Is in the Tree

| Module | Provides |
|---|---|
| `math/bits` | 32/64-bit word operations, rotations, unsigned compare, byte packing |
| `math/words` | fixed-size arena-backed `Int` arrays, hex and string conversion |
| `math/secret/secret` | `ct-eq`/`ct-ne`/`ct-select`/`ct-mask`, `declassify`, `zeroize` |
| `math/bignum/bignum` | fixed-width naturals: add, sub, mul, shifts, byte conversion |
| `math/bignum/montgomery` | Montgomery multiplication, constant-time `mont-exp` |
| `math/bignum/barrett` | reduction of a wide value by a fixed modulus |
| `math/bignum/modular` | modular add/sub, Fermat inverse, Miller–Rabin |
| `math/rand/rand` | helpers shared by the generators (`rand-u64-from-bytes`, `rand-below`); "Rng" is a naming convention (`<name>-fill`, `<name>-next-u64`), not yet a trait |
| `math/rand/crypto` | `getrandom(2)` entropy (`sysrng-fill`, `sysrng-bytes`, `sysrng-key32`), fork-safe by construction |
| `math/rand/deterministic` | seeded ChaCha20 generator (`chacharng-new`, ...) for tests and simulations — never for key material |
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

## 34.3 Hashing

The shortest thing in the library:

```lisp
(use allocator/allocator)
(use core/core)
(use math/hash/sha2)

(defn main ()
  (let a (arena-create 0)
    (print (sha256-hex-of-string a "abc")))
  0)
```

```
ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
```

Every hash module follows the same shape. `sha256-words` takes a word
array and a length and returns the digest as a word array;
`sha256-bytes` returns it as bytes; `sha256-hex-of-string` is the
convenience wrapper above. The arena is the first argument everywhere —
the library allocates scratch space, and you decide when that space
goes away.

## 34.4 Authenticated Encryption

ChaCha20-Poly1305 is the AEAD to reach for unless something else
dictates otherwise:

```lisp
(use math/crypto/symmetric/chacha20poly)

;; Returns ciphertext || tag, so the sealed buffer is ctlen + 16 bytes.
(aead-encrypt arena key nonce aad aadlen pt ptlen)

;; Returns (Some plaintext) on success, None when the tag does not
;; verify. There is no "decrypt without checking" entry point.
(aead-decrypt arena key nonce aad aadlen sealed ctlen)
```

The tag check goes through `ct-eq-words-bool`, which compares the full
length and reduces the result to one public bit. That single bit *is*
the declassification — see Chapter 33 — and it reveals only the verdict
the caller is about to act on.

AES-GCM is there too (`gcm-encrypt` and `gcm-decrypt`, which take the
key length as an extra argument and also return an `Option`), but it
refuses to run without AES-NI: `aes-available` returns `false` and the
functions return `None`. That is deliberate, and §34.6 explains why.

## 34.5 Key Agreement and Derivation

```lisp
(use math/crypto/asymmetric/x25519)
(use math/crypto/kdf/hkdf)

(let apub   (x25519-public arena alice-private)
  (let shared (x25519 arena alice-private bob-public)
    (hkdf arena shared 32 salt saltlen info infolen 32)))
```

`tests/integration/math-protocol.zyl` runs exactly this, end to end: two
X25519 key pairs agree on a shared secret, HKDF turns it into two
*different* directional traffic keys (the `info` label is what keeps
client-to-server and server-to-client from colliding), ChaCha20-Poly1305
protects a message under one of them, and Ed25519 signs the transcript
for the other side to verify. It is the best worked example in the tree
and worth reading before writing a protocol of your own.

## 34.6 What Is Deliberately Missing

These are not gaps waiting to be filled. Each is left out because
shipping it would make the library worse:

- **PKCS#1 v1.5 encryption and signatures.** The padding-oracle history
  is Bleichenbacher's, and a library that offers it invites new
  protocols to keep using it. `rsa.zyl` implements OAEP and PSS only.
- **Software AES.** Every portable AES implementation is a key-indexed
  table lookup, which leaks the key through the data cache. `aesgcm`
  reports `aes-available` as `false` and refuses rather than falling back to
  something that looks like AES and is not safe.
- **RSA key generation.** Finding 1024-bit primes needs thousands of
  exponentiations at this arithmetic's speed. Keys are loaded, not
  generated.
- **Randomised ECDSA nonces.** RFC 6979 deterministic nonces are the
  only mode. A repeated nonce reveals the private key; removing the RNG
  removes the entire failure class.
- **DER signature encoding.** ECDSA signatures are the fixed-width
  `r || s` form.

## 34.7 The Constant-Time Discipline in Practice

Secret-dependent code uses only operations that compile to a fixed,
branchless instruction sequence: `bit-and`, `bit-or`, `bit-xor`, the
shifts, and `+`/`-`/`*`. A decision that depends on a secret is made
with a mask (`ct-select`, `bn-cond-copy`), never with `if`. Loop counts
come from public parameters — a digest length, a limb count, a declared
bit width — never from a secret's value.

Where a branch on secret-derived data is unavoidable and harmless, it
is declassified explicitly. Every such site in the tree:

| Site | Why the value is public |
|---|---|
| `chacha20poly` / `aesgcm` tag check | the AEAD verdict itself (via `ct-eq-words-bool`) |
| `poly1305-verify`, `hmac-sha256-verify` | the MAC verdict (via `ct-eq-words-bool`) |
| `ed25519` verification equation | the signature verdict (via `ct-eq-words-bool`) |
| `rsa` PSS verification | the signature verdict (via `ct-eq-words-bool`) |
| `modular`'s Miller–Rabin rounds | a composite candidate is rejected and redrawn |
| `ecdsa` r/s zero tests, RFC 6979 rejection | RFC 6979 §3.2's own retry loop |
| `ecdsa` verification | runs entirely on public inputs |
| `ed25519` point decompression | decodes a public key or a signature's R |
| `x25519` all-zero output | RFC 7748 §6.1's published low-order-point rejection |
| `rsa` OAEP extraction | one combined bit, which is what keeps it free of a Manger oracle |

## 34.8 How It Was Verified

Three layers, because a fixed vector list alone is not enough:

```bash
./run_regression_tests.sh --full --no-boot --filter math    # published vectors
./run_regression_tests.sh --full --no-boot --filter timing  # leakage harness
python3 verify/sha2.py                                      # vs hashlib
python3 verify/crypto.py                                    # vs hashlib + pyca
```

- `tests/regression/math-*.zyl` hold published NIST, FIPS and RFC test
  vectors, embedded as S-expressions.
- `verify/sha2.py` compares 414 digests — SHA-256 and SHA-512 of 207
  messages, every length 0 to 200 plus 255, 256, 257, 511, 512 and
  1000 — against `hashlib`.
- `verify/crypto.py` cross-checks *randomised* inputs (from a fixed
  seed, so a failure reproduces) against `hashlib` and pyca
  `cryptography`: SHA3-256/512, SHAKE256 and BLAKE2b digests,
  ChaCha20-Poly1305 and AES-GCM seals, X25519 agreement, Ed25519 keys
  and signatures, and HKDF, PBKDF2 and Argon2id outputs. BLAKE3 has no
  Python reference there and is covered by the published vectors. This
  is the layer that catches the block-boundary and carry bugs a fixed
  vector list walks straight past. It needs the `cryptography` package
  installed.
- `verify/timing.py` is a dudect-style statistical leakage harness
  (Welch's t-test over two input classes, per-process wall-clock timing
  of a loop). It carries a deliberately leaky comparison as a
  **positive control** and fails if it cannot detect it, so a clean
  result means the measurement itself worked. It detects gross
  data-dependence — an early exit, a secret-dependent branch — not a
  few cycles of cache effect. The regression runner includes it only
  when asked (`--filter timing`, which runs it with `--quick`).

Every algorithm was first mirrored in Python against its reference —
CIOS Montgomery, Keccak's index conventions, the RCB complete addition
formulas, Argon2's addressing, BLAKE3's tree — before being written in
Zyl. That is why the first compile-and-run cycle turned up compiler
bugs rather than algorithm bugs.

## 34.9 Known Limits

- **BLAKE3 has no SIMD backend**; the portable compression function is
  used.
- **No ctgrind or valgrind instrumentation.** `verify/timing.py` is the
  statistical substitute.
- **`Secret` annotations stop at `math/secret/secret`.** The AEAD, KDF,
  signature and bignum entry points are not yet under the checker; see
  Chapter 33.

## Summary

- Byte strings are one byte per word; big numbers are 24-bit limbs,
  least significant first.
- Every entry point takes an arena first, and you decide when the
  scratch space goes away.
- The omissions — PKCS#1 v1.5, software AES, RSA key generation,
  randomised ECDSA nonces — are decisions, not gaps.
- Verification is layered: published vectors, randomised cross-checks
  against Python, and a leakage harness with its own positive control.
