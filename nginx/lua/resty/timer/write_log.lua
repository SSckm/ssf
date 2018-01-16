-- Zhenxing Liu


local log = ngx.log
local e = ngx.ERR
local l = ngx.CRIT
local info = ngx.INFO
local alert = ngx.ALERT
local concat = table.concat
local timer = ngx.timer.at
local debug = ngx.config.debug
local flush_time = 10
local write_status = false
local tinsert = table.insert
local type = type
local cache = require "common.cache"
local cjson = require "cjson"
local logconf = require "config.log"

local _M = {}
local _CYCLE
local ALL_TYPES = logconf.LOG

local function write_log()
    if write_status then
        return
    end
    write_status = true
    local length, err
    local key
    for _,v in pairs(_CYCLE) do
        key = v.LOG_TYPE .. "_log"
        length, err = cache.llen(key)
        if length and length > 0 then
            local msg
            local w_logs = {}
            for _=1,length do
                msg = cache.lpop(key)
                if msg and type(msg) == "string" then
                    tinsert(w_logs, msg)
                end
            end

            if #w_logs > 0 then
                ALL_TYPES._WRITE(concat(w_logs, "\n"), v)
            end
        else
            if not length then
                log(l, "###########################Write_log ERROR, LOG_TYPE" .. " ERR MSG:" .. (err or "NULL"))
            end
        end
    end
    write_status = false
end

local function build_CYCLE()
    local ngx_work_id = ngx.worker.id()
    local key = ngx_work_id .. "_worker_id"
    local types = cache.get_from_cache(key)
    if not types then
        return
    end

    log(alert, "######################ngx_work_id: " .. ngx_work_id .. ", types:" .. (types or "NULL"))
    types = cjson.decode(types)
    _CYCLE = {}
    for _,v in pairs(ALL_TYPES) do
        if type(v) == "table" then
            local t = v.LOG_TYPE
            for _, b in pairs(types) do
                if t == b then
                    tinsert(_CYCLE, v)
                end
            end
        end
    end
end

local handler
handler = function ()
    local ok, err = pcall(function () write_log() end)
    if not ok then
        write_status = false
        log(l, err)
    end
    ok, err = timer(flush_time, handler)
    if not ok then
        log(l, "failed to create the timer: ", err)
        return
    end
end

function _M.timer()
    local ok, err = pcall(function () build_CYCLE() end)
    if not ok then
        log(l, err)
        return
    end

    if not _CYCLE then
        if debug then
            local ngx_work_id = ngx.worker.id()
            log(info, "######################the ngx_work_id: " .. ngx_work_id .. ", is not exec the log task")
        end
        return
    end
    ok, err = timer(flush_time, handler)
    if not ok then
        log(l, "failed to create the timer: ", err)
        return
    end
end

return _M