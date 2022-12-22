local wibox = require("wibox")
local awful = require("awful")
local markup = require("lame.markup")
local keys = require("keys")

-- ALSA volume
local volume = {}
volume.widget = wibox.widget.textbox()

volume.volume_callback = function(callback)
	local cmd = "wpctl get-volume @DEFAULT_AUDIO_SINK@"
	awful.spawn.easy_async_with_shell(cmd, function(stdout)

		local vol = string.match(stdout, "Volume: (%S+)")

		if not vol then return end

		vol = math.floor(tonumber(vol) * 100)

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
	awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. percent, function ()
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
	awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. percent .. "%", function () volume.update() end)
end

volume.toggle_mute = function()
	awful.spawn.easy_async("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", function () volume.update() end)
end

volume.toggle_mic_mute = function()
	awful.spawn.easy_async("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", function () volume.update() end)
end

volume.update = function(callback)
	local cmd = "wpctl get-volume @DEFAULT_AUDIO_SINK@ && wpctl get-volume @DEFAULT_AUDIO_SOURCE@"

	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local line1, line2 = string.match(stdout, "([^\n]*)\n(.*)\n")

		local vol, muted = string.match(line1, "Volume: (%S+)%s?(.*)")
		local mic_vol, mic_muted = string.match(line2, "Volume: (%S+)%s?(.*)")

		if not vol or not mic_vol then return end

		vol = math.floor(tonumber(vol) * 100)
		mic_vol = math.floor(tonumber(mic_vol) * 100)
		muted = (muted == "[MUTED]")
		mic_muted = (mic_muted == "[MUTED]")

		local text = "" .. vol
		if vol == 0 or muted then
			text = text .. "M"
		else
			text = text .. "%"
		end

		if mic_muted then
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
    end)
))

return volume
