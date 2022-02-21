local prefs = require("prefs")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local beautiful = require("beautiful")

local menu_entries = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", prefs.terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", prefs.terminal, prefs.editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}

local main_menu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or 16,
    before = {
        { "Awesome", menu_entries, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", prefs.terminal },
        -- other triads can be put here
    }
})

return main_menu
