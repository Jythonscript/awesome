local awful = require("awful")
local markup = require("lame.markup")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("lame.helpers")
local notify = require("lame.helpers").notify

local cpu = {}

cpu.color = "#e33a6e"

cpu.widget = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.font,
	markup = markup.fg.color(cpu.color, "00%")
}

cpu.init = function(timeout, color)
	if not timeout then timeout = 2 end
	if color then cpu.color = color end
	local cmd = os.getenv("HOME") .. "/.config/awesome/scripts/cpu-usage " .. timeout

	awful.spawn.with_line_callback(cmd, {
		stdout = function(line)
			local percent = tonumber(line)
			percent = helpers.floor_mult(percent, 5)
			local text = string.format("%02.0f%%", percent)
			cpu.widget:set_markup(markup.fg.color(cpu.color, text))
		end
	})
end

return cpu
