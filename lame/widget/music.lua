local awful = require("awful")

local tab = {}

tab.mpd_toggle = function()
	awful.spawn("mpc toggle")
end

tab.mpd_next = function()
	awful.spawn("mpc next")
end

tab.mpd_prev = function()
	awful.spawn("mpc prev")
end

tab.mpd_seek = function(sec)
	if sec > 0 then
		sec = "+" .. sec
	end
	awful.spawn("mpc seek " .. sec)
end

tab.mpd_volume = function(perc)
	if perc > 0 then
		perc = "+" .. perc
	end
	awful.spawn("mpc volume " .. perc)
end

-- tab.playerctl_callback = function(callback)
-- 	local cmd = "playerctl status && playerctl metadata"

-- 	local player_now = {
-- 		playing = false,
-- 		title = "...",
-- 		artist = "...",
-- 		artUrl = nil
-- 	}

-- 	awful.spawn.easy_async_with_shell(cmd, function (stdout)
-- 		for line in stdout:gmatch("[^\n]+") do
-- 			for k,v in line:gmatch("[%w]+%s[%w]+:([%w]+)[%s]+(.*)$") do
-- 				if k == "title" then player_now.title = v end
-- 				if k == "artist" then player_now.artist = v end
-- 				if k == "artUrl" then
-- 					local _, idx = v:find("file://")
-- 					local img = v:sub(idx+1)
-- 					player_now.artUrl = img
-- 				end
-- 			end
-- 			if line:find("^Playing$") then
-- 				player_now.playing = true
-- 			end
-- 		end

-- 		callback(player_now)
-- 	end)
-- end

tab.playerctl_callback = function(callback)
	local cmd = [[
playerctl metadata --format '{{status}}
{{trunc(title,60)}}
{{artist}}
{{mpris:artUrl}}']]

	local player_now = {
		playing = false,
		title = "...",
		artist = "...",
		artUrl = nil
	}

	awful.spawn.easy_async_with_shell(cmd, function (stdout)

		local t = {}
		for str in stdout:gmatch("[^\n]+") do
			table.insert(t,str)
		end

		if t[1] == "Playing" then
			player_now.playing = true
		end
		player_now.title = t[2] or "..."
		player_now.artist = t[3] or "..."

		if t[4] then
			local _, idx = t[4]:find("file://")
			local img = t[4]:sub(idx+1)
			player_now.artUrl = img
		else
			player_now.artUrl = nil
		end

		callback(player_now)
	end)
end

tab.playerctl_play_pause = function(callback)
	awful.spawn.easy_async("playerctl play-pause", callback)
end

tab.playerctl_next = function(callback)
	awful.spawn.easy_async("playerctl next", callback)
end

tab.playerctl_previous = function(callback)
	awful.spawn.easy_async("playerctl previous", callback)
end

return tab
