package maptest

var (
	mymap map[int64]int64 = make(map[int64]int64)
)


func UP(key, value int64) {
	println("=== CURRENT MAP === ")
	println(mymap)

	v := mymap[key]

	if v == 0 {
		println("insert key:", key)
		println("insert value:", value)
		mymap[key] = value
	} else {
		println("update key:", key)
		println("update value:", value)
		mymap[key] = value
	}

	println("=== AFTER UPSERT === ")
	println(mymap)
	println()
}