--Matematica Superpiatta
--Copyright (C) 2023 Matematica Superpiatta
--
--Minetest
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

SERVER_ADDRESS = core.settings:get("ms_address") or "mt.matematicasuperpiatta.it"
SERVER_PORT = core.settings:get("ms_port") or 29999
URL_GET = "http://"..SERVER_ADDRESS..":"..SERVER_PORT

SERVICE_DISCOVERY = core.settings:get("ms_discovery") or "jp4ffxegbm2n57igrjm5t7qjsa0ygyhi.lambda-url.eu-south-1.on.aws"

mt_color_grey  = "#AAAAAA"
mt_color_blue  = "#6389FF"
mt_color_green = "#72FF63"
mt_color_dark_green = "#25C191"
mt_color_orange  = "#FF8800"

defaulttexturedir = core.get_texturepath_share() .. DIR_DELIM .. "base" ..
						DIR_DELIM .. "pack" .. DIR_DELIM

ms_mainmenu = {
	remote = { server = { ticket = ""}},
	discover_ts = nil,
	service_url = "https://"..SERVICE_DISCOVERY.."/"
}

function ms_mainmenu.spawnPort()
	local http = core.get_http_api()
    --  GET PORT NUMBER BY HTTP REQUEST - START
	local response = http.fetch_sync({ url = URL_GET })
	if not response.succeeded then
		-- lazy debug (but also) desperate choice
		return 30000
	end
	--  GET PORT NUMBER BY HTTP REQUEST - END
	return tonumber(response.data)
end

local function sleep(secs)
	os.execute("sleep " .. math.max(secs, 1))
end

function ms_mainmenu:play(username, token, passwd)
	while self.remote.server.ip == nil do
		sleep(self.remote.server.waiting_time - (os.time() - self.discover_ts))
	end
    core.log("warning", "Connection " ..
		self.remote.server.ip or SERVER_ADDRESS .. ":" ..
		self.remote.server.port or self.spawnPort())
	-- Minetest connection
	gamedata.playername = username
	gamedata.password   = passwd
	gamedata.address    = self.remote.server.ip or SERVER_ADDRESS
	gamedata.port       = self.remote.server.port or self.spawnPort()
	gamedata.token      = token

	core.log("warning", "Connecting to " .. gamedata.address .. ":" .. gamedata.port)

	gamedata.selected_world = 0
	-- Move this away...
	--gamedata.serverdescription = json.refresh

	core.settings:set("address",     "")
	core.settings:set("remote_port", "")

	core.start()
end

--------------------------------------------------------------------------------
local function check_updates()
	local http = core.get_http_api()
	-- random results for testing purpose. Append 'dawn` to be sure to enable connection
	local res = http.fetch_sync({
		url = ms_mainmenu.service_url,
		extra_headers = { "Content-Type: application/json" },
		post_data = core.write_json({
			operating_system = 'posix',
			version = '0.0.3',
			ms_type = 'full',
			lang = 'it',
			debug = 'true',
			ticket = ms_mainmenu.remote.server.ticket
		}),
		timeout = 30
	})
	core.log("warning", ms_mainmenu.service_url .. " says " .. res.data)
	ms_mainmenu.discover_ts = os.time()
	ms_mainmenu.remote = res.succeeded and res.code == 200 and
		core.parse_json(res.data) or
		{ client_update = {
			required = true, -- DISABLE connect button
			pending = true, -- maybe?
			message = "Non sono in grado di collegarmi al server. Verifica se è disponibile un aggiornamento.",
            url = "https://play.google.com/apps/testing/it.matematicasuperpiatta.minetest"
		}}
	if ms_mainmenu.remote.discovery ~= nil then
		core.settings:set("ms_discovery", ms_mainmenu.remote.discovery)
	end
	if ms_mainmenu.remote.server ~= nil and ms_mainmenu.remote.server.waiting_time > 0 then
		core.log("warning", "Delayed connection w/ ticket " .. ms_mainmenu.remote.server.ticket )
		core.handle_async(
			sleep, ms_mainmenu.remote.server.waiting_time - (os.time() - ms_mainmenu.discover_ts),
			check_updates)
	elseif ms_mainmenu.remote.server ~= nil and ms_mainmenu.remote.server.ticket == "" then
		ms_mainmenu.remote = { client_update = {
			required = true, -- DISABLE connect button
			pending = true, -- maybe?
			message = "Errore di comunicazione. Verifica se è disponibile un aggiornamento.",
			url = "https://play.google.com/apps/testing/it.matematicasuperpiatta.minetest"
		}}
	end
	return ''
