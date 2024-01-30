package nft

import (
	"gno.land/p/demo/avl"
)

var (
	collections   = avl.NewMutTree()
	collectionCtr int // increments Collection.id
)
