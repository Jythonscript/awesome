local awful = require("awful")
local lain = require("lain")
local markup = require("feign.markup")
local beautiful = require("beautiful")
local naughty = require("naughty")
local prefs = require("prefs")

local bat = lain.widget.bat({
	settings = function()
		local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc

		if bat_now.ac_status == 1 then
			perc = perc .. " plug"
		end

		widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal, perc .. " "))
	end

})

bat.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function() -- left click
		-- update battery percentage number in widget
		bat.update()
		battery_info_toggle()
		battery_info_toggle()
	end),
	awful.button({}, 2, function() -- middle click

	end),
	awful.button({}, 3, function() -- right click

	end),
	awful.button({}, 4, function() -- scroll up

	end),
	awful.button({}, 5, function() -- scroll down

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

-- don't show battery if on desktop
if not prefs.laptop then
	bat.widget = nil
end

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
