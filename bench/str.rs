fn main() { let mut acc = 0usize; for i in 0..5000000i64 { let s = String::from("item-") + &i.to_string(); acc += s.len(); } println!("{}", acc); }
