package nft

import (
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/grc/grc721"
)

func CreateCollection(name, symbol, uri string, minter std.Address) CollectionID {
	collection := newCollection(name, symbol, uri, minter)
	noError(collection.validate())
	cid := nextCollectionID()
	collections.Set(string(cid), collection)
	return cid
}

func Mint(cid CollectionID, tid grc721.TokenID, to std.Address, uri string) {
	token := newToken(to, uri)
	noError(token.validate())

	c := getCollection(cid)
	if c.minter != getCaller() {
		panic("unauthorized")
	}

	if c.tokens.Has(string(tid)) {
		panic("token already exists")
	}

	c.addToken(tid, token)
	c.addOwnerToken(tid, to)
	c.incrTotalSupply()
}

func TransferFrom(cid CollectionID, from, to std.Address, tid grc721.TokenID) {
	c := getCollection(cid)
	caller := getCaller()
	token := c.getToken(tid)

	if from != token.owner {
		panic("from is not the current owner")
	}

	if !isValidAddr(to) {
		panic("recipient address is invalid or empty")
	}

	if !canSend(caller, token, c) {
		panic("unauthorized")
	}

	c.delOwnerToken(tid, token.owner)
	token.owner = to
	c.addOwnerToken(tid, to)

	// reset approval
	token.approved = ""
}

func Approve(cid CollectionID, approved std.Address, tid grc721.TokenID) {
	c := getCollection(cid)
	caller := getCaller()
	token := c.getToken(tid)

	if !canChangeApprovals(caller, token, c) {
		panic("unauthorized")
	}

	token.approved = approved
}

func ApproveAll(cid CollectionID, operator std.Address) {
	if operator == "" {
		panic("operator cannot be empty")
	}

	c := getCollection(cid)
	caller := getCaller()
	c.setOperator(caller, operator)
}

func Revoke(cid CollectionID, tid grc721.TokenID) {
	c := getCollection(cid)
	caller := getCaller()
	token := c.getToken(tid)

	if !canChangeApprovals(caller, token, c) {
		panic("unauthorized")
	}

	token.approved = ""
}

func RevokeAll(cid CollectionID) {
	c := getCollection(cid)
	caller := getCaller()
	removed := c.delOperator(caller)
	if !removed {
		panic("no operator found")
	}
}

func Burn(cid CollectionID, tid grc721.TokenID) {
	caller := getCaller()
	c := getCollection(cid)
	token := c.getToken(tid)

	if !canSend(caller, token, c) {
		panic("unauthorized")
	}

	c.decrTotalSupply()
	c.delOwnerToken(tid, token.owner)
	c.tokens.Remove(string(tid))
}

// Query

func BalanceOf(cid CollectionID, owner std.Address) (count int64) {
	c := getCollection(cid)
	_, nfts, exist := c.owners.Get(owner.String())
	if !exist {
		return 0
	}

	total := int64(0)
	nfts.(*avl.Tree).Iterate("", "", func(t *avl.Tree) bool {
		total++
		return false
	})

	return total
}

func OwnerOf(cid CollectionID, tid grc721.TokenID) std.Address {
	c := getCollection(cid)
	token := c.getToken(tid)
	return token.owner
}

func GetCollection(cid CollectionID) CollectionInfo {
	c := getCollection(cid)
	return c.GetInfo()
}

func GetNftInfo(cid CollectionID, tid grc721.TokenID) NftInfo {
	c := getCollection(cid)
	token := c.getToken(tid)

	return token.GetInfo()
}

func GetMinter(cid CollectionID) std.Address {
	c := getCollection(cid)
	return c.minter
}

func TokensOf(cid CollectionID, owner std.Address, start grc721.TokenID, limit int) string {
	if limit <= 0 {
		panic("limit must be greater than 0")
	}

	c := getCollection(cid)
	_, nfts, exist := c.owners.Get(owner.String())
	if !exist {
		return ""
	}

	count := 0
	tokens, separator := "", ""
	nfts.(*avl.Tree).Iterate(string(start), "", func(t *avl.Tree) bool {
		tokens += separator + t.Key()
		count++
		if count == limit {
			return true
		}
		separator = ","
		return false
	})

	return tokens
}

func AllTokens(cid CollectionID, start grc721.TokenID, limit int) string {
	c := getCollection(cid)
	count := 0
	tokens, separator := "", ""
	c.tokens.Iterate(string(start), "", func(t *avl.Tree) bool {
		tokens += separator + t.Key()

		count++
		if count == limit {
			return true
		}
		separator = ","
		return false
	})

	return tokens
}

func GetApproval(cid CollectionID, tid grc721.TokenID) std.Address {
	c := getCollection(cid)
	token := c.getToken(tid)
	return token.approved
}

func GetOperator(cid CollectionID, owner std.Address) std.Address {
	c := getCollection(cid)
	operator, ok := c.getOperator(owner)
	if !ok {
		return ""
	}

	return operator
}
