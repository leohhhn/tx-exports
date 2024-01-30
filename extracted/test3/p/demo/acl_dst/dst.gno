package dst


import (
	src "gno.land/p/demo/acl_src"
)


func EditSrcBigVal() {
	println("old__src.BigVar:", src.BigVar)

	src.BigVar += 111
	println("new__src.BigVar #1:", src.BigVar)

	src.BigVar += 222
	println("new__src.BigVar #2:", src.BigVar)
}