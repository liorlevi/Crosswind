-- ****************************************
-- * providing plugin LUA file management *
-- ****************************************

local JSON = assert(require("JSON"))

local plugins = {}

-- This function load all LUA plugins file that located at the plugin folder
function managerLoadPlugin()

	logInformation("Manager starting loading plugins")	

	local mode = getConfig("manager", "loaded_plugins")	
	local lfs = require("lfs")
	local folderPath = lfs.writedir().."Scripts/Crosswind/Plugins"
	local count = 0	
	
	logVerbose(folderPath)
	
	for file in lfs.dir(folderPath) do
	
		logVerbose(file)
	
		if (file ~= ".") and (file ~= "..") then
			local pluginPath = folderPath.."/"..file
			
			logVerbose("Loading plugin at "..pluginPath)
			
			dofile(pluginPath)			
			local plugin = Plugin:new()
			
			if(mode == "ALL") then					
				plugins[plugin.id] = plugin
			
				logVerbose(string.format("Loaded '%s' plugin", plugin.id))
						
				count = count + 1
			else
				-- try match plugin identefire via the requested plugins from config
				local index = string.find(mode, plugin.id, 1) 
				
				if(index) then
					plugins[plugin.id] = plugin
					
					logVerbose(string.format("Loaded '%s' plugin", plugin.id))
						
					count = count + 1
				end
			end
		end
	end
	
	logInformation(string.format("Manager loaded %d plugins", count))	
end

-- This function get the plugin by its id and call the 'collect' function on the plugin
function managerGetPluginData(pluginId)
	local data = nil
	local plugin = plugins[pluginId]
	
	if(plugin) then
		data = plugin.collect()
	end
		
	return data
end

-- This function collect and concat all plugins data
function managerGetPluginsCollectedData()
	local table = {}
	
	for k in pairs(plugins) do			
		table[k] = managerGetPluginData(k)						
	end
				
	return table
end

-- This function routs client request to their proper handle function using the topic
function managerHandleRequest(data)
	logInformation(string.format("Client request '%s' has received", data))
	
	local table = JSON:decode(data)
	
	if(table) then	
		local topic = table["topic"]
		
		if (topic == "COMMAND") then
			managerSetCommand(table)
		elseif (topic == "SYSTEM") then
			-- Nothing for now
		end
	else
		logVerbose("Failed to parse json from client request")
	end
end

-- This function send command to DCS to be execue
function managerSetCommand(table)
	local command = table["command"]
	local value = table["value"]

	--logVerbose(string.format("Sending command %d to DCS with value of %.1f", command, value))
	logInformation(string.format("Sending command %d to DCS with value of %.1f", command, value))
	
	LoSetCommand(command, value)
end
