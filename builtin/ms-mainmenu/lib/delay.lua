
local function locked_sleep(params)
	if (core ~= nil) then
		local http = core.get_http_api()
		-- timeout must be greater than 0 otherwise fetch_sync will set the default timeout value
		local wt = params.secs > 0 and params.secs or 5
		core.log("locked_sleep: " .. tostring(wt) .. "s")

		-- loop multiple times cause the maximum timeout is 10
		local i = math.floor(wt / 10)
		while i > 0 do
			i = i - 1
			wt = wt - 10
			http.fetch_sync({url = "https://wiscoms.matematicasuperpiatta.it:8888", timeout = 10})
		end
		if wt > 0 then
			http.fetch_sync({url = "https://wiscoms.matematicasuperpiatta.it:8888", timeout = wt})
		end
	end
	return params.payload
end

function wait_go(callback)
	local wait = 0.5
	if (handshake.roadmap.server.ip == nil) then
		if lambda_read then
			handshake:launchpad()
			lambda_read = false
		end

		if lambda_waiting then
			wait = 5
			core.log("wait_go [waiting_lambda]: " .. tostring(wait) .. "s")
		else
			lambda_read = true
			wait = handshake.roadmap.server.waiting_time
			core.log("wait_go: " .. tostring(wait) .. "s")
		end
		
		-- update flavor time label
		update_flavor()
	else
		callback(core, handshake, gamedata)
		return
	end
	core.handle_async( locked_sleep,
		{payload = callback, secs = wait},
		wait_go)
end

