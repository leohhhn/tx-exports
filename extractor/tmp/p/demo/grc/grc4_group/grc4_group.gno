package grc4_group

import (
	"errors"
	"std"
	"strconv"

	"gno.land/p/demo/avl"
)

// TODO: fully match cw4 api where it makes sense
type IGRC4Group interface {
	UpdateMembers(toAdd []Member, toRemove []std.Address)
	// AddHook()
	// RemoveHook()

	Member(address std.Address) (uint64, bool)
	ListMembers() *avl.Tree
	TotalWeight() uint64
	// Hooks()

	Render(path string) string
}

type Member struct {
	Address std.Address
	Weight  uint64
}

type grc4Group struct {
	IGRC4Group

	admin       std.Address
	members     *avl.Tree
	totalWeight uint64
}

func NewGRC4Group(members []Member) IGRC4Group {
	AssertUniqueMembers(members)

	totalWeight := uint64(0)
	for _, member := range members {
		totalWeight += member.Weight
	}

	membersTree := avl.NewTree()
	for _, member := range members {
		membersTree.Set(member.Address.String(), member.Weight)
	}

	return &grc4Group{
		members:     membersTree,
		totalWeight: totalWeight,
	}
}

func (g *grc4Group) UpdateMembers(toAdd []Member, toRemove []std.Address) {
	AssertUniqueMembers(toAdd)

	for _, member := range toAdd {
		strAddr := member.Address.String()
		oldWeight, has := g.members.Get(strAddr)
		if has {
			g.totalWeight -= oldWeight.(uint64)
		}
		g.members.Set(strAddr, member.Weight)
		g.totalWeight += member.Weight
	}

	for _, addr := range toRemove {
		strAddr := addr.String()
		weight, has := g.members.Get(strAddr)
		if has {
			g.totalWeight -= weight.(uint64)
		}
		g.members.Remove(strAddr)
	}

	// TODO: call hooks
}

func (g *grc4Group) Admin() std.Address {
	return g.admin
}

func (g *grc4Group) Member(addr std.Address) (uint64, bool) {
	weight, has := g.members.Get(addr.String())
	return weight.(uint64), has
}

func (g *grc4Group) ListMembers() *avl.Tree {
	return g.members
}

func (g *grc4Group) TotalWeight() uint64 {
	return g.totalWeight
}

func (g *grc4Group) Render(path string) string {
	membersCount := g.members.Size()
	membersString := strconv.Itoa(membersCount) + " member"
	if membersCount > 1 {
		membersString += "s"
	}

	r := "# GRC4 Group" + "\n" +
		"## Summary" + "\n" +
		"Admin: " + g.admin.String() + "\n\n" +
		membersString + "\n\n" +
		"Total weight: " + strconv.FormatUint(g.totalWeight, 10) + "\n" +
		"## Members" + "\n"

	g.members.Iterate("", "", func(key string, weight interface{}) bool {
		r += "- " + key + " (" + strconv.FormatUint(weight.(uint64), 10) + ")" + "\n"
		return false
	})

	return r
}

func (g *grc4Group) AssertIsAdmin() {
	caller := std.GetOrigCaller()
	if caller != g.admin {
		panic(errors.New("you're not admin"))
	}
}
