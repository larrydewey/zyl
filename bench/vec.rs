fn main() { let mut v: Vec<i64> = Vec::with_capacity(16); for i in 0..10000000i64 { v.push(i); } let s: i64 = v.iter().sum(); println!("{}", s); }
