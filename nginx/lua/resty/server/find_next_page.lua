
local query = require "template.search_template"
local uuid = require "util.uuid"
local uri = ngx.var.request_uri
local tinsert = table.insert
local tconcat = table.concat
local SysLogConfig = require "config.log"
local SysLog = require "service.log.log"
local str = require "util.str"
local Log_type = SysLogConfig.LOG._BLOG_SEARCH
local cjson = require "cjson"
local cache = require "common.cache"
local constant = require "constant"

local result = {}
local args, err = ngx.req.get_post_args()
if not args then
    result.code = 0
    ngx.say(cjson.encode(result))
    return
end

ngx.req.set_header("Content-Type", "application/json")
local pageNumber = args['pageNumber']
if not pageNumber or pageNumber == "" then
	result.code = 0
	result.error = "传送数据错误"
    ngx.say(cjson.encode(result))
    return
end

pageNumber = tonumber(pageNumber) or 1


local blogList = cache.get_from_cache(constant.BLOG_LIST_ALL .. pageNumber)
if blogList then
	ngx.say(blogList)
	return;
end

local pageSize = 10
local start = (pageNumber - 1) * pageSize

local QueryTemplate = query.getBlogWithNoKeyword()
QueryTemplate.from = start
QueryTemplate.size = 10

local postBody = cjson.encode(QueryTemplate)
local res = ngx.location.capture(
     '/blog/blog/_search',
     { method = ngx.HTTP_POST, body = postBody}
)

local function parseHit(hit, list)
	local source = hit._source
	local highlight = hit.highlight
	table.insert(list, source)
	if not highlight then
		return
	end
	for k,v in pairs(highlight) do
		local content = table.concat(v, "")
		source[k] = content
	end
end


local function buildSearchResult(body)
	local respnseBody = cjson.decode(body)
	local hits = respnseBody.hits
	local total = hits.total
	result.code = 1
	result.total = total
	local hitArray = hits.hits
	local list = {}
	for _,v in ipairs(hitArray) do
		parseHit(v, list)
	end
	result.list = list
	return cjson.encode(result)
end

local status = res.status
if (status == 200) then
	local body = res.body
	local listRes = buildSearchResult(body)
	cache.set_to_cache(constant.BLOG_LIST_ALL .. pageNumber, listRes, 24 * 3600)
	ngx.say(listRes)
	return
end

result.code = 0
result.error = "服务器错误"
ngx.say(cjson.encode(result))