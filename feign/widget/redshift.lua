local lain = require("lain")
local markup = require("feign.markup")
local beautiful = require("beautiful")
local wibox = require("wibox")

local myredshift = wibox.widget.textbox()
lain.widget.contrib.redshift:attach(
	myredshift,
	function (active)
		if active then
			myredshift:set_markup(markup.fontfg(beautiful.font, "#4fcc2c", "RS"))
		else
			myredshift:set_markup(markup.fontfg(beautiful.font, "#d30000", "RS"))
		end
	end
)

return myredshift
