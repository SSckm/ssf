local cjson = require "cjson"
local enc = require "encrypt.encrypt"
local dec = require "encrypt.decrypt"
local constant = require "constant"
local strutil = require "util.str"
local cookie = require "util.cookie"


local result = {}
local args, err = ngx.req.get_post_args()
if not args then
    result.code = 0
    ngx.say(cjson.encode(result))
    return
end

local cid = args['cid']

if not cid then
	result.code = 0
	result.error = "验证信息不能为空"
    ngx.say(cjson.encode(result))
    return
end

local function decode()
	cid = ngx.unescape_uri(cid)
	cid = dec.decode_base64(cid)
	cid = dec.decrypt_with_des(constant.CIPHER_KEY, cid)
end

local ok, err = pcall(function () decode() end)
if not ok then
    result.code = 0
    result.error = "验证失败"
    ngx.log(ngx.ERR, err)
    ngx.say(cjson.encode(result))
    return;
end

if not cid then
	result.code = 0
    result.error = "验证失败"
    ngx.say(cjson.encode(result))
    return
end

local array = strutil.split(cid, ",")
local email = array[1]
local time = array[2]
local n = ngx.now() * 1000
local range = n - (tonumber(time) or 0)

if (range >= 7 * 24 *3600 * 1000) then
	result.code = 0
    result.error = "验证信息已过期"
    ngx.say(cjson.encode(result))
    return
end

local random = math.random(1, #constant.names)
local author = constant.names[random]
-- author = enc.encode_base64(author)

local cipher = {}
cipher.author = author
cipher.email = email
cipher.time = n

local n = enc.encrypt_with_aes(constant.CIPHER_KEY,cjson.encode(cipher))
n = enc.encode_base64(n)
n = ngx.escape_uri(n)

result.code = 1
result.error = "验证成功"
cookie.set_cookie(constant.COOKIE_KEY, n)
cookie.set_cookie(constant.COOKIE_NAME, enc.encode_base64(author))
ngx.say(cjson.encode(result))