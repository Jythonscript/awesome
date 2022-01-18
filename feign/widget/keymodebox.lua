local beautiful = require("beautiful")
local wibox = require("wibox")
local markup = require("feign.markup")

local keymodebox = {}

keymodebox.widget = wibox.widget.textbox("")

keymodebox.set_text = function(text)
	keymodebox.widget.markup = markup.font(beautiful.font, text)
end

return keymodebox
