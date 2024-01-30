package register

import (
	"strings"
	"unicode/utf8"

	"gno.land/p/demo/grc/grc721"
	"gno.land/r/disperze/domains"
	"gno.land/r/disperze/nft"
	"std"
)

func Register(domain string, to std.Address) grc721.TokenID {
	std.AssertOriginCall()
	sender := std.GetOrigCaller()
	parts := strings.Split(domain, ".")
	if len(parts) != 2 {
		panic("invalid domain")
	}
	_tld := tld
	if parts[1] != _tld {
		panic("invalid domain")
	}

	name := strings.ToLower(parts[0])
	if !canRegister(sender, name) {
		panic("cannot register")
	}

	domainN := name + "." + _tld
	tid := nextNftID(domain)
	t := domains.GetTLD(_tld)
	nft.Mint(t.CID, tid, to, "")
	domains.RegisterDomain(tid, domainN)

	return tid
}

// gno:admin
func UpdatePrice(price uint64, len int) {
	std.AssertOriginCall()
	sender := std.GetOrigCaller()
	if sender != admin {
		panic("unauthorized")
	}

	updated := false
	for i, p := range prices {
		if len == p.length {
			prices[i].amount = price
			updated = true
			break
		}
	}

	if !updated {
		prices = append(prices, &Price{len, price})
	}
}

// gno:admin
func Withdraw(to std.Address) {
	std.AssertOriginCall()
	caller := std.GetOrigCaller()
	if caller != admin {
		panic("unauthorized")
	}

	pkgAddr := std.GetOrigPkgAddr()
	bank := std.GetBanker(std.BankerTypeRealmSend)
	balance := bank.GetCoins(pkgAddr)
	bank.SendCoins(pkgAddr, to, balance)
}

// gno:admin
func Initialize(addr std.Address, _denom, _tld string) {
	if initiated {
		panic("already initiated")
	}

	if addr != "" {
		admin = addr
	}

	if _denom != "" {
		denom = _denom
	}

	if _tld != "" {
		tld = _tld
	}

	initiated = true
}

// gno:query
func GetPrice(domain string) uint64 {
	parts := strings.Split(domain, ".")
	if len(parts) != 2 {
		panic("invalid domain")
	}

	if parts[1] != tld {
		panic("invalid domain")
	}
	name := parts[0]
	return getPrice(name)
}

func canRegister(addr std.Address, name string) bool {
	if addr == admin {
		return true
	}
	price := getPrice(name)
	amount := std.GetOrigSend().AmountOf(denom)

	return amount >= int64(price)
}

func getPrice(name string) uint64 {
	len := utf8.RuneCountInString(name)
	for _, price := range prices {
		if len <= price.length {
			return price.amount
		}
	}

	panic("invalid length")
}
