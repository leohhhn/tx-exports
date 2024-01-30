package outer

import (
	inner "gno.land/r/demo/contract_inner"
)


func OuterFunc() string {
	println("print OuterFunc()")
	return "return OuterFunc()"
}

func InnerFunc() string {
	println("println Outer-InnterFunc()")

	res := inner.InnferFunc()
	println(res)

	return "return Outer-InnerFunc()"
}