package pool

import "math"

func position(tick int) (int, int) {
	return tick >> 8, tick % 256
}

func flipTick(
	self map[int]int,
	tick int,
	tickSpacing int,
) {
	if tick%tickSpacing != 0 {
		panic("tick is not divisible by tickSpacing")
	}
	wordPos, bitPos := position(tick / tickSpacing)
	mask := 1 << uint(bitPos)
	self[wordPos] ^= mask
}

func nextInitializedTickWithinOneWord(
	self map[int]int,
	tick int,
	tickSpacing int,
	lte bool,
) (int, bool) {
	compress := int(tick / tickSpacing)
	if tick < 0 && tick%tickSpacing != 0 {
		compress--
	}
	if lte {
		wordPos, bitPos := position(compress)
		mask := (1 << bitPos) - 1 + (1 << bitPos)
		masked := self[wordPos] & mask

		intialized := masked != 0
		if intialized {
			return (compress - int(bitPos-int(mostSignificantBit(mask)))) * tickSpacing, intialized
		}
		return (compress - int(bitPos)) * tickSpacing, intialized
	}
	wordPos, bitPos := position(compress + 1)
	mask := ^((1 << bitPos) - 1)
	masked := self[wordPos] & mask

	intialized := masked != 0
	if intialized {
		return compress + 1 + int(int(leastSignificantBit(uint (masked)))-int(bitPos))*tickSpacing, intialized
	}
	return compress + 1 + int(math.MaxUint8-bitPos)*tickSpacing, intialized
}

func mostSignificantBit(x uint) uint {
	if x <= 0 {
		panic("x must be positive")
	}
	r := 0
	if x >= 0x100000000 {
		x >>= 32
		r += 32
	}
	if x >= 0x10000 {
		x >>= 16
		r += 16
	}
	if x >= 0x100 {
		x >>= 8
		r += 8
	}
	if x >= 0x10 {
		x >>= 4
		r += 4
	}
	if x >= 0x4 {
		x >>= 2
		r += 2
	}
	if x >= 0x2 {
		r += 1
	}
	return uint(r)
}

func leastSignificantBit(x uint) uint {
	if x <= 0 {
		panic("x must be positive")
	}
	r := 127
	if x&math.MaxUint > 0 {
		r -= 64
	} else {
		x >>= 64
	}
	if x&math.MaxUint32 > 0 {
		r -= 32
	} else {
		x >>= 32
	}
	if x&math.MaxUint16 > 0 {
		r -= 16
	} else {
		x >>= 16
	}
	if x&math.MaxUint8 > 0 {
		r -= 8
	} else {
		x >>= 8
	}
	if x&0xf > 0 {
		r -= 4
	} else {
		x >>= 4
	}
	if x&0x3 > 0 {
		r -= 2
	} else {
		x >>= 2
	}
	if x&0x1 > 0 {
		r -= 1
	}
	return uint(r)
}
