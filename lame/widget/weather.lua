local lain = require("lain")
local markup = require("lame.markup")
local beautiful = require("beautiful")
local naughty = require("naughty")
local prefs = require("prefs")

weather = lain.widget.weather({
    city_id = prefs.city_id,
	units = "imperial",
    notification_preset = { font = "xos4 Terminus 10", fg = beautiful.fg_normal },
    weather_na_markup = markup.fontfg(beautiful.font, "#eca4c4", "N/A "),
    settings = function()
        descr = weather_now["weather"][1]["description"]:lower()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup.fontfg(theme.font, "#eca4c4", descr .. " @ " .. units .. "°F "))
    end
})

weather.toggle = function()
	if not weather.notification then
		weather.show(0)
	else
		weather.hide()
	end
end

return weather
