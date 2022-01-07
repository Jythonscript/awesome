local return_table = {}

return setmetatable(return_table, {
	__index = function(table, key)
		local module = rawget(table, key)
		if not module then
			module = require("feign." .. key)
			rawset(table, key, module)
		end
		return module
	end
})
