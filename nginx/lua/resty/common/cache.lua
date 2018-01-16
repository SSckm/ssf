-- Zhenxing Liu

local cache = ngx.shared.cache

local _M = {}

-- get value from ngx.shared
function _M.get_from_cache(key)
    local value = cache:get(key)
    return value
end

function _M.set_to_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local succ, err = cache:set(key, value, exptime)
    return succ, err
end

function _M.incream(key, step)
    return cache:incr(key, step)
end

function _M.safe_set(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local succ, err = cache:safe_set(key, value, exptime)
    return succ, err
end

function _M.add(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local ok, err = cache:safe_add(key, value, exptime)
    return ok, err
end

function _M.lpush(key, value)
    return cache:lpush(key, value)
end

function _M.rpush(key, value)
    return cache:rpush(key, value)
end

function _M.delete(key, value)
    return cache:delete(key)
end

function _M.rpop(key)
    return cache:rpop(key)
end

function _M.lpop(key)
    return cache:lpop(key)
end

function _M.llen(key)
    return cache:llen(key)
end

function _M.incrby_not_found(key, step, exptime)
    local val, err = cache:incr(key, step)
    if not val and err == "not found" then
        cache:safe_add(key, 0, exptime)
        val, err = cache:incr(key, step)
    end
    return val,err
end

return _M