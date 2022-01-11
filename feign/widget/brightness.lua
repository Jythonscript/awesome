local awful = require("awful")

local brightness = {}

brightness.increase = function(args)
	local amount
	if not args.amount then
		amount = 5
	end
	awful.util.spawn("xbacklight -inc " .. amount)
end

brightness.decrease = function(args)
	local amount
	if not args.amount then
		amount = 5
	end
	awful.util.spawn("xbacklight -dec " .. amount)
end

brightness.set = function(amt)
	awful.util.spawn("xbacklight -set " .. amt)
end

brightness.minimum = function()
	brightness.set(0.04)
end

brightness.prompt = function()
	awful.prompt.run {
		prompt = "Brightness: ",
		textbox = awful.screen.focused().mypromptbox.widget,
		exe_callback = function(amt)
			brightness.set(amt)
		end
	}
end

return brightness
