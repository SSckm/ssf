-- Zhenxing Liu

local aes = require "resty.aes"
local md5 = require "resty.md5"
local sha = require "resty.sha"
local str = require "resty.string"

local _M = {}


function _M.decrypt_with_des(key, decrypt_msg)
    if nil == key or nil == decrypt_msg then
        return nil
    end
    local aes_128_cbc_md5 = aes:new(key)
    return aes_128_cbc_md5:decrypt(decrypt_msg)
end

local function decode_base64(arg)
    if nil == arg then
        return nil
    end
    return ngx.decode_base64(arg)
end

_M.decode_base64 = decode_base64

return _M