--Matematica Superpiatta
--Copyright (C) 2022 Matematica Superpiatta
--
--MINETEST
--Copyright (C) 2014 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


-- Matematica Superpiatta's environment

SERVER_ADDRESS = "mt.matematicasuperpiatta.it"
SERVER_PORT = 29999
URL_GET = "http://"..SERVER_ADDRESS..":"..SERVER_PORT

SERVICE_DISCOVERY = "swissknife.raspberryip.com"
SERVICE_URL = "https://"..SERVICE_DISCOVERY.."/"

dofile(core.get_builtin_path() .. "ms-mainmenu/oop/oo_formspec.lua")

local http = core.get_http_api()

local function spawnPort()
--  GET PORT NUMBER BY HTTP REQUEST - START
	local response = http.fetch_sync({ url = URL_GET })
        if not response.succeeded then
					-- lazy debug (but also) desperate choice
                return "30000"
        end

--  GET PORT NUMBER BY HTTP REQUEST - END
	return response.data
end

local function check_updates()
	local url = SERVICE_URL .. "dawn.json"
	local res = http.fetch_sync({
		url = url,
		-- post_data = { version = '0.1', system = 'POSIX', lang = 'it' },
		timeout = 10
	})
	local raw = core.parse_json(res.data)
	if raw == nil then
		return { message = "Non sono in grado di collegarmi" }
	end
	return raw
end

local function get_formspec(tabview, name, tabdata)
	-- Update the cached supported proto info,
	-- it may have changed after a change by the settings menu.
	common_update_cached_supp_proto()

	if not tabdata.search_for then
		tabdata.search_for = ""
	end

	local update = check_updates()

	return FormspecVersion:new{version=6}:render() ..
		Label:new{x=4.58, y=0.8, label = fgettext("Un videogioco per la scuola")}:render() ..

		TableColumns:new{ columns = { {"text"} } }:render() ..
		TableOptions:new{ options =	{"background=#00000000", "highlight=#00000000"}}:render() ..
		Table:new{ x = 0.5, y = 1.8, w = 11, h = 2.2, name = "news", cells = update.news}:render() ..
		--Label:new{x=1, y=1.8, label = update.news}:render() ..

		Label:new{x=0.5, y=4.5, label = fgettext("Università degli Studi dell'Aquila")}:render() ..
		Label:new{x=0.5, y=4.9, label = fgettext("per informazioni: matematicasuperpiatta@gmail.com")}:render() ..

		-- Connect
		Style:new{selectors = {"btn_mp_connect"}, props = {"bgcolor=#dd2222", "font=bold"}}:render() ..
		Button:new{x=9, y=4.2, w=2.5, h=1.75, name = "btn_mp_connect", label = fgettext("Connect")}:render() ..

		-- Styled Title - at the end 'cause I'm lazy
		StyleType:new{selectors = {"label"}, props = {"textcolor=yellow", "font_size=+5"}}:render() ..
		Label:new{x=4.35, y=0.4, label = fgettext("Matematica Superpiatta")}:render()
end

--------------------------------------------------------------------------------


local function search_server_list(input)
	menudata.search_result = nil
	if #serverlistmgr.servers < 2 then
		return
	end

	-- setup the keyword list
	local keywords = {}
	for word in input:gmatch("%S+") do
		word = word:gsub("(%W)", "%%%1")
		table.insert(keywords, word)
	end

	if #keywords == 0 then
		return
	end

	menudata.search_result = {}

	-- Search the serverlist
	local search_result = {}
	for i = 1, #serverlistmgr.servers do
		local server = serverlistmgr.servers[i]
		local found = 0
		for k = 1, #keywords do
			local keyword = keywords[k]
			if server.name then
				local sername = server.name:lower()
				local _, count = sername:gsub(keyword, keyword)
				found = found + count * 4
			end

			if server.description then
				local desc = server.description:lower()
				local _, count = desc:gsub(keyword, keyword)
				found = found + count * 2
			end
		end
		if found > 0 then
			local points = (#serverlistmgr.servers - i) / 5 + found
			server.points = points
			table.insert(search_result, server)
		end
	end

	if #search_result == 0 then
		return
	end

	table.sort(search_result, function(a, b)
		return a.points > b.points
	end)
	menudata.search_result = search_result
end

local function set_selected_server(tabdata, idx, server)
	-- reset selection
	if idx == nil or server == nil then
		tabdata.selected = nil

		core.settings:set("address", "")
		core.settings:set("remote_port", "30000")
		return
	end

	local address = server.address
	local port    = server.port
	gamedata.serverdescription = server.description

	gamedata.fav = false
	for _, fav in ipairs(serverlistmgr.get_favorites()) do
		if address == fav.address and port == fav.port then
			gamedata.fav = true
			break
		end
	end

	if address and port then
		core.settings:set("address", address)
		core.settings:set("remote_port", port)
	end
	tabdata.selected = idx
end

local function main_button_handler(tabview, fields, name, tabdata)
	local serverlist = menudata.search_result or menudata.favorites

--	if fields.te_name then
--		gamedata.playername = fields.te_name
--		core.settings:set("name", fields.te_name)
--	end
	gamedata.playername = 'test'
	core.settings:set("name", 'test')

--	if (fields.btn_mp_connect or fields.key_enter)
--			and fields.te_address ~= "" and fields.te_port then
	if (fields.btn_mp_connect or fields.key_enter) then
--		gamedata.playername = fields.te_name
--		gamedata.password   = fields.te_pwd
--		gamedata.address    = fields.te_address
--		gamedata.port       = tonumber(fields.te_port)


		gamedata.playername = 'test'
		gamedata.password   = ''
		gamedata.address = SERVER_ADDRESS
		gamedata.port       = tonumber(spawnPort())

		gamedata.selected_world = 0

		local idx = core.get_table_index("servers")
		local server = idx and tabdata.lookup[idx]

		set_selected_server(tabdata)

		if server and server.address == gamedata.address and
				server.port == gamedata.port then

			serverlistmgr.add_favorite(server)

			gamedata.servername        = server.name
			gamedata.serverdescription = server.description

			if not is_server_protocol_compat_or_error(
						server.proto_min, server.proto_max) then
				return true
			end
		else
			gamedata.servername        = ""
			gamedata.serverdescription = ""

			serverlistmgr.add_favorite({
				address = gamedata.address,
				port = gamedata.port,
			})
		end

		core.settings:set("address",     "")
        core.settings:set("remote_port", "")

		core.start()
		return true
	end

	return false
end

local function on_change(type, old_tab, new_tab)
	if type == "LEAVE" then return end
	serverlistmgr.sync()
end


return {
	name = "online",
	caption = fgettext("Join Game"),
	cbf_formspec = get_formspec,
	cbf_button_handler = main_button_handler,
	on_change = on_change
}
