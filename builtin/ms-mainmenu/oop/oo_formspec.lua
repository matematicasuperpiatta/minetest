
function btos(b)
	return b and "true" or "false"
end

--
-- abstract Component
--
Component = {_sep = ','}

function Component:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Component:_withSep(sep)
	self._sep = sep
	return self
end

function Component:_list(o)
	if (#o == 0) then
		return ""
	end
	return table.concat(o, self._sep)
end

function Component:_compose(name, rendered)
	return string.format("%s[%s]", name, rendered)
end

--
-- concrete FormspecVersion
--
FormspecVersion = Component:new{version = 6}

function FormspecVersion:render()
	return self:_compose("formspec_version", self.version)
end

--
-- concrete Size
--
Size = Component:new{w = 0, h = 0, fix=false}

function Size:render()
	return self:_compose( "size", string.format("%g,%g,%s", self.w, self.h, btos(self.fix)))
end

--
-- abstract Point
--
Point = Component:new{_name = "abstract", x = 0, y = 0}

function Point:_partial()
	return string.format("%g,%g", self.x, self.y)
end

function Point:render()
	return self:_compose( self._name, self:_partial())
end

--
-- concrete Position
--
Position = Point:new{_name = "position", x = 0, y = 0}

--
-- concrete Anchor
--
Anchor = Point:new{_name = "anchor", x = 0.5, y = 0.5}

--
-- concrete Padding
--
Padding = Point:new{_name = "padding", x = 0.05, y = 0.05}

--
-- concrete NoPrepend
--
NoPrepend = Component:new{}

function NoPrepend:render()
	return self:_compose("no_prepend", "")
end

--
-- concrete RealCoordinates
--
RealCoordinates = Component:new{enable = true}

function RealCoordinates:render()
	return self:_compose("real_coordinates", btos(self.enable))
end

--
-- concrete Container
--
Container = Point:new{_name = "container", x = 0, y = 0, elements = {}}

function Container:_render(buf)
	local i = 1
	while self.elements[i] do
		buf = buf .. self.elements[i].render(self.elements[i])
		i = i+1
	end
	return buf .. string.format("%s_end[]", self._name)
end

function Container:render()
	return self:_render(Point.render(self))
end

--
-- abstract Tetragon
--
Tetragon = Point:new{_name = "abstract", x = 0, y = 0, w = 0, h = 0}

function Tetragon:_partial()
	return string.format("%s;%g,%g", Point._partial(self), self.w, self.h)
end

--
-- concrete ScrollContainer
--

ScrollContainer = Container:new{
	_name = "scroll_container",
	x = 0, y = 0, w = 0, h = 0, name = "", orientation = "vertical", factor = 0.1, elements = {}}

function ScrollContainer:render()
	return self:_render(self:_compose(
		"scroll_container",
		string.format(
			"%g,%g;%g,%g;%s;%s;%g",
			self.x, self.y, self.w, self.h, self.name, self.orientation, self.factor)
	))
end

--
-- concrete List
--

List = Tetragon:new{inv_loc = "", name = "", x = 0, y = 0, w = 0, h = 0, idx = 1}

function List:render()
	return self:_compose( "list", string.format("%s;%s;%s;%d", self.inv_loc, self.name, self:_partial(), self.idx))
end

--
-- concrete VoidListring
--
VoidListring = Component:new()

function VoidListring:render()
	return "listring[]"
end

--
-- concrete Listring
--
Listring = Component:new{inv_loc = "", name = ""}

function Listring:render()
	return self:_compose( "listring", string.format("%s;%s", self.inv_loc, self.name))
end

--
-- concrete Listcolors
--
Listcolors = Component:new{bg_normal = "", bg_hover = "", border = false, bg_tooltip = false, fontcolor_tooltip = false}

function Listcolors:render()
	local buf
	if (self.bg_tooltip) then
		buf = string.format(
			"%s;%s;%s;%s;%s",
			self.bg_normal, self.bg_hover, self.border, self.bg_tooltip, self.fontcolor_tooltip)
	elseif (self.border) then
		buf = string.format("%s;%s;%s", self.bg_normal, self.bg_hover, self.border)
	else
		buf = string.format("%s;%s", self.bg_normal, self.bg_hover)
	end
	return self:_compose( "listcolors", buf)
end

--
-- concrete Tooltip
--
Tooltip = Tetragon:new{
	x = false, y = false, w = false, h = false,
	name = false, text = "", bgcolor = false, fontcolor = false}

function Tooltip:_common()
	if (self.fontcolor) then
		return string.format("%s;%s;%s", self.text, self.bgcolor, self.fontcolor)
	elseif (self.bgcolor) then
		return string.format("%s;%s", self.text, self.bgcolor)
	else
		return string.format("%s", self.text)
	end
end

function Tooltip:render()
	local buf
	if (self.name) then
		buf = string.format("%s;%s", self.name, self:_common())
	else
		buf = string.format("%s;%s", self:_partial(), self:_common())
	end
	return self:_compose( "tooltip", buf)
end

--
-- concrete Image
--
Image = Tetragon:new{x = 0, y = 0, w = 0, h = 0, path = "", middle = false}

function Image:render()
	local buf
	if (self.middle) then
		buf = string.format("%s;%s;%s", self:_partial(), self.path, self.middle)
	else
		buf = string.format("%s;%s", self:_partial(), self.path)
	end
	return self:_compose( "image", buf)
end

--
-- concrete AnimatedImage
--
AnimatedImage = Tetragon:new{
	x = 0, y = 0, w = 0, h = 0,
	name = "", path = "", fr_count = 1, fr_duration = 40, fr_start = 1, middle = false}

function AnimatedImage:render()
	local buf
	if (self.middle) then
		buf = string.format(
			"%s;%s;%s;%g,%g,%g;%s",
			self:_partial(), self.name, self.path, self.fr_count, self.fr_duration, self.fr_start, self.middle)
	else
		buf = string.format(
			"%s;%s;%s;%g,%g,%g",
			self:_partial(), self.name, self.path, self.fr_count, self.fr_duration, self.fr_start)
	end
	return self:_compose( "image", buf)
end

--
-- TODO concrete Model
--

--
-- concrete ItemImage
--
ItemImage = Component:new{x = 0, y = 0, w = 0, h = 0, name = ""}

function ItemImage:render()
	return self:_compose(
		"item_image", string.format("%d,%d;%d,%d;%s", self.x, self.y, self.w, self.h, self.name))
end

--
-- concrete BGColor
--
BGColor = Component:new{color = "", fullscreen = false, fcolor = false}

function BGColor:render()
	local buf = self.color
	if (self.fullscreen) then
		buf = string.format("%s;%s", buf, self.fullscreen)
	end
	if (self.fcolor) then
		buf = string.format("%s;%s%s", buf, self.fullscreen and '' or ';', self.fcolor)
	end
	return self:_compose( "bgcolor", buf)
end

--
-- concrete Background
--
Background = Component:new{x = 0, y = 0, w = 0, h = 0, name = "", autoclip = false}

function Background:render()
	local buf
	if (self.autoclip) then
		buf = string.format("%d,%d;%d,%d;%s,%s", self.x, self.y, self.w, self.h, self.name, btos(self.autoclip))
	else
		buf = string.format("%d,%d;%d,%d;%s", self.x, self.y, self.w, self.h, self.name)
	end
	return self:_compose( "background", buf)
end

--
-- concrete PasswdField
--
PasswdField = Tetragon:new{x = 0, y = 0, w = 0, h = 0, name = "", label = ""}

function PasswdField:render()
	return self:_compose( "pwdfield", string.format("%s;%s;%s", self:_partial(), self.name, self.label))
end

--
-- abstract Text
--
Text = Tetragon:new{x = 0, y = 0, w = 0, h = 0, name = "", label = "", value = ""}

function Text:_render()
	return string.format("%s;%s;%s;%s", self:_partial(), self.name, self.label, self.value)
end

--
-- concrete Field
--
Field = Text:new{x = 0, y = 0, w = 0, h = 0, name = "", label = "", value = ""}

function Field:render()
	return self:_compose( "field", self:_render())
end

--
-- concrete MonoField
--
MonoField = Component:new{name = "", label = "", value = ""}

function MonoField:render()
	return self:_compose( "field", string.format("%s;%s;%s", self.name, self.label, self.value))
end

--
-- concrete CloseOnEnter
--
CloseOnEnter = Component:new{name = "", coe = false}

function CloseOnEnter:render()
	return self:_compose( "field_close_on_enter", string.format("%s;%s;%s", self.name, btos(self.coe)))
end

--
-- concrete TextArea
--
TextArea = Text:new{x = 0, y = 0, w = 0, h = 0, name = "", label = "", value = ""}

function TextArea:render()
	return self:_compose( "textarea", self:_render())
end

--
-- abstract BaseLabel
--
BaseLabel = Point:new{x = 0, y = 0, label = ""}

function BaseLabel:_render()
	return string.format("%s;%s", self:_partial(), self.label)
end

--
-- concrete Label
--
Label = BaseLabel:new{x = 0, y = 0, label = ""}

function Label:render()
	return self:_compose( "label", self:_render())
end

--
-- concrete VertLabel
--
VertLabel = BaseLabel:new{x = 0, y = 0, label = ""}

function VertLabel:render()
	return self:_compose( "vertlabel", self:_render())
end

--
-- abstract BaseButton
--
BaseButton = Tetragon:new{x = 0, y = 0, w = 0, h = 0, name = "", label = ""}

function BaseButton:_render()
	return string.format("%s;%s;%s", self:_partial(), self.name, self.label)
end

--
-- concrete Button
--
Button = BaseButton:new{x = 0, y = 0, w = 0, h = 0, name = "", label = ""}

function Button:render()
	return self:_compose( "button", self:_render())
end

--
-- concrete ImageButton
--
ImageButton = BaseButton:new{
	x = 0, y = 0, w = 0, h = 0,
	name = "", label = "", path = "",
	noclip = true, border = false, pressed_path = ""
}

function ImageButton:_render()
	return string.format("%s;%s;%s;%s;%s;%s;%s",
		self:_partial(), self.path, self.name, self.label,
		btos(self.noclip),  btos(self.border), self.pressed_path
	)
end

function ImageButton:render()
	return self:_compose( "image_button", self:_render())
end


--
-- abstract BaseStyle
--
BaseStyle = Component:new{_name= "abstract", selectors = {}, props = {} }

function BaseStyle:render()
	return self:_compose( self._name,
		string.format("%s;%s", self:_list(self.selectors), self:_withSep(";"):_list(self.props))
	)
end

--
-- concrete Style
--
Style = BaseStyle:new{_name = "style" }

--
-- concrete StyleType
--
StyleType = BaseStyle:new{_name = "style_type" }


--
-- concrete TableOptions
--
TableOptions = Component:new{options = {}}

function TableOptions:render()
	return self:_compose( "tableoptions", self:_withSep(";"):_list(self.options))
end

--
-- concrete TableColumns
--
TableColumns = Component:new{columns = {{}}}

function TableColumns:render()
	local buf = {}
	local i = 1
	while self.columns[i] do
		table.insert(buf, self:_list(self.columns[i]))
		i = i+1
	end
	return self:_compose( "tablecolumns", table.concat(buf, ';'))
end
--
-- concrete Table
--
Table = Tetragon:new{x = 0, y = 0, w = 0, h = 0, name = "", cells = {}, idx = 1}

function Table:render()
	return self:_compose( "table", string.format(
		"%s;%s;%s;%d",
		self:_partial(), self.name, self:_list(self.cells), self.idx
	))
end
