--[[

     Multicolor Awesome WM theme 2.0
     github.com/lcpz

--]] 

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty  = require("naughty")
local ipairs
local os    = { getenv = os.getenv, setlocale = os.setlocale, execute = os.execute }

theme                                     = {}
theme.confdir                                   = os.getenv("HOME") .. "/.config/awesome/themes/multicolor"
theme.wallpaper                                 = theme.confdir .. "/wall.png"
theme.font                                      = "xos4 Terminus 8"
theme.fira_font                                 = "Fira Mono 11"
theme.bg_normal                                 = "#000102"
theme.bg_focus                                  = "#000102"
theme.bg_urgent                                 = "#000102"
theme.fg_normal                                 = "#aaaaaa"
theme.fg_focus                                  = "#ff8c00"
theme.fg_urgent                                 = "#af1d18"
theme.fg_minimize                               = "#ffffff"
theme.border_width                              = 0
theme.titlebar_size								= 1
theme.titlebar_bg_normal 						= "#000102"
theme.titlebar_bg_focus							= "#11AAFC"
theme.border_normal                             = "#1c2022"
theme.border_focus                              = "#606060"
theme.border_marked                             = "#3ca4d8"
theme.menu_border_width                         = 0
theme.menu_width                                = 130
theme.menu_submenu_icon                         = theme.confdir .. "/icons/submenu.png"
theme.menu_fg_normal                            = "#aaaaaa"
theme.menu_fg_focus                             = "#ff8c00"
theme.menu_bg_normal                            = "#000102"
theme.menu_bg_focus                             = "#000102"
theme.widget_temp                               = theme.confdir .. "/icons/temp.png"
theme.widget_uptime                             = theme.confdir .. "/icons/ac.png"
theme.widget_cpu                                = theme.confdir .. "/icons/cpu.png"
theme.widget_weather                            = theme.confdir .. "/icons/dish.png"
theme.widget_fs                                 = theme.confdir .. "/icons/fs.png"
theme.widget_mem                                = theme.confdir .. "/icons/mem.png"
theme.widget_fs                                 = theme.confdir .. "/icons/fs.png"
theme.widget_note                               = theme.confdir .. "/icons/note.png"
theme.widget_note_on                            = theme.confdir .. "/icons/note_on.png"
theme.widget_netdown                            = theme.confdir .. "/icons/net_down.png"
theme.widget_netup                              = theme.confdir .. "/icons/net_up.png"
theme.widget_mail                               = theme.confdir .. "/icons/mail.png"
theme.widget_batt                               = theme.confdir .. "/icons/bat.png"
theme.widget_clock                              = theme.confdir .. "/icons/clock.png"
theme.widget_vol                                = theme.confdir .. "/icons/spkr.png"
theme.taglist_squares_sel                       = theme.confdir .. "/icons/square_a.png"
theme.taglist_squares_unsel                     = theme.confdir .. "/icons/square_b.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 0
theme.layout_tile                               = theme.confdir .. "/icons/tile.png"
theme.layout_tilegaps                           = theme.confdir .. "/icons/tilegaps.png"
theme.layout_tileleft                           = theme.confdir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.confdir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.confdir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.confdir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.confdir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.confdir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.confdir .. "/icons/dwindle.png"
theme.layout_max                                = theme.confdir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.confdir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.confdir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.confdir .. "/icons/floating.png"
theme.titlebar_close_button_normal              = theme.confdir .. "/icons/titlebar/close_normal.png"
theme.titlebar_close_button_focus               = theme.confdir .. "/icons/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal           = theme.confdir .. "/icons/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = theme.confdir .. "/icons/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive     = theme.confdir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = theme.confdir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = theme.confdir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = theme.confdir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive    = theme.confdir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = theme.confdir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = theme.confdir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = theme.confdir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive  = theme.confdir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = theme.confdir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = theme.confdir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = theme.confdir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "/icons/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.confdir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = theme.confdir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = theme.confdir .. "/icons/titlebar/maximized_focus_active.png"

beautiful.tooltip_bg                                = "#000000"
beautiful.tooltip_fg                                = "#ffffff"

local markup = lain.util.markup

theme.tagnames =  {
	utf8.char(0xf269), -- Firefox
	utf8.char(0xf0e0), -- Mail
	utf8.char(0xf086), -- Chat
	"4",
	"5",
	"6", "7", "8", "9",
	"F1", "F2", "F3", "F4", "F5", "F6",
	"F7", "F8", "F9", "F10", "F11", "F12"
}

-- Textclock
os.setlocale(os.getenv("LANG")) -- to localize the clock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
theme.mytextclock = wibox.widget.textclock(markup("#7788af", "%Y/%m/%d ") .. markup("#535f7a", ">") .. markup("#de5e1e", " %H:%M"))
theme.mytextclock.font = theme.font

