package pool

type LowGasSafeMath struct {
}

func (l *LowGasSafeMath) add(x uint, y uint) uint {
	z := x + y
	if z >= x {
		return z
	} else {
		panic("add overflow")
	}
}

func (l *LowGasSafeMath) sub(x uint, y uint) uint {
	z := x - y
	if z <= x {
		return z
	} else {
		panic("sub overflow")
	}
}

func (l *LowGasSafeMath) mul(x uint, y uint) uint {
	if (x == 0) || (y == 0) {
		return 0
	}
	return x * y
}
