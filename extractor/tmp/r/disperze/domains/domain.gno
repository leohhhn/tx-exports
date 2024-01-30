package domains

import (
	"errors"
	"strings"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/grc/grc721"
	"gno.land/r/disperze/nft"
	"std"
)

type Domain struct {
	tid     grc721.TokenID
	name    string
	records *avl.Tree
}

func newDomain(name string, nftID grc721.TokenID) *Domain {
	return &Domain{
		tid:  nftID,
		name: name,
	}
}

func (d *Domain) getRecord(keyID string) string {
	_, value, exists := d.records.Get(keyID)
	if !exists {
		return ""
	}

	return value.(string)
}

func (d *Domain) setRecord(keyID, value string) {
	d.records, _ = d.records.Set(keyID, value)
}

func (d *Domain) validate() error {
	if d.name == "" {
		return errors.New("domain cannot be empty")
	}

	return nil
}

type TLDomain struct {
	tld      string
	cid      nft.CollectionID // tld nft collectionID
	issuer   std.Address
	domains  *avl.Tree // tld -> Domain
	resolver *avl.Tree // address -> domain name
}

func newTLDomain(ext string, cid nft.CollectionID, issuer std.Address) *TLDomain {
	return &TLDomain{
		tld:    ext,
		cid:    cid,
		issuer: issuer,
	}
}

func (t *TLDomain) isRegDomain(name string) bool {
	return t.domains.Has(name)
}

func (t *TLDomain) getDomain(domain string) *Domain {
	name, tld := parseDomain(domain)
	if tld != t.tld {
		panic("invalid tld")
	}

	_, data, exists := t.domains.Get(name)
	if !exists {
		panic("domain not found")
	}

	return data.(*Domain)
}

func (t *TLDomain) addDomain(domain *Domain) {
	t.domains, _ = t.domains.Set(domain.name, domain)
}

func (t *TLDomain) resolve(address std.Address) string {
	_, value, exists := t.resolver.Get(address.String())
	if !exists {
		return ""
	}

	return value.(string)
}

func (t *TLDomain) setDefaultResolver(owner std.Address, domain string) {
	if !t.resolver.Has(owner.String()) {
		t.setResolver(owner, domain)
	}
}

func (t *TLDomain) setResolver(owner std.Address, domain string) {
	t.resolver, _ = t.resolver.Set(owner.String(), domain)
}

func (t *TLDomain) validate() error {
	if t.cid == "" {
		return errors.New("collection ID cannot be empty")
	}

	if len(t.tld) == 0 || len(t.tld) > 10 {
		return errors.New("invalid tld length")
	}

	for _, r := range t.tld {
		if r < 'a' || r > 'z' {
			panic("invalid tld format")
		}
	}

	if !isValidAddr(t.issuer) {
		return errors.New("invalid issuer address")
	}

	return nil
}

func parseTLD(domain string) *TLDomain {
	_, tld := parseDomain(domain)

	return getTLD(tld)
}

func getTLD(tld string) *TLDomain {
	data, exists := tlds.Get(tld)
	if !exists {
		panic("tld not found")
	}

	return data.(*TLDomain)
}

func parseDomain(domain string) (string, string) {
	parts := strings.Split(domain, ".")
	if len(parts) != 2 {
		panic("invalid domain")
	}

	return parts[0], parts[1]
}
