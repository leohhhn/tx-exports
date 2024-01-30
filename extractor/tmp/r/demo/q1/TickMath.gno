package pool

import "math"

// MIN_TICK is the minimum tick that may be passed to getSqrtRatioAtTick, computed from log base 1.0001 of 2**-128.
const MIN_TICK int = -887272

// MAX_TICK is the maximum tick that may be passed to getSqrtRatioAtTick, computed from log base 1.0001 of 2**128.
const MAX_TICK int = -MIN_TICK

// MIN_SQRT_RATIO is the minimum value that can be returned from getSqrtRatioAtTick.
// It is equivalent to getSqrtRatioAtTick(MIN_TICK).
const MIN_SQRT_RATIO uint = 4295128739

// MAX_SQRT_RATIO is the maximum value that can be returned from getSqrtRatioAtTick.
// It is equivalent to getSqrtRatioAtTick(MAX_TICK).
const MAX_SQRT_RATIO uint = 18446744073709551615

// getSqrtRatioAtTick calculates sqrt(1.0001^tick) * 2^96.
// It returns a fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0) at the given tick.
// It throws an error if the absolute value of tick is greater than the max tick.
func getSqrtRatioAtTick(tick int) (sqrtPriceX96 uint) {
	absTick := int(math.Abs(float64(tick)))
	if absTick > MAX_TICK {
		panic("Tick out of range")
	}
	tickPow := math.Pow(1.0001, float64(absTick))
	sqrtPrice := math.Sqrt(tickPow)
	return uint(sqrtPrice)
}

func getTickAtSqrtRatio(sqrtPriceX96 uint) int {
	if sqrtPriceX96 < MIN_SQRT_RATIO || sqrtPriceX96 > MAX_SQRT_RATIO {
		panic("Sqrt ratio out of range")
	}
	x := float64(sqrtPriceX96)
	log := math.Log10(x) / math.Log10(1.0001)
	return int(2 * log)
}
