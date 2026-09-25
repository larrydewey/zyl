struct T { l: Option<Box<T>>, r: Option<Box<T>> }
fn mk(d: i32) -> Box<T> { if d == 0 { Box::new(T { l: None, r: None }) } else { Box::new(T { l: Some(mk(d - 1)), r: Some(mk(d - 1)) }) } }
fn check(t: &T) -> i64 { match (&t.l, &t.r) { (Some(l), Some(r)) => 1 + check(l) + check(r), _ => 1 } }
fn main() { println!("{}", check(&mk(21))); let mut acc = 0i64;
  let mut d = 4; while d <= 20 { let n = 16 * (20 + 4 - d); for _ in 0..n { acc += check(&mk(d)); } d += 2; } println!("{}", acc); }
