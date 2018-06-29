-- *************************************************************************
-- * This is the main export module that will be hooked by DCS export mode *
-- *************************************************************************

package.path = package.path.. ';.\\Scripts\\?.lua;.\\LuaSocket\\?.lua;'
package.cpath = package.cpath.. ';.\\Scripts\\?.lua;.\\LuaSocket\\?.dll;'

dofile(require('lfs').writedir()..'Scripts/Crosswind/config.lua')
dofile(require('lfs').writedir()..'Scripts/Crosswind/logger.lua')
dofile(require('lfs').writedir()..'Scripts/Crosswind/server.lua')
dofile(require('lfs').writedir()..'Scripts/Crosswind/manager.lua')

-- ******************************************************************
-- * These functions will be called by DCS when a mission is started *
-- ******************************************************************

local telemetry_refresh_rate = getConfig("server", "telemetry_next_rate")

-- This function will be triggered on mission start
-- Initialization and open\bind TCP socket to a port
-- Load all plugins
function LuaExportStart()    
    logInitialize()
    logInformation("DCS 'LuaExportStart' function was triggerd!")	
	
	managerLoadPlugin()
	serverStart()
end


-- This function will be triggered at a rate equal to time 't' 
-- Collect each plugins data and dispatch it via the socket to clients
function LuaExportActivityNextEvent(t)	
	logVerbose("DCS 'LuaExportActivityNextEvent' function was triggerd!")
	
	local table = managerGetPluginsCollectedData()
	
	-- loop all plugins data and dispatch it to client
	for k,v in pairs(table) do
		local data = v
					
		if(data) then
			serverDispatch(data)
		end
	end
	
	return t + telemetry_refresh_rate
end

-- This function will be triggered before every frame
-- retrive command from client session
function LuaExportBeforeNextFrame()
	logVerbose("DCS 'LuaExportBeforeNextFrame' function was triggerd!")

	local data = serverReceiveData()
	
	if (data) then
		managerHandleRequest(data)
	end
end

-- This function will be triggered on mission ended
-- Termination\close TCP socket and release resources
function LuaExportStop()
	serverStop()

    logInformation("DCS 'LuaExportStop' function was triggerd!")
    logClose()
end

