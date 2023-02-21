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

	return FormspecVersion:new{version=6}:render() ..
	    -- Title
		Image:new{
			x=2.20, y=-0.4, w=7.68, h=3.17,
			path = defaulttexturedir .. "ms" .. DIR_DELIM .. "logo_320x132.png"}:render() ..

		Image:new{
			x=0.10, y=3.6, w=2, h=2,
			path = defaulttexturedir .. "ms" .. DIR_DELIM .."univaq_block_image_small.png"}:render() ..

		Label:new{x=2.5, y=4.5, label = fgettext("Spinoff dell'Università degli Studi dell'Aquila")}:render() ..
		StyleType:new{selectors = {"label"}, props = {"font=italic"}}:render() ..
		Label:new{x=2.5, y=4.9, label = fgettext("per informazioni: matematicasuperpiatta@gmail.com")}:render() ..

		-- Connect
		Style:new{selectors = {"btn_mp_connect"}, props = {"bgcolor=#FF7F00", "font=bold", "alpha=false"}}:render() ..
		Button:new{x=9, y=4.2, w=2.5, h=1.75, name = "btn_mp_connect", label = fgettext("Connect")}:render()
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

local function main_button_handler(tabview, fields, name, tabdata)
	if (fields.btn_mp_connect or fields.key_enter) then
		local whoareu_dlg = create_whoareu_dlg()
		whoareu_dlg:set_parent(this)
		tabview:hide()
		whoareu_dlg:show()
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
