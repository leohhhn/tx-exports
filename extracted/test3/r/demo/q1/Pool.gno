package pool

import (
	"gno.land/p/demo/grc/grc20"
	"std"
)

type Slot0 struct {
	// the current price
	sqrtPriceX96 uint
	// the current tick
	tick int
	// the current protocol fee as a percentage of the swap fee taken on withdrawal
	// represented as an integer denominator (1/x)%
	feeProtocol uint
	// whether the pool is locked
	unlocked bool
}

type ProtocolFees struct {
	token0 std.Address
	token1 std.Address
}

type TickInfo struct {
	// the total position liquidity that references this tick
	liquidityGross uint
	// amount of net liquidity added (subtracted) when tick is crossed from left to right (right to left),
	liquidityNet int
	// fee growth per unit of liquidity on the _other_ side of this tick (relative to the current tick)
	// only has relative meaning, not absolute — the value depends on when the tick is initialized
	feeGrowthOutside0X128 uint
	feeGrowthOutside1X128 uint
	// the cumulative tick value on the other side of the tick
	tickCumulativeOutside int
	// the seconds per unit of liquidity on the _other_ side of this tick (relative to the current tick)
	// only has relative meaning, not absolute — the value depends on when the tick is initialized
	secondsPerLiquidityOutsideX128 uint
	// the seconds spent on the other side of the tick (relative to the current tick)
	// only has relative meaning, not absolute — the value depends on when the tick is initialized
	secondsOutside uint
	// true iff the tick is initialized, i.e. the value is exactly equivalent to the expression liquidityGross != 0
	// these 8 bits are set to prevent fresh sstores when crossing newly initialized ticks
	initialized bool
}

var token0 std.Address
var token1 std.Address
var Token0 *grc20.AdminToken
var Token1 *grc20.AdminToken
var fee uint
var tickSpacing int
var maxLiquidityPerTick uint
var feeGrowthGlobal0X128 uint
var feeGrowthGlobal1X128 uint
var liquidity uint

var slot0 Slot0
var protocolFees ProtocolFees

var ticks map[int]TickInfo
var tickBitmap map[int]uint
var positions map[[]uint8]PositionInfo

func require(isTrue bool, message string) {
	if (!isTrue) {
		panic(message)
	}
}

func lock(inner func ()) {
	require(slot0.unlocked, "LOCK")
	slot0.unlocked = false
	inner()
	slot0.unlocked = true
}

/// @dev Common checks for valid tick inputs.
func checkTicks(tickLower int, tickUpper int) {
	require(tickLower < tickUpper, "TLU")
	require(tickLower >= -887272, "TLM")
	require(tickUpper <= 887272, "TUM")
}

/// @dev Returns the block timestamp truncated to 32 bits, i.e. mod 2**32. This method is overridden in tests.
func blockTimestamp() int {
	return int (std.GetHeight()) // truncation is desired
}

// TODO: change me initialization
func Initialize(sqrtPriceX96 uint) {
	require(slot0.sqrtPriceX96 == 0, "AI")

	Token0 = testtoken1.GetGRC20()
	Token1 = testtoken2.GetGRC20()
	var tick int = 0
	var cardinality = 0
	var cardinalityNext = 0

	slot0 = Slot0{
		sqrtPriceX96,
		tick,
		0,
		true,
	}
}

/// @dev Get the pool's balance of token0
/// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
/// check
func Balance0() uint {
	v, _ := Token0.BalanceOf(std.GetOrigPkgAddr())
	return uint (v)
}

/// @dev Get the pool's balance of token1
/// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
/// check
func Balance1() uint {
	v, _ := Token1.BalanceOf(std.GetOrigPkgAddr())
	return uint (v)
}

// TODO: implement this updatePosition
// func GetPositionKey(owner std.Address, tickLower int, tickUpper int) []uint8 {
// 	var key = fmt.Sprint(owner, "0000000000000000", tickLower, "0000000000000000", tickUpper)
// 	h := sha256.New()

// 	h.Write([]byte(key))

// 	return h.Sum(nil)
// }

