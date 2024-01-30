package cinap

import (
	"errors"
)

var ErrCinap = errors.New("A wild cinap has appeared!")

func Render(path string) string {
	return ""
}

func Panic() {
	panic("cinap")
}

func PanicWithError() {
	panic(ErrCinap)
}

func Error() error {
	return ErrCinap
}
