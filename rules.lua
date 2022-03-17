local awful = require("awful")
local beautiful = require("beautiful")
local keys = require("keys")

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = keys.clientkeys,
                     buttons = keys.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = true } },

	--Special rules
    { rule = { class = "firefox" },
      properties = { maximized = false, titlebars_enabled = false }
    },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized = true } },

    { rule = { class = "Thunderbird" },
      properties = { tag = beautiful.tagnames[2], titlebars_enabled = false } },

    { rule = { class = "discord" },
      properties = { tag = beautiful.tagnames[3] } },
	{ rule = { class = "Todoist" },
	  properties = { tag = beautiful.tagnames[3] } },
    { rule = { class = "Steam" },
      properties = { tag = beautiful.tagnames[5] } },
	{
	    rule = { class = "URxvt" },
	    except_any = { instance = { "vis", "ncmpcpp" } },
	},
	{
		rule = { name = "WP34s" },
		properties = {
			titlebars_enabled = false,
			ontop = true
		}
	},
	-- development
	{
		rule = {class = "Sudoku"},
		properties = {
			floating = true
		}
	},
	{
	    rule = { class = "URxvt", instance = "vis" },
	    properties = {
			tag = beautiful.tagnames[4],
			maximized = true,
			focusable = false,
			below = true,
			sticky = true,
			skip_taskbar = true,
			titlebars_enabled = false
	    }
	},
	{
	    rule = { class = "Surf", instance = "surf" },
	    properties = {
			tag = beautiful.tagnames[4],
			maximized = true,
			focusable = false,
			below = true,
			sticky = true,
			skip_taskbar = true,
			titlebars_enabled = false
	    }
	},
	{
	rule = { class = "URxvt", instance = "popup" },
		properties = {
			placement = awful.placement.top+awful.placement.center_horizontal,
			above = true,
			skip_taskbar = true,
			floating = true
		}
	},
	{
		rule = { class = "portal2_linux" },
		properties = {
			callback = function(c)
				--no_picom_when_focused_setup(c)
			end
		}
	},
	{
		rule = { class = "origin.exe" },
		properties = {
			below = true,
			floating = true,
			minimized = true,
		}
	},
	{
		rule = { class = "steam_app_1182480" },
		properties = {
			below = true,
			floating = true,
			minimized = true,
		}
	},
	{
		rule = { class = "steam_app_620" },
		properties = {
			fullscreen = true,
		}
	}
}
-- }}}
