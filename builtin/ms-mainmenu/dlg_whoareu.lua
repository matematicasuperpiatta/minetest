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
	local bkg_w = 7.5
	local btn_w = 2.2
	local btn_halign_right = true
	local btn_abs_x = 0.5
	if btn_halign_right  then
		btn_abs_x = bkg_w - (0.5 + btn_w * 2 + 0.1)
	end
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = bkg_w, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 1.5, label = fgettext("Username:")}:render() ..
		-- see here to edit field color
		-- https://github.com/minetest/minetest/blob/8c7276c9d4fc8afa05f859297048c7153cc11f5b/src/client/clientlauncher.cpp#L176
		StyleType:new{selectors = {"field"}, props = {"textcolor=#ffffff"}}:render() ..
		Field:new{x = 0.5, y = 1.75, w = bkg_w - 1.0, h = 0.7, name = "username", value = whoareu}:render() ..
		StyleType:new{selectors = {"button"}, props = {"bgcolor=#ffa900", "alpha=false"}}:render() .. --orig: #ff8000
		Button:new{x=btn_abs_x, y=3.25, w=btn_w, h=0.75, name = "btn_back", label = fgettext("Back")}:render() ..
		StyleType:new{selectors = {"button"}, props = {"bgcolor=#00dc28", "alpha=false"}}:render() .. --orig: #00993b
		Button:new{x=btn_abs_x + btn_w + 0.1, y=3.25, w=btn_w, h=0.75, name = "btn_next", label = fgettext("Next")}:render() ..

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

local function is_student(username)
	local syntax = "A?AA0A00"
	if #username == #syntax then
		local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local numbers = "0123456789"
		for i = 1, #username do
			local ch = string.sub(username, i, i)
			local constraint = string.sub(syntax, i, i)
			local belonging_set
			if constraint == "A" then
				belonging_set = letters
			elseif constraint == "0" then
				belonging_set = numbers
			elseif constraint == "?" then
				belonging_set = letters .. numbers
			end
			if not string.find(belonging_set, ch) then
				return false
			end
		end
		return true
	else
		return false
	end
end

local function hide_password(username)
	return not is_student(username)
end

local function get_passwd_formspec(tabview, _, tabdata)
	local bkg_w = 7.5
	local btn_w = 2.2
	local btn_halign_right = true
	local btn_abs_x = 0.5
	if btn_halign_right  then
		btn_abs_x = bkg_w - (0.5 + btn_w * 2 + 0.1)
	end
	if hide_password(whoareu) then
		core.log("Hide password of " .. whoareu)
		return FormspecVersion:new{version=6}:render() ..
			Size:new{w = bkg_w, h = 4.5, fix = true}:render() ..
			Label:new{x = 0.5, y = 0.5, label = fgettext("Welcome") .. " " .. whoareu}:render() ..
			Label:new{x = 0.5, y = 1.5, label = fgettext("Password:")}:render() ..
			PasswdField:new{x = 0.5, y = 1.75, w = bkg_w - 1.0, h = 0.7, name = "passwd", value = ""}:render() ..
			StyleType:new{selectors = {"button"}, props = {"bgcolor=#ffa900", "alpha=false"}}:render() ..
			Button:new{x=btn_abs_x, y=3.25, w=btn_w, h=0.75, name = "btn_back", label = fgettext("Back")}:render() ..

			-- Styled stuff
			StyleType:new{selectors = {"button"}, props = {"font=bold", "bgcolor=#00dc28", "alpha=false"}}:render() ..
			Button:new{x=btn_abs_x + btn_w + 0.1, y=3.25, w=btn_w, h=0.75, name = "btn_play", label = fgettext("Play!")}:render()
	else
		core.log("Show password of " .. whoareu)
		return FormspecVersion:new{version=6}:render() ..
			Size:new{w = bkg_w, h = 4.5, fix = true}:render() ..
			Label:new{x = 0.5, y = 0.5, label = fgettext("Welcome") .. " " .. whoareu}:render() ..
			Label:new{x = 0.5, y = 1.5, label = fgettext("Password:")}:render() ..
			Field:new{x = 0.5, y = 1.75, w = bkg_w - 1.0, h = 0.7, name = "passwd", value = ""}:render() ..
			StyleType:new{selectors = {"button"}, props = {"bgcolor=#ffa900", "alpha=false"}}:render() ..
			Button:new{x=btn_abs_x, y=3.25, w=btn_w, h=0.75, name = "btn_back", label = fgettext("Back")}:render() ..

			-- Styled stuff
			StyleType:new{selectors = {"button"}, props = {"font=bold", "bgcolor=#00dc28", "alpha=false"}}:render() ..
			Button:new{x=btn_abs_x + btn_w + 0.1, y=3.25, w=btn_w, h=0.75, name = "btn_play", label = fgettext("Play!")}:render()
	end
