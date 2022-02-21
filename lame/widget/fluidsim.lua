local awful = require("awful")
local helpers = require("lame.helpers")

local fluidsim = {}

fluidsim.spawn = function(s)
	awful.spawn("surf /home/avery/git/WebGL-Fluid-Simulation/index.html")
end

fluidsim.kill = function(s)
	if not s then
		s = awful.screen.focused()
	end

	local c = helpers.client_instance_exists(s.all_clients, "surf")

	if c then
		c:kill()
	end
end

fluidsim.toggle = function(s)
	if not s then
		s = awful.screen.focused()
	end

	local c = helpers.client_instance_exists(s.all_clients, "surf")

	if c then
		c:kill()
	else
		fluidsim.spawn(s)
	end
end

return fluidsim
