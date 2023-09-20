--[[
Create a popup window with a custom message and a single buttom: 'ok'.
When player click the buttom, client kill himself.
]]--
-- Lambda Error
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

-- Required new version error
local function get_required_version_formspec(tabview, _, tabdata)
	local fs = FormspecVersion:new{version=6}:render() ..
		Size:new{w = 10, h = 4.5, fix = true}:render() ..
		Label:new{x = 0.5, y = 0.5, label = fgettext("Update the app to play!")}:render() ..
		Button:new{x=5 - 1.1, y=3.25, w=2.2, h=0.75, name = "btn_quit", label = fgettext("Quit")}:render()
	return fs
end

local function handle_required_version_buttons(this, fields, tabname, tabdata)
	if (fields.key_enter or fields.btn_quit) then
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
end

function create_required_version_dlg()
	return dialog_create("requiredVersion",
				get_required_version_formspec,
				handle_required_version_buttons,
				nil)
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
