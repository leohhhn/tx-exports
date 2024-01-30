package nft

import (
	"std"
)

func getCaller() std.Address {
	return std.GetCallerAt(3)
}

func canSend(sender std.Address, token *NFToken, c *Collection) bool {
	if sender != token.owner && sender != token.approved {
		_, operator, ok := c.operators.Get(token.owner.String())
		if !ok || sender != operator.(std.Address) {
			return false
		}
	}

	return true
}

func canChangeApprovals(sender std.Address, token *NFToken, c *Collection) bool {
	if sender != token.owner {
		_, operator, ok := c.operators.Get(token.owner.String())
		if !ok || sender != operator.(std.Address) {
			return false
		}
	}

	return true
}

func noError(err error) {
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

func normalizeAddr(addr std.Address) (std.Address, bool) {
	prefix, bytes, ok := std.DecodeBech32(addr)
	if !ok {
		return "", false
	}

	return std.Address(std.EncodeBech32(prefix, bytes)), true
}
