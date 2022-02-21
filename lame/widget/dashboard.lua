local wibox = require("wibox")

local dashboard = {}

dashboard.wibox = wibox {
	visible = false,
	ontop = true,
	type = "dock"
}

return dashboard
