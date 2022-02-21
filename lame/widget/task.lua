local wibox = require("wibox")
local markup = require("lame.markup")
local beautiful = require("beautiful")
local lain = require("lain")

local tasks = wibox.widget.textbox()
tasks:set_markup(markup.fontfg(beautiful.font, "#4286f4", " Tasks"))
lain.widget.contrib.task.attach(beautiful.tasks, {})

return tasks
