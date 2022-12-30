local wibox = require("wibox")
local helpers = require("lame.helpers")
local awful = require("awful")
local beautiful = require("beautiful")
local markup = require("lame.markup")
local lame = require("lame")
local prefs = require("prefs")
local gears = require("gears")
local keys = require("keys")
local naughty = require("naughty")

local dpi = prefs.dpi
local font_dpi = prefs.font_dpi or helpers.font_dpi

local table = {}

local box_radius = 12
local box_gap = 6
local big_font = font_dpi("xos4 Terminus",34)
local medium_font = font_dpi("xos4 Terminus",20)
local small_font = font_dpi("xos4 Terminus",12)
local icon_font = font_dpi("Font Awesome", 24)
local box_background = "#2e2e2e"
local dark_text_color = "#636363"

table.wibox = wibox {
	visible = false,
	ontop = true,
	type = "dock"
}
local dashboard = table.wibox

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
user_picture_container.shape = helpers.rrect(dpi(40))
-- user_picture_container.shape = gears.shape.circle
user_picture_container.forced_height = dpi(140)
user_picture_container.forced_width = dpi(140)
local user_picture = wibox.widget {
	{
		wibox.widget.imagebox(prefs.profile_picture),
		widget = user_picture_container,
		-- bg = "#00FF00",
	},
	shape = helpers.rrect(box_radius),
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
	helpers.vertical_pad(dpi(24)),
	user_text,
	helpers.vertical_pad(dpi(4)),
	host_text,
	layout = wibox.layout.fixed.vertical
}
local user_box = create_boxed_widget(user_widget, dpi(300), dpi(340), box_background)

-- pacman widget
local pacman_textbox = wibox.widget.textbox()
local pacman_date_textbox = wibox.widget.textbox()
local pacman_widget = wibox.widget {
	{
		align = "center",
		valign = "center",
		font = big_font,
		text = "...",
		widget = pacman_textbox
	},
	{
		align = "center",
		valign = "center",
		font = medium_font,
		text = "... days out-of-date",
		widget = pacman_date_textbox
	},
	spacing = dpi(6),
	layout = wibox.layout.fixed.vertical
}

local pacman_box = create_boxed_widget(pacman_widget, dpi(200), dpi(100), box_background)
local pacman_notification = nil
pacman_box:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		lame.widget.pacman.refresh()
		lame.widget.pacman.num_upgradable_callback(function (output)
			pacman_textbox:set_markup(markup.font(big_font, output))
		end)
		lame.widget.pacman.date_callback(function (d)
			local total_sec = os.difftime(os.time(), d)
			local days = total_sec / 60 / 60 / 24
			days = math.floor(days + 0.5)
			pacman_date_textbox.text = days .. " days out-of-date"
		end)
	end),
	awful.button({}, keys.mouse2, function ()
		lame.widget.pacman.upgrade_list_callback(function (stdout)
			if pacman_notification then
				pacman_notification.visible = false
				naughty.destroy(pacman_notification)
				pacman_notification = nil
			else
				pacman_notification = naughty.notify {
					text = stdout:gsub('%s*$',''),
					font = small_font,
					timeout = 0
				}
			end
		end)
	end)
))

dashboard:connect_signal("property::visible", function ()
	if dashboard.visible then
		lame.widget.pacman.num_upgradable_callback(function (output)
			pacman_textbox:set_markup(markup.font(big_font, output))
		end)
		lame.widget.pacman.date_callback(function (d)
			local total_sec = os.difftime(os.time(), d)
			local days = total_sec / 60 / 60 / 24
			days = math.floor(days + 0.5)
			pacman_date_textbox.text = days .. " days out-of-date"
		end)
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

local clock_box = create_boxed_widget(clock_widget, dpi(300), dpi(200), box_background)

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

local calendar_offset = 0

local calendar_widget = wibox.widget {
	date = os.date('*t'),
	fn_embed = decorate_calendar,
	font = small_font,
	widget = wibox.widget.calendar.month,
	forced_width = dpi(250),
}

function calendar_inc(offset)
	calendar_offset = calendar_offset + offset
	local today = os.date('*t')
	local new_date = os.date('*t')
	new_date.month = new_date.month + calendar_offset
	while new_date.month > 12 do
		new_date.month = new_date.month - 12
		new_date.year = new_date.year + 1
	end
	while new_date.month < 1 do
		new_date.month = new_date.month + 12
		new_date.year = new_date.year - 1
	end
	if new_date.month ~= today.month or new_date.year ~= today.year then
		new_date.day = nil
	end
	calendar_widget.date = new_date
end


local calendar_box = create_boxed_widget(calendar_widget, dpi(300), dpi(300), box_background)

dashboard:connect_signal("property::visible", function ()
	calendar_widget.date = os.date('*t')
end)

calendar_box:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		calendar_inc(-1)
	end),
	awful.button({}, keys.mouse2, function ()
		calendar_inc(1)
	end)
))

