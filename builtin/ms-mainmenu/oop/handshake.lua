--
-- Note: Into async functions I need to use `handshake`
--       (the object, not the class Handshake)
--

Handshake = {}

function Handshake:new(o)
	local o = o or {
		is_ready = false,
		is_booting = true,
		discover_ts = nil,
		service_url = "https://"..SERVICE_DISCOVERY.."/",
		roadmap = {
			server = { ticket = core.settings:get("ticket.last") or ""}
		}
	}
	setmetatable(o, self)
	self.__index = self

	self.http = core.get_http_api()

	return o
end

local function locked_sleep(params)
	local startTime = os.time()
	local elapsed_time = 0
	while elapsed_time < math.max(params.secs, 1) do
		elapsed_time = os.time() - startTime
	end
	return params.me
end

function Handshake:sleep(delay, callback)
	core.log("warning", "Sleeping for " .. delay .. "secs")
	if self == nil then
		core.log("error", "I lost mySELF")
	end
	core.handle_async(locked_sleep,
		{me = self, secs = delay},
		callback)
end

function Handshake:spawnPort()
	--  GET PORT NUMBER BY HTTP REQUEST - START
	local response = http.fetch_sync({ url = URL_GET })
	if not response.succeeded then
		-- lazy debug (but also) desperate choice
		return 30000
	end
	--  GET PORT NUMBER BY HTTP REQUEST - END
	return tonumber(response.data)
end

function Handshake:check_updates()
	if self.roadmap.server.ticket ~= '' then
		core.settings:set("ticket.last", self.roadmap.server.ticket)
		core.log("warning", "I'm using the ticket: " .. self.roadmap.server.ticket)
	end
	local res = handshake.http.fetch_sync({
		url = self.service_url,
		extra_headers = { "Content-Type: application/json" },
		post_data = core.write_json({
			operating_system = 'posix',
			version = '0.0.3',
			ms_type = 'full',
			lang = 'it',
			debug = 'true',
			ticket = self.roadmap.server.ticket
		}),
		timeout = 30
	})

	core.log("warning", self.service_url .. " says " .. res.data)
	handshake.discover_ts = os.time()
	handshake.roadmap = res.succeeded and res.code == 200 and
		core.parse_json(res.data) or
		{ client_update = {
			required = true, -- DISABLE connect button
			pending = true, -- maybe?
			message = "Non sono in grado di collegarmi al server. Verifica se è disponibile un aggiornamento.",
			url = "https://play.google.com/apps/testing/it.matematicasuperpiatta.minetest"
		}}
	if handshake.roadmap.discovery ~= nil then
		core.settings:set("ms_discovery", handshake.roadmap.discovery)
	end
	if handshake.roadmap.server ~= nil and handshake.roadmap.server.waiting_time > 0 then
		local delay = handshake.roadmap.server.waiting_time - (os.time() - handshake.discover_ts)
		core.log("warning", "Delayed (" .. delay .. "secs)  connection w/ ticket " .. handshake.roadmap.server.ticket )
		handshake:sleep(delay, handshake.check_updates)
	elseif handshake.roadmap.server ~= nil and handshake.roadmap.server.ticket == "" then
		handshake.roadmap = { client_update = {
			required = true, -- DISABLE connect button
			pending = true, -- maybe?
			message = "Errore di comunicazione. Verifica se è disponibile un aggiornamento.",
			url = "https://play.google.com/apps/testing/it.matematicasuperpiatta.minetest"
		}}
	end
end

function Handshake:play(username, token, passwd)
	local timeout = 95
	local start_ts = os.time()
	core.log("warning", "Inspect setup... " ..
	(handshake.roadmap == nil and "no handshake.roadmap" or
	(handshake.roadmap.server == nil and "no server") or
	(handshake.roadmap.server.ip == nil and "no ip") or handshake.roadmap.server.ip))

	while handshake.roadmap.server.ip == nil do
		if os.time() - start_ts > timeout then
			core.log("warning", "Connection timeout")
			return
		end
		locked_sleep({delay = handshake.roadmap.server.waiting_time - (os.time() - handshake.discover_ts),
		me = handshake})
	end

	core.log("warning", "Connection " ..
		handshake.roadmap.server.ip or SERVER_ADDRESS .. ":" ..
		handshake.roadmap.server.port or self.spawnPort())

	-- Minetest connection
	gamedata.playername = username
	gamedata.password   = passwd
	gamedata.address    = handshake.roadmap.server.ip or SERVER_ADDRESS
	gamedata.port       = handshake.roadmap.server.port or self.spawnPort()
	gamedata.token      = token

	core.log("warning", "Connecting to " .. gamedata.address .. ":" .. gamedata.port)

	gamedata.selected_world = 0
	-- Move this away...
	--gamedata.serverdescription = json.refresh

	core.settings:set("address",     "")
	core.settings:set("remote_port", "")

	core.start()
end

handshake = Handshake:new()
