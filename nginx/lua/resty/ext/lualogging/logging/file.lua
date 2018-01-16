-------------------------------------------------------------------------------
-- Saves logging information in a file
--
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
--
-------------------------------------------------------------------------------

local logging = require"ext.lualogging.logging"
local log = ngx.log
local info = ngx.INFO
local e = ngx.ERR

local debug = ngx.config.debug


local function format_ten_minute()
    local date_pattern = os.date("%Y%m%d%H%M")
    return math.floor(date_pattern / 10) * 10
end

local openFileLogger = function (file_name, log_type)
    local write_file_name = string.gsub(file_name, "_%%s", "")
    local format_file_name = string.format(file_name, format_ten_minute())
    if not log_type.info then
        log_type.info = {}
    end

    local last_file_name_date_pattern = log_type.info.last_file_name_date_pattern
    if last_file_name_date_pattern ~= format_file_name then
        if last_file_name_date_pattern then
            log_type.info.file_handler:close()
            log_type.info.file_handler = nil;
            local _, msg = os.rename(write_file_name, last_file_name_date_pattern)
            if msg then
                return nil, string.format("error %s on log rollover", msg)
            end
        end

        local f = io.open(write_file_name, "a")
        if (f) then
            f:setvbuf ("line")
            log_type.info.last_file_name_date_pattern = format_file_name
            log_type.info.file_handler = f
            return f
        else
            return nil, string.format("file `%s' could not be opened for writing", write_file_name)
        end
    else
        return log_type.info.file_handler
    end
end



function logging.file(log_type)
    local file_name = log_type.PATH
    if type(file_name) ~= "string" then
        file_name = "lualogging.log"
    end
    return logging.new( function(self, level, message)
        local f, msg = openFileLogger(file_name, log_type)
        if not f then
            local err_log = "#############################LOG TYPE IS: " .. (log_type.LOG_TYPE or "NULL") ..  ", ERR FileHandler############################\n"
            err_log = err_log .. tostring((msg or "NULL"))
            ngx.log(ngx.CRIT, err_log)
            return nil, msg
        end
        f:write(message .. "\n")
        return true
    end)
end

return logging.file