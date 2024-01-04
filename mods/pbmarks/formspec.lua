
--- Personal Bookmarks Formspec
--
--  @module formspec.lua


local S = core.get_translator(pbmarks.modname)


local player_flags = {}


--- Retrieves formspec formatted string for this mod.
--
--  Usable flags:
--
--    - version (number) formspec version (default: 4)
--    - noversion (boolean) no formspec version (overrides "version")
--    - width (number) formspec width
--    - height (number) formspec height
--    - noback (boolean) show "close" button instead of "back"
--
--  @tparam string pname Player name referenced for bookmarks.
--  @tparam table flags Custom flags to set for formspec layout.
--  @treturn string Formatted string.
function pbmarks.get_formspec(pname, flags)
	flags = flags or {}
	if not flags.version then
		flags.version = 4
	end
	if not flags.width then
		flags.width = 10
	end
	if not flags.height then
		flags.height = 8
	end

	local formspec = ""

	if not flags.noversion then
		formspec = "formspec_version[" .. flags.version .. "]"
	end

	formspec = formspec
		.. "size[" .. tostring(flags.width) .. "," .. tostring(flags.height) .. "]"

	if flags.noback then
		player_flags[pname] = {noback=true}

		formspec = formspec
		.. "button_exit[0.5,0.25;1.5,0.75;btn_back;" .. S("Close") .. "]"
	else
		formspec = formspec
		.. "button[0.5,0.25;1.5,0.75;btn_back;" .. S("Back") .. "]"
	end

	formspec = formspec
		.. "label[2.25,0.65;" .. S("Personal Bookmarks") .. "]"

	local init_y = 1.5 -- horizontal position of first bookmark
	for idx = 1, pbmarks.max do
		local pbm = pbmarks.get(pname, idx) or {}
		local label = pbm.label or ""
		local pos = pbm.pos or ""
		if type(pos) == "table" then
			pos = tostring(pos.x) .. "," .. tostring(pos.y) .. "," .. tostring(pos.z)
		end

		local fname = "input" .. tostring(idx)
		local btn_go = "btn_go" .. tostring(idx)
		local btn_set = "btn_set" .. tostring(idx)
		formspec = formspec
			.. "field[0.5," .. tostring(init_y) .. ";3,0.75;" .. fname .. ";;" .. label .. "]"
			.. "field_close_on_enter[" .. fname .. ";false]"
			.. "label[3.75," .. tostring(init_y) + 0.25 .. ";" .. core.formspec_escape(pos) .. "]"
			.. "button[6.25," .. tostring(init_y) .. ";1.5,0.75;" .. btn_go .. ";" .. S("Go") .. "]"
			.. "button[8," .. tostring(init_y) .. ";1.5,0.75;" .. btn_set .. ";" .. S("Set") .. "]"

		init_y = init_y + 1.25
	end

	return formspec
end

--- Displays formspec for managing bookmarks.
--
--  @tparam string pname Player name referenced for bookmarks & who will be shown formspec.
--  @tparam table flags see: `pbmarks.get_formspec`
function pbmarks.show_formspec(pname, flags)
	core.show_formspec(pname, pbmarks.modname, pbmarks.get_formspec(pname, flags))
end


core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == pbmarks.modname then
		local pname = player:get_player_name()

		if fields.quit then
			player_flags[pname] = nil
			return
		end

		if fields.btn_back then
			core.show_formspec(player:get_player_name(), "", player:get_inventory_formspec())
			return
		end

		local idx
		local go = false
		local set = false
		for x = 1, pbmarks.max do
			if fields["btn_go" .. tostring(x)] then
				go = true
				idx = x
			elseif fields["btn_set" .. tostring(x)] then
				set = true
				idx = x
			end

			if idx then break end
		end

		local pbm = pbmarks.get(pname, idx) or {}

		if go then
			if not pbm.pos then
				core.chat_send_player(pname, S("This bookmark is not set."))
				return
			end

			core.close_formspec(pname, pbmarks.modname)

			pbm.pos.y = pbm.pos.y + 0.5 -- make sure we don't get stuck in the ground
			player:set_pos(pbm.pos)
		elseif set then
			local label = (fields["input" .. tostring(idx)] or ""):trim()
			if label == "" then
				-- unset
				if pbm.pos then
					pbmarks.unset(pname, idx)
					core.chat_send_player(pname, S("Unset bookmark at @1,@2,@3.", pbm.pos.x, pbm.pos.y, pbm.pos.z))
					pbmarks.show_formspec(pname, player_flags[pname])
				else
					core.chat_send_player(pname, S("You must choose a label to set this bookmark."))
				end

				return
			end

			local pos = player:get_pos()
			pos.x = math.floor(pos.x)
			pos.y = math.floor(pos.y)
			pos.z = math.floor(pos.z)

			pbmarks.set(pname, idx, label, pos)
			pbmarks.show_formspec(pname, player_flags[pname])
		end
	end
end)
