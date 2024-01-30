package pool

type LiquidityMath struct {
}

func addDelta(x uint, y int) uint {
	if y < 0 {
		if x-uint(-y) < x {
			panic("LS")
		}
		return x - uint(-y)
	} else {
		if x+uint(y) >= x {
			panic("LS")
		}
		return x + uint(y)
	}
}
