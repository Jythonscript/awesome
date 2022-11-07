local wibox = require("wibox")
local awful = require("awful")
local notify = require("lame.helpers").notify
local markup = require("lame.markup")

memory = {}
memory.widget = wibox.widget.textbox()

memory.setup = function(textcolor)
	mem = {}

	if not textcolor then textcolor = "#e0da37" end

	local cmd = "free --mebi --total --seconds 3"

	awful.spawn.with_line_callback(cmd, {
		stdout = function(line)
			mem.total, mem.used, mem.free
				= string.match(line, "Total:[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)")

			local text = ""
			if mem.used then
				text = string.format("%.1fG", mem.used / 1024)
				memory.widget:set_markup(markup(textcolor, text))
			end
		end
	})
end

return memory
