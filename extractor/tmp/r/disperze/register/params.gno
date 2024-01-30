package register

import (
	"std"
)

var (
	initiated = false

	nftPrefix = "GND-"
	admin     = std.Address("")
	tld       = "gno"
	denom     = "ugnot"
	prices    = []*Price{
		{1, 50000000},
		{3, 30000000},
		{256, 10000000},
	}
)

type Price struct {
	length int
	amount uint64
}
