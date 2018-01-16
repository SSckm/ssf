-- Zhenxing Liu


local aes = require "resty.aes"
local str = require "resty.string"

local _M = {}


function _M.encrypt_with_aes(key, encrypt_msg)
    if nil == key or nil == encrypt_msg then
        return nil
    end
    local aes_128_cbc_md5 = aes:new(key)
    local encrypted = aes_128_cbc_md5:encrypt(encrypt_msg)
    return encrypted
end

local function encode_base64(arg)
    if nil == arg then
        return nil
    end
    return  ngx.encode_base64(arg)
end


_M.encode_base64 = encode_base64

return _M