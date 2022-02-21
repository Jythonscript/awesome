local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local markup = require("lame.markup")

memory = {}
memory.widget = wibox.widget.textbox()

memory.update = function()
	mem = {}
	swap = {}

	local cmd = "free --mebi"
	awful.spawn.easy_async(cmd, function(stdout)
		mem.total, mem.used, mem.free, mem.shared, mem.buf, mem.available
			= string.match(stdout, "Mem:[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)")
		swap.total, swap.used, swap.free
			= string.match(stdout, "Swap:[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)")

		local text = ""
		if mem.used and swap.used then
			text = string.format("%.1fG", (mem.used + swap.used) / 1024)
		end
		memory.widget:set_markup(markup("#e0da37", text))
	end)
end
gears.timer({timeout = 3,
	autostart = true,
	call_now = true,
	callback =memory.update
})

memory.update()

return memory
