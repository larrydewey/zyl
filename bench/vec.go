package main
import "fmt"
func main() { v := make([]int, 0, 16); for i := 0; i < 10000000; i++ { v = append(v, i) }; s := 0; for i := 0; i < len(v); i++ { s += v[i] }; fmt.Println(s) }
