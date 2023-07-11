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

	return o
end

function Handshake:on_launch()
	if self.roadmap.discovery ~= nil then
		core.settings:set("ms_discovery", self.roadmap.discovery)
	end
	if self.roadmap.server ~= nil and self.roadmap.server.waiting_time > 0 then
		core.log("warning", "Delayed (" .. self.roadmap.server.waiting_time .. "secs)  connection w/ ticket " .. self.roadmap.server.ticket )
		self.roadmap.server.ready_ts = os.time() + self.roadmap.server.waiting_time;
		core.log("warning", "Server will be ready at " .. self.roadmap.server.ready_ts)
	elseif self.roadmap.server ~= nil and self.roadmap.server.ticket == "" then
		self.roadmap = { client_update = {
			required = true, -- DISABLE connect button
			pending = true, -- maybe?
			message = "Errore di comunicazione. Verifica se è disponibile un aggiornamento.",
			url = "https://play.google.com/apps/testing/it.matematicasuperpiatta.minetest"
		}}
	end
end

function Handshake:launchpad()
	core.handle_async(function(params)
		local http = core.get_http_api()
		return http.fetch_sync(params)
	end, {
		url = self.service_url,
		extra_headers = { "Content-Type: application/json" },
		post_data = core.write_json({
			operating_system = 'posix',
			version = '0.0.3',
			ms_type = 'full',
			lang = 'it',
			debug = 'true',
			-- local_server = 'true',
			ticket = self.roadmap.server.ticket
		}),
		timeout = 30
	}, function(res)
		core.log("warning", "checking: " .. res.data )
		self.roadmap = (res.succeeded and res.code == 200 and
			core.parse_json(res.data)) or
			{ client_update = {
				required = true, -- DISABLE connect button
				pending = true, -- maybe?
				message = "Non sono in grado di collegarmi al server. Verifica se è disponibile un aggiornamento.",
				url = "https://play.google.com/apps/testing/it.matematicasuperpiatta.minetest"
			}}
		self:on_launch()
	end)
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

function Handshake:play(username, token, passwd)
	local timeout = 95
	local start_ts = os.time()
	core.log("warning", "Inspect setup... " ..
	(self.roadmap == nil and "no Handshake.roadmap" or
	(self.roadmap.server == nil and "no server") or
	(self.roadmap.server.ip == nil and "no ip") or self.roadmap.server.ip))

	while self.roadmap.server.ip == nil do
		if os.time() - start_ts > timeout then
			core.log("warning", "Connection timeout")
			return
		end
		locked_sleep(
		  {secs = self.roadmap.server.waiting_time - (os.time() - self.discover_ts),
		  payload = self})
	end

	core.log("warning", "Connection " ..
		self.roadmap.server.ip or SERVER_ADDRESS .. ":" ..
		self.roadmap.server.port or self.spawnPort())

	-- Minetest connection
	gamedata.playername = username
	gamedata.password   = passwd
	gamedata.address    = self.roadmap.server.ip or SERVER_ADDRESS
	gamedata.port       = self.roadmap.server.port or self.spawnPort()
	gamedata.token      = token

	core.log("warning", "Connecting to " .. gamedata.address .. ":" .. gamedata.port)

	gamedata.selected_world = 0
	-- Move this away...
	--gamedata.serverdescription = json.refresh

	core.settings:set("address",     "")
	core.settings:set("remote_port", "")

	core.start()
end

function Handshake:check_updates()
	if self.roadmap.server.ticket ~= '' then
		core.log("info", "I'm using the ticket: " .. self.roadmap.server.ticket)
		core.settings:set("ticket.last", self.roadmap.server.ticket)
	end
	self:launchpad()
end
