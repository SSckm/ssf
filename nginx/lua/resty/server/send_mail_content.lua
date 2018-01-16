
local cjson = require "cjson"
local enc = require "encrypt.encrypt"
local dec = require "encrypt.decrypt"
local constant = require "constant"
local uuid = require "util.uuid"
local uri = ngx.var.request_uri
local tinsert = table.insert
local tconcat = table.concat
local SysLogConfig = require "config.log"
local SysLog = require "service.log.log"
local str = require "util.str"
local Log_type = SysLogConfig.LOG._EMAIL_SEND

local result = {}
local args, err = ngx.req.get_post_args()
if not args then
    result.code = 0
    result.error = "邮箱不能为空!"
    ngx.say(cjson.encode(result))
    return
end

local email = args['email']

if not email then
    result.code = 0
    result.error = "邮箱不能为空"
    ngx.say(cjson.encode(result))
    return
end

local function is_mail_url(s)
    return ngx.re.find(s, [[^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$]])
end

local checkMail = is_mail_url(email)
if not checkMail then
    result.code = 0
    result.error = "邮箱格式不正确"
    ngx.say(cjson.encode(result))
    return
end


local function get_cipher(req_email)
    local time = ngx.now() * 1000
    local cipherStr = req_email .. "," .. time
    local n = enc.encrypt_with_aes(constant.CIPHER_KEY,cipherStr)
    n = enc.encode_base64(n)
    n = ngx.escape_uri(n)
    return n
end

local function writeLog(email)
    local content = {}
    local req_id = uuid.get_uuid() or "-"
    local ip = ngx.ctx.IP
    tinsert(content, req_id)
    tinsert(content, ngx.now() * 1000)
    tinsert(content, ip)
    tinsert(content, ngx.escape_uri(email))
    local contentStr = tconcat(content, '\t')
    local access_msg = {type = Log_type, content = contentStr}
    SysLog.log(access_msg)
end

writeLog(email)

local function send_mail()
    local smtp = require("smtp")
    local mime = require("smtp.mime")
    local ltn12 = require("smtp.ltn12")
    local subject = "评论需要验证信息"
    local body = get_cipher(email)
    local from = "<soaer_service@163.com>"
    local to = {"<" .. email .. ">"}

    local mesgt = { 
        headers = {
            from = "soaer.com <"..from..">",
            to = table.concat(to, ","),
            subject = mime.ew(subject, nil, {charset= "utf8"})
        },

        body= {
            [1]= {body= body:gsub("%b<>", "")}
        }
    }

    local ret, err = smtp.send {
        from = from,
        rcpt = to,
        port = 465,
        user = 'soaer_service@163.com',
        password = 'liuzhenxing1',
        server = "220.181.12.14",
        -- domain = 'mail.163.com',
        source = smtp.message(mesgt),
        ssl = { enable = true, verify_cert = false }
    }

    if err then
        ngx.log(ngx.ERR, err)
    end
end

local ok, err = pcall(function () send_mail() end)
if not ok then
    result.code = 0
    result.error = "发送邮件失败"
    ngx.log(ngx.ERR, err)
    ngx.say(cjson.encode(result))
else
    result.code = 1
    result.error = "发送邮件成功"
    ngx.say(cjson.encode(result))
end

ngx.eof()