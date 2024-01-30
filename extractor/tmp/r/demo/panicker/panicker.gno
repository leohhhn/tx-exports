package cinap

var ErrCinap = errors.New("cinap-err")

func Panic() {
	panic("cinap")
}

func PanicWithError() {
	panic(ErrCinap)
}
