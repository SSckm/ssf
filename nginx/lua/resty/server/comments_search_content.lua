local cache = require "common.cache"
local constant = require "constant"
local cjson = require "cjson"


local result = {}
local args, err = ngx.req.get_post_args()
if not args then
    result.code = 0
    ngx.say(cjson.encode(result))
    return
end

local blogIdReq = args['blogId']
if not blogIdReq or "" == blogIdReq then
	result.code = 0
	result.error = "Id不能为空"
    ngx.say(cjson.encode(result))
    return
end

local blogList = cache.get_from_cache(constant.BLOG_COMMENTS .. blogIdReq)
if blogList then
	ngx.say(blogList)
	return;
end

ngx.req.set_header("Content-Type", "application/json")
local searchLastBlogs = {}
searchLastBlogs.from = 0
searchLastBlogs.size = 50
searchLastBlogs.timeout = "30s"
local sort = {}
local sortDetial = {}
local sortFiled = {}
sortFiled.order = "asc"
sortDetial.createDate = sortFiled
table.insert(sort, sortDetial)
searchLastBlogs.sort = sort

local filter = {}
local usableStatus = {}
usableStatus.value = 0
usableStatus.boost = 1
local termUsableStatus = {}
termUsableStatus.usableStatus = usableStatus
local a = {}
a.term = termUsableStatus
table.insert(filter, a)


local blogId = {}
blogId.value = tonumber(blogIdReq)
blogId.boost = 1
local termBlogId = {}
termBlogId.blogId = blogId
local b = {}
b.term = termBlogId
table.insert(filter, b)


local bool = {}
bool.filter = filter
bool.adjust_pure_negative = true
bool.boost = 1
local query = {}
query.bool = bool
searchLastBlogs.query = query
local postBody = cjson.encode(searchLastBlogs)

-- ngx.log(ngx.ERR, "=====", postBody)
local res = ngx.location.capture(
     '/comments/comments/_search',
     { method = ngx.HTTP_POST, body = postBody}
)


local function buildCommentsList(esRes)
	local comments = cjson.decode(esRes)
	local list = {}
	for k,v in pairs(comments.hits.hits) do
		table.insert(list, v._source)
	end
	local result = {}
	result.code = 1
	result.list = list or {}
	return cjson.encode(result)
end


local comments = res.body
-- ngx.log(ngx.ERR, "=====", cjson.encode(res))
if (res.status == 200) then
	if comments then
		local cacheComments = buildCommentsList(comments)
		cache.set_to_cache(constant.BLOG_COMMENTS .. blogIdReq, cacheComments, 600)
		ngx.say(cacheComments)
		return;
	end
end

result.code = 0
result.error = "服务器错误"
ngx.say(cjson.encode(result))