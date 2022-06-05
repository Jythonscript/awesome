local wibox = require("wibox")
local helpers = require("lame.helpers")
local awful = require("awful")
local beautiful = require("beautiful")
local markup = require("lame.markup")
local lame = require("lame")
local prefs = require("prefs")
local gears = require("gears")
local keys = require("keys")

local table = {}

local box_radius = 12
local box_gap = 6
local big_font = "xos4 Terminus 34"
local medium_font = "xos4 Terminus 20"
local small_font = "xos4 Terminus 12"
local box_background = "#2e2e2e"
local dark_text_color = "#636363"

table.wibox = wibox {
	visible = false,
	ontop = true,
	type = "dock"
}
local dashboard = table.wibox
local prevkeys

awful.placement.maximize(dashboard)
dashboard.bg = "#000000CC"
dashboard.fg = "#FEFEFE"

local function create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
	local box_container = wibox.container.background()
	box_container.bg = bg_color
	box_container.forced_height = height
	box_container.forced_width = width
	box_container.shape = helpers.rrect(box_radius)

	local boxed_widget = wibox.widget {
		-- Add margins
		{
			-- Add background color
			{
				-- Center widget_to_be_boxed horizontally
				nil,
				{
					-- Center widget_to_be_boxed vertically
					nil,
					-- The actual widget goes here
					widget_to_be_boxed,
					layout = wibox.layout.align.vertical,
					expand = "none"
				},
				layout = wibox.layout.align.horizontal,
				expand = "none"
			},
			widget = box_container,
		},
		margins = box_gap,
		color = "#FF000000",
		widget = wibox.container.margin
	}

	return boxed_widget
end

-- user widget
local user_picture_container = wibox.container.background()
user_picture_container.shape = helpers.rrect(40)
-- user_picture_container.shape = gears.shape.circle
user_picture_container.forced_height = 140
user_picture_container.forced_width = 140
local user_picture = wibox.widget {
	{
		wibox.widget.imagebox(prefs.profile_picture),
		widget = user_picture_container,
		-- bg = "#00FF00",
	},
	shape = helpers.rrect(box_radius / 2),
	-- bg = "#FFFFFF",
	widget = wibox.container.background
}

local username = os.getenv("USER")
local user_text = wibox.widget.textbox()
user_text.align = "center"
user_text.valign = "center"
user_text:set_markup(markup.bold(markup.font(big_font, username:sub(1,1):upper() .. username:sub(2,-1))))

local host_text = wibox.widget.textbox()
host_text.align = "center"
host_text.valign = "center"

awful.spawn.easy_async_with_shell("hostname", function(out)
	out = out:gsub('^%s*(.-)%s*$', '%1')
	host_text:set_markup(markup.fontfg(medium_font, dark_text_color, "@"..out))
end)

local user_widget = wibox.widget {
	user_picture,
	helpers.vertical_pad(24),
	user_text,
	helpers.vertical_pad(4),
	host_text,
	layout = wibox.layout.fixed.vertical
}
local user_box = create_boxed_widget(user_widget, 300, 340, box_background)

-- pacman widget
local pacman_packages = wibox.widget.textbox()
local pacman_widget = wibox.widget {
	{
		align = "center",
		valign = "center",
		font = beautiful.font,
		widget = pacman_packages
	},
	{
		align = "center",
		valign = "center",
		markup = markup.fontfg(medium_font, "#FFFFFF", "out-of-date packages"),
		widget = wibox.widget.textbox()
	},
	spacing = 6,
	layout = wibox.layout.fixed.vertical
}

local pacman_box = create_boxed_widget(pacman_widget, 200, 100, box_background)

dashboard:connect_signal("property::visible", function ()
	if dashboard.visible then
		pacman_packages:set_markup(markup.fontfg(big_font,
		"#FFFFFF", lame.widget.pacman.get_num_upgradable()))
	end
end)

-- clock widget
local clock_textbox_24hr = wibox.widget.textclock("%T", 1)
local clock_textbox_12hr = wibox.widget.textclock("%l:%M %p", 1)
local clock_widget = wibox.widget {
	{
		align = "center",
		valign = "center",
		font = big_font,
		widget = clock_textbox_24hr
	},
	{
		align = "center",
		valign = "center",
		font = medium_font,
		widget = clock_textbox_12hr
	},
	layout = wibox.layout.align.vertical
}

local clock_box = create_boxed_widget(clock_widget, 300, 200, box_background)

local decorate_calendar = function(widget, flag, date)
	if widget.get_text and widget.set_markup then
		if flag == 'monthheader' or flag == 'header' then
			widget:set_markup(markup.font(medium_font, widget:get_text()))
		end
		if flag == 'focus' then
			widget:set_markup(markup.bold(markup.fg.color('#009ec9',widget:get_text())))
		end
	end
	return widget
end

