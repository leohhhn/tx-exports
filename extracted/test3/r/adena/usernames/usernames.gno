package adena

import (
	users "gno.land/r/demo/users"
)

func GetAddressByUsername(username string) string {
    user := users.GetUserByName(username)

    if user == nil {
        return ""
    }

    return string(user.Address())
}