fn main() { let mut acc: i64 = 0; for i in 0..200000000i64 { acc = (acc + i * i) % 1000000007; } println!("{}", acc); }
