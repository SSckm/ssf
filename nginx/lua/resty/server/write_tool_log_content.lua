local uuid = require "util.uuid"
local uri = ngx.var.request_uri
local tinsert = table.insert
local tconcat = table.concat
local SysLogConfig = require "config.log"
local SysLog = require "service.log.log"
local Log_type = SysLogConfig.LOG._TOOL_ACCESS

local function getAccessLog()
	local content = {}
	local req_id = uuid.get_uuid() or "-"
	local ip = ngx.ctx.IP
    tinsert(content, req_id)
    tinsert(content, ngx.now() * 1000)
    tinsert(content, ip)
    tinsert(content, "tool.soaer.com")
    tinsert(content, "/")
    return tconcat(content, '\t')
end


local content = getAccessLog()
local access_msg = {type = Log_type, content = content}
SysLog.log(access_msg)


ngx.exit(ngx.HTTP_OK)