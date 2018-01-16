
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


local result = {}
local args, err = ngx.req.get_post_args()
if not args then
    result.code = 0
    ngx.say(cjson.encode(result))
    return
end

ngx.req.set_header("Content-Type", "application/json")

local keyword = args['keyWord']
local pageNumber = args['pageNumber']
if not keyword or not pageNumber or keyword == "" or pageNumber == "" then
	result.code = 0
	result.error = "传送数据错误"
    ngx.say(cjson.encode(result))
    return
end

if (string.len(keyword) > 30) then
	keyword = string.sub(keyword, 0, 30)
end

pageNumber = tonumber(pageNumber) or 1
local pageSize = 10
local start = (pageNumber - 1) * pageSize

local QueryTemplate = query.getBlogQueryTemplate()
QueryTemplate.from = start
QueryTemplate.size = 10


local shouldArray = QueryTemplate.query.bool.should

shouldArray[1].multi_match.query = keyword
shouldArray[2].regexp.title.value = "~*" .. keyword .. "~*"
shouldArray[3].regexp.content.value = "~*" .. keyword .. "~*"

local postBody = cjson.encode(QueryTemplate)
local res = ngx.location.capture(
     '/blog/blog/_search',
     { method = ngx.HTTP_POST, body = postBody}
)


local function writeLog(keyword)
	local content = {}
	local req_id = uuid.get_uuid() or "-"
	local ip = ngx.ctx.IP
    tinsert(content, req_id)
    tinsert(content, ngx.now() * 1000)
    tinsert(content, ip)
    tinsert(content, ngx.escape_uri(keyword))
    local contentStr = tconcat(content, '\t')
    local access_msg = {type = Log_type, content = contentStr}
    SysLog.log(access_msg)
end

writeLog(keyword)

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
	ngx.say(buildSearchResult(body))
	return
end

result.code = 0
result.error = "服务器错误"
ngx.say(cjson.encode(result))