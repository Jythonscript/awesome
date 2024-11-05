local markup = require("lame.markup")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local prefs = require("prefs")
local gears = require("gears")

local temp = {}

temp.color = "#f1af5f"
temp.widget = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.font,
	markup = markup.fg.color(temp.color, "00%")
}

temp.temp_now = function()
	if not temp.last_temp then
		return 0
	else
		return temp.last_temp
	end
end

temp.init = function(prefix_name, timeout, color)
	if not prefix_name and prefs.prefix_name then prefix_name = prefs.prefix_name end
	if not prefix_name and not prefs.prefix_name then prefix_name = 'k10temp' end
	require('lame.helpers').notify(prefix_name)
	if not timeout then timeout = 4 end
	if color then temp.color = color end
	local cmd = os.getenv("HOME") .. "/.config/awesome/scripts/temperature " .. prefix_name .. " " .. timeout

	awful.spawn.with_line_callback(cmd, {
		stdout = function(line)
			local temp_c = tonumber(line)
			local text = string.format("%02.1f", temp_c)
			temp.widget:set_markup(markup.fg.color(temp.color, text))
			awesome.emit_signal("custom::cpu_temp", temp_c)
		end
	})
end

return temp
