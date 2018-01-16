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

local payload = ngx.req.get_body_data()
local result = {}
if not payload then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

if payload then
    local status = pcall(function () payload = cjson.decode(payload) end)
    if not status then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
        return
    end
end

local token = payload.token
if not token then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

if token ~= "84ae986edef62809ffa97a2d40c36807" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local htmlId = payload.htmlFileId
if not htmlId or htmlId == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local content = payload.content

if not content or content == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end


local createDate = payload.createDate

if not createDate or createDate == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end


local title = payload.title

if not title or title == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local createUserId = payload.createUserId
if not createUserId or createUserId == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end
local id = payload.id
if not id or id == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local usableStatus = payload.usableStatus
if not usableStatus or usableStatus == "" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

payload.token = nil

local postBody = cjson.encode(payload)
local res = ngx.location.capture(
     '/blog/blog/' .. id,
     { method = ngx.HTTP_POST, body = postBody}
)

if res.status == 201 then
	result.code = 1
	ngx.say(cjson.encode(result))
	return
end


ngx.log(ngx.ERR, "添加失败:失败原因", cjson.encode(res))
result.code = 0
result.error = "添加失败"
ngx.say(cjson.encode(result))