-- program launchers
local launcher_setup = function(textbox, box, color, program)
	box:connect_signal("mouse::enter", function ()
		textbox:set_markup(markup.fg.color(color,textbox.text))
	end)
	box:connect_signal("mouse::leave", function ()
		textbox.text = textbox.text
	end)
	box:buttons(gears.table.join(
		awful.button({}, keys.mouse1, function ()
			awful.spawn(program)
		end)
	))
end

local firefox_textbox = wibox.widget.textbox(utf8.char(0xf269))
firefox_textbox.font = icon_font
local firefox_box = create_boxed_widget(firefox_textbox, dpi(100), dpi(100), box_background)
launcher_setup(firefox_textbox, firefox_box, "#ff9400", "firefox")

local terminal_textbox = wibox.widget.textbox(utf8.char(0xf120))
terminal_textbox.font = icon_font
local terminal_box = create_boxed_widget(terminal_textbox, dpi(100), dpi(100), box_background)
launcher_setup(terminal_textbox, terminal_box, "#000000", prefs.terminal)

local discord_textbox = wibox.widget.textbox(utf8.char(0xf392))
discord_textbox.font = icon_font
local discord_box = create_boxed_widget(discord_textbox, dpi(100), dpi(100), box_background)
launcher_setup(discord_textbox, discord_box, "#5865f2", "discord")

local todoist_textbox = wibox.widget.textbox(utf8.char(0xf0ca))
todoist_textbox.font = icon_font
local todoist_box = create_boxed_widget(todoist_textbox, dpi(100), dpi(100), box_background)
launcher_setup(todoist_textbox, todoist_box, "#4688f4", "flatpak run com.todoist.Todoist")

local steam_textbox = wibox.widget.textbox(utf8.char(0xf3f6))
steam_textbox.font = icon_font
local steam_box = create_boxed_widget(steam_textbox, dpi(100), dpi(100), box_background)
launcher_setup(steam_textbox, steam_box, "#000000", "steam")

-- lock widget
local lock_textbox = wibox.widget.textbox(utf8.char(0xf023))
lock_textbox.font = icon_font
local lock_box = create_boxed_widget(lock_textbox, dpi(100), dpi(100), box_background)
launcher_setup(lock_textbox, lock_box, dark_text_color, "light-locker-command -l")

-- gaming widget
local gaming_on = false
local gaming_on_color = "#ffffff"
local gaming_off_color = dark_text_color
local gaming_textbox = wibox.widget.textbox()
gaming_textbox.font = icon_font
gaming_textbox:set_markup(markup.fontfg(icon_font, gaming_off_color, utf8.char(0xf11b)))
local gaming_box = create_boxed_widget(gaming_textbox, dpi(100), dpi(100), box_background)
gaming_box:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
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

-- awake widget
local awake_on = false
local awake_on_color = '#ffffff'
local awake_off_color = dark_text_color
local awake_textbox = wibox.widget.textbox()
awake_textbox.font = icon_font
awake_textbox:set_markup(markup.fontfg(icon_font, awake_off_color, utf8.char(0xf06e)))
local awake_box = create_boxed_widget(awake_textbox, dpi(100), dpi(100), box_background)
awake_box:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		awake_on = not awake_on
		if awake_on then
			awake_textbox:set_markup(markup.fg.color(awake_on_color, awake_textbox.text))
			awful.spawn("xset s off -dpms")
		else
			awake_textbox:set_markup(markup.fg.color(awake_off_color, awake_textbox.text))
			awful.spawn("xset s on dpms")
		end
	end)
))

-- fortune widget
-- TODO

-- Music widget
local music_image = wibox.widget.imagebox()
local music_title = wibox.widget.textbox()
local music_artist = wibox.widget.textbox()
local music_playpause_button = wibox.widget.textbox()
local music_backward_button = wibox.widget.textbox()
local music_forward_button = wibox.widget.textbox()

local music_playing_text = utf8.char(0xf04c)
local music_paused_text = utf8.char(0xf04b)

local music_widget = wibox.widget {
	{
		{
			{
				{
					widget = wibox.widget.textbox(),
					text = utf8.char(0xf001),
					font = icon_font,
					align = "center",
					valign = "center"
				},
				{
					widget = music_image,
				},
				layout = wibox.layout.stack
			},
			widget = wibox.container.background(),
			forced_width = dpi(280),
			shape_clip = true,
			shape = helpers.rrect(box_radius),
			bg = dark_text_color,
			align = "center"
		},
		helpers.vertical_pad(dpi(30)),
		{
			font = medium_font,
			text = "...",
			align = "center",
			valign = "center",
			widget = music_title
		},
		helpers.vertical_pad(dpi(10)),
		{
			font = small_font,
			text = "...",
			align = "center",
			valign = "center",
			widget = music_artist
		},
		helpers.vertical_pad(dpi(10)),
		{
			{
				font = icon_font,
				text = utf8.char(0xf04a),
				align = "center",
				widget = music_backward_button
			},
			{
				font = icon_font,
				text = utf8.char(0xf04b),
				align = "center",
				widget = music_playpause_button
			},
			{
				font = icon_font,
				text = utf8.char(0xf04e),
				align = "center",
				widget = music_forward_button
			},
			spacing = dpi(30),
			align = "center",
			valign = "center",
			layout = wibox.layout.flex.horizontal
		},
		-- spacing = dpi(40),
		align = "center",
		valign = "center",
		layout = wibox.layout.fixed.vertical
	},
	widget = wibox.container.margin,
	margins = dpi(10)
}

