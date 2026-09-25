package main
import ("fmt"; "strconv")
func main() { acc := 0; for i := 0; i < 5000000; i++ { acc += len("item-" + strconv.Itoa(i)) }; fmt.Println(acc) }
