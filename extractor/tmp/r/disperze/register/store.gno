package register

import (
	"strconv"
	"strings"

	"gno.land/p/demo/grc/grc721"
)

var (
	ctr     = 0
	delimit = "|"
)

func nextNftID(options ...string) grc721.TokenID {
	ctr++
	id := nftPrefix + strconv.Itoa(ctr)
	if len(options) > 0 {
		id += delimit + strings.Join(options, delimit)
	}
	return grc721.TokenID(id)
}
