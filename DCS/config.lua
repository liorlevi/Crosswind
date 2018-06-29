configuration = {
    ["logger"] = {
        ["level"] = "INFO", --VERB, INFO, WARN, EROR
        ["name"] = "crosswind.log"
    },
    ["server"] = {
        ["tcp_port"] = 8090,
		["telemetry_next_rate"] = 0.2
    },
	["manager"] = {
		["loaded_plugins"] = "ALL", -- ALL or specific plugins seperated by any seperation carecter ('space', ',', ':', ';' etc...)
	}
}

function getConfig(section, key)
    return assert(configuration[section][key])
end
