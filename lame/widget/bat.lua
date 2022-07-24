local awful = require("awful")
local lain = require("lain")
local markup = require("lame.markup")
local beautiful = require("beautiful")
local naughty = require("naughty")
local prefs = require("prefs")
local keys = require("keys")

local bat = lain.widget.bat({
	settings = function()
		local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc
		widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal, perc .. " "))
	end

})

bat.widget:buttons(awful.util.table.join(
	awful.button({}, keys.mouse1, function()
		-- update battery percentage number in widget
		bat.update()
		battery_info_toggle()
		battery_info_toggle()
	end)
))

bat.widget:connect_signal('mouse::enter', function()
	bat.update()
	battery_info_toggle()
end)
bat.widget:connect_signal('mouse::leave', function()
	bat.update()
	battery_info_toggle()
end)

-- display status, battery count, each percentage, and watts
function battery_info_toggle()
	if not battery_notification then
		local battery_text = ""
		for i in pairs(bat_now.n_perc) do
			battery_text = battery_text .. i .. ": " .. bat_now.n_perc[i] .. "% , " .. bat_now.n_status[i] .. "\n"
		end
		battery_text = battery_text .. bat_now.watt .. " Watts\n"
		battery_text = battery_text .. bat_now.time .. " remaining"

		battery_notification = naughty.notify( {
			text = battery_text,
			timeout = 0,
			font = "Fira Mono 20",
		})
	else
		naughty.destroy(battery_notification)
		battery_notification = nil
	end
end

return bat
