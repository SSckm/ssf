local ck = require "common.cookie"

local C = {}


local function set_cookie(name, value1)
	local cookie, err = ck:new()
	if not cookie then
    	ngx.log(ngx.CRIT, err)
    	return
	end

	local ok, err = cookie:set({
        	key = name, value = value1, path = "/",
        	domain = ".soaer.com", max_age = 2592000
	})

	if not ok then
    	ngx.log(ngx.CRIT, err)
    	return
	end
end


local function get_field(name)
	local cookie, err = ck:new()
	if not cookie then
    	ngx.log(ngx.CRIT, err)
    	return
	end

	local field, err = cookie:get(name)
    if not field then
        return
    end
    return field
end

C.set_cookie = set_cookie
C.get_field = get_field

return C