local markup = require("lame.markup")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local prefs = require("prefs")
local gears = require("gears")
local awesome

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

temp.init = function(file_path, timeout, color)
	if not file_path and prefs.temperature_path then file_path = prefs.temperature_path end
	if not file_path and not prefs.temperature_path then file_path = "/sys/class/hwmon/hwmon1/temp1_input" end
	if not timeout then timeout = 4 end
	if color then temp.color = color end
	local cmd = os.getenv("HOME") .. "/.config/awesome/scripts/cat-loop " .. file_path .. " " .. timeout

	awful.spawn.with_line_callback(cmd, {
		stdout = function(line)
			local raw_temp = tonumber(line)
			local temp_c = raw_temp / 1000
			local text = string.format("%02.1f", temp_c)
			temp.widget:set_markup(markup.fg.color(temp.color, text))
				awesome.emit_signal("custom::cpu_temp", temp_c)
		end
	})
end

return temp
