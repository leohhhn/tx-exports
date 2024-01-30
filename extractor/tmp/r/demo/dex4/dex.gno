package dex

import (
	"std"

	"gno.land/p/demo/grc/grc20"
	"gno.land/r/demo/token20"
	"gno.land/r/demo/token21"
)

var (
	tokenZero, tokenOne grc20.IGRC20
)

func init() {
	tokenZero := testtoken1.GetGRC20()
	tokenOne := testtoken2.GetGRC20()
}	



func ProvideLp() {
	caller := std.GetOrigCaller()
	pkgaddr := std.GetOrigPkgAddr()
	tokenZero.TransferFrom(caller,pkgaddr, 10000*10000)
	tokenOne.TransferFrom(caller,pkgaddr, 2*10000*10000)
}


func Swap(amount uint64, zeroToOne bool) (out uint64) {
	caller := std.GetOrigCaller()
	pkgaddr := std.GetOrigPkgAddr()
	if amount <= 0 {
		panic("Amount is zero")
	}
	if zeroToOne {
		tokenZero.TransferFrom(caller, pkgaddr, amount)
		out := CalculateOut(amount, zeroToOne)
		tokenOne.Transfer(caller, out)
	} else {
		tokenOne.TransferFrom(caller, pkgaddr, amount)
		out := CalculateOut(amount, zeroToOne)
		tokenZero.Transfer(caller, out)
	}
	return out
}

func CalculateOut(amount uint64, zeroToOne bool) (out uint64) {
	var temp float64
	if zeroToOne {
		temp = float64(amount * 2)
	} else {
		temp = float64(amount / 2)
	}
	return uint64(temp)
}

func GetAddress() std.Address {
	pkgaddr := std.GetOrigPkgAddr()
	return pkgaddr
}