-- Calendar
cal = lain.widget.cal({
	attach_to = { theme.mytextclock },
	followtag = true,
	notification_preset = {
		font = theme.fira_font,
		fg   = theme.fg_normal,
		bg   = theme.bg_normal
	}
})

-- Weather
local weathericon = wibox.widget.imagebox(theme.widget_weather)
theme.weather = lain.widget.weather({
    city_id = 5025219, -- Eden Prairie, MN 
	units = "imperial",
    notification_preset = { font = "xos4 Terminus 10", fg = theme.fg_normal },
    weather_na_markup = markup.fontfg(theme.font, "#eca4c4", "N/A "),
    settings = function()
        descr = weather_now["weather"][1]["description"]:lower()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup.fontfg(theme.font, "#eca4c4", descr .. " @ " .. units .. "°F "))
    end
})

local fsicon = wibox.widget.imagebox(theme.widget_fs)
theme.fs = lain.widget.fs({
	followtag = true,
    notification_preset = { font = theme.fira_font, fg = theme.fg_normal },
    settings  = function()
        widget:set_markup(markup.fontfg(theme.font, "#80d9d8", string.format("%.1f", fs_now["/"].used) .. "% "))
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
		local percent = cpu_now.usage - (cpu_now.usage % 5)
		--leading zero
		if percent < 10 then
			widget:set_markup(markup.fontfg(theme.font, "#e33a6e", "0" .. percent .. "%"))
		else
			widget:set_markup(markup.fontfg(theme.font, "#e33a6e", percent .. "%"))
		end
    end
})

function cpu_toggle()
	if not cpu_notification then
		cpu_notification = naughty.notify( {
			text = "cpu hover text"
		})
	else
		cpu_notification = nil
	end
end

-- Coretemp
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#f1af5f", coretemp_now .. "°C "))
    end
})

-- Visualizer
-- terminal pretty much needs to be urxvt(c)
function theme.spawn_visualizer(s, terminal)
	awful.spawn(terminal .. "\
	-font 'xft:Fira Mono:size=11'\
	-scollBar false\
	-sl 0\
	-lsp 0\
	-letsp 0\
	-depth 32\
	-bg rgba:0000/0000/0000/0000\
	--highlightColor rgba:0000/0000/0000/0000\
	-name vis\
	-e sh -c 'export XDG_CONFIG_HOME=" .. theme.confdir .. " && \
	vis -c " .. theme.confdir .. "/vis/config'"
	)
end

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_batt)
local bat = lain.widget.bat({
	settings = function()
		local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc

		if bat_now.ac_status == 1 then
			perc = perc .. " plug"
		end

		widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, perc .. " "))
	end

})

bat.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function() -- left click
		-- update battery percentage number in widget
		bat.update()
		battery_info_toggle()
		battery_info_toggle()
	end),
	awful.button({}, 2, function() -- middle click

	end),
	awful.button({}, 3, function() -- right click

	end),
	awful.button({}, 4, function() -- scroll up

	end),
	awful.button({}, 5, function() -- scroll down

	end)
))

bat.widget:connect_signal('mouse::enter', function() battery_info_toggle() end)
bat.widget:connect_signal('mouse::leave', function() battery_info_toggle() end)

-- don't show battery if on desktop
if selectedConfig == "elrond" then
	bat.widget = nil
end

-- display status, battery count, each percentage, and watts
function battery_info_toggle()
	if not battery_notification then
		local battery_text = ""
		for i in pairs(bat_now.n_perc) do
			battery_text = battery_text .. i .. ": " .. bat_now.n_perc[i] .. "% , " .. bat_now.n_status[i] .. "\n"
		end
		battery_text = battery_text .. bat_now.watt .. " Watts\n"
		battery_text = battery_text .. bat_now.time .. " remaining"

		battery_notification = naughty.notify( {
			text = battery_text,
			timeout = 0,
			font = "Fira Mono 20",
		})
	else
		naughty.destroy(battery_notification)
		battery_notification = nil
	end
end

function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

-- ALSA volume
local volicon = wibox.widget.imagebox(theme.widget_vol)

theme.volume = {}
theme.volume.widget = wibox.widget.textbox()

theme.volume.inc = function(percent)
	if percent >= 0 then
		percent = percent .. "%+"
	else
		percent = -1 * percent .. "%-"
	end
	awful.spawn.easy_async("amixer set Master " .. percent, theme.volume.update)
end

theme.volume.toggle_mute = function()
	awful.spawn.easy_async("amixer -q set Master toggle", theme.volume.update)
end

