package domains

import "strconv"

func Render(path string) string {
	out := "# GNO Domains"
	out += "\nTLD count: " + strconv.Itoa(tlds.Size())

	return out
}
