local awful = require("awful")
local prefs = require("prefs")
local beautiful = require("beautiful")
local helpers = require("lame.helpers")

local visualizer = {}

-- Visualizer
-- terminal pretty much needs to be urxvt(c)
visualizer.spawn = function(s)
	awful.spawn(prefs.terminal .. "\
	-font 'xft:Fira Mono:size=11'\
	-scollBar false\
	-sl 0\
	-lsp 0\
	-letsp 0\
	-depth 32\
	-bg rgba:0000/0000/0000/0000\
	--highlightColor rgba:0000/0000/0000/0000\
	-name vis\
	-e sh -c 'export XDG_CONFIG_HOME=" .. beautiful.confdir .. " && \
	vis -c " .. beautiful.confdir .. "/vis/config'"
	)
end

visualizer.kill = function(s)
	if not s then
		s = awful.screen.focused()
	end

	local c = helpers.client_instance_exists(s.all_clients, "vis")

	if c then
		c:kill()
	end
end

visualizer.toggle = function(s)
	if not s then
		s = awful.screen.focused()
	end

	local c = helpers.client_instance_exists(s.all_clients, "vis")

	if c then
		c:kill()
	else
		visualizer.spawn(s)
	end
end

return visualizer
