package nft

import "strconv"

func Render(path string) string {
	out := "# NFT"
	out += "\nTotal Collections: " + strconv.Itoa(collectionCtr)

	return out
}
