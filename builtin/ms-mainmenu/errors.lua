--[[
Create a popup window with a custom message and a single buttom: 'ok'.
When player click the buttom, client kill himself.
]]--
local function get_fatal_error_formspec(tabview, _, tabdata)
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = 10, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("Connection Error!\nPlease restart.")}:render() ..
		Button:new{x=5 - 1.1, y=3.25, w=2.2, h=0.75, name = "btn_quit", label = fgettext("Quit")}:render()
	return fs
end

local function handle_fatal_error_buttons(this, fields, tabname, tabdata)
	if (fields.key_enter or fields.btn_quit) then
		core.close()
	end
end

function create_fatal_error_dlg()
	return dialog_create("fatalError",
				get_fatal_error_formspec,
				handle_fatal_error_buttons,
				nil)
end
