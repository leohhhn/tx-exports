package hello


import "std"

var (
	hash_str string = "hello"
)

func Hello() (string, bigint) {
	// println("std.AssertOriginCall()", std.AssertOriginCall())
	println("std.IsOriginCall()", std.IsOriginCall())
	println("std.Hash([]byte(hash_str))", std.Hash([]byte(hash_str)))
	println("std.CurrentRealmPath()", std.CurrentRealmPath())
	println("std.GetChainID()", std.GetChainID())
	println("std.GetHeight()", std.GetHeight())
	println("std.GetOrigSend()", std.GetOrigSend())
	println("std.GetOrigCaller()", std.GetOrigCaller())
	println("std.GetOrigPkgAddr()", std.GetOrigPkgAddr())
	// println("std.GetCallerAt(0)", std.GetCallerAt(0))
	println("std.GetCallerAt(1)", std.GetCallerAt(1))
	println("std.GetCallerAt(2)", std.GetCallerAt(2))
	// println("std.GetCallerAt(3)", std.GetCallerAt(3))
	println("std.GetBanker(0)", std.GetBanker(0))
	println("std.GetBanker(1)", std.GetBanker(1))
	println("std.GetBanker(2)", std.GetBanker(2))
	println("std.GetBanker(3)", std.GetBanker(3))
	// println("std.GetBanker(4)", std.GetBanker(4))
	println("std.GetTimestamp()", std.GetTimestamp())
	// println("std.FormatTimestamp(1, \"\\%s\")", std.FormatTimestamp(123456789, "%m%h%s"))
	// println("std.EncodeBech32('g1', '[]byte(12345678901234567890)' )")
	
	println("HELLLLLO")

	return "res_str", bigint(123)
}


/*

std.IsOriginCall() true
std.Hash([]byte(hash_str)) array[0x91320DE1A87805C93C8FF5BE268A86406DD851AA]
std.CurrentRealmPath()
std.GetChainID() dev
std.GetHeight() 123
std.GetOrigSend()
std.GetOrigCaller() g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm
std.GetOrigPkgAddr() g17rgsdnfxzza0sdfsdma37sdwxagsz378833ca4
std.GetCallerAt(1) g18p6su7e40fpyudgcgfx65gch6trdzt8nyzetea
std.GetCallerAt(2) g18p6su7e40fpyudgcgfx65gch6trdzt8nyzetea
std.GetCallerAt(3) g199ugqdxfx3dut209p0q6f078fw96dwhs9cddff
std.GetBanker(0) struct{(gonative{{0x14000314388}} gonative{stdlibs.ReadonlyBanker})}
std.GetBanker(1) struct{(gonative{{0x14000314388 g17rgsdnfxzza0sdfsdma37sdwxagsz378833ca4 [] 0x14000128b58}} gonative{stdlibs.OrigSendBanker})}
std.GetBanker(2) struct{(gonative{{0x14000314388 g17rgsdnfxzza0sdfsdma37sdwxagsz378833ca4}} gonative{stdlibs.RealmSendBanker})}
std.GetBanker(3) struct{(gonative{&{map[g17rgsdnfxzza0sdfsdma37sdwxagsz378833ca4:[{ugnot 200000000}]]}} gonative{*tests.testBanker})}
std.GetTimestamp() 1234567890
HELLLLLO

*/