end

local function bootstrap()
	local default_menupath = core.get_mainmenu_path()
	dofile(default_menupath .. DIR_DELIM .. "async_event.lua")
	-- ASAP!
	check_updates()

	local basepath = core.get_builtin_path()
	local menupath = basepath .. "ms-mainmenu" .. DIR_DELIM

	dofile(basepath .. "common" .. DIR_DELIM .. "filterlist.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "buttonbar.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "dialog.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "tabview.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "ui.lua")
	dofile(default_menupath .. DIR_DELIM .. "common.lua")
	dofile(default_menupath .. DIR_DELIM .. "pkgmgr.lua")
	dofile(default_menupath .. DIR_DELIM .. "serverlistmgr.lua")
	dofile(default_menupath .. DIR_DELIM .. "game_theme.lua")

	dofile(default_menupath .. DIR_DELIM .. "dlg_config_world.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_settings_advanced.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_contentstore.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_create_world.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_delete_content.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_delete_world.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_rename_modpack.lua")

	dofile(menupath .. "oop" .. DIR_DELIM .. "oo_formspec.lua")

	dofile(menupath .. DIR_DELIM .. "dlg_whoareu.lua")
	-- dofile(menupath .. DIR_DELIM .. "dlg_passwd.lua")

	return {
		ms       = dofile(menupath .. DIR_DELIM .. "tab_ms.lua"),
		settings = dofile(default_menupath .. DIR_DELIM .. "tab_settings.lua"),
		about    = dofile(menupath .. DIR_DELIM .. "tab_about.lua")
	}
end

--------------------------------------------------------------------------------
local function main_event_handler(tabview, event)
	if event == "MenuQuit" then
		core.close()
	end
	return true
end

--------------------------------------------------------------------------------
local function init_globals(tabs)
	-- Init gamedata
	gamedata.worldindex = 0

	menudata.worldlist = filterlist.create(
		core.get_worlds,
		compare_worlds,
		-- Unique id comparison function
		function(element, uid)
			return element.name == uid
		end,
		-- Filter function
		function(element, gameid)
			return element.gameid == gameid
		end
	)

	menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
	menudata.worldlist:set_sortmode("alphabetic")

	if not core.settings:get("menu_last_game") then
		local default_game = core.settings:get("default_game") or "minetest"
		core.settings:set("menu_last_game", default_game)
	end

	mm_game_theme.init()

	-- Create main tabview
	local tv_main = tabview_create("maintab", {x = 12, y = 5.4}, {x = 0, y = 0})

	tv_main:set_autosave_tab(true)
	tv_main:add(tabs.ms)

	tv_main:add(tabs.settings)
	tv_main:add(tabs.about)

	tv_main:set_global_event_handler(main_event_handler)
	tv_main:set_fixed_size(false)

	local last_tab = core.settings:get("maintab_LAST")
	if last_tab and tv_main.current_tab ~= last_tab then
		tv_main:set_tab(last_tab)
	end

	-- In case the folder of the last selected game has been deleted,
	-- display "Minetest" as a header
--	if tv_main.current_tab == "local" then
--		local game = pkgmgr.find_by_gameid(core.settings:get("menu_last_game"))
--		if game == nil then
--			mm_texture.reset()
--		end
--	end

	ui.set_default("maintab")
	tv_main:show()

	ui.update()

	mm_game_theme.reset()
	mm_game_theme.update_game(pkgmgr.find_by_gameid(core.settings:get("menu_last_game")))
end

init_globals( bootstrap() )
