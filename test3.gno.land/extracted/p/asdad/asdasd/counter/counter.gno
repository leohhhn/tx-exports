package counter

import "fmt"

var count int

func Render(path string) string {
	return fmt.Sprintf("Count: %d", count)
}

func Add() {
	count++
}

func Remove() {
	count--
}
