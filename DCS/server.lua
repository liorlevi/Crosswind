-- *****************************************************************************************
-- * providing TCP server cepebilities, all data will be dispatch to all connected clients *
-- *****************************************************************************************

local socket = assert(require("socket"))
local JSON = assert(require("JSON"))
local master = nil
local server = nil
local session = nil
local isConnected = false

-- start listening for client connection
function serverStart()

	logInformation("Server intializing")	

	local port = getConfig("server", "tcp_port")
			
	-- only one client is allowd to be connect to this server
	master = socket.tcp()
	master:listen(1)
	
	-- create a TCP socket and bind it to the local host, at any port
	 server = assert(socket.bind("*", port))
	
	-- set timeout to breack blocking operation until timeout has expired
	-- timeout MUST be 0.0 so reconnecting on every frame will NOT cause letency on game!!!!
	server:settimeout(0.0, "b")
	server:setoption("keepalive", true)
	server:setoption("tcp-nodelay", true)
	
	listen()
end

function serverDispatch(data)

	-- wait for client to connect
	if(isConnected == false) then
		listen()
	end

	if (session) then
		local index, status = session:send(data)
		
		-- if client connected is lost? prepare for client reconnecting
		if(index) then
			logVerbose("Server send: " .. data)	
		else
			if (session) then			
				session:close()
				session = nil
				
				isConnected = false 
				
				logVerbose(string.format("Failed sending data to client, status = '%s', wating client to reconnect", status))
			end			
		end					
	end
end

function serverReceiveData()

	local data = nil	
	
	-- wait for client to connect
	if(isConnected == false) then
		listen()
	end

	if (session) then
		local msg, status = session:receive("*l")
		
		if(msg) then
			data = msg
			logVerbose(string.format("Server received: %s", msg))
		else			
			logVerbose(string.format("No data was received! due to '%s'", status))
		end
	end
	
	return data
end

-- close the server socket
function serverStop()

	if (session) then
		session:send(getStatusCommand("STOPPED"))
		session:close()	
		session:shutdown("both")
		
		logVerbose("Server stop session closed")	
	end	
	
	if (server) then
		server:close()
		
		logVerbose("Server stop server closed")	
	end
	
	if (master) then
		master:close()
		
		logVerbose("Server stop master closed")	
	end
	
	logInformation("Server stopped!")	
end

-- ********** local function **********
 function listen()
	-- block until client is connected (handsack) OR breack on timeout (return nil)
	session = server:accept()
	
	if (session) then
		isConnected = true
		
		session:settimeout(0.0, "b")		
		session:setoption("keepalive", true)
		session:setoption("tcp-nodelay", true)
		session:send(getStatusCommand("STARTED"))
				
		logInformation("Server started! client session connected")
	else
		logVerbose("Server accept has timeout")	
	end
end

function getStatusCommand(status)
	local table = {}
	table["topic"] = "SYSTEM"
	table["server_command"] = "STATUS"
	table["server_status"] = status
	
	return JSON:encode(table)
end