func updatePosition(owner std.Address, tickLower int, tickUpper int, liquidityDelta int, tick int) PositionInfo {
	key := GetPositionKey(owner, tickLower, tickUpper)

	var flippedLower bool
	var flippedUpper bool

	if (liquidityDelta != 0) {
		time := blockTimestamp()
		flippedLower = updateTick()
		flippedUpper = updateTick()

		if (flippedLower) {
			flipTickBitmap(tickLower, tickSpacing)
		}
		if (flippedUpper) {
			flipTickBitmap(tickUpper, tickSpacing)
		}
	}

	feeGrowthInside0X128, feeGrowthInside1X128 := getFeeGrowthInside(
		tickLower,
		tickUpper,
		tick,
		feeGrowthGlobal0X128,
		feeGrowthGlobal1X128,
	)

	// updatePositionWithKey(key, liquidityDelta, feeGrowthInside0X128, feeGrowthInside1X128)

	 // clear any tick data that is no longer needed
	// if (liquidityDelta < 0) {
	// 	if (flippedLower) {
	// 			clearTick(tickLower)
	// 	}
	// 	if (flippedUpper) {
	// 			clearTick(tickUpper)
	// 	}
	// }
	return PositionInfo{
		0,0,0,0,0,
	}
}

func clearTick(tick int) {
	ticks[tick] = TickInfo{}
}

func updatePositionWithKey(key []uint8, liquidityDelta int, feeGrowthInside0X128 uint, feeGrowthInside1X128 uint) {
	position, _ := positions[key]
	// updatePositionInfo(&position, liquidityDelta, feeGrowthInside0X128, feeGrowthInside1X128)
}

func getFeeGrowthInside(
	tickLower int,
	tickUpper int,
	tickCurrent int,
	feeGrowthGlobal0X128 uint,
	feeGrowthGlobal1X128 uint,
) (uint, uint) {
	return 1, 1
}
func updateTick() (bool) {
	return true
}

func flipTickBitmap(tick int, spacing int) {

}



type ModifyPositionParams struct {
	// the address that owns the position
	owner std.Address
	// the lower and upper tick of the position
	tickLower int
	tickUpper int
	// any change in liquidity
	liquidityDelta int
}

func modifyPosition(params ModifyPositionParams) (PositionInfo, int, int) {
	// checkTicks(params.tickLower, params.tickUpper)

	position := updatePosition(
		params.owner,
		params.tickLower,
		params.tickUpper,
		params.liquidityDelta,
		slot0.tick,
	)

	// positionRef := &position

	return position, 0, 0

	// if params.liquidityDelta == 0 {
	// 	return
	// }

	// if (slot0.tick < params.tickLower) {
	// 	amount0 = getAmount0Delta(
	// 		getSqrtRatioAtTick(params.tickLower),
	// 		getSqrtRatioAtTick(params.tickUpper),
	// 		params.liquidityDelta,
	// 	)
	// 	return
	// }

	// if (slot0.tick >= params.tickUpper) {
	// 	amount1 = getAmount1Delta(
	// 		getSqrtRatioAtTick(params.tickLower),
	// 		getSqrtRatioAtTick(params.tickUpper),
	// 		params.liquidityDelta,
	// 	)
	// 	return
	// }

	// // case tickLower <= tick < tickUpper
	// amount0 = getAmount0Delta(
	// 		slot0.sqrtPriceX96,
	// 		getSqrtRatioAtTick(params.tickUpper),
	// 		params.liquidityDelta,
	// )
	// amount1 = getAmount1Delta(
	// 		getSqrtRatioAtTick(params.tickLower),
	// 		slot0.sqrtPriceX96,
	// 		params.liquidityDelta,
	// )

	// liquidity = addDelta(liquidity, params.liquidityDelta)
}

func Mint(recipient std.Address, tickLower int, tickUpper int, amount uint) (int, int) {
	require(amount > 0, "must amount > 0")
	_, amount0, amount1 := modifyPosition(
			ModifyPositionParams{
				recipient,
				tickLower,
				tickUpper,
				int (amount),
			},
	)
	return amount0, amount1

	// amount0 = uint(amount0Int)
	// amount1 = uint(amount1Int)

	// var balance0Before uint
	// var balance1Before uint
	// if (amount0 > 0) {
	// 	balance0Before = Balance0()
	// }
	// if (amount1 > 0) {
	// 	balance1Before = Balance1()
	// }

	// // TODO: callback

	// if (amount0 > 0) {
	// 	require(balance0Before + amount0 <= Balance0(), "M0")
	// }
	// if (amount1 > 0) {
	// 	require(balance1Before + amount1 <= Balance1(), "M1")
	// }
}