local calendar_widget = wibox.widget {
	date = os.date('*t'),
	font = "Fira Mono 15",
	fn_embed = decorate_calendar,
	font = small_font,
	widget = wibox.widget.calendar.month
}

local calendar_box = create_boxed_widget(calendar_widget, 300, 300, box_background)

-- program launchers
local launcher_font = "Font Awesome 24"
local launcher_setup = function(textbox, box, color, program)
	box:connect_signal("mouse::enter", function ()
		textbox:set_markup(markup.fg.color(color,textbox.text))
	end)
	box:connect_signal("mouse::leave", function ()
		textbox.text = textbox.text
	end)
	box:buttons(gears.table.join(
		awful.button({}, 1, function ()
			awful.spawn(program)
		end)
	))
end

local firefox_textbox = wibox.widget.textbox(utf8.char(0xf269))
firefox_textbox.font = launcher_font
local firefox_box = create_boxed_widget(firefox_textbox, 100, 100, box_background)
launcher_setup(firefox_textbox, firefox_box, "#ff9400", "firefox")

local chromium_textbox = wibox.widget.textbox(utf8.char(0xf268))
chromium_textbox.font = launcher_font
local chromium_box = create_boxed_widget(chromium_textbox, 100, 100, box_background)
launcher_setup(chromium_textbox, chromium_box, "#4688f4", "chromium")

local terminal_textbox = wibox.widget.textbox(utf8.char(0xf120))
terminal_textbox.font = launcher_font
local terminal_box = create_boxed_widget(terminal_textbox, 100, 100, box_background)
launcher_setup(terminal_textbox, terminal_box, "#000000", prefs.terminal)

local discord_textbox = wibox.widget.textbox(utf8.char(0xf392))
discord_textbox.font = launcher_font
local discord_box = create_boxed_widget(discord_textbox, 100, 100, box_background)
launcher_setup(discord_textbox, discord_box, "#5865f2", "discord")

local steam_textbox = wibox.widget.textbox(utf8.char(0xf3f6))
steam_textbox.font = launcher_font
local steam_box = create_boxed_widget(steam_textbox, 100, 100, box_background)
launcher_setup(steam_textbox, steam_box, "#000000", "steam")

-- lock widget
local lock_textbox = wibox.widget.textbox(utf8.char(0xf023))
lock_textbox.font = launcher_font
local lock_box = create_boxed_widget(lock_textbox, 100, 100, box_background)
launcher_setup(lock_textbox, lock_box, dark_text_color, "light-locker-command -l")

-- gaming widget
local gaming_on = false
local gaming_on_color = "#ffffff"
local gaming_off_color = dark_text_color
local gaming_textbox = wibox.widget.textbox()
gaming_textbox.font = launcher_font
gaming_textbox:set_markup(markup.fontfg(launcher_font, gaming_off_color, utf8.char(0xf11b)))
local gaming_box = create_boxed_widget(gaming_textbox, 100, 100, box_background)
gaming_box:buttons(gears.table.join(
	awful.button({}, 1, function ()
		gaming_on = not gaming_on
		if gaming_on then
			gaming_textbox:set_markup(markup.fg.color(gaming_on_color, gaming_textbox.text))
			awful.spawn.with_shell("source ~/.func.zsh && gamer")
		else
			gaming_textbox:set_markup(markup.fg.color(gaming_off_color, gaming_textbox.text))
			awful.spawn.with_shell("source ~/.func.zsh && gamer off")
		end
	end)
))

-- fortune widget
-- TODO

-- MPD widget
-- TODO

-- Volume widget
-- TODO

dashboard:setup {
	nil,
	{
		nil,
		{
			{
				user_box,
				{
					lock_box,
					gaming_box,
					layout = wibox.layout.flex.horizontal
				},
				pacman_box,
				layout = wibox.layout.align.vertical
			},
			{
				clock_box,
				calendar_box,
				-- pacman_box,
				layout = wibox.layout.align.vertical
			},
			{
				firefox_box,
				chromium_box,
				terminal_box,
				discord_box,
				steam_box,
				layout = wibox.layout.flex.vertical
			},
			layout = wibox.layout.fixed.horizontal
		},
		expand = "none",
		layout = wibox.layout.align.horizontal
	},
	expand = "none",
	layout = wibox.layout.align.vertical
}

dashboard:buttons(gears.table.join(
	awful.button({}, 2, function ()
		table.toggle()
	end)
))

table.dashboard_keys = gears.table.join(
	awful.key({}, "q", function ()
		table.toggle()
	end),
	awful.key({}, "Escape", function ()
		table.toggle()
	end)
)

table.toggle = function ()
	local s = awful.screen.focused()
	dashboard.screen = s
	dashboard.visible = not dashboard.visible

	if dashboard.visible then
		prevkeys = root.keys()
		root.keys(gears.table.join(prevkeys, table.dashboard_keys))
	else
		root.keys(prevkeys)
	end
end

return table
