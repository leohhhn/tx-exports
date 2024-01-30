package domains

import (
	"errors"
	"strconv"
	"strings"

	"std"
)

type Record struct {
	index string
	typ   RecordType
}

type RecordType interface {
	validate(string) error
}

type URLType struct {
}

func (URLType) validate(value string) error {
	return nil
}

type IPType struct {
}

func (IPType) validate(value string) error {
	parts := strings.Split(value, ".")
	if len(parts) != 4 {
		return errors.New("invalid ip address")
	}

	for _, part := range parts {
		num, err := strconv.Atoi(part)
		if err != nil {
			return errors.New("invalid ip address")
		}

		if num < 0 || num > 255 {
			return errors.New("invalid ip address")
		}
	}
	return nil
}

type Bech32Type struct {
}

func (Bech32Type) validate(value string) error {
	_, _, ok := std.DecodeBech32(std.Address(value))
	if !ok {
		return errors.New("invalid bech32 address")
	}

	return nil
}

type EmailType struct {
}

func (EmailType) validate(value string) error {
	return nil
}

type TextType struct {
}

func (TextType) validate(value string) error {
	if len(value) > 4096 {
		return errors.New("text is too long")
	}

	return nil
}

type UserNameType struct {
}

func (UserNameType) validate(value string) error {
	if len(value) > 255 {
		return errors.New("name is too long")
	}

	// for _, r := range value {
	// 	if r != '#' && r != '-' && r != '_' && (r < 'A' || r > 'Z') && (r < 'a' || r > 'z') && (r < '0' || r > '9') {
	// 		return errors.New("invalid name")
	// 	}
	// }

	return nil
}
