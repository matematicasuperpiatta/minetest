--[[
Create a popup window with a custom message and a single buttom: 'ok'.
When player click the buttom, client kill himself.
]]--
-- Lambda Error
local function get_fatal_error_formspec(tabview, _, tabdata)
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = 10, h = 4.5, fix = true}:render() ..
		--Label:new{x = 0.5, y = 0.5, label = fgettext("Connection Error!\nPlease restart.")}:render() ..
		Label:new{x = 0.5, y = 0.5, label = global_data.message_text}:render() ..
		Button:new{x=5 - 1.1, y=3.25, w=2.2, h=0.75, name = "btn_quit", label = fgettext("Quit")}:render()
	return fs
end

local function handle_fatal_error_buttons(this, fields, tabname, tabdata)
	if (fields.key_enter or fields.btn_quit) then
		core.close()
	end
end

local function handle_fatal_error_event(self, event)
	-- https://github.com/minetest/minetest/blob/master/builtin/fstk/dialog.lua#L18
	-- do nothing
end

function create_fatal_error_dlg()
	return dialog_create("fatalError",
				get_fatal_error_formspec,
				handle_fatal_error_buttons,
				handle_fatal_error_event)
end

-- Required new version error
local function get_required_version_formspec(tabview, _, tabdata)
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = 10, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("The version of Superflat Math needs an update!\nPlease download and install new version from the website.")}:render() ..
		Button:new{x=5 - 1.1 -2, y=3.25, w=2.2, h=0.75, name = "btn_update", label = fgettext("Update")}:render() ..
		Button:new{x=5 - 1.1 +2, y=3.25, w=2.2, h=0.75, name = "btn_quit", label = fgettext("Quit")}:render()
	return fs
end

local function handle_required_version_buttons(this, fields, tabname, tabdata)
	if (fields.key_enter or fields.btn_update) then
		local separator = package.config:sub(1,1)
		local cmd = ""
		if separator == '\\' then
			cmd = "start "
		else
			cmd = "xdg-open "
		end
		local url = "https://www.matematicasuperpiatta.it/gioco"
		os.execute(cmd .. url)
		this:delete()
		core.close()
		return true
	elseif (fields.btn_quit) then
		core.close()
	end
end

local function handle_required_version_event(self, event)
	-- https://github.com/minetest/minetest/blob/master/builtin/fstk/dialog.lua#L18
	-- do nothing
end

function create_required_version_dlg()
	return dialog_create("requiredVersion",
				get_required_version_formspec,
				handle_required_version_buttons,
				handle_required_version_event)
end

-- Pending new version error
local function get_pending_version_formspec(tabview, _, tabdata)
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = 8, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("New version is available!")}:render() .. -- Trova il modo di metterci il messaggio tornato dalla lambda
		Button:new{x=4 - 1.1, y=2.25, w=2.2, h=0.75, name = "btn_update", label = fgettext("Update")}:render() ..
		Button:new{x=4 - 1.1, y=3.25, w=2.2, h=0.75, name = "btn_continue", label = fgettext("Continue")}:render()
	return fs
end

local function handle_pending_version_buttons(this, fields, tabname, tabdata)
	if (fields.btn_continue) then
		this:delete()
		return true
	end

	if (fields.btn_update) then
		local separator = package.config:sub(1,1)
		local cmd = ""
		if separator == '\\' then
			cmd = "start "
		else
			cmd = "xdg-open "
		end
		local url = "https://www.matematicasuperpiatta.it/gioco"
		os.execute(cmd .. url)
		this:delete()
		core.close()
		return true
	end
	return false
end

function create_pending_version_dlg()
	return dialog_create("pendingVersion",
				get_pending_version_formspec,
				handle_pending_version_buttons,
				nil)
end

function display_fatal_error()
	local error_dlg = create_fatal_error_dlg()
	ui.cleanup()
	error_dlg:show()
	ui.update()
end

function display_required_version_error()
	local error_dlg = create_required_version_dlg()
	ui.cleanup()
	error_dlg:show()
	ui.update()
end
