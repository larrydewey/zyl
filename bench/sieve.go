package main
import "fmt"
func main() { n := 50000000; b := make([]byte, n); c := 0
  for i := 2; i < n; i++ { if b[i] == 0 { c++; for j := i * i; j < n; j += i { b[j] = 1 } } }
  fmt.Println(c) }
