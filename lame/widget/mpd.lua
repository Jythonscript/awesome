local awful = require("awful")
local wibox = require("wibox")
local lain = require("lain")
local gears = require("gears")
local beautiful = require("beautiful")
local markup = require("lame.markup")

local mpdicon = wibox.widget.imagebox()
local minimized = false
local mpd = lain.widget.mpd({
	timeout = 1,
    settings = function()
		-- playlist position
		local songnumber = 0
		local totalsongs = 0
		if mpd_now.pls_pos ~= "N/A" then
			songnumber = math.floor(mpd_now.pls_pos + 1)
		end
		if mpd_now.pls_len ~= "N/A" then
			totalsongs = mpd_now.pls_len
		end

		local display_text = ""
		-- song time
		local cstmin = 0
		local cstsec = 0
		local currentsongtime = 0
		local tstmin = 0
		local tstsec = 0
		local songtime = 0
		if mpd_now.elapsed ~= "N/A" then
			cstmin = math.floor(mpd_now.elapsed / 60) .. ":"
			cstsec = math.floor(mpd_now.elapsed % 60)
			if cstsec < 10 then
				cstsec = "0" .. cstsec
			end
			currentsongtime =  cstmin .. "" .. cstsec

			tstmin = math.floor(mpd_now.time / 60) .. ":"
			tstsec = math.floor(mpd_now.time % 60)
			if tstsec < 10 then
				tstsec = "0" .. tstsec
			end
			display_text = string.format("%s [%s] - %s\n%s", mpd_now.artist, mpd_now.album, mpd_now.date, mpd_now.title)
		end

		local totalsongtime =  tstmin .. tstsec
        mpd_notification_preset = {
			-- SETTINGS
			followtag = true,
            text = display_text
        }

		-- widget text
		local prefix = ""
        if mpd_now.state == "play" then

			if mpd_now.artist == "N/A" then
				artist = ""
			else
				artist = mpd_now.artist .. " > "
			end

			prefix = " [" .. songnumber .. "/" .. totalsongs .. "]" .. " (" .. currentsongtime .. " / " .. totalsongtime .. ") "
			if mpd_now.title == "N/A" then
				title = mpd_now.name
			else
				title  = mpd_now.title
			end
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon._private.image = nil
            mpdicon:emit_signal("widget::redraw_needed")
            mpdicon:emit_signal("widget::layout_changed")
        end

		if minimized then
			widget:set_markup(markup.fontfg(markup.fontfg(beautiful.font, "#6dc2ff", title)))
		else
			widget:set_markup(markup.fontfg(beautiful.font, "#e54c62", artist) .. markup.fontfg(beautiful.font, "#428ff4", prefix) .. markup.fontfg(beautiful.font, "#6dc2ff", title))
		end
    end
})

mpd.toggle = function()
	os.execute("mpc toggle")
	mpd.update()
	mpd.timer:start()
end

mpd.stop = function()
	os.execute("mpc stop")
	mpd.update()
	mpd.timer:stop()
end

mpd.next = function()
	local cmd = "playerctl status"
	if mpd_now.state == "stop" then
		awful.spawn.easy_async(cmd, function(stdout)
			if string.find(stdout,"Playing") then
				awful.spawn("playerctl next")
			end
		end)
	else
		os.execute("mpc next")
		mpd.update()
	end
end

mpd.prev = function()
	local cmd = "playerctl status"
	if mpd_now.state == "stop" then
		awful.spawn.easy_async(cmd, function(stdout)
			if string.find(stdout,"Playing") then
				awful.spawn("playerctl previous")
			end
		end)
	else
		os.execute("mpc prev")
		mpd.update()
	end
end

mpd.seek = function(sec)
	if sec > 0 then
		sec = "+" .. sec
	end
	os.execute("mpc seek " .. sec)
	mpd.update()
end

mpd.volume = function(perc)
	if perc > 0 then
		perc = "+" .. perc
	end
	os.execute("mpc volume " .. perc)
	mpd.update()
end

mpd.widget:buttons(gears.table.join(
	awful.button({ }, 1, function()
		mpd.toggle()
	end),
	awful.button({ }, 2, function()
	end),
	awful.button({ }, 3, function()
		minimized = not minimized
	end),
	awful.button({ }, 4, function()
		mpd.next()
	end),
	awful.button({ }, 5, function()
		mpd.prev()
	end)
))

return mpd
