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
		Image:new{
			x=2.20, y=-0.4, w=7.68, h=3.17,
			path = defaulttexturedir .. "ms" .. DIR_DELIM .. "logo_320x132.png"}:render() ..

		Image:new{
			x=0.10, y=3.6, w=2, h=2,
			path = defaulttexturedir .. "ms" .. DIR_DELIM .."univaq_block_image_small.png"}:render() ..

		Label:new{x=2.5, y=4.5, label = fgettext("Spinoff dell'Università degli Studi dell'Aquila")}:render()

	if ms_mainmenu.update.update.required then
		-- Update
		fs = fs .. StyleType:new{selectors = {"label"}, props = {"font=bold"}}:render() ..
			Label:new{x=2.5, y=2.5, label = fgettext(ms_mainmenu.update.update.message)}:render() ..

			Style:new { selectors = { "btn_mp_update" }, props = { "bgcolor=#FF7F00", "font=bold", "alpha=false" } }:render() ..
			Button:new { x = 9, y = 4.2, w = 2.5, h = 1.75, name = "btn_mp_update", label = fgettext("Update") }:render()
	else
		if ms_mainmenu.update.update.pending then
			fs = fs .. StyleType:new{selectors = {"label"}, props = {"font=bold"}}:render() ..
			Label:new{x=2.5, y=2.5, label = fgettext(ms_mainmenu.update.update.message)}:render() ..

			Style:new { selectors = { "btn_mp_update" }, props = { "font=bold" } }:render() ..
			Button:new { x = 9, y = 3.2, w = 2.5, h = 1.75, name = "btn_mp_update", label = fgettext("Update") }:render()
		end
		-- Connect
		fs = fs .. Style:new{selectors = {"btn_mp_connect"}, props = {"bgcolor=#FF7F00", "font=bold", "alpha=false"}}:render() ..
			Button:new{x=9, y=4.2, w=2.5, h=1.75, name = "btn_mp_connect", label = fgettext("Connect")}:render()
	end
	return fs .. StyleType:new{selectors = {"label"}, props = {"font=italic"}}:render() ..
			Label:new{x=2.5, y=4.9, label = fgettext("per informazioni: matematicasuperpiatta@gmail.com")}:render()
end

--------------------------------------------------------------------------------

local function main_button_handler(tabview, fields, name, tabdata)
	if fields.key_enter then
		fields.btn_mp_update = ms_mainmenu.update.update.required
		fields.btn_mp_connect = not fields.btn_mp_update
	end

	if fields.btn_mp_connect then
		if ms_mainmenu.update.version ~= null and ms_mainmenu.update.version >= 0.9 then
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
		core.open_url(ms_mainmenu.update.update.url)
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
