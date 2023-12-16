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

local is_windows = (nil ~= string.find(defaulttexturedir, "\\"))
local texturedir = defaulttexturedir
if is_windows then
	core.log("info", "Windows release")
    texturedir = string.gsub(defaulttexturedir, "\\", "\\\\")
end

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
			path = texturedir .. "logo_320x132.png"}:render() ..
		Image:new{
			x=4.15, y=2.5, w=3, h=0.378,
			path = texturedir .. "menu_header.png"}:render() ..

		Image:new{
			x=0.10, y=3.6, w=2, h=2,
			path = texturedir .."univaq_block_image_small.png"}:render() ..

		Label:new{x=4.9, y=2, label = fgettext("based on")}:render() ..
		Label:new{x=2, y=4.1, label = fgettext("Università degli Studi of L'Aquila")}:render() ..
		Label:new{x=2, y=4.5, label = fgettext("spin-off")}:render() .. Style:new{
			selectors = {"btn_mp_connect"},
			props = {"bgcolor=#00dc28", "font=bold", "alpha=false"} --orig: #00993b
		}:render() ..
		Button:new{x=9, y=4.2, w=2.5, h=1.75, name = "btn_mp_connect", label = fgettext("Start")}:render()
	return fs .. StyleType:new{selectors = {"label"}, props = {"font=italic"}}:render() ..
	Label:new{x=2, y=4.9, label = fgettext("www.matematicasuperpiatta.it")}:render()
end

--------------------------------------------------------------------------------

local function main_button_handler(tabview, fields, name, tabdata)
	if fields.key_enter then
		fields.btn_mp_update = handshake.roadmap.client_update.required
		fields.btn_mp_connect = not fields.btn_mp_update
	end

	if fields.btn_mp_debug then
		core.log("warning", "Update pending")
		local error_dlg = create_pending_version_dlg()
		ui.cleanup()
		error_dlg:show()
		ui.update()
		return true
	end

	if fields.btn_mp_connect then
		local whoareu_dlg = create_whoareu_dlg()
		--tabview:hide()
		ui.cleanup()
		whoareu_dlg:show()
		ui.update()
		return true
	end

	if fields.btn_mp_update then
		core.open_url(handshake.roadmap.client_update.url)
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
