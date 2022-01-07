local widget = {}

return setmetatable(widget, {
	__index = function(table, key)
		local module = rawget(table, key)
		if not module then
			module = require("feign.widget." .. key)
			rawset(table, key, module)
		end
		return module
	end
})
