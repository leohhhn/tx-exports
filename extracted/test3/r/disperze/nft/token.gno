package nft

import (
	"errors"

	"std"
)

type NFToken struct {
	owner    std.Address
	approved std.Address
	uri      string
}

func newToken(owner std.Address, uri string) *NFToken {
	return &NFToken{
		owner: owner,
		uri:   uri,
	}
}

func (t *NFToken) validate() error {
	if !isValidAddr(t.owner) {
		return errors.New("owner is not a valid address")
	}

	return nil
}

func (t *NFToken) Render() string {
	panic("unimplemented")
}

func (t *NFToken) GetInfo() NftInfo {
	return NftInfo{
		Uri: t.uri,
	}
}
