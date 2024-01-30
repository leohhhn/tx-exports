package dr

import (
	"std"

	"gno.land/r/demo/foo20"
	"gno.land/r/demo/users"
)

func FooBal() uint64 {
	orig := std.GetOrigCaller()
	return foo20.BalanceOf(users.AddressOrName(orig))
}

func FooFaucetBal() uint64 {
	orig := std.GetOrigCaller()
	foo20.Faucet()
	return foo20.BalanceOf(users.AddressOrName(orig))
}
