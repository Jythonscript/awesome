local lain = require("lain")
local naughty = require("naughty")

local cal = {}

cal.init = function(widget)
	cal.textclock = widget
	cal.widget = lain.widget.cal({
		attach_to = { widget },
		followtag = true,
		notification_preset = {
			font = theme.fira_font,
			fg   = theme.fg_normal,
			bg   = theme.bg_normal
		}
	})
end

cal.toggle = function()
	if cal.textclock then
		cal.textclock:force_update()
	end

	if not cal.widget.notification then
		cal.widget.show(0)
	else
		naughty.destroy(cal.notification)
		cal.widget.hide()
	end
end

return cal
