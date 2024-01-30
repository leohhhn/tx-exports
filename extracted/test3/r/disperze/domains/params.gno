package domains

import (
	"std"
)

var (
	initiated = false
	admin     std.Address

	defaultTypes = map[string]RecordType{
		"bech32": Bech32Type{},
		"url":    URLType{},
		"ip":     IPType{},
		"email":  EmailType{},
		"text":   TextType{},
		"name":   UserNameType{},
	}
	keys = map[string]Record{
		"fullname": {index: "1", typ: defaultTypes["text"]},
		"bio":      {index: "2", typ: defaultTypes["text"]},
		"ip":       {index: "3", typ: defaultTypes["ip"]},
		"twitter":  {index: "4", typ: defaultTypes["name"]},
		"github":   {index: "5", typ: defaultTypes["name"]},
		"discord":  {index: "6", typ: defaultTypes["name"]},
		"telegram": {index: "7", typ: defaultTypes["name"]},
		"email":    {index: "8", typ: defaultTypes["email"]},
		"picture":  {index: "9", typ: defaultTypes["url"]},
		"site":     {index: "10", typ: defaultTypes["url"]},
	}
)
