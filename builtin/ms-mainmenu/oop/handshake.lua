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
			server = {
				ticket = ticket,
				waiting_time = 5
			}
		},
		token = ''
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
	end
end

atLeastOnceLambda = false

function Handshake:launchpad()
	core.log("warning", "Ticket: " .. self.roadmap.server.ticket)
	lambda_waiting = true
	core.handle_async(function(params)
		local http = core.get_http_api()
		return http.fetch_sync(params)
	end, {
		url = self.service_url,
		extra_headers = { "Content-Type: application/json" },
		post_data = core.write_json({
			operating_system = "windows",
			version = "1.1.2",
			ms_type = "full",
			dev_phase = "release",
			server_type = "ecs",
			lang = 'it',
			debug = "false",
			ticket = self.roadmap.server.ticket,
			access = self.token
		}),
		timeout = 10
	}, function(res)
		lambda_waiting = false
		core.log("warning", "Lambda response: [" .. res.code .. "] - " .. res.data)

		-- Check for json 
		local jsonRes = core.parse_json(res.data)
		if jsonRes == nil then
			core.log("warning", "Lambda error: cannot parse data.")

			local error_dlg = create_fatal_error_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()
			
			lambda_error = true
			return true
		end

		-- Check Connection
		if res.code ~= 200 then
			core.log("warning", "Error calling lambdaClient")
			
			local error_dlg = create_fatal_error_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()

			lambda_error = true
			return true
		end

		-- Check for messages/errors
		local message_type = jsonRes["messages"]["custom_message_type"]
		local message_text = jsonRes["messages"]["custom_message_text"]
		if message_type == "error" then
			core.log("warning", "Lambda error: [" .. message_type .. "] " .. message_text)
			global_data.message_type = message_type
			global_data.message_text = message_text

			local error_dlg = create_fatal_error_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()

			lambda_error = true
			return true
		end

		-- Check Version
		local pending = jsonRes["client_update"]["pending"]
		local required = jsonRes["client_update"]["required"]
		if required then
			core.log("warning", "Update required")
			
			local error_dlg = create_required_version_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()

			lambda_error = true
			return true
		else
			if pending then
				--core.log("warning", "Update pending")
				--local error_dlg = create_pending_version_dlg()
				--ui.cleanup()
				--error_dlg:show()
				--ui.update()
				return true
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

	-- update flavor if this is not called by check_version
	-- self.token is empty when launchpad is called by check_version
	--update_flavor(self.token == '')
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
