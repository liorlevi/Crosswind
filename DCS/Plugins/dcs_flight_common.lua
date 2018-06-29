-- **************************************************
-- * This pulgin collect information DCS model time *
-- **************************************************

local JSON = assert(require("JSON"))

Plugin = {id = "DCS_FLIGHT_COMMON"}

function Plugin:new()
	object = {}
	setmetatable(object, self)
	self.__index = self
	
	return object
end

function Plugin:collect()

	local table = {plugin_id = "DCS_FLIGHT_COMMON", topic = "PLUGIN"}
	
	table["mission_start_time"] = LoGetMissionStartTime()
	table["model_time"] = LoGetModelTime()
	table["aircraft"] = LoGetObjectById(LoGetPlayerPlaneId())
	table["engine_info"] = LoGetEngineInfo()
	table["pilot_name"] = LoGetPilotName()
	table["hsi"] = LoGetControlPanel_HSI()
	table["sight_system_info"] = LoGetSightingSystemInfo()
	table["mech_info"] = LoGetMechInfo()
	
	local pitch, bank, yaw = LoGetADIPitchBankYaw()
	
	table["pitch"] = pitch
	table["bank"] = bank
	table["yaw"] = yaw	
	
	return JSON:encode(table)
end

-- Converts an Object to String (recursive)
function ObjectToString(ObjectToDump, Level)

		-- Default Value
		if not Level then
			Level=0;
		end

		-- Prevent recursion issues
		if Level>7 then
			return "";
		end

		if type(ObjectToDump)=="string" then
			return "\""..string.gsub(ObjectToDump,"\n"," ").."\",";
		end

		if type(ObjectToDump)=="number" then
			return string.format("%.6g,", ObjectToDump);
		end

		if type(ObjectToDump)=="boolean" then

			if ObjectToDump==true then
				return "true,";
			else
				return "false,";
			end
		end

		if type(ObjectToDump)=="table" then

			local TableDump="\n"..string.rep("\t",Level).."{\n";

			-- Sort Table
			local SortedTable={};
			local ItemIndex=0;

			for k in pairs(ObjectToDump) do
				ItemIndex=ItemIndex+1;
				SortedTable[ItemIndex]=k;
			end

			table.sort(SortedTable);

			for k,v in pairs(SortedTable) do

				-- Get source data from sorted array
				k=v;
				v=ObjectToDump[v];

				-- Prevent recursion issues
				if v~=ObjectToDump and not (Level>0 and k=="_G") and not (Level>1 and k=="package") then
					TableDump=TableDump..string.rep("\t",Level+1)..k.." = "..Tacview.ObjectToString(v,Level+1).."\n";
				end
			end

			return TableDump..string.rep("\t",Level).."},";
		end

		if type(ObjectToDump)=="userdata" then

			local MetaTable=getmetatable(ObjectToDump);

			if MetaTable then
				return Tacview.ObjectToString(MetaTable,Level)
			end
		end

		return tostring(ObjectToDump)..",";
	end