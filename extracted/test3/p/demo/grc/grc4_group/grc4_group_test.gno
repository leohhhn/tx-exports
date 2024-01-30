package grc4_group

import (
	"std"
	"testing"
)

func Test(t *testing.T) {
	{
		h := NewGRC4Group(nil)
		got := h.TotalWeight()
		expected := 0
		if got != expected {
			t.Fatalf("expected %q, got %q.", expected, got)
		}
	}
	{
		h := NewGRC4Group([]Member{
			{std.Address("g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a"), 11},
			{std.Address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"), 31},
		})
		got := h.TotalWeight()
		expected := 42
		if got != expected {
			t.Fatalf("expected %q, got %q.", expected, got)
		}
	}
	{
		func() {
			defer func() {
				if r := recover(); r == nil {
					t.Fatalf("expected panic, got none.")
				}
			}()
			h := NewGRC4Group([]Member{
				{std.Address("g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a"), 1},
				{std.Address("g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a"), 1},
			})
		}()
	}
	{
		h := NewGRC4Group([]Member{
			{std.Address("g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a"), 11},
			{std.Address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"), 31},
		})
		h.Render("")
	}
	{
		h := NewGRC4Group([]Member{
			{std.Address("g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a"), 11},
		})
		h.UpdateMembers([]Member{
			{std.Address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"), 31},
		},
			[]std.Address{
				std.Address("g14u5eaheavy0ux4dmpykg2gvxpvqvexm9cyg58a"),
			},
		)
		got := h.TotalWeight()
		expected := 31
		if got != expected {
			t.Fatalf("expected %q, got %q.", expected, got)
		}
		members := h.ListMembers()
		if members.Size() != 1 {
			t.Fatalf("expected %q, got %q.", 1, members.Size())
		}
		addr, weight := members.GetByIndex(0)
		if addr != "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" {
			t.Fatalf("expected %q, got %q.", "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5", addr)
		}
		if weight.(uint64) != 31 {
			t.Fatalf("expected %q, got %q.", 31, weight.(uint64))
		}
	}
	{
		h := NewGRC4Group(nil)
		func() {
			defer func() {
				if r := recover(); r == nil {
					t.Fatalf("expected panic, got none.")
				}
			}()
			h.UpdateMembers([]Member{
				{std.Address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"), 1},
				{std.Address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"), 1},
			}, nil)
		}()
	}
}
