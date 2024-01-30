package dao_core

import (
	"std"
	"strings"

	dao_interfaces "gno.land/p/demo/daodao/interfaces"
	"gno.land/p/demo/markdown_utils"
)

type IDAOCore interface {
	AddProposalModule(proposalMod dao_interfaces.IProposalModule)

	VotingModule() dao_interfaces.IVotingModule
	ProposalModules() []dao_interfaces.IProposalModule

	Render(path string) string
}

type daoCore struct {
	IDAOCore

	votingModule    dao_interfaces.IVotingModule
	proposalModules []dao_interfaces.IProposalModule
}

func NewDAOCore(
	votingModule dao_interfaces.IVotingModule,
	proposalModules []dao_interfaces.IProposalModule,
) IDAOCore {
	return &daoCore{
		votingModule:    votingModule,
		proposalModules: proposalModules,
	}
}

func (d *daoCore) VotingModule() dao_interfaces.IVotingModule {
	return d.votingModule
}

func (d *daoCore) ProposalModules() []dao_interfaces.IProposalModule {
	return d.proposalModules
}

func (d *daoCore) AddProposalModule(proposalMod dao_interfaces.IProposalModule) {
	d.proposalModules = append(d.proposalModules, proposalMod)
}

func (d *daoCore) Render(path string) string {
	s := "# DAO Core\n"
	s += "This is a port of [DA0-DA0 contracts](https://github.com/DA0-DA0/dao-contracts)\n"
	s += markdown_utils.Indent(d.votingModule.Render(path)) + "\n"
	for _, propMod := range d.proposalModules {
		s += markdown_utils.Indent(propMod.Render(path)) + "\n"
	}
	return s
}
