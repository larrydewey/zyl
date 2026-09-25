package main
import "fmt"
type L struct { h int; t *L }
func build(n int, acc *L) *L { for ; n > 0; n-- { acc = &L{n, acc} }; return acc }
func sum(xs *L) int { s := 0; for ; xs != nil; xs = xs.t { s += xs.h }; return s }
func main() { tot := 0; for k := 0; k < 30; k++ { tot += sum(build(1000000, nil)) }; fmt.Println(tot) }
