package domains

import (
	"gno.land/p/demo/grc/grc721"
	"gno.land/r/disperze/nft"
	"std"
)

type DomainResponse struct {
	Name  string
	Tld   string
	TID   grc721.TokenID
	Owner std.Address
}

type TLDResponse struct {
	Tld    string
	CID    nft.CollectionID
	Issuer std.Address
	Total  int
}
