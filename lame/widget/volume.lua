local wibox = require("wibox")
local awful = require("awful")
local markup = require("lame.markup")
local keys = require("keys")

-- ALSA volume
local volume = {}
volume.widget = wibox.widget.textbox()

volume.volume_callback = function(callback)
	local cmd = "amixer get Master"
	awful.spawn.easy_async_with_shell(cmd, function(stdout)

		local vol, playback = string.match(stdout, "Playback [%d]+ %[([%d]+)%%%] %[([%l]*)")

		if not vol or not playback then return end

		vol = tonumber(vol)
		callback(vol)
	end)
end

volume.inc = function(percent, callback)
	if not percent then percent = 2 end
	if percent >= 0 then
		percent = percent .. "%+"
	else
		percent = -1 * percent .. "%-"
	end
	awful.spawn.easy_async("amixer set Master " .. percent, function ()
		if callback then
			volume.update(callback)
		else
			volume.update()
		end
	end)
end

volume.dec = function(percent, callback)
	if not percent then percent = 2 end
	volume.inc(-percent, callback)
end

volume.set = function(percent)
	if not percent then percent = 0 end
	awful.spawn.easy_async("amixer set Master " .. percent .. "%", volume.update)
end

volume.toggle_mute = function()
	awful.spawn.easy_async("amixer -q set Master toggle", volume.update)
end

volume.toggle_mic_mute = function()
	awful.spawn.easy_async("amixer set Capture toggle", volume.update)
end

volume.update = function(callback)
	local cmd = "amixer get Master && amixer get Capture"

	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local vol, playback = string.match(stdout, "Playback [%d]+ %[([%d]+)%%%] %[([%l]*)")
		local mic_vol, mic_playback = string.match(stdout, "Capture [%d]+ %[([%d]+)%%%] %[([%l]*)")

		if not vol or not playback or not mic_vol or not mic_playback then return end

		vol = tonumber(vol)
		mic_vol = tonumber(mic_vol)

		local text = "" .. vol
		if vol == 0 or playback == "off" then
			text = text .. "M"
		else
			text = text .. "%"
		end

		if mic_playback == "off" then
			text = text .. " " .. utf8.char(0xf131)
		end

		volume.widget:set_markup(markup("#7493d2", text))

		if callback then
			callback(vol)
		end
	end)
end

-- run it once so that the volume is shown on startup
volume.update()

volume.widget:buttons(awful.util.table.join(
    awful.button({}, keys.mouse1, function()
        awful.spawn("pavucontrol")
    end),
    awful.button({}, keys.mouse2, function()
		volume.toggle_mute()
    end),
    awful.button({}, keys.mouse3, function()
		volume.toggle_mic_mute()
    end),
    awful.button({}, keys.mwheelup, function()
		volume.inc(1)
    end),
    awful.button({}, keys.mwheeldown, function()
		volume.dec(1)
    end)
))

return volume
