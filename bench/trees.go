package main
import "fmt"
type T struct{ l, r *T }
func mk(d int) *T { if d == 0 { return &T{} }; return &T{mk(d - 1), mk(d - 1)} }
func (t *T) check() int { if t.l == nil { return 1 }; return 1 + t.l.check() + t.r.check() }
func main() {
  fmt.Println(mk(21).check()); acc := 0
  for d := 4; d <= 20; d += 2 { n := 16 * (20 + 4 - d); for i := 0; i < n; i++ { acc += mk(d).check() } }
  fmt.Println(acc) }
