local uuid = require "util.uuid"
local uri = ngx.var.request_uri
local tinsert = table.insert
local tconcat = table.concat
local SysLogConfig = require "config.log"
local SysLog = require "service.log.log"
local str = require "util.str"
local Log_type = SysLogConfig.LOG._BLOG_ACCESS
local cjson = require "cjson"


local function getAccessLog()
    local args = ngx.req.get_uri_args()
    local htmlId = args['blogKey']
    local blogId = args['blogId']

    if (tonumber(blogId) == nil) then
        return;
    end

    if (string.len(htmlId) >= 40) then
        return;
    end

    local userId = 1
	local content = {}
	local req_id = uuid.get_uuid() or "-"
	local ip = ngx.ctx.IP
    tinsert(content, req_id)
    tinsert(content, ngx.now() * 1000)
    tinsert(content, ip)
    local host = ngx.req.get_headers()["Host"]
    tinsert(content, host or "-")
    tinsert(content, 1)
    tinsert(content, blogId or 0)
    tinsert(content, htmlId or "-")
    return tconcat(content, '\t')
end


local content = getAccessLog()
if not content then
    ngx.exit(ngx.HTTP_OK)
    return;
end
local access_msg = {type = Log_type, content = content}
SysLog.log(access_msg)

ngx.exit(ngx.HTTP_OK)