// func Burn(tickLower int, tickUpper int, amount uint) (amount0 uint, amount1 uint) {
// 	require(amount > 0)
// 	_, amount0Int, amount1Int := modifyPosition(
// 			ModifyPositionParams{
// 					std.GetOrigCaller(),
// 					tickLower,
// 					tickUpper,
// 					-int128(amount)
// 			}
// 	)

// 	amount0 = uint(-amount0Int)
// 	amount1 = uint(-amount1Int)

// 	if (amount0 > 0 || amount1 > 0) {
// 		position.tokensOwed0 = position.tokensOwed0 + uint(amount0)
// 		position.tokensOwed1 = position.tokensOwed1 + uint(amount1)
// 	}
// }

// // TODO: implement this Collect
// func Collect(recipient std.Address, tickLower int, tickUpper int, amount0Requested uint, amount1Requested uint) (amount0 uint, amount1 uint) {
// 	lock(func () => {
// 		// we don't need to checkTicks here, because invalid positions will never have non-zero tokensOwed{0,1}
// 		key := GetPositionKey(msg.sender, tickLower, tickUpper)
// 		position, _ := positions[key]

// 		if amount0Requested > position.tokensOwed0 {
// 			amount0 = position.tokensOwed0
// 		}
// 		else {
// 			amount0 = amount0Requested
// 		}

// 		if amount1Requested > position.tokensOwed1 {
// 			amount1 = position.tokensOwed1
// 		}
// 		else {
// 			amount1 = amount1Requested
// 		}

// 		if (amount0 > 0) {
// 				position.tokensOwed0 -= amount0
// 				// TODO: transfer TransferHelper.safeTransfer(token0, recipient, amount0)
// 				Token0.Transfer(recipient, amount0)
// 		}
// 		if (amount1 > 0) {
// 				position.tokensOwed1 -= amount1
// 				// TODO: transfer TransferHelper.safeTransfer(token1, recipient, amount1)
// 				Token1.Transfer(recipient, amount1)
// 		}
// 	})
// }

// // TODO: implement this Swap
// func Swap(recipient std.Address, zeroForOne bool, amountSpecified uint, sqrtPriceLimitX96 uint) (amount0 int, amount1 int) {

// }

// // TODO: implement this SetFeeProtocol
// func SetFeeProtocol(feeProtocol0 uint, feeProtocol1 uint) {

// }

// // TODO: implement this CollectProtocol
// func CollectProtocol(recipient std.Address, amount0Requested uint, amount1Requested uint) (amount0 int, amount1 int) {

// }

// type SwapCache struct {
// 	// the protocol fee for the input token
// 	feeProtocol uint
// 	// liquidity at the beginning of the swap
// 	liquidityStart uint
// 	// the timestamp of the current block
// 	blockTimestamp uint
// }

// type SwapState struct {
//  	// the amount remaining to be swapped in/out of the input/output asset
//   amountSpecifiedRemaining int
//  	// the amount already swapped out/in of the output/input asset
//   amountCalculated int
//  	// current sqrt(price)
//   sqrtPriceX96 uint
//  	// the tick associated with the current price
// 	tick int
//  	// the global fee growth of the input token
// 	feeGrowthGlobalX128 uint
//  	// amount of input token paid as protocol fee
// 	protocolFee uint
//  	// the current liquidity in range
// 	liquidity uint
// }

// type StepComputations struct {
// 	// the price at the beginning of the step
// 	sqrtPriceStartX96 uint
// 	// the next tick to swap to from the current tick in the swap direction
// 	tickNext int
// 	// whether tickNext is initialized or not
// 	initialized bool
// 	// sqrt(price) for the next tick (1/0)
// 	sqrtPriceNextX96 uint
// 	// how much is being swapped in in this step
// 	amountIn uint
// 	// how much is being swapped out
// 	amountOut uint
// 	// how much fee is being paid in
// 	feeAmount uint
// }

