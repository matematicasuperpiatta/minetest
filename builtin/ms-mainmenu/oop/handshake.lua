Handshake = {}

function Handshake:new(o)
	local ticket = ""
	local o = o or {
		is_ready = false,
		is_booting = true,
		discover_ts = nil,
		service_url = "https://"..SERVICE_DISCOVERY.."/",
		service_url_local = "http://"..SERVICE_DISCOVERY_LOCAL.."/",
		wiscoms_url = WISCOMS_URL,
		wiscoms_url_local = WISCOMS_URL_LOCAL,
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
	core.log("service_url: " .. o.service_url)
	core.log("service_url_local: " .. o.service_url_local)
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
	core.handle_async(
		function(params)
			-- Try call real AWS lambda. If does not responds, if user is a demo user, try call local (fake) lambda.
			--[[local http = core.get_http_api()
			if params.gamedata.playername == nil or not string.find(params.gamedata.playername, "demo") then
				--means that this call is a check version call or that is a regular call of a NOT DEMO user.
				if params.gamedata.playername == nil then
					params.timeout = 5
				end
				params.parameters.url = params.handshake.service_url
				local lambda_res = http.fetch_sync(params.parameters)
				if lambda_res == nil and params.gamedata.playername == nil then
					--means that it is a check version call and remote attempt has failed.
					params.url = params.handshake.service_url_local
					lambda_res = http.fetch_sync(params.parameters)
				end
				return lambda_res
			else --means that it is a real lambda call to obtain game server ip and port for a DEMO user.
				params.url = params.handshake.service_url_local
				local lambda_res = http.fetch_sync(params.parameters)
				if lambda_res == nil then
					params.url = params.handshake.service_url
					lambda_res = http.fetch_sync(params.parameters)
				end
				return lambda_res
			end --]]
			local http = core.get_http_api()
			local lambda_res = http.fetch_sync(params.parameters)
			core.log("Result of lambda interrogation" .. tostring(lambda_res))
			if lambda_res == nil or lambda_res.code == 0 then
				if params.gamedata.playername == nil or string.find(params.gamedata.playername, "demo") then
					-- Check Version or Demo Account
					params.parameters.url = params.handshake.service_url_local
					core.log("url local: " .. tostring(params.handshake.service_url_local))
					lambda_res = http.fetch_sync(params.parameters)
				end
			end
			return lambda_res
		end,
		{
			gamedata = gamedata,
			handshake = self,
			parameters = {
				url = self.service_url,
				extra_headers = { "Content-Type: application/json" },
				post_data = core.write_json({
					operating_system = "android",
					version = "1.1.4",
					ms_type = global_ms_type,
					dev_phase = "release",
					server_type = "ecs",
					lang = 'it',
					debug = "false",
					ticket = self.roadmap.server.ticket,
					access = self.token,
					timeout = 10
				}),
				timeout = 10
			}
		},
		function(res)
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
