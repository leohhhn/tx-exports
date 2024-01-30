package pool

/// @notice Gets the amount0 delta between two prices
/// @dev Calculates liquidity / sqrt(lower) - liquidity / sqrt(upper),
/// i.e. liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))
/// @param sqrtRatioAX96 A sqrt price
/// @param sqrtRatioBX96 Another sqrt price
/// @param liquidity The amount of usable liquidity
/// @param roundUp Whether to round the amount up or down
/// @return amount0 Amount of token0 required to cover a position of size liquidity between the two passed prices
func getAmount0DeltaBase(
	sqrtRatioAX96 uint,
	sqrtRatioBX96 uint,
	liquidity uint,
	roundUp bool,
) (amount0 uint) {
	if sqrtRatioAX96 > sqrtRatioBX96 {
		tempValue := sqrtRatioAX96
		sqrtRatioAX96 = sqrtRatioBX96
		sqrtRatioBX96 = tempValue
	}

	numerator1 := liquidity;
	numerator2 := sqrtRatioBX96 - sqrtRatioAX96;

	require(sqrtRatioAX96 > 0, "must sqrtRatioAX96 > 0");

	// TODO: rounding up
	// if roundUp {
	// 	return ((numerator1 * numerator2) / sqrtRatioBX96) / sqrtRatioAX96
	// }

	return ((numerator1 * numerator2) / sqrtRatioBX96) / sqrtRatioAX96
}

/// @notice Gets the amount1 delta between two prices
/// @dev Calculates liquidity * (sqrt(upper) - sqrt(lower))
/// @param sqrtRatioAX96 A sqrt price
/// @param sqrtRatioBX96 Another sqrt price
/// @param liquidity The amount of usable liquidity
/// @param roundUp Whether to round the amount up, or down
/// @return amount1 Amount of token1 required to cover a position of size liquidity between the two passed prices
func getAmount1DeltaBase(
	sqrtRatioAX96 uint,
	sqrtRatioBX96 uint,
	liquidity uint,
	roundUp bool,
) (amount1 uint) {
	if sqrtRatioAX96 > sqrtRatioBX96 {
		tempValue := sqrtRatioAX96
		sqrtRatioAX96 = sqrtRatioBX96
		sqrtRatioBX96 = tempValue
	}

	numerator1 := liquidity;
	numerator2 := sqrtRatioBX96 - sqrtRatioAX96;

	// TODO: rounding up
	// if roundUp {
	// 	return numerator1 * numerator2
	// }

	return numerator1 * numerator2
}

/// @notice Helper that gets signed token0 delta
/// @param sqrtRatioAX96 A sqrt price
/// @param sqrtRatioBX96 Another sqrt price
/// @param liquidity The change in liquidity for which to compute the amount0 delta
/// @return amount0 Amount of token0 corresponding to the passed liquidityDelta between the two prices
func getAmount0Delta(
	sqrtRatioAX96 uint,
	sqrtRatioBX96 uint,
	liquidity int,
) (amount0 int) {
	if liquidity < 0 {
		return int (-getAmount0DeltaBase(sqrtRatioAX96, sqrtRatioBX96, uint (-liquidity), false))
	}

	return int (getAmount0DeltaBase(sqrtRatioAX96, sqrtRatioBX96, uint (liquidity), true))
}

/// @notice Helper that gets signed token1 delta
/// @param sqrtRatioAX96 A sqrt price
/// @param sqrtRatioBX96 Another sqrt price
/// @param liquidity The change in liquidity for which to compute the amount1 delta
/// @return amount1 Amount of token1 corresponding to the passed liquidityDelta between the two prices
func getAmount1Delta(
	sqrtRatioAX96 uint,
	sqrtRatioBX96 uint,
	liquidity int,
) (amount1 int) {
	if liquidity < 0 {
		return int (-getAmount1DeltaBase(sqrtRatioAX96, sqrtRatioBX96, uint (-liquidity), false))
	}

	return int (getAmount1DeltaBase(sqrtRatioAX96, sqrtRatioBX96, uint (liquidity), true))
}