theme.volume.toggle_mic_mute = function()
	awful.spawn.easy_async("amixer set Capture toggle", theme.volume.update)
end

theme.volume.update = function()
	local cmd = "amixer get Master && amixer get Capture"

	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local vol, playback = string.match(stdout, "Playback [%d]+ %[([%d]+)%%%] %[([%l]*)")
		local mic_vol, mic_playback = string.match(stdout, "Capture [%d]+ %[([%d]+)%%%] %[([%l]*)")

		if not vol or not playback or not mic_vol or not mic_playback then return end

		vol = tonumber(vol)
		mic_vol = tonumber(mic_vol)

		local text = "" .. vol
		if vol == 0 or playback == "off" then
			text = text .. "M"
		else
			text = text .. "%"
		end

		if mic_playback == "off" then
			text = text .. " " .. utf8.char(0xf131)
		end

		theme.volume.widget:set_markup(lain.util.markup("#7493d2", text))
	end)
end

-- run it once so that the volume is shown on startup
theme.volume.update()

theme.volume.widget:buttons(awful.util.table.join(
    awful.button({}, 1, function() -- left click
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 2, function() -- middle click
		theme.volume.toggle_mic_mute()
    end),
    awful.button({}, 3, function() -- right click
		theme.volume.toggle_mute()
    end),
    awful.button({}, 4, function() -- scroll up
		theme.volume.inc(1)
    end),
    awful.button({}, 5, function() -- scroll down
		theme.volume.inc(-1)
    end)
))

-- MEM
theme.memory = {}
theme.memory.widget = wibox.widget.textbox()

theme.memory.update = function()
	mem = {}
	swap = {}

	local cmd = "free --mebi"
	awful.spawn.easy_async(cmd, function(stdout)
		mem.total, mem.used, mem.free, mem.shared, mem.buf, mem.available
			= string.match(stdout, "Mem:[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)")
		swap.total, swap.used, swap.free
			= string.match(stdout, "Swap:[%s]+([%d]+)[%s]+([%d]+)[%s]+([%d]+)")

		local text = ""
		if mem.used and swap.used then
			text = string.format("%.1fG", (mem.used + swap.used) / 1024)
		end
		theme.memory.widget:set_markup(lain.util.markup("#e0da37", text))
	end)
end
gears.timer({timeout = 3,
	autostart = true,
	call_now = true,
	callback = theme.memory.update})
theme.memory.update()


-- taskwarrior
theme.tasks = wibox.widget.textbox()
theme.tasks:set_markup(markup.fontfg(theme.font, "#4286f4", " Tasks"))
lain.widget.contrib.task.attach(theme.tasks, {})

-- pacman
pacman = {}

pacman.widget = awful.widget.watch("checkupdates", 3600,
function(widget,stdout)
	local _, lines = stdout:gsub('\n','\n')
	pacman.last_output = stdout
	widget:set_markup(lain.util.markup("#4286f4", lines))
end)

pacman_t = awful.tooltip {}
pacman_t:add_to_object(pacman.widget)

pacman.widget:connect_signal("mouse::enter", function()
	local cmd = "grep \"Running 'pacman -Syu\" /var/log/pacman.log | tail -n 1"
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local text = ""

		if stdout then
			local last_date = string.match(stdout, "%[(%d+%-%d+%-%d+)")
			text = text .. "Last update: " .. last_date .. "\n\n"
		end

		if pacman.last_output then
			text = text .. pacman.last_output
		end

		pacman_t.text = text
	end)
end)

-- redshift
myredshift = wibox.widget.textbox()
lain.widget.contrib.redshift:attach(
	myredshift,
	function (active)
		if active then
			myredshift:set_markup(markup.fontfg(theme.font, "#4fcc2c", "RS"))
		else
			myredshift:set_markup(markup.fontfg(theme.font, "#d30000", "RS"))
		end
	end
)

-- naughty suspended notifications toggle
naughtywidget = {}
naughtywidget.disable_notifications=false
mynaughtynotif = wibox.widget.textbox()
mynaughtynotif:set_markup(markup.fontfg(theme.font, "#4286f4", "mynaughtynotif"))

function naughtywidget.toggle()
	naughtywidget.disable_notifications = not naughtywidget.disable_notifications
	if naughtywidget.disable_notifications then
		theme.mpd.notify="off"
	else
		theme.mpd.notify="on"
	end
	naughtywidget.update()
end

function naughtywidget.update()
	if not naughtywidget.disable_notifications then
		mynaughtynotif:set_markup(markup.fontfg(theme.font, "#4fcc2c", "Notifs"))
	else
		mynaughtynotif:set_markup(markup.fontfg(theme.font, "#d30000", "Notifs"))
	end
end

-- Start with correct naughty colors
naughtywidget.update()

