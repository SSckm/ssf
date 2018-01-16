-- Zhenxing Liu


require "ext.lualogging.logging.file"
local cache = require "common.cache"
-- local config = require "config.config"
local tostring = tostring
local tonumber = tonumber
local log = ngx.log
local e = ngx.ERR


--[[

  use the socket logger to write business log

]]--

local _M = {}

function _M.write_log(message, log_type)
    local logger = logging.file(log_type)
    logger:info(message)
end

local function write_log_to_file(message)

    if type(message) ~= "table" then
        ngx.log(ngx.CRIT, "the log message type must be a table value")
        return
    end

    local log_type = message.type
    if log_type == nil then
        ngx.log(ngx.CRIT, "can't find the log type from the message, please add the property 'log type' in your message")
    end
    local content = message.content

    if nil == content then
        return
    end

    if type(content) ~= "string" then
        content = tostring(content)
    end

    if content == "\n" or content == "" or content == "\t" then
        return
    end

    local num_type = tonumber(log_type.LOG_TYPE)
    if num_type == nil then
        return
    end

    local _, err = cache.rpush(num_type .. "_log", content)
    if err then
        ngx.log(ngx.CRIT, "put the log in queue error, msg:" .. tostring(err))
    end
end


function _M.log(msg)
    if nil == msg then
        return
    end
    write_log_to_file(msg)
end

return _M
