--MatematicaSuperpiatta
--Copyright (C) 2022 Matematica Superpiatta
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

local whoareu = ""
local passwd = ""

local error_msg = ""

--
-- Utils
--

local http = core.get_http_api()

--------------------------------------------------------------------------------
--
-- Username dialog
--

local function get_whoareu_formspec(tabview, _, tabdata)
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = 5.5, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 1.5, label = fgettext("Username:")}:render() ..
		Field:new{x = 0.5, y = 1.75, w = 4.5, h = 0.7, name = "username", value = whoareu}:render() ..
		Button:new{x=0.5, y=3.25, w=2.2, h=0.75, name = "btn_back", label = fgettext("Back")}:render() ..
		Button:new{x=2.8, y=3.25, w=2.2, h=0.75, name = "btn_next", label = fgettext("Next")}:render() ..

		-- Styled stuff
		StyleType:new{selectors = {"label"}, props = {"font=italic"}}:render() ..
		Label:new{x = 0.5, y = 2.75, label = fgettext("You need a provided account")}:render()

	if error_msg ~= "" then
		fs = fs .. StyleType:new{selectors = {"label"}, props = {"font=normal", "textcolor=red"}}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext(error_msg)}:render()
	end
	return fs
end

local function handle_whoareu_buttons(this, fields, tabname, tabdata)
	if (fields.key_enter or fields.btn_next) then
		if (fields.username ~= "") then
			whoareu = fields.username
			local passwd_dlg = create_passwd_dlg()
			passwd_dlg:set_parent(this)
			this:hide()
			passwd_dlg:show()
			return true
		end
	end

	if (fields.btn_back) then
		this:delete()
		return true
	end

	return false
end

function create_whoareu_dlg()
	return dialog_create("whoareu",
				get_whoareu_formspec,
				handle_whoareu_buttons,
				nil)
end

--------------------------------------------------------------------------------
--
-- Password dialog
--

local function get_passwd_formspec(tabview, _, tabdata)
	return FormspecVersion:new{version=6}:render() ..
		Size:new{w = 5.5, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("Welcome") .. " " .. whoareu}:render() ..
		Label:new{x = 0.5, y = 1.5, label = fgettext("Password:")}:render() ..
		PasswdField:new{x = 0.5, y = 1.75, w = 4.5, h = 0.7, name = "passwd", value = ""}:render() ..
		Button:new{x=0.5, y=3.25, w=2.2, h=0.75, name = "btn_back", label = fgettext("Back")}:render() ..

		-- Styled stuff
		StyleType:new{selectors = {"button"}, props = {"font=bold"}}:render() ..
		Button:new{x=2.8, y=3.25, w=2.2, h=0.75, name = "btn_play", label = fgettext("Play!")}:render()
end

local function handle_passwd_buttons(this, fields, tabname, tabdata)
	-- whoareu was 'test'
	-- fields.passwd was ''
	gamedata.playername = whoareu
	core.settings:set("name", whoareu)

	if fields.passwd ~= "" and (fields.key_enter or fields.btn_play) then
		-- Wiscom auth
		passwd = fields.passwd
		local response = http.fetch_sync({
			url = "https://wiscomsbeta.matematicasuperpiatta.it/wiscom/api/token/",
			timeout = 10,
			post_data = { username = whoareu, password = passwd },
		})

		if response.succeeded then
			core.log("info", "Payload is " .. response.data)
			local json = minetest.parse_json(response.data)
			if json ~= nil and json.access ~= nil then
				if handshake.roadmap.server ~= nil then
					if handshake.roadmap.server.ip == nil then
						local flavor_dlg = create_flavor_dlg()
						flavor_dlg:set_parent(this)
						this:hide()
						flavor_dlg:show()
					end

					-- inject refresh token. Server musts support this!
					local timeout = 95

					-- Minetest connection
					gamedata.playername = whoareu
					gamedata.password   = passwd
					gamedata.token      = json.refresh
					gamedata.access  	= json.access
					gamedata.selected_world = 0

					-- probably don't have these, yet
					gamedata.address    = '' --handshake.roadmap.server.ip or SERVER_ADDRESS
					gamedata.port       = '' --handshake.roadmap.server.port or handshake.spawnPort()

					core.settings:set("address",     "")
					core.settings:set("remote_port", "")

					-- set access token to the handshake
					handshake.token = gamedata.access

					-- debug roadmap
					debug_roadmap = core.write_json(handshake.roadmap)
					core.log("warning", "Roadmap: " .. debug_roadmap)

					wait_go(function(core, handshake, gamedata)
						gamedata.address    = handshake.roadmap.server.ip or SERVER_ADDRESS
						gamedata.port       = handshake.roadmap.server.port or handshake.spawnPort()

						-- debug
						core.log("warning", "ACCESS: " .. gamedata.access)
						core.log("warning", "ROADMAP: " .. core.write_json(handshake.roadmap))
						
						local http = core.get_http_api()
						local response = http.fetch_sync({
							url = "https://wiscomsbeta.matematicasuperpiatta.it/wiscom/api/users/me/server_info",
							extra_headers = {
								"Authorization: Bearer " .. gamedata.access,
								"Content-Type: application/json"
							},
							timeout = 10,
							post_data = core.write_json({
								server_info = handshake.roadmap.server_info,
								client_info = handshake.roadmap.client_info
							})
						})
						core.log("warning", "Log Response: " .. response.data)

						core.log("warning", gamedata.address .. ':' .. gamedata.port)
						core.start()
					end)
					return true
				end
			else
				error_msg = "Sorry. No access!"
			end
		else
			error_msg = "Login failed, try again"
		end
		local login_dlg = create_whoareu_dlg()
		login_dlg:set_parent(this)		login_dlg:set_parent(this)

		this:hide()
		login_dlg:show()
		return true
	end

	if fields.btn_back then
		this:delete()
		return true
	end

	return false
end

function create_passwd_dlg()
	return dialog_create("passwd",
				get_passwd_formspec,
				handle_passwd_buttons,
				nil)
end

--------------------------------------------------------------------------------
--
-- Flavor box
--

local function get_flavor_formspec(tabview, _, tabdata)
	local flavor = handshake.roadmap.messages ~= nil and
		handshake.roadmap.messages.news or
		{"Sapevi che", "Nel computer anche questo testo è rappresentato con dei numeri"}
	local waitingTime = handshake.roadmap.server ~= nil and
		handshake.roadmap.server["waiting_time"]+10 or 61
	waitingTime = math.min(61, waitingTime)
	return FormspecVersion:new{version=6}:render() ..
		Size:new{w = 12, h = 4.8, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("Loading in... ") .. waitingTime .. "''"}:render() ..
		TableColumns:new{ columns = { {"text"} } }:render() ..
		TableOptions:new{ options =	{"background=#00000000", "highlight=#00000000"}}:render() ..
		Table:new{ x = 0.5, y = 1, w = 11, h = 3.2, name = "news", cells = flavor}:render()
end

local function handle_nothing(this, fields, tabname, tabdata)
	core.log("warning", "You've to wait some more time")
	return false
end

function create_flavor_dlg()
	local dlg = dialog_create("flavor",
				get_flavor_formspec,
				handle_nothing,
				nil)
	return dlg
end
