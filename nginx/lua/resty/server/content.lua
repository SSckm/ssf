local cache = require "common.cache"
local constant = require "constant"
local cjson = require "cjson"

local blogList = cache.get_from_cache(constant.BLOG_LIST)

if blogList then
	ngx.say(blogList)
	return;
end

-- res = ngx.location.capture(
--      '/blog/list',
--      { method = ngx.HTTP_POST, args = 'pageNumber=1&pageSize=10'}
--  )
-- {
--     "from": 0,
--     "size": 10,
--     "timeout": "30s",
--     "sort": [
--         {
--             "createDate": {
--                 "order": "desc"
--             }
--         }
--     ]
-- }


-- {
--     "from": 0,
--     "size": 10,
--     "timeout": "30s",
--     "query": {
--         "bool": {
--             "filter": [
--                 {
--                     "term": {
--                         "usableStatus": {
--                             "value": 0,
--                             "boost": 1
--                         }
--                     }
--                 }
--             ],
--             "adjust_pure_negative": true,
--             "boost": 1
--         }
--     },
--     "sort": [
--         {
--             "createDate": {
--                 "order": "desc"
--             }
--         }
--     ]
-- }

ngx.req.set_header("Content-Type", "application/json")
local searchLastBlogs = {}
searchLastBlogs.from = 0
searchLastBlogs.size = 10
searchLastBlogs.timeout = "30s"
local sort = {}
local sortDetial = {}
local sortFiled = {}
sortFiled.order = "desc"
sortDetial.createDate = sortFiled
table.insert(sort, sortDetial)
searchLastBlogs.sort = sort


local filter = {}

local usableStatus = {}
usableStatus.value = 0
usableStatus.boost = 1

local term = {}
term.usableStatus = usableStatus

local a = {}
a.term = term

table.insert(filter, a)

local bool = {}
bool.filter = filter
bool.adjust_pure_negative = true
bool.boost = 1
local query = {}
query.bool = bool
searchLastBlogs.query = query

local postBody = cjson.encode(searchLastBlogs)
local res = ngx.location.capture(
     '/blog/blog/_search',
     { method = ngx.HTTP_POST, body = postBody}
)

local function buildBlogList(esRes)
	local blogs = cjson.decode(esRes)
	local list = {}
	for k,v in pairs(blogs.hits.hits) do
		table.insert(list, v._source)
	end
	local result = {}
	result.code = 1
	result.list = list or {}
	return cjson.encode(result)
end

local blogs = res.body
if (res.status == 200) then
	if blogs then
		local cacheBlog = buildBlogList(blogs)
		cache.set_to_cache(constant.BLOG_LIST, cacheBlog, 600)
		ngx.say(cacheBlog)
		return;
	end
end

local default = {}
default.code = 0
ngx.say(cjson.encode(default))