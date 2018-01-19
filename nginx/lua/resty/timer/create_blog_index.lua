local cache = require "common.cache"
local constant = require "constant"
local cjson = require "cjson"

local BLOGINDEXTEMPLATE = "/home/sunny/ssf/nginx/lua/resty/template/blog_index.html"

function readTemplate()
	local file = io.open(BLOGINDEXTEMPLATE, "r");
    local data = file:read("*a");
    file:close();
    return data;
end

local blogList = cache.get_from_cache(constant.BLOG_LIST)
if not blogList then
	return
end

blogList = cjson.decode(blogList)
local sources = blogList.list
if type(sources) ~= "table" || #sources <= 0 then
	return
end

for i,v in ipairs(sources) do
	
end