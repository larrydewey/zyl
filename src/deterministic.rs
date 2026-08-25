//! Deterministic hash collections.
//!
//! Rust's std `HashMap`/`HashSet` use a randomly-seeded hasher (SipHash
//! with a per-process key), so iteration order differs between runs of the
//! compiler. Any compilation decision that depends on that order breaks
//! Zyl's core determinism guarantee (same source -> same binary). This
//! module provides FNV-1a-hashed variants with an identical API surface:
//!
//!     use crate::deterministic::{HashMap, HashSet};
//!
//! FNV-1a is not collision-resistant, which is fine here: these are
//! compiler-internal work structures keyed by names/ids, never exposed to
//! untrusted input.

use std::hash::{BuildHasherDefault, Hasher};

#[derive(Default, Clone)]
pub struct FnvHasher(u64);

impl Hasher for FnvHasher {
    fn finish(&self) -> u64 {
        self.0
    }
    fn write(&mut self, bytes: &[u8]) {
        let mut hash = self.0;
        for &b in bytes {
            hash ^= b as u64;
            hash = hash.wrapping_mul(0x100000001b3);
        }
        self.0 = hash;
    }
}

pub type BuildHasher = BuildHasherDefault<FnvHasher>;

pub type HashMap<K, V> = std::collections::HashMap<K, V, BuildHasher>;
pub type HashSet<K> = std::collections::HashSet<K, BuildHasher>;