// // TODO: noDelegateCall
// func Swap(
// 	recipient std.Address,
// 	zeroForOne bool,
// 	amountSpecified int,
// 	sqrtPriceLimitX96 uint
// ) (amount0 uint, amount1 uint) {
// 	require(amountSpecified != 0, "AS")

// 	slot0Start := slot0

// 	require(slot0Start.unlocked, "LOK")
// 	require(
// 			zeroForOne
// 					? sqrtPriceLimitX96 < slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 > TickMath.MIN_SQRT_RATIO
// 					: sqrtPriceLimitX96 > slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 < TickMath.MAX_SQRT_RATIO,
// 			"SPL"
// 	)

// 	slot0.unlocked = false

// 	cache := SwapCache{
// 			liquidityStart: liquidity,
// 			blockTimestamp: _blockTimestamp(),
// 			feeProtocol: zeroForOne ? (slot0Start.feeProtocol % 16) : (slot0Start.feeProtocol >> 4),
// 	}

// 	bool exactInput = amountSpecified > 0

// 	state := SwapState{
// 			amountSpecifiedRemaining: amountSpecified,
// 			amountCalculated: 0,
// 			sqrtPriceX96: slot0Start.sqrtPriceX96,
// 			tick: slot0Start.tick,
// 			feeGrowthGlobalX128: zeroForOne ? feeGrowthGlobal0X128 : feeGrowthGlobal1X128,
// 			protocolFee: 0,
// 			liquidity: cache.liquidityStart
// 	}

// 	// continue swapping as long as we haven't used the entire input/output and haven't reached the price limit
// 	for state.amountSpecifiedRemaining != 0 && state.sqrtPriceX96 != sqrtPriceLimitX96 {
// 		var step StepComputations

// 		step.sqrtPriceStartX96 = state.sqrtPriceX96

// 		step.tickNext, step.initialized = nextInitializedTickWithinOneWord(
// 			tickBitmap,
// 			state.tick,
// 			tickSpacing,
// 			zeroForOne
// 		)

// 		// ensure that we do not overshoot the min/max tick, as the tick bitmap is not aware of these bounds
// 		if step.tickNext < TickMath.MIN_TICK {
// 			step.tickNext = TickMath.MIN_TICK
// 		} else if step.tickNext > TickMath.MAX_TICK {
// 			step.tickNext = TickMath.MAX_TICK
// 		}

// 		// get the price for the next tick
// 		step.sqrtPriceNextX96 = getSqrtRatioAtTick(step.tickNext)

// 		// compute values to swap to the target tick, price limit, or point where input/output amount is exhausted
// 		sqrtRatioTargetX96 := 0
// 		if zeroForOne && step.sqrtPriceNextX96 < sqrtPriceLimitX96 {
// 			sqrtRatioTargetX96 = sqrtPriceLimitX96
// 		} else {
// 			sqrtRatioTargetX96 = step.sqrtPriceNextX96
// 		}

// 		if !zeroForOne && step.sqrtPriceNextX96 > sqrtPriceLimitX96 {
// 			sqrtRatioTargetX96 = sqrtPriceLimitX96
// 		} else {
// 			sqrtRatioTargetX96 = step.sqrtPriceNextX96
// 		}
// 		state.sqrtPriceX96, step.amountIn, step.amountOut, step.feeAmount = computeSwapStep(
// 			state.sqrtPriceX96,
// 			sqrtRatioTargetX96,
// 			state.liquidity,
// 			state.amountSpecifiedRemaining,
// 			fee
// 		)

// 		if exactInput {
// 			state.amountSpecifiedRemaining -= step.amountIn + step.feeAmount
// 			state.amountCalculated = state.amountCalculated - step.amountOut
// 		} else {
// 			state.amountSpecifiedRemaining += step.amountOut
// 			state.amountCalculated = state.amountCalculated + step.amountIn + step.feeAmount
// 		}

