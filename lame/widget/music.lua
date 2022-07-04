local awful = require("awful")

local tab = {}

tab.player = ""

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

tab.playerctl_callback = function(callback)
	local cmd = [[
playerctl metadata -p "]]..tab.player..[[" --format '{{status}}
{{trunc(title,60)}}
{{artist}}
{{mpris:artUrl}}'
]]

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
	awful.spawn.easy_async("playerctl play-pause -p '"..tab.player.."'", callback)
end

tab.playerctl_next = function(callback)
	awful.spawn.easy_async("playerctl next -p '"..tab.player.."'", callback)
end

tab.playerctl_previous = function(callback)
	awful.spawn.easy_async("playerctl previous -p '"..tab.player.."'", callback)
end

tab.playerctl_next_player = function(callback, skip_func)
	if not skip_func then skip_func = function(i) return i+1 end end
	local cmd = "playerctl -l"

	awful.spawn.easy_async(cmd, function(stdout)
		local players = {}
		local next_index = -1
		local next_player = ""
		for str in stdout:gmatch("[^\n]+") do
			table.insert(players, str)
		end
		if tab.player == "" then
			tab.player = players[1] or ""
		end

		for i, p in ipairs(players) do
			if p == tab.player then
				next_index = ((skip_func(i)-1) % (#players))+1
			end
		end

		next_player = players[next_index] or ""
		tab.player = next_player
		callback()
	end)
end

tab.playerctl_previous_player = function(callback)
	tab.playerctl_next_player(callback, function(i) return i-1 end)
end

return tab
