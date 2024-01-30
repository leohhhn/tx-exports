package domains

import (
	"strings"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/grc/grc721"
	"gno.land/r/disperze/nft"
	"std"
)

func RegisterTLD(tld string, cid nft.CollectionID, issuer std.Address) {
	caller := getCaller()
	if caller != admin {
		panic("unauthorized")
	}

	g := newTLDomain(tld, cid, issuer)
	checkNoError(g.validate())
	tlds.Set(tld, g)
}

func RegisterDomain(tid grc721.TokenID, domain string) {
	tld := parseTLD(domain)
	caller := getCaller()
	if caller != tld.issuer {
		panic("unauthorized")
	}

	name, _ := parseDomain(domain)
	if tld.isRegDomain(name) {
		panic("domain already exists")
	}

	d := newDomain(name, tid)
	checkNoError(d.validate())
	tld.addDomain(d)

	// Set default first domain
	owner := nft.OwnerOf(tld.cid, tid)
	tld.setDefaultResolver(owner, domain)
}

func SetRecord(domain, key, value string) {
	keyR, ok := keys[key]
	if !ok {
		panic("key not allowed")
	}
	checkNoError(keyR.typ.validate(value))
	tld := parseTLD(domain)
	d := tld.getDomain(domain)
	caller := getCaller()
	owner := nft.OwnerOf(tld.cid, d.tid)
	if caller != owner {
		panic("unauthorized")
	}

	d.setRecord(keyR.index, value)
}

func SetDomain(domain string) {
	tld := parseTLD(domain)
	d := tld.getDomain(domain)
	caller := getCaller()
	owner := nft.OwnerOf(tld.cid, d.tid)
	if caller != owner {
		panic("unauthorized")
	}

	tld.setResolver(caller, domain)
}

// Admin oper.

func AddRecordType(id, newKey, rType string) {
	caller := getCaller()
	if caller != admin {
		panic("unauthorized")
	}

	if _, ok := keys[newKey]; ok {
		panic("key already exists")
	}

	data, exists := defaultTypes[rType]
	if !exists {
		panic("record type not found")
	}

	keys[newKey] = Record{index: id, typ: data}
}

func UpdateAdmin(newAdmin std.Address) {
	if newAdmin == "" {
		panic("invalid address")
	}

	caller := getCaller()
	if caller != admin {
		panic("unauthorized")
	}

	admin = newAdmin
}

func Initialize(addr std.Address) {
	if initiated {
		panic("already initiated")
	}

	admin = addr
	initiated = true
}

// query

func GetTLD(tld string) TLDResponse {
	t := getTLD(tld)

	return TLDResponse{
		Tld:    t.tld,
		CID:    t.cid,
		Issuer: t.issuer,
		Total:  t.domains.Size(),
	}
}

func GetDomain(domain string) DomainResponse {
	tld := parseTLD(domain)
	d := tld.getDomain(domain)

	return DomainResponse{
		Name:  d.name,
		Tld:   tld.tld,
		TID:   d.tid,
		Owner: nft.OwnerOf(tld.cid, d.tid),
	}
}

func DomainExists(domain string) bool {
	domain, tld := parseDomain(strings.ToLower(domain))
	t := getTLD(tld)

	return t.domains.Has(domain)
}

func Resolve(domain string) std.Address {
	t := parseTLD(domain)

	return nft.OwnerOf(t.cid, t.getDomain(domain).tid)
}

func GetName(tld string, address std.Address) string {
	t := getTLD(tld)

	return t.resolve(address)
}

func GetRecord(domain, key string) string {
	tld := parseTLD(domain)
	keyR, ok := keys[key]
	if !ok {
		panic("key not allowed")
	}

	d := tld.getDomain(domain)
	return d.getRecord(keyR.index)
}

func GetAllRecords(domain string) map[string]string {
	tld := parseTLD(domain)
	d := tld.getDomain(domain)

	reverseKeys := make(map[string]string, len(keys))
	for k, v := range keys {
		reverseKeys[v.index] = k
	}

	records := make(map[string]string, len(keys))
	d.records.Iterate("", "", func(t *avl.Tree) bool {
		records[reverseKeys[t.Key()]] = t.Value().(string)
		return false
	})

	// set defaults values
	for k := range keys {
		if _, ok := records[k]; !ok {
			records[k] = ""
		}
	}

	return records
}
