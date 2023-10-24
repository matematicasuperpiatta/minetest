
local function locked_sleep(params)
	if (core ~= nil) then
		local http = core.get_http_api()
		-- timeout time must be greater than 0 otherwise fetch_sync will set the default timeout value
		local wt = params.secs > 0 and params.secs or 5
		core.log("locked_sleep: " .. tostring(wt) .. "s")
		http.fetch_sync({url = "https://wiscoms.matematicasuperpiatta.it:8888", timeout = wt})
	end
	return params.payload
end

function wait_til(params)
	if (os.time() > params.ts) then
		params.callback(params.payload)
	else
		core.handle_async( locked_sleep,
		{payload = params, secs = 0.5},
		wait_til)
	end
end

function wait_go(callback)
	local wait = 0.5
	if (handshake.roadmap.server.ip == nil) then
		wait = handshake.roadmap.server.waiting_time
		core.log("wait_go: " .. tostring(wait) .. "s")
		handshake:launchpad()
	else
		callback(core, handshake, gamedata)
		return
	end
	core.handle_async( locked_sleep,
		{payload = callback, secs = wait},
		wait_go)
end
