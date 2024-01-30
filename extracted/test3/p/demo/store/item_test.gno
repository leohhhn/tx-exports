package store

import (
	"testing"
)

// TestNewItem verifies that a new item can be successfully created
func TestNewItem(t *testing.T) {
	const (
		id 				uint = 123
		price 			uint64 = 456
		description 	string = "item description"
	)

	i := NewItem(id, price, description)

	if i.GetId() != id {
		t.Fatalf("invalid ID")
	}

	if i.GetPrice() != price {
		t.Fatalf("invalid price")
	}

	if  i.GetDescription() != description {
		t.Fatalf("invalid description")
	}
}