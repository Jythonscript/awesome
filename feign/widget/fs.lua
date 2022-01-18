local lain = require("lain")
local markup = require("feign.markup")

local fs = lain.widget.fs({
	followtag = true,
    notification_preset = { font = theme.mono_font, fg = theme.fg_normal },
    settings  = function()
        widget:set_markup(markup.fontfg(theme.font, "#80d9d8", string.format("%.1f", fs_now["/"].used) .. "% "))
    end
})

fs.toggle = function()
	if not fs.notification then
		fs.show(0)
	else
		fs.hide()
	end
end

return fs
