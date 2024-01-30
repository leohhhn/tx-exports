package dao_voting_grc4

import (
	"std"

	dao_interfaces "gno.land/p/demo/daodao/interfaces"
	"gno.land/p/demo/grc/grc4_group"
	"gno.land/p/demo/markdown_utils"
)

type grc4Voting struct {
	dao_interfaces.IVotingModule

	group grc4_group.IGRC4Group
}

func NewGRC4Voting(group grc4_group.IGRC4Group) dao_interfaces.IVotingModule {
	return &grc4Voting{group: group}
}

func (v *grc4Voting) VotingPower(addr std.Address) uint64 {
	weight, has := v.group.Member(addr)
	if !has {
		return 0
	}
	return weight
}

func (v *grc4Voting) TotalPower() uint64 {
	return v.group.TotalWeight()
}

func (v *grc4Voting) Render(path string) string {
	return "# GRC4 Voting Module\n" + markdown_utils.Indent(v.group.Render(path))
}
