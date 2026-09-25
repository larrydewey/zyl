struct L { h: i64, t: Option<Box<L>> }
fn main() { let mut tot = 0i64; for _ in 0..30 { let mut acc: Option<Box<L>> = None; for n in (1..=1000000i64).rev() { acc = Some(Box::new(L { h: n, t: acc })); }
  let mut s = 0i64; let mut p = &acc; while let Some(c) = p { s += c.h; p = &c.t; } tot += s;
  while let Some(mut c) = acc { acc = c.t.take(); } } println!("{}", tot); }
