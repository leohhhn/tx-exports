package pool

import (
	"crypto/sha3"
	"std"
)

type PositionInfo struct {
	// the amount of liquidity owned by this position
	liquidity uint
	// fee growth per unit of liquidity as of the last update to liquidity or fees owed
	feeGrowthInside0LastX128 uint
	feeGrowthInside1LastX128 uint
	// the fees owed to the position owner in token0/token1
	tokensOwed0 uint
	tokensOwed1 uint
}

func GetPositionKey(owner std.Address, tickLower int, tickUpper int) ([]uint8) {
	h := sha3.New()
	var key = fmt.Sprint(owner, "0000000000000000", tickLower, "0000000000000000", tickUpper)
	h.Write([]byte(key))

	return h.Sum(nil)
}

func updatePositionInfo(self *PositionInfo, liquidityDelta int, feeGrowthInside0X128 uint, feeGrowthInside1X128 uint) {
	var liquidityNext uint

	if liquidityDelta == 0 {
		require(self.liquidity > 0, "NP")
		liquidityNext = self.liquidity
	} else {
		addDelta(self.liquidity, liquidityDelta)
	}

	tokensOwed0 := (feeGrowthInside0X128 - self.feeGrowthInside0LastX128) * self.liquidity
	tokensOwed1 := (feeGrowthInside1X128 - self.feeGrowthInside1LastX128) * self.liquidity

	// update the position
	if liquidityDelta != 0 {
		self.liquidity = liquidityNext
	}
	self.feeGrowthInside0LastX128 = feeGrowthInside0X128
	self.feeGrowthInside1LastX128 = feeGrowthInside1X128
	if (tokensOwed0 > 0 || tokensOwed1 > 0) {
			// overflow is acceptable, have to withdraw before you hit type(uint128).max fees
			self.tokensOwed0 += tokensOwed0
			self.tokensOwed1 += tokensOwed1
	}
}