// 		// if the protocol fee is on, calculate how much is owed, decrement feeAmount, and increment protocolFee
// 		if cache.feeProtocol > 0 {
// 			uint256 delta = step.feeAmount / cache.feeProtocol
// 			step.feeAmount -= delta
// 			state.protocolFee += delta
// 		}

// 		// update global fee tracker
// 		if state.liquidity > 0
// 			state.feeGrowthGlobalX128 += (step.feeAmount * FixedPoint128.Q128 / state.liquidity)

// 		// shift tick if we reached the next price
// 		if state.sqrtPriceX96 == step.sqrtPriceNextX96 {
// 			// if the tick is initialized, run the tick transition
// 			if step.initialized {
// 				// check for the placeholder value, which we replace with the actual value the first time the swap
// 				// crosses an initialized tick
// 				// TODO: cross func
// 				// liquidityNet := ticks.cross(
// 				// 	step.tickNext,
// 				// 	(zeroForOne ? state.feeGrowthGlobalX128 : feeGrowthGlobal0X128),
// 				// 	(zeroForOne ? feeGrowthGlobal1X128 : state.feeGrowthGlobalX128),
// 				// 	cache.secondsPerLiquidityCumulativeX128,
// 				// 	cache.tickCumulative,
// 				// 	cache.blockTimestamp
// 				// )
// 				// if we're moving leftward, we interpret liquidityNet as the opposite sign
// 				// safe because liquidityNet cannot be type(int128).min
// 				if zeroForOne {
// 					liquidityNet = -liquidityNet
// 				}

// 				// TODO: state.liquidity = LiquidityMath.addDelta(state.liquidity, liquidityNet)
// 			}

// 			if zeroForOne {
// 				state.tick = step.tickNext - 1
// 			} else {
// 				state.tick = step.tickNext
// 			}
// 		} else if state.sqrtPriceX96 != step.sqrtPriceStartX96 {
// 				// recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved
// 				state.tick = getTickAtSqrtRatio(state.sqrtPriceX96)
// 		}
// 	}

// 	// update tick and write an oracle entry if the tick change
// 	if state.tick != slot0Start.tick {
// 		slot0.sqrtPriceX96 = state.sqrtPriceX96
// 		slot0.tick = state.tick
// 	} else {
// 			// otherwise just update the price
// 			slot0.sqrtPriceX96 = state.sqrtPriceX96
// 	}

// 	// update liquidity if it changed
// 	if cache.liquidityStart != state.liquidity {
// 		liquidity = state.liquidity
// 	}

// 	// update fee growth global and, if necessary, protocol fees
// 	// overflow is acceptable, protocol has to withdraw before it hits type(uint128).max fees
// 	if zeroForOne {
// 			feeGrowthGlobal0X128 = state.feeGrowthGlobalX128
// 			if state.protocolFee > 0 { protocolFees.token0 += state.protocolFee }
// 	} else {
// 			feeGrowthGlobal1X128 = state.feeGrowthGlobalX128
// 			if state.protocolFee > 0 { protocolFees.token1 += state.protocolFee }
// 	}

// 	(amount0, amount1) = 
// 	if zeroForOne == exactInput {
// 		amount0 = amountSpecified - state.amountSpecifiedRemaining
//     amount1 = state.amountCalculated
// 	}
// 	else {
// 		amount0 = state.amountCalculated
//     amount1 = amountSpecified - state.amountSpecifiedRemaining
//   }

// 	// do the transfers and collect payment
// 	if zeroForOne {
// 			if amount1 < 0 { 
// 				Token1.Transfer(recipient, -amount1)
// 			}

// 			balance0Before := Balance0()
// 			ISwapCallback.UniswapV3SwapCallback(amount0, amount1)
// 			require(balance0Before + amount0) <= Balance0(), "IIA")
// 	} else {
// 			if amount0 < 0 {
// 				Token0.Transfer(recipient, -amount0)
// 			} 

// 			balance1Before := Balance1()
// 			ISwapCallback.UniswapV3SwapCallback(amount0, amount1)
// 			require(balance1Before + amount1) <= Balance1(), "IIA")
// 	}

// 	slot0.unlocked = true
// }