-- Zhenxing Liu


local cache = ngx.shared.cache
local ffi = require 'ffi'

local uuid_key = "uuid"

local _M = {}

ffi.cdef[[
    typedef unsigned char uuid_t[16];
    void uuid_generate(uuid_t out);
    void uuid_unparse(const uuid_t uu, char *out);
]]


local uuid = ffi.load('libuuid')

function _M.get_uuid()
    local result
    if uuid then
        local uuid_t   = ffi.new("uuid_t")
        local uuid_out = ffi.new("char[64]")
        uuid.uuid_generate(uuid_t)
        uuid.uuid_unparse(uuid_t, uuid_out)
        result = ffi.string(uuid_out)
    end
    return string.gsub(result, "-", "");
end

function _M.put_uuid_mq()
	for _=1,10000 do
		local id = _M.get_uuid()
		if type(id) == "string" and "" ~= id then
			id = string.gsub(id, "-", "");
            id = string.upper(id)
			cache:lpush(uuid_key, id)
		end
	end
end

return _M
