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

--
-- Utils
--

local http = core.get_http_api()

local function spawnPort()
--  GET PORT NUMBER BY HTTP REQUEST - START
	local response = http.fetch_sync({ url = URL_GET })
        if not response.succeeded then
					-- lazy debug (but also) desperate choice
                return 30000
        end

--  GET PORT NUMBER BY HTTP REQUEST - END
	return tonumber(response.data)
end


--------------------------------------------------------------------------------
--
-- Username dialog
--

local function get_whoareu_formspec(tabview, _, tabdata)
	return FormspecVersion:new{version=6}:render() ..
		Size:new{w = 5.5, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 1, label = fgettext("Username:")}:render() ..
		Field:new{x = 0.5, y = 1.25, w = 4.5, h = 0.7, name = "username", value = whoareu}:render() ..
		-- Button:new{x=0.5, y=2.25, w=3.5, h=0.75, name = "btn_unsafe_next", label = fgettext("Someone look at me")}:render() ..
		Button:new{x=0.5, y=3.25, w=2.2, h=0.75, name = "btn_back", label = fgettext("Back")}:render() ..
		Button:new{x=2.8, y=3.25, w=2.2, h=0.75, name = "btn_next", label = fgettext("Next")}:render() ..

		-- Styled stuff
		StyleType:new{selectors = {"label"}, props = {"font=italic"}}:render() ..
		Label:new{x = 0.5, y = 2.25, label = fgettext("You need a provided account")}:render()
end

local function handle_whoareu_buttons(this, fields, tabname, tabdata)
	if (fields.btn_next or fields.key_enter) then
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
	local dlg = dialog_create("whoareu",
				get_whoareu_formspec,
				handle_whoareu_buttons,
				nil)
	return dlg
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

	if (fields.btn_play or fields.key_enter) then
		gamedata.playername = whoareu
		gamedata.password   = fields.passwd
		gamedata.address    = SERVER_ADDRESS
		gamedata.port       = spawnPort()

		gamedata.selected_world = 0

		core.settings:set("address",     "")
		core.settings:set("remote_port", "")

		core.start()
		return true
	end

	if (fields.btn_back) then
		this:delete()
		return true
	end

	return false
end

function create_passwd_dlg()
	local dlg = dialog_create("passwd",
				get_passwd_formspec,
				handle_passwd_buttons,
				nil)
	return dlg
end

--
-- Maybe obsolete
--
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

