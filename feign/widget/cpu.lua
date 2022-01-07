local markup = require("feign.markup")
local lain = require("lain")
local beautiful = require("beautiful")

local cpu = lain.widget.cpu({
    settings = function()
		local percent = cpu_now.usage - (cpu_now.usage % 5)
		--leading zero
		if percent < 10 then
			widget:set_markup(markup.fontfg(beautiful.font, "#e33a6e", "0" .. percent .. "%"))
		else
			widget:set_markup(markup.fontfg(beautiful.font, "#e33a6e", percent .. "%"))
		end
    end
})

return cpu
