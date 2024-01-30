package grc4_group

import (
	"gno.land/p/demo/avl"
)

func AssertUniqueMembers(members []Member) {
	seen := avl.NewTree()
	for _, member := range members {
		memberAddress := member.Address.String()
		if seen.Has(memberAddress) {
			panic("duplicate member: " + memberAddress)
		}
		seen.Set(memberAddress, true)
	}
}
