Handshake = {}

function Handshake:new(o)
	--local ticket = core.settings:get("ticket.last") or ""
	local ticket = ""
	local o = o or {
		is_ready = false,
		is_booting = true,
		discover_ts = nil,
		service_url = "https://"..SERVICE_DISCOVERY.."/",
		roadmap = {
			server = { ticket = ticket}
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

atLeastOnceLambda = false

function Handshake:launchpad()
	core.log("warning", "\nTicket: " .. self.roadmap.server.ticket)
	core.handle_async(function(params)
		local http = core.get_http_api()
		return http.fetch_sync(params)
	end, {
		url = self.service_url,
		extra_headers = { "Content-Type: application/json" },
		post_data = core.write_json({
			operating_system = 'posix',
			version = '1.0.0',
			ms_type = 'full', --change with 'beta' for setting the beta version
			lang = 'it',
			debug = 'true',
			-- local_server = 'true',
			ticket = self.roadmap.server.ticket
		}),
		timeout = 10
	}, function(res)
		local jsonRes = core.parse_json(res.data)
		core.log("warning", "checking: " .. res.data )
		-- Check Connection
		if res.code ~= 200 then
			core.log("warning", "Error calling lambdaClient")
			local error_dlg = create_fatal_error_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()
			return true
		end
		-- Check Version
		if not atLeastOnceLambda then
			atLeastOnceLambda = true
			local pending = jsonRes["client_update"]["pending"]
			local required = jsonRes["client_update"]["required"]
			local url = jsonRes["client_update"]["url"]
			local message = jsonRes["client_update"]["message"]
			if required then
				core.log("warning", "Update required")
				local error_dlg = create_required_version_dlg()
				ui.cleanup()
				error_dlg:show()
				ui.update()
				return true
			else
				if pending then
					core.log("warning", "Update pending")
					local error_dlg = create_pending_version_dlg()
					ui.cleanup()
					error_dlg:show()
					ui.update()
					return true
				end
			end
		end

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

function Handshake:check_updates()
	if self.roadmap.server.ticket ~= '' then
		core.log("info", "I'm using the ticket: " .. self.roadmap.server.ticket)
		core.settings:set("ticket.last", self.roadmap.server.ticket)
	end
	self:launchpad()
end
