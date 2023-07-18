
local function locked_sleep(params)
	os.execute("sleep " .. math.max(params.secs, 1))
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
	if (os.time() < (handshake.roadmap.server.ready_ts or 0)) then
	elseif (handshake.roadmap.server.ip == nil) then
		wait = 10
		handshake:launchpad()
	else
		callback(core, handshake, gamedata)
		return
	end
	core.handle_async( locked_sleep,
		{payload = callback, secs = wait},
		wait_go)
end
