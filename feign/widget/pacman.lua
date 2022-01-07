local awful = require("awful")
local feign = require("feign")
local beautiful = require("beautiful")

pacman = {}

pacman.widget = awful.widget.watch("checkupdates", 3600,
function(widget,stdout)
	local _, lines = stdout:gsub('\n','\n')
	pacman.last_output = stdout
	widget:set_markup(feign.markup("#4286f4", lines))
end)

pacman_t = awful.tooltip {}
pacman_t:add_to_object(pacman.widget)

pacman.widget:connect_signal("mouse::enter", function()
	local cmd = "grep \"Running 'pacman -Syu\" /var/log/pacman.log | tail -n 1"
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local text = ""

		if stdout then
			local last_date = string.match(stdout, "%[(%d+%-%d+%-%d+)")
			text = text .. "Last update: " .. last_date .. "\n\n"
		end

		if pacman.last_output then
			text = text .. pacman.last_output
		end

		pacman_t.text = text
		--pacman_t.markup = feign.markup(beautiful.tooltip_fg, text)
	end)
end)

return pacman.widget
