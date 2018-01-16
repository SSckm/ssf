local writeLog = require "timer.write_log"

local Manager = {}

local function start()
	writeLog.timer();
end


Manager.start = start
return Manager