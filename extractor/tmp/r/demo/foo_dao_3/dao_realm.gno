package dao_realm

import (
	"std"
	"time"

	"gno.land/p/demo/daodao/core"
	"gno.land/p/demo/daodao/interfaces"
	"gno.land/p/demo/daodao/proposal_single"
	"gno.land/p/demo/daodao/voting_grc4"
	"gno.land/p/demo/grc/grc4_group"
)

var daoCore = dao_core.NewDAOCore(dao_voting_grc4.NewGRC4Voting(grc4_group.NewGRC4Group([]grc4_group.Member{
	{"g1747t5m2f08plqjlrjk2q0qld7465hxz8gkx59c", 1}, // zooma
	{"g108cszmcvs4r3k67k7h5zuhm4el3qhlrxzhshtv", 1}, // normadena
	{"g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a", 1}, // no dev
	{"g1ckn395mpttp0vupgtratyufdaakgh8jgkmr3ym", 1}, // yo
})), nil)

func init() {
	tt := dao_interfaces.Percent(100) // 1%
	tq := dao_interfaces.Percent(100) // 1%
	proposalMod := dao_proposal_single.NewDAOProposalSingle(daoCore, &dao_proposal_single.DAOProposalSingleOpts{
		MaxVotingPeriod: time.Hour * 24 * 42,
		Threshold: dao_interfaces.Threshold{ThresholdQuorum: &dao_interfaces.ThresholdQuorum{
			Threshold: dao_interfaces.PercentageThreshold{Percent: &tt},
			Quorum:    dao_interfaces.PercentageThreshold{Percent: &tq},
		}},
	})
	daoCore.AddProposalModule(proposalMod)
}

func Render(path string) string {
	return daoCore.Render(path)
}

func GetCore() dao_core.IDAOCore {
	return daoCore
}

func Vote(moduleIndex int, proposalID int, vote dao_interfaces.Vote, rationale string) {
	mods := GetCore().ProposalModules()
	if len(mods) <= moduleIndex {
		panic("invalid module index")
	}
	mods[moduleIndex].Vote(proposalID, vote, rationale)
}

func Execute(moduleIndex int, proposalID int) {
	mods := GetCore().ProposalModules()
	if len(mods) <= moduleIndex {
		panic("invalid module index")
	}
	mods[moduleIndex].Execute(proposalID)
}

func Propose(moduleIndex int, title string, description string) {
	mods := GetCore().ProposalModules()
	if len(mods) <= moduleIndex {
		panic("invalid module index")
	}
	mods[moduleIndex].Propose(title, description, nil)
}
