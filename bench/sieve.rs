fn main() { let n = 50000000usize; let mut b = vec![0u8; n]; let mut c = 0i64; for i in 2..n { if b[i] == 0 { c += 1; let mut j = i * i; while j < n { b[j] = 1; j += i; } } } println!("{}", c); }
