package nft

import (
	"errors"
	"strconv"

	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/grc/grc721"
)

type CollectionID string

type Collection struct {
	name      string
	symbol    string
	uri       string
	minter    std.Address
	supply    int
	tokens    *avl.Tree // grc721.TokenID -> *NFToken{}
	operators *avl.Tree // owner std.Address -> operator std.Address
	owners    *avl.Tree // owner std.Address -> (grc721.TokenID -> nil)
}

func newCollection(name, symbol, uri string, minter std.Address) *Collection {
	return &Collection{
		name:   name,
		symbol: symbol,
		uri:    uri,
		minter: minter,
	}
}

func (c CollectionID) String() string {
	return string(c)
}

func (c *Collection) validate() error {
	if len(c.name) < 3 || len(c.name) > 50 {
		return errors.New("name is not in the expected format")
	}

	if len(c.symbol) < 3 || len(c.symbol) > 12 {
		return errors.New("symbol is not in expected format")
	}

	if !isValidAddr(c.minter) {
		return errors.New("minter is not a valid")
	}

	return nil
}

func (c *Collection) incrTotalSupply() {
	c.supply++
}

func (c *Collection) decrTotalSupply() {
	c.supply--
}

func (c *Collection) addOwnerToken(tid grc721.TokenID, owner std.Address) {
	nfts := c.ownerStore(owner)
	nfts, _ = nfts.Set(string(tid), "")
	c.owners, _ = c.owners.Set(owner.String(), nfts)
}

func (c *Collection) delOwnerToken(tid grc721.TokenID, owner std.Address) {
	_, nfts, exist := c.owners.Get(owner.String())
	if !exist {
		panic("unexpected error")
	}
	nfts, _, _, _ = nfts.(*avl.Tree).Remove(string(tid))
	c.owners, _ = c.owners.Set(owner.String(), nfts)
}

func (c *Collection) ownerStore(addr std.Address) *avl.Tree {
	if !c.owners.Has(addr.String()) {
		var tree *avl.Tree
		c.owners, _ = c.owners.Set(addr.String(), tree)

		return tree
	}

	_, tree, _ := c.owners.Get(addr.String())
	return tree.(*avl.Tree)
}

func (c *Collection) getToken(tid grc721.TokenID) *NFToken {
	_, token, ok := c.tokens.Get(string(tid))
	if !ok {
		panic("token does not exist")
	}

	return token.(*NFToken)
}

func (c *Collection) addToken(tid grc721.TokenID, token *NFToken) {
	c.tokens, _ = c.tokens.Set(string(tid), token)
}

func (c *Collection) getOperator(owner std.Address) (std.Address, bool) {
	_, operator, ok := c.operators.Get(owner.String())
	if !ok {
		return "", false
	}

	return operator.(std.Address), true
}

func (c *Collection) setOperator(sender, operator std.Address) {
	c.operators, _ = c.operators.Set(sender.String(), operator)
}

func (c *Collection) delOperator(sender std.Address) bool {
	newOperators, _, _, removed := c.operators.Remove(sender.String())
	if removed {
		c.operators = newOperators
	}

	return removed
}

func (c *Collection) Render() string {
	panic("unimplemented")
}

func (c *Collection) GetInfo() CollectionInfo {
	return CollectionInfo{
		Name:   c.name,
		Symbol: c.symbol,
		Uri:    c.uri,
		Supply: c.supply,
	}
}

func getCollection(cid CollectionID) *Collection {
	collectionI, exists := collections.Get(cid.String())
	if !exists {
		panic("collection does not exist")
	}

	return collectionI.(*Collection)
}

func nextCollectionID() CollectionID {
	collectionCtr++
	s := strconv.Itoa(collectionCtr)
	return CollectionID(s)
}
