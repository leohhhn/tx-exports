package domains

import (
	"std"
)

func getCaller() std.Address {
	return std.GetCallerAt(3)
}

func checkNoError(err error) {
	if err != nil {
		panic(err)
	}
}

func isValidAddr(addr std.Address) bool {
	if addr == "" {
		return false
	}

	prefix, bytes, ok := std.DecodeBech32(addr)
	if prefix != "g" || len(bytes) != 20 || !ok {
		return false
	}

	return true
}
