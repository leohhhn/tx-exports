package maptest

import (
	"testing"
)

func TestUP(t *testing.T) {
	// gno test ok
	// gnokey maketx ok
	UP(int64(1), int64(100)) 

	// gno test ok
	// gnokey maketx fail
	UP(int64(2), int64(200))
}
