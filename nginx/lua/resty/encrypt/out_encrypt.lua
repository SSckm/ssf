local aes = require "resty.aes"
local str = require "resty.string"
local out_decrypt = require "service.encrypt.out_decrypt"

local _M = {}

function _M.out_encrypt_aes_iv(key, encrypt_msg)
    if key == nil or key == "" or encrypt_msg == nil or encrypt_msg == "" then
        return nil
    end
    if #key < 32 then
        local count = 32 - #key 
        for i=1,count,1 do
            key = key .. '0'
        end
    end
    
    local token = string.sub(key, 1, 16)
    token = ngx.encode_base64(token)
    token = string.sub(token, 1,16)
    local iv = string.sub(key, 17, #key)
    iv = ngx.encode_base64(iv)
    iv = string.sub(iv, 1, 16)
    if #iv < 16 then
        local ivc = 16 - #iv
        for i=1,ivc,1 do
            iv = iv .. '0'
        end
    end
    if #token < 16 then
        local tokenc = 16 - #key
        for i=1,tokenc,1 do
            token = token .. '0'
        end
    end 
    local aes_128_cbc_with_iv = assert(aes:new(token,nil, aes.cipher(128,"cbc"), {iv = iv}))
    local encrypted = aes_128_cbc_with_iv:encrypt(encrypt_msg)
    return encrypted
end

return _M


