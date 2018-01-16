local cache = require "common.cache"
local constant = require "constant"
local cjson = require "cjson"
local cookie = require "util.cookie"
local enc = require "encrypt.encrypt"
local dec = require "encrypt.decrypt"
local strutil = require "util.str"
local uuid = require "util.uuid"
local uri = ngx.var.request_uri
local tinsert = table.insert
local tconcat = table.concat
local SysLogConfig = require "config.log"
local SysLog = require "service.log.log"
local str = require "util.str"
local Log_type = SysLogConfig.LOG._COMMENTS_ADD


ngx.req.set_header("Content-Type", "application/json")

local cid = cookie.get_field('cid')
local result = {}
if not cid or cid == "" then
	result.code = 0
	result.error = "没有验证邮箱"
	ngx.say(cjson.encode(result))
    return;
end

function decode_cid()
	cid = ngx.unescape_uri(cid)
	cid = dec.decode_base64(cid)
	cid = dec.decrypt_with_des(constant.CIPHER_KEY, cid)
end
decode_cid()

if not cid then
	result.code = 0
    result.error = "验证失败"
    ngx.say(cjson.encode(result))
    return
end

cid = cjson.decode(cid)

local addComments = {}
local result = {}
local args, err = ngx.req.get_post_args()
if not args then
    result.code = 0
    return cjson.encode(result)
end

for key, val in pairs(args) do
    addComments[key] = val
end

if (addComments.content == nil or "" == addComments.content) then
	result.code = 0
	result.error = "评论不能为空"
    ngx.say(cjson.encode(result))
	return;
end

if (addComments.blogId == nil or "" == addComments.blogId) then
	result.code = 0
	result.error = "提交数据错误"
	ngx.say(cjson.encode(result))
    return;
end

if (string.len(addComments.content) > 120) then
    result.code = 0
    result.error = "评论内容过长"
    ngx.say(cjson.encode(result))
    return;
end


local createDate = ngx.now()*1000 or 0
addComments.createDate = createDate

addComments.author = cid.author
addComments.email = cid.email
addComments.usableStatus = 0
local postBody = cjson.encode(addComments)
local res = ngx.location.capture(
     '/comments/comments',
     { method = ngx.HTTP_POST, body = postBody}
)


local function writeLog(commentsDetial, email)
    local content = {}
    local req_id = uuid.get_uuid() or "-"
    local ip = ngx.ctx.IP
    tinsert(content, req_id)
    tinsert(content, ngx.now() * 1000)
    tinsert(content, ip)
    tinsert(content, email)
    tinsert(content, ngx.escape_uri(commentsDetial))
    local contentStr = tconcat(content, '\t')
    local access_msg = {type = Log_type, content = contentStr}
    SysLog.log(access_msg)
end

writeLog(addComments.content, addComments.email)

if res.status == 201 then
	cache.delete(constant.BLOG_COMMENTS .. addComments.blogId)
	result.code = 1
	ngx.say(cjson.encode(result))
	return
end

ngx.log(ngx.ERR, "添加失败:失败原因", cjson.encode(res))

result.code = 0
result.error = "添加评论失败"
ngx.say(cjson.encode(result))