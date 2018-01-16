--Zhenxing Liu


local constant = require "constant"
local logconf = require "config.log"
local cache = require "common.cache"
local cjson = require "cjson"
local debug = ngx.config.debug
local log = ngx.log
local info = ngx.INFO
local log_type = logconf.LOG


local start_create = "mkdir -p "

local command = constant.LOG_PATH .. "blog.soaer.com/access"
command = command .. " " .. constant.LOG_PATH .. "soaer.com/access"
command = command .. " " .. constant.LOG_PATH .. "tool.soaer.com/access"
command = command .. " " .. constant.LOG_PATH .. "blog.soaer.com/search"
command = command .. " " .. constant.LOG_PATH .. "blog.soaer.com/email"
command = command .. " " .. constant.LOG_PATH .. "blog.soaer.com/comments"
command = command .. " " .. constant.LOG_PATH .. "blog.soaer.com/index"


local start_chmod = "chmod o+w "
local res = os.execute(start_create .. command)
if res ~= 0 then
	ngx.log(ngx.ALERT, "create the log path failed")
end

res = os.execute(start_chmod .. command)
if res ~= 0 then
	ngx.log(ngx.ALERT, "create the log path failed")
end


local count = ngx.worker.count()
if debug then
	log(info, "##################################The worker process count is : " .. ngx.worker.count() .. "#####################################")
end

local i = 0

local key = "_worker_id"

for _,v in pairs(log_type) do
	if type(v) == "table" then
		if tonumber(v.LOG_TYPE) ~= nil then
			cache.rpush(i .. key, v.LOG_TYPE)
			if debug then
				log(info, i .. key .. ":" .. v.LOG_TYPE)
			end
			i = i + 1
			if i == count then
				i = 0
			end
		end
	end
end

for z=0,(count - 1) do
	local queue_key = z .. key
	local length = cache.llen(queue_key)
	local c = {}
	for _=1,length do
        table.insert(c, cache.lpop(queue_key))
    end

    if debug then
		log(info, cjson.encode(c))
	end

	if #c > 0 then
		cache.set_to_cache(z .. key, cjson.encode(c))
	end
end