local music_box = create_boxed_widget(music_widget, dpi(300), dpi(450), box_background)

local music_text_update = function()

	lame.widget.music.playerctl_callback(function (player_now)
		music_title.text = player_now.title
		music_artist.text = player_now.artist
		music_image.image = player_now.artUrl or beautiful.no_music_image

		if player_now.playing then
			music_playpause_button.text = music_playing_text
		else
			music_playpause_button.text = music_paused_text
		end
	end)
end

music_playpause_button:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		lame.widget.music.playerctl_play_pause(music_text_update)
	end)
))

music_forward_button:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		lame.widget.music.playerctl_next(music_text_update)
	end)
))

music_backward_button:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		lame.widget.music.playerctl_previous(music_text_update)
	end)
))

dashboard:connect_signal("property::visible", music_text_update)

awful.spawn.with_line_callback("playerctl metadata -F --format '{{status}} {{title}} {{artist}} {{artUrl}}'", {
	stdout = music_text_update
})

music_image:buttons(gears.table.join(
	awful.button({}, keys.mouse1, function ()
		lame.widget.music.playerctl_play_pause(music_text_update)
	end),
	awful.button({}, keys.mwheelup, function ()
		lame.widget.music.playerctl_next(music_text_update)
	end),
	awful.button({}, keys.mwheeldown, function ()
		lame.widget.music.playerctl_previous(music_text_update)
	end),
	awful.button({}, keys.mouse4, function ()
		lame.widget.music.playerctl_previous_player(function ()
			music_text_update()
		end)
	end),
	awful.button({}, keys.mouse5, function ()
		lame.widget.music.playerctl_next_player(function ()
			music_text_update()
		end)
	end)
))

-- Volume widget
local volume_textbox = wibox.widget.textbox()
local volume_slider = wibox.container.background()
local volume_background = wibox.container.background()
local volume_slider_max = dpi(300)

local volume_box = wibox.widget {
	{
		{
			{
				{
					{
						widget = wibox.widget.textbox()
					},
					widget = volume_slider,
					bg = dark_text_color,
					shape = helpers.rrect(box_radius),
					forced_width = 0
				},
				{
					{
						widget = wibox.widget.textbox()
					},
					widget = wibox.container.background()
				},
				layout = wibox.layout.align.horizontal
			},
			{
				nil,
				{
					nil,
					{
						widget = volume_textbox,
						text = '20%',
						font = medium_font,
						align = 'center',
						valign = 'center',
					},
					layout = wibox.layout.align.vertical,
					expand = "none"
				},
				layout = wibox.layout.align.horizontal,
				expand = "none"
			},
			layout = wibox.layout.stack
		},
		widget = volume_background,
		shape = helpers.rrect(box_radius),
		shape_clip = true,
		bg = box_background,
		forced_width = volume_slider_max,
		forced_height = dpi(100),
	},
	margins = box_gap,
	color = '#ff000000',
	widget = wibox.container.margin
}

local volume_box_update = function(vol)
	local width = volume_slider_max * (vol / 100)
	volume_slider.forced_width = width
	volume_textbox.text = vol .. "%"
end

volume_box:buttons(gears.table.join(
	awful.button({}, keys.mwheelup, function ()
		lame.widget.volume.inc(2, function (vol)
			volume_box_update(vol)
		end)
	end),
	awful.button({}, keys.mwheeldown, function ()
		lame.widget.volume.dec(2, function (vol)
			volume_box_update(vol)
		end)
	end)
))

dashboard:connect_signal("property::visible", function ()
	lame.widget.volume.volume_callback(function (vol)
		volume_box_update(vol)
	end)
end)

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
					awake_box,
					layout = wibox.layout.flex.horizontal
				},
				pacman_box,
				layout = wibox.layout.align.vertical
			},
			{
				clock_box,
				calendar_box,
				layout = wibox.layout.align.vertical
			},
			{
				firefox_box,
				terminal_box,
				discord_box,
				todoist_box,
				steam_box,
				layout = wibox.layout.flex.vertical
			},
			{
				music_box,
				volume_box,
				layout = wibox.layout.align.vertical
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
	awful.button({}, keys.mouse3, function ()
		table.toggle()
	end)
))

table.toggle = function ()
	local s = awful.screen.focused()
	dashboard.screen = s
	dashboard.visible = not dashboard.visible

	-- cleanup
	if not dashboard.visible then
		if pacman_notification then
			pacman_notification.visible = false
			naughty.destroy(pacman_notification)
			pacman_notification = false
		end
	end
end

return table
