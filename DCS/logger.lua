-- *********************************
-- * providing logger cepebilities *
-- *********************************

dofile(require('lfs').writedir()..'Scripts/Crosswind/config.lua')

-- logger log level: VERB, INFO, WARN, EROR
local lvl_verbose, lvl_info, lvl_warning, lvl_error = 0, 1, 2, 3
local logger_level = lvl_verbose
local file = nil

function logInitialize()

	local level = getConfig("logger", "level")
    local name  = getConfig("logger", "name")

    if (level == "INFO") then
        logger_level = lvl_info
    elseif (level == "WARN") then
        logger_level = lvl_warning
    elseif (level == "EROR") then
        logger_level = lvl_error
    else
        logger_level = lvl_verbose --use default verbose
    end

    -- if file open failed the handler will be nil
    file = assert(io.open(lfs.writedir() .. "Logs/" .. name, "w"))	
	
	file:write(os.date("%c") .. string.format(" %s '%s'\n", "Logger started with level", level))
end

function logClose()
    -- flush all buffer and closes the open log file
	file:flush()
	file:close()   
end

function logVerbose(str)
    if(lvl_verbose >= logger_level) then
        writeToFile("VERB", str)
    end
end

function logInformation(str)
    if(lvl_info >= logger_level) then
        writeToFile("INFO", str)
    end
end

function logWarning(str)
    if(lvl_warning >= logger_level) then
        writeToFile("WARN", str)
    end
end

function logError(str)
    if(lvl_error >= logger_level) then
        writeToFile("EROR", str)
    end
end

-- ********** local function **********
function writeToFile(level, str)
	-- appends to the last line of the log file
    file:write(os.date("%c") .. string.format(" [%s] %s\n", level, str))
end



