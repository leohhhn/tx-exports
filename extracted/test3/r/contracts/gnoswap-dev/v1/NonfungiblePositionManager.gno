package gnolangperiphery

type NonfungiblePositionManager struct {
	Name string
}

func (t *NonfungiblePositionManager) GetName() string {
	return t.Name
}
