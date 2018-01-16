-- local cookie = require "util.cookie"
-- local constant = require "constant"

-- local req_uri = ngx.var.request_uri
-- if req_uri == "/loginFilter" or req_uri == "/indexPage" then
-- 	return;
-- end

-- local method = ngx.req.get_method()
-- if method ~= "POST" then
-- 	ngx.exit(ngx.HTTP_NOT_ALLOWED)
-- end

-- local idpTicket = cookie.get_field(constant.KEY_CHECK)
-- if idpTicket == nil or idpTicket == "" then
-- 	ngx.exit(ngx.HTTP_BAD_REQUEST)
-- end

-- Zhenxing Liu

local str = require "util.str"
local IP = ngx.req.get_headers()["x-forwarded-for"]
if IP ~= nil and "" ~= IP then
	IP = str.split(IP, ",")[1]
else
	IP = ngx.req.get_headers()["X-Real-IP"]
end

if IP == nil then
    IP = ngx.var.remote_addr
end
ngx.ctx.IP = IP or ""