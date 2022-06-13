local awful = require("awful")
local lame = require("lame")
local beautiful = require("beautiful")
local gears = require("gears")

pacman = {}

pacman.widget, pacman.timer = awful.widget.watch("checkupdates", 3600,
function(widget, stdout, stderr, reason, exit_code)
	if exit_code == 1 then return end
	local _, lines = stdout:gsub('\n','\n')
	pacman.last_output = stdout
	widget:set_markup(lame.markup("#4286f4", lines))
end)

pacman_t = awful.tooltip {}
pacman_t:add_to_object(pacman.widget)

-- helper recursion function for num_upgradable_callback
pacman.checkupdates_async = function(callback_arg)
	awful.spawn.easy_async("checkupdates", function(stdout, stderr, reason, exit_code)
		if exit_code == 1 then
			gears.timer {
				timeout = 1.0,
				autostart = true,
				single_shot = true,
				call_now = true,
				callback = function ()
					pacman.checkupdates_async(callback_arg)
				end
			}
			return
		else
			local _, lines = stdout:gsub('\n','\n')
			callback_arg(lines)
		end
	end)
end

pacman.num_upgradable_callback = function(callback)
	if pacman.last_output then
		local _, lines = pacman.last_output:gsub('\n','\n')
		callback(lines)
		return
	end
	pacman.checkupdates_async(callback)
end

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
		--pacman_t.markup = lame.markup(beautiful.tooltip_fg, text)
	end)
end)

pacman.refresh = function ()
	pacman.timer:again()
end

pacman.get_num_upgradable = function()
	if not pacman.last_output then return -1 end

	local _, lines = pacman.last_output:gsub('\n','\n')
	return lines
end

return pacman