-- MPD
function theme.mpd_toggle()
	os.execute("mpc toggle")
	theme.mpd.update()
	theme.mpd.timer:start()
end

function theme.mpd_stop()
	os.execute("mpc stop")
	theme.mpd.update()
	theme.mpd.timer:stop()
end

function theme.mpd_next()
	os.execute("mpc next")
	theme.mpd.update()
end

function theme.mpd_prev()
	os.execute("mpc prev")
	theme.mpd.update()
end

local mpdicon = wibox.widget.imagebox()
local minimized = false
theme.mpd = lain.widget.mpd({
	timeout = 1,
    settings = function()
		-- playlist position
		local songnumber = 0
		local totalsongs = 0
		if mpd_now.pls_pos ~= "N/A" then
			songnumber = math.floor(mpd_now.pls_pos + 1)
		end
		if mpd_now.pls_len ~= "N/A" then
			totalsongs = mpd_now.pls_len
		end

		local display_text = ""
		-- song time
		local cstmin = 0
		local cstsec = 0
		local currentsongtime = 0
		local tstmin = 0
		local tstsec = 0
		local songtime = 0
		if mpd_now.elapsed ~= "N/A" then
			cstmin = math.floor(mpd_now.elapsed / 60) .. ":"
			cstsec = math.floor(mpd_now.elapsed % 60)
			if cstsec < 10 then
				cstsec = "0" .. cstsec
			end
			currentsongtime =  cstmin .. "" .. cstsec

			tstmin = math.floor(mpd_now.time / 60) .. ":"
			tstsec = math.floor(mpd_now.time % 60)
			if tstsec < 10 then
				tstsec = "0" .. tstsec
			end
			display_text = string.format("%s [%s] - %s\n%s", mpd_now.artist, mpd_now.album, mpd_now.date, mpd_now.title)
		end

		local totalsongtime =  tstmin .. tstsec
        mpd_notification_preset = {
			-- SETTINGS 
			followtag = true,
            text = display_text
        }

		-- widget text
		local prefix = ""
        if mpd_now.state == "play" then

			if mpd_now.artist == "N/A" then
				artist = ""
			else
				artist = mpd_now.artist .. " > "
			end

			prefix = " [" .. songnumber .. "/" .. totalsongs .. "]" .. " (" .. currentsongtime .. " / " .. totalsongtime .. ") "
			if mpd_now.title == "N/A" then
				title = mpd_now.name
			else
				title  = mpd_now.title
			end
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else  
            artist = ""
            title  = ""
            mpdicon._private.image = nil
            mpdicon:emit_signal("widget::redraw_needed")
            mpdicon:emit_signal("widget::layout_changed")
        end

		if minimized then
			widget:set_markup(markup.fontfg(markup.fontfg(theme.font, "#6dc2ff", title)))
		else
			widget:set_markup(markup.fontfg(theme.font, "#e54c62", artist) .. markup.fontfg(theme.font, "#428ff4", prefix) .. markup.fontfg(theme.font, "#6dc2ff", title))
		end
    end
})

theme.mpd.widget:buttons(gears.table.join(
	awful.button({ }, 1, function()
		theme.mpd_toggle()
	end),
	awful.button({ }, 2, function()
	end),
	awful.button({ }, 3, function()
		minimized = not minimized
	end),
	awful.button({ }, 4, function()
		theme.mpd_next()
	end),
	awful.button({ }, 5, function()
		theme.mpd_prev()
	end)
))

--change systray monitor
local systray = wibox.widget.systray()

-- Eminent-like task filtering
local orig_taglist_filter = awful.widget.taglist.filter.all

-- Taglist label functions
awful.widget.taglist.filter.all = function(t, args)
	-- hide empty tags, unless they are renamed or are the first 3
	if t.selected or #focusable(t:clients()) > 0 or string.match(t.name, "-") or t.index <= 3 then
		return orig_taglist_filter(t, args)
	end
end

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(theme.tagnames, s, awful.layout.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt({

	})
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
	-- append platform shortcuts
	if selectedConfig == "elrond" then
		s.mywibox = awful.wibar({ position = "top", screen = s, height = 18, bg = "#000102", fg = theme.fg_normal })
	elseif selectedConfig == "aragorn" then
		s.mywibox = awful.wibar({ position = "top", screen = s, height = 25, bg = "#000102", fg = theme.fg_normal })
	end

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
            mpdicon,
            theme.mpd.widget,
        },
		s.mytasklist,
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			spacing = 5,
			systray,
			pacman.widget,
			myredshift,
			theme.volume.widget,
			theme.memory.widget,
			cpu.widget,
			bat.widget,
			theme.mytextclock,
		},
    }
end

return theme
