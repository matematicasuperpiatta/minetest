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

local function get_formspec(tabview, name, tabdata)
	-- Update the cached supported proto info,
	-- it may have changed after a change by the settings menu.
	common_update_cached_supp_proto()

	if not tabdata.search_for then
		tabdata.search_for = ""
	end

	local fs = FormspecVersion:new{version=6}:render() ..
	    -- Title
		-- “image[2.2,0.3;7.68,3.17;” .. core.formspec_escape(defaulttexturedir .. “logo_320x132.png”)..“]”..
		Image:new{
			x=2.20, y=-0.4, w=7.68, h=3.17,
			path = defaulttexturedir .. "logo_320x132.png"}:render() ..
		Image:new{
			x=4.15, y=2.1, w=3, h=0.378,
			path = defaulttexturedir .. "menu_header.png"}:render() ..

		Image:new{
			x=0.10, y=3.6, w=2, h=2,
			path = defaulttexturedir .."univaq_block_image_small.png"}:render() ..

		Label:new{x=4.9, y=1.7, label = fgettext("based on")}:render() ..
		Label:new{x=2, y=4.1, label = fgettext("Università degli Studi of L'Aquila")}:render() ..
		Label:new{x=2, y=4.5, label = fgettext("Spinoff")}:render()

	if ms_mainmenu.remote.client_update.required then
		-- Update
		fs = fs .. StyleType:new{selectors = {"label"}, props = {"font=bold"}}:render() ..
			Label:new{x=2.5, y=2.5, label = fgettext(ms_mainmenu.remote.client_update.message)}:render() ..

			Style:new { selectors = { "btn_mp_update" }, props = { "bgcolor=#FF7F00", "font=bold", "alpha=false" } }:render() ..
			Button:new { x = 9, y = 4.2, w = 2.5, h = 1.75, name = "btn_mp_update", label = fgettext("Update") }:render()
	else
		if ms_mainmenu.remote.client_update.pending then
			fs = fs .. StyleType:new{selectors = {"label"}, props = {"font=bold"}}:render() ..
			Label:new{x=2.5, y=2.5, label = fgettext(ms_mainmenu.remote.client_update.message)}:render() ..

			Style:new { selectors = { "btn_mp_update" }, props = { "font=bold" } }:render() ..
			Button:new { x = 9, y = 3.2, w = 2.5, h = 1.75, name = "btn_mp_update", label = fgettext("Update") }:render()
		end
		-- Connect
		fs = fs .. Style:new{
			selectors = {"btn_mp_connect"},
			props = {"bgcolor=#FF7F00", "font=bold", "alpha=false"}
		}:render() ..
			Button:new{x=9, y=4.2, w=2.5, h=1.75, name = "btn_mp_connect", label = fgettext("Start")}:render()
	end
	return fs .. StyleType:new{selectors = {"label"}, props = {"font=italic"}}:render() ..
	Label:new{x=2, y=4.9, label = fgettext("more info: matematicasuperpiatta@gmail.com")}:render()
	-- .. ImageButton:new{x=3.6, y=4.9, w=0.6, h=0.6, path=defaulttexturedir .."envelope.png", name="btn_email"}:render()
end

--------------------------------------------------------------------------------

local function main_button_handler(tabview, fields, name, tabdata)
	if fields.key_enter then
		fields.btn_mp_update = ms_mainmenu.remote.client_update.required
		fields.btn_mp_connect = not fields.btn_mp_update
	end

	if fields.btn_mp_connect then
		if ms_mainmenu.remote.server.server_version ~= nil and ms_mainmenu.remote.server.server_version >= "1.0" then
			local whoareu_dlg = create_whoareu_dlg()
			-- whoareu_dlg:set_parent(this)
			tabview:hide()
			whoareu_dlg:show()
		else
			-- legacy server. Pseudologin
			ms_mainmenu:play("test", "")
		end
		return true
	end

	if fields.btn_mp_update then
		core.open_url(ms_mainmenu.remote.client_update.url)
		return true
	end

	if fields.btn_email then
		core.open_url("mailto:matematicasuperpiatta@gmail.com")
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
