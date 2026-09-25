package main
import "fmt"
func main() { acc := 0; for i := 0; i < 200000000; i++ { acc = (acc + i*i) % 1000000007 }; fmt.Println(acc) }
