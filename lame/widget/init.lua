local widget = {}

return setmetatable(widget, {
	__index = function(table, key)
		local module = rawget(table, key)
		if not module then
			module = require("lame.widget." .. key)
			rawset(table, key, module)
		end
		return module
	end
})
