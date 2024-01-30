package pool


func getNextSqrtPriceFromAmount0RoundingUp(
	sqrtPX96 uint,
	liquidity uint,
	amount uint,
	add bool,
) (uint) {
	// we short circuit amount == 0 because the result is otherwise not guaranteed to equal the input price
	if amount == 0 {
		return sqrtPX96
	}
	numerator1 := liquidity
	var denominator uint
	product := amount * sqrtPX96
	
	if add {
			if product / amount == sqrtPX96 {
					denominator = numerator1 + product
					if denominator >= numerator1 {
						// TODO: rounding up
						return numerator1 * sqrtPX96 / denominator
					}
			}

		// TODO: rounding up
		return numerator1 * (numerator1 / sqrtPX96) + amount
	} 
	// if the product overflows, we know the denominator underflows
	// in addition, we must check that the denominator does not underflow
	require(product / amount == sqrtPX96 && numerator1 > product, "BAD")
	denominator = numerator1 - product
	return numerator1 * sqrtPX96 / denominator
}

func getNextSqrtPriceFromAmount1RoundingDown(
	sqrtPX96 uint,
	liquidity uint,
	amount uint,
	add bool,
) (uint) {
	// if we're adding (subtracting), rounding down requires rounding the quotient down (up)
	// in both cases, avoid a mulDiv for most inputs
	quotient := amount / liquidity
	if (add) {
		return quotient + sqrtPX96
	} 
	require(sqrtPX96 > quotient, "BAD");
	// always fits 160 bits
	return sqrtPX96 - quotient
}

func getNextSqrtPriceFromInput(
	sqrtPX96 uint,
	liquidity uint,
	amountIn uint,
	zeroForOne bool,
) (sqrtQX96 uint) {
	require(sqrtPX96 > 0, "BAD");
	require(liquidity > 0, "BAD");

	if zeroForOne {
		return getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
	}

	return getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true)
}

func getNextSqrtPriceFromOutput(
	sqrtPX96 uint,
	liquidity uint,
	amountOut uint,
	zeroForOne bool,
) (sqrtQX96 uint) {
	require(sqrtPX96 > 0, "BAD");
	require(liquidity > 0, "BAD");

	if zeroForOne {
		return getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
	}

	return getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false)
}

/// @notice Computes the result of swapping some amount in, or amount out, given the parameters of the swap
/// @dev The fee, plus the amount in, will never exceed the amount remaining if the swap's `amountSpecified` is positive
/// @param sqrtRatioCurrentX96 The current sqrt price of the pool
/// @param sqrtRatioTargetX96 The price that cannot be exceeded, from which the direction of the swap is inferred
/// @param liquidity The usable liquidity
/// @param amountRemaining How much input or output amount is remaining to be swapped in/out
/// @param feePips The fee taken from the input amount, expressed in hundredths of a bip
/// @return sqrtRatioNextX96 The price after swapping the amount in/out, not to exceed the price target
/// @return amountIn The amount to be swapped in, of either token0 or token1, based on the direction of the swap
/// @return amountOut The amount to be received, of either token0 or token1, based on the direction of the swap
/// @return feeAmount The amount of input that will be taken as a fee
func computeSwapStep(
	sqrtRatioCurrentX96 uint,
	sqrtRatioTargetX96 uint,
	liquidity uint,
	amountRemaining int,
	feePips uint,
) (
	sqrtRatioNextX96 uint,
	amountIn uint,
	amountOut uint,
	feeAmount uint,
) {
	zeroForOne := sqrtRatioCurrentX96 >= sqrtRatioTargetX96
	exactIn := amountRemaining >= 0

	if exactIn {
			amountRemainingLessFee := amountRemaining * int (uint (1e6) - feePips) / int (1e6)
			if zeroForOne {
				amountIn = getAmount0DeltaBase(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, true)
			} else {
				amountIn = getAmount1DeltaBase(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, true)
			}
			
			if amountRemainingLessFee >= int (amountIn) {
				sqrtRatioNextX96 = sqrtRatioTargetX96
			} else {
				sqrtRatioNextX96 = getNextSqrtPriceFromInput(
					sqrtRatioCurrentX96,
					liquidity,
					uint (amountRemainingLessFee),
					zeroForOne,
				)
			}
	} else {
			if zeroForOne {
				amountOut = getAmount1DeltaBase(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, false)
			} else {
				amountOut = getAmount0DeltaBase(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, false)
			}
		
			if uint(-amountRemaining) >= amountOut {
				sqrtRatioNextX96 = sqrtRatioTargetX96
			} else {
				sqrtRatioNextX96 = getNextSqrtPriceFromOutput(
						sqrtRatioCurrentX96,
						liquidity,
						uint(-amountRemaining),
						zeroForOne,
				)
			}
	}

	max := sqrtRatioTargetX96 == sqrtRatioNextX96

	// get the input/output amounts
	if zeroForOne {
		if !(max && exactIn) {
			amountIn = getAmount0DeltaBase(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, true)
		}
		if max && !exactIn {
			amountOut = getAmount1DeltaBase(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, false)
		}
	} else {
			if !(max && exactIn) {
				amountIn = getAmount1DeltaBase(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, true)
			}
			if max && !exactIn {
				amountOut = getAmount0DeltaBase(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, false)
			}
	}

	// cap the output amount to not exceed the remaining output amount
	if !exactIn && amountOut > uint(-amountRemaining) {
			amountOut = uint(-amountRemaining)
	}

	if exactIn && sqrtRatioNextX96 != sqrtRatioTargetX96 {
			// we didn't reach the target, so take the remainder of the maximum input as fee
			feeAmount = uint(amountRemaining) - amountIn
	} else {
			// TODO: rounding up feeAmount = FullMath.mulDivRoundingUp(amountIn, feePips, 1e6 - feePips)
			feeAmount = amountIn * feePips / (1e6 - feePips)
	}
}