end

local function handle_passwd_buttons(this, fields, tabname, tabdata)
	--gamedata.playername = whoareu
	--core.settings:set("name", whoareu)

	if fields.passwd ~= "" and (fields.key_enter or fields.btn_play) then
		-- Wiscom auth
		passwd = fields.passwd
		local response = http.fetch_sync({
			url = WISCOMS_URL .. "/api/token/",
			timeout = 10,
			post_data = { username = whoareu, password = passwd },
		})
		core.log("wiscom answer: " .. tostring(response.code))
		if response == nil or response.code == 0 then
			if string.find(whoareu, "demo") then
				response = http.fetch_sync({
					url = WISCOMS_URL_LOCAL .. "/api/token/",
					timeout = 10,
					post_data = { username = whoareu, password = passwd },
				})
			end
		end

		if response.succeeded then
			core.log("info", "Payload is " .. response.data)
			local json = minetest.parse_json(response.data)
			error_msg = handle_connection(json, whoareu, passwd)
			if error_msg == '' then
				return true
			end
		else
			core.log("warning", "Error calling lambdaClient")
			local error_dlg = create_fatal_error_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()
			return true
		end

		local login_dlg = create_whoareu_dlg()
		login_dlg:set_parent(this)
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
		handshake.roadmap.server["waiting_time"] or 60
	waitingTime = math.min(60, waitingTime)
	return FormspecVersion:new{version=6}:render() ..
		Size:new{w = 12, h = 4.8, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("Loading in... ") .. tostring(waitingTime) .. " " .. fgettext("seconds")}:render() ..
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


--------------------------------------------------------------------------------
--
-- Handle connection
--

function handle_connection(json, user, pass)
    if json ~= nil and json.access ~= nil then
        if handshake.roadmap.server ~= nil then
            -- inject refresh token. Server musts support this!
            local timeout = 95

            -- Minetest connection
            gamedata.playername = user --whoareu
            gamedata.password   = pass --passwd
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
			handshake.is_demo_user = string.find(whoareu, "demo")

            wait_go(
				function(core, handshake, gamedata)
					gamedata.address    = handshake.roadmap.server.ip
					gamedata.port       = handshake.roadmap.server.port

					-- debug
					--core.log("warning", "ACCESS: " .. gamedata.access)
					--core.log("warning", "ROADMAP: " .. core.write_json(handshake.roadmap))
					local http = core.get_http_api()
					local extra_headers = {
						"Authorization: Bearer " .. gamedata.access,
						"Content-Type: application/json"
					}
					local post_data = core.write_json({
						server_info = handshake.roadmap.server_info,
						client_info = handshake.roadmap.client_info
					})
					local url = handshake.wiscoms_url .. "/api/users/me/server_info"
				    local response = http.fetch_sync({
						url = url,
						extra_headers = extra_headers,
						timeout = 10,
						post_data = post_data
					})
					if response == nil or response.code == 0 then
						if handshake.is_demo_user then
							url = handshake.wiscoms_url_local .. "/api/users/me/server_info"
							local response = http.fetch_sync({
								url = url,
								extra_headers = extra_headers,
								timeout = 10,
								post_data = post_data
							})
						end
					end
					core.log("warning", gamedata.address .. ':' .. gamedata.port)
					core.start()
				end)
            return ""
        end
	end
	return "Login failed, try again"
end

-- update flavor text with the new waiting_time
function update_flavor()
	local flavor_dlg = create_flavor_dlg()
	ui.cleanup()
	flavor_dlg:show()
	ui.update()
end
