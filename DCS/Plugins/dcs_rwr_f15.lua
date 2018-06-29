-- *********************************************************
-- * This pulgin collect information for FC3 F15 RWR (TWS) *
-- *********************************************************

local JSON = assert(require("JSON"))

Plugin = {id = "DCS_RWR_F15"}

function Plugin:new()
	object = {}
	setmetatable(object, self)
	self.__index = self
	
	return object
end

function Plugin:collect()

	local table = {plugin_id = "DCS_RWR_F15", topic = "PLUGIN"}
	local emits = {}
	
	local tws = LoGetTWSInfo()
		
	for mode, emit in pairs (tws.Emitters) do
	
		local type = LoGetNameByType(emit.Type.level1, emit.Type.level2, emit.Type.level3, emit.Type.level4)
				
		if(type) then
			emit["threate_type"] = type
		end			
	end
	
	table["tws_info"] = tws
	
	return JSON:encode(table)
end