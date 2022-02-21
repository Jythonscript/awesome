local lain = require("lain")
local markup = require("lame.markup")
local beautiful = require("beautiful")

local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, "#f1af5f", coretemp_now .. "°C "))
    end
})

return temp
