-- Zhenxing Liu

local logservice = require "service.log.log"
local constant = require "constant"

local Logconf = {}

-- the log type for all sys

Logconf.LOG = {
    _WRITE = logservice.write_log,

    _TOOL_ACCESS = {
        LOG_TYPE = 1,
        PATH = constant.LOG_PATH .. "tool.soaer.com/access/access_%s.log"
    },
    _INDEX_ACCESS = {
        LOG_TYPE = 2,
        PATH = constant.LOG_PATH .. "soaer.com/access/access_%s.log"
    },
    _BLOG_ACCESS = {
        LOG_TYPE = 3,
        PATH = constant.LOG_PATH .. "blog.soaer.com/access/access_%s.log"
    },
    _BLOG_SEARCH = {
        LOG_TYPE = 4,
        PATH = constant.LOG_PATH .. "blog.soaer.com/search/search_%s.log"
    },
    _EMAIL_SEND = {
        LOG_TYPE = 5,
        PATH = constant.LOG_PATH .. "blog.soaer.com/email/email_%s.log"
    },
    _COMMENTS_ADD = {
        LOG_TYPE = 6,
        PATH = constant.LOG_PATH .. "blog.soaer.com/comments/comments_%s.log"
    },
    _BLOG_INDEX = {
        LOG_TYPE = 7,
        PATH = constant.LOG_PATH .. "blog.soaer.com/index/index_%s.log"
    }
}

return Logconf