local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local prefs = require("prefs")
local helpers = require("feign.helpers")
local feign = require("feign")
local mouse = mouse
local os = os

local prefs = require("prefs")

local modkey       = "Mod4"
local altkey       = "Mod1"

local keys = {}

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
	--awful.key({}, "XF86Calculator",
	awful.key({ modkey, "Shift" }, "c",
        function ()
			if fake_input_mouse3_pressed == true then
				root.fake_input("button_release", 3);
				fake_input_mouse3_pressed = false
				naughty.notify({text = "rmb released"})
			else
				root.fake_input("button_press", 3);
				fake_input_mouse3_pressed = true
				naughty.notify({text = "rmb pressed"})
			end
        end,
        {description = "toggle secondary mouse pressed", group = "custom"}),
	awful.key({ modkey }, "p",
		function()
			local s_geo = mouse.screen.geometry
			awful.spawn("import -window root -crop " ..
			s_geo.width .. "x" .. s_geo.height ..
			"+" .. s_geo.x .. "+" .. s_geo.y ..
			" " .. os.getenv("HOME") .. "/Pictures/Screenshots/" ..
			os.date("%Y-%m-%d@%H:%M:%S") .. ".png")
		end,
		{description = "single display screenshot", group = "hotkeys"}),
    awful.key({ modkey, "Shift" }, "p",
		function()
			os.execute("scrot -e 'mv $f ~/Pictures/Screenshots/'")
			naughty.notify({text = "full screenshot taken"})
		end,
        {description = "take a scrot screenshot", group = "hotkeys"}),

	awful.key({ modkey }, "s", function()
		awful.spawn.with_shell("sleep 0.2;scrot -s -fe 'mv $f ~/Pictures/Screenshots/';zsh;")
	end,
              {description = "take a scrot screenshot with selection", group = "hotkeys"}),

	awful.key({ modkey, "Shift" }, "s",
		function()
			doSloppyFocus = not doSloppyFocus
			if doSloppyFocus then
				naughty.notify({text = "sloppy focus enabled"})
			else
				naughty.notify({text = "sloppy focus disabled"})
			end
		end,
	{description = "toggle sloppy focus", group = "awesome"}),
	--terminal in same directory
    awful.key({ modkey,  "Shift"         }, "Return",
		function()
			local term_id = "/run/user/$(id --user)/urxvtc_ids/" .. client.focus.window
			awful.spawn.with_shell(prefs.terminal ..
				" -cd \"$([ -f " .. term_id .. " ] && \
				readlink -e /proc/$(cat " .. term_id .. ")/cwd || \
				echo $HOME)\""
			)
		end,
		{description = "new terminal w/ same directory", group = "launcher"}),
	-- Toggle redshift with Mod+Shift+t
    awful.key({ modkey, "Shift" }, "t",
		function ()
			feign.widget.redshift:toggle()
		end,
		{description = "toggle redshift", group = "widgets"}),
	-- train popup
	awful.key({ altkey, modkey}, "t",
		function ()
			cmd = "source $HOME/.zshrc && trains"
			awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
				naughty.notify({text = stdout})
			end)
		end
	),
	--Toggle widgets with 1-5 macro keys
	awful.key({}, "XF86Launch5",
		function ()
			feign.widget.task.show()
        end,
        {description = "task popup", group = "widgets"}),
	awful.key({}, "XF86Launch6",
		function ()
			feign.widget.cal.toggle()
		end,
		  {description = "show cal", group = "widgets"}),
    awful.key({}, "XF86Launch7",
		function ()
			feign.widget.weather.toggle()
		end,
        {description = "toggle weather popup", group = "widgets"}),
    awful.key({}, "XF86Launch8",
		function ()
			feign.widget.fs.toggle()
		end,
              {description = "show filesystem", group = "widgets"}),
	--Task prompt
	awful.key({}, "XF86Launch9",
		function ()
			feign.widget.task.prompt()
		end,
		{description = "task prompt", group = "widgets"}),

    -- X screen locker
    awful.key({ altkey, "Control" }, "l",
		function ()
			os.execute("xscreensaver-command -lock")
		end,
        {description = "lock screen", group = "hotkeys"}),
	-- Move mouse with keyboard
    awful.key({ modkey, altkey}, "Right",
		function ()
			os.execute("xdotool mousemove_relative -- 10 0")
		end,
        {description = "move mouse right", group = "custom"}),
    awful.key({ modkey, altkey}, "Left",
		function ()
			os.execute("xdotool mousemove_relative -- -10 0")
		end,
        {description = "move mouse left", group = "custom"}),
    awful.key({ modkey, altkey}, "Up",
		function ()
			os.execute("xdotool mousemove_relative -- 0 -10")
		end,
        {description = "move mouse up", group = "custom"}),
    awful.key({ modkey, altkey}, "Down",
		function ()
			os.execute("xdotool mousemove_relative -- 0 10")
		end,
        {description = "move mouse down", group = "custom"}),
    awful.key({ modkey, altkey}, ";",
		function ()
			os.execute("xdotool click 1")
		end,
        {description = "primary click mouse", group = "custom"}),
    awful.key({ modkey, altkey}, "'",
		function ()
			os.execute("xdotool click 3")
		end,
        {description = "secondary click mouse", group = "custom"}),
	-- Hotkeys
    awful.key({ modkey, "Shift" }, "y",      hotkeys_popup.show_help,
              {description = "show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
	--alternate Tag browsing
	awful.key({ altkey,           }, "h",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ altkey,           }, "l",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
	awful.key({ altkey }, "j",
		function ()
			awful.screen.focus_bydirection("left")
		end,
		{description = "focus screen to left", group = "screen"}),
	awful.key({ altkey }, "k",
		function ()
			awful.screen.focus_bydirection("right")
		end,
		{description = "focus screen to right", group = "screen"}),

    -- Default client focus
	-- (This has been modified to be the opposite of the default)
    awful.key({ modkey, altkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus left index", group = "client"}
    ),
	-- (This has been modified to be the opposite of the default)
    awful.key({ modkey, altkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus right index", group = "client"}
    ),

    -- directional client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
	awful.key({ altkey }, "o",
        function()
			os.execute("transset-df -at")
        end,
        {description = "toggle transparency", group = "custom"}),

    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),
    awful.key({ modkey }, "w",
		function ()
			feign.widget.main_menu:toggle()
		end,
		{description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( 1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j",
		function ()
			awful.screen.focus_bydirection("left")
		end,
              {description = "focus the screen to the right", group = "screen"}),
    awful.key({ modkey, "Control" }, "k",
		function ()
			awful.screen.focus_bydirection("right")
		end,
	{description = "focus the screen to the right", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    awful.key({ altkey,           }, "Tab",
        function ()
			awful.tag.history.restore()
        end,
        {description = "switch to previous tag", group = "tag"}),

    awful.key({ modkey }, "]",
        function()
            local og_c = client.focus

            if og_c == nil then
                return
            end

            local matcher = function(c)
				return (c.window == og_c.window
					or awful.widget.tasklist.filter.minimizedcurrenttags(c, c.screen))
					and c:tags()[#c:tags()] == og_c:tags()[#og_c:tags()]
            end

            local n = 0
            for c in awful.client.iterate(matcher) do
                if n == 0 then
                elseif n == 1 then
                    og_c.minimized = true
                    c.minimized = false
                    client.focus = c
                    c:raise()
                else
                    c.minimized = true
                end
                c:swap(og_c)
                n = n + 1
            end
        end,
		{description = "cycle forward between minimized windows", group = "client"}),
    awful.key({ modkey }, "[",
		function()
            local og_c = client.focus

            if og_c == nil then
                return
            end

            local matcher = function(c)
                return awful.widget.tasklist.filter.minimizedcurrenttags(c, c.screen)
                    and c:tags()[#c:tags()] == og_c:tags()[#og_c:tags()]
            end

            local stack = {}
            for c in awful.client.iterate(matcher) do
                stack[#stack+1] = c
            end
            stack[#stack+1] = og_c

            local n = 0
            for _, c in ipairs(gears.table.reverse(stack))  do
                if n == 0 then
                elseif n == 1 then
                    og_c.minimized = true
                    c.minimized = false
                    client.focus = c
                    c:raise()
                else
                    c.minimized = true
                end
                c:swap(og_c)
                n = n + 1
            end
        end,
		{description = "cycle backwards between minimized windows", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "b", function ()
            for s in screen do
                s.mywibox.visible = true
                if s.mybottomwibox then
                    s.mybottomwibox.visible = true
                end
            end
        end,
        {description = "enable all wiboxes", group = "awesome"}),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n",
		function ()
			helpers.add_tag()
		end,
              {description = "add new tag", group = "tag"}),
    awful.key({ modkey }, "y",
		function ()
			helpers.rename_tag()
		end,
              {description = "rename tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Left",
		function ()
			helpers.move_tag_left()
		end,
		{description = "move tag to the left", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Right",
		function ()
			helpers.move_tag_right()
		end,
		{description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, "Shift" }, "d",
		function ()
			helpers.delete_tag()
		end,
		{description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(prefs.terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r",
		function()
            local cmd = "find ~/.config/awesome/ -iname '*.lua' -exec luac -o - {} \\;"
            awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
                if stderr == "" then
                    awesome.restart()
                else
                    naughty.notify({
                        preset = naughty.config.presets.critical,
                        title = "An error was detected, aborting restart!",
                        text = stderr
                    })
                end
            end)
        end,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, "Shift"   }, "l",
		function ()
			awful.tag.incmwfact( 0.05)
		end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",
		function ()
			awful.tag.incmwfact(-0.05)
		end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "0",
		function ()
			awful.tag.setmwfact(0.5)
		end,
              {description = "reset master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}), awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey }, "space",
		function ()
			awful.layout.set(awful.layout.suit.tile)
		end,
              {description = "switch between tile left and tile above", group = "layout"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ modkey, altkey}, "m",
			function ()
				  for _, client in ipairs(client.get()) do
					  client.minimized = false
					  client.maximized = false
					  client.opacity = 1
                  end
              end,
              {description = "reset all window settings", group = "client"}),
    awful.key({ modkey, altkey}, "n",
              function ()
				  for _, client in ipairs(client.get()) do
					  if client.minimized then
						  client.minimized = not client.minimized
					  end
                  end
              end,
              {description = "restore all minimized", group = "client"}),

    awful.key({ modkey, }, "z",
		function ()
			awful.screen.focus_relative(1)
		end,
			  {description = "focus the next screen", group = "screen"}),

    -- Widgets popups
    awful.key({ altkey, modkey}, "c",
		function ()
			feign.widget.cal.toggle()
		end,
              {description = "toggle cal", group = "widgets"}),
    awful.key({ altkey, modkey}, "f",
		function ()
			feign.widget.fs.toggle()
		end,
              {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey, modkey}, "w",
		function ()
			feign.widget.weather.toggle()
		end,
        {description = "toggle weather popup", group = "widgets"}),
    -- Pulse volume control
	awful.key({}, "XF86AudioRaiseVolume",
        function ()
			feign.widget.volume.inc(2)
        end,
        {description = "volume up", group = "hotkeys"}),

	awful.key({}, "XF86AudioLowerVolume",
		function ()
			feign.widget.volume.inc(-2)
        end,
        {description = "volume down", group = "hotkeys"}),
	awful.key({}, "XF86AudioMute",
        function ()
			feign.widget.volume.toggle_mute()
        end,
        {description = "toggle mute", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "m",
        function ()
           os.execute(string.format("amixer -D pulse set Master toggle"))
            beautiful.volume.update()
        end,
        {description = "toggle mute", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "0",
        function ()
            os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        {description = "volume 0%", group = "hotkeys"}),

    -- MPD control
	awful.key({ altkey, "Shift" }, "'",
		function ()
			awful.spawn("playerctl play-pause")
		end,
		{description = "playerctl play-pause", group = "custom"}),
    awful.key({ altkey }, "'",
        function ()
			feign.widget.mpd.toggle()
        end,
        {description = "mpc toggle", group = "mpd"}),
    awful.key({ altkey }, ";",
        function ()
			feign.widget.mpd.stop()
        end,
        {description = "mpc stop", group = "mpd"}),
    awful.key({ altkey }, "[",
        function ()
			feign.widget.mpd.prev()
        end,
        {description = "mpc prev", group = "mpd"}),
    awful.key({ altkey }, "]",
        function ()
			feign.widget.mpd.next()
        end,
        {description = "mpc next", group = "mpd"}),
    awful.key({ altkey }, "=",
        function ()
			feign.widget.mpd.seek(10)
        end,
        {description = "mpc seek +10", group = "mpd"}),
    awful.key({ altkey }, "-",
        function ()
			feign.widget.mpd.seek(-10)
        end,
        {description = "mpc seek -10", group = "mpd"}),
	awful.key({ altkey }, "0",
        function ()
			feign.widget.mpd.seek(0)
        end,
        {description = "restart song", group = "mpd"}),
	awful.key({ modkey }, "Up",
        function ()
			feign.widget.mpd.volume(5)
        end,
        {description = "mpd volume up", group = "mpd"}),
	awful.key({ modkey }, "Down",
        function ()
			feign.widget.mpd.volume(-5)
        end,
        {description = "mpd volume down", group = "mpd"}),
	awful.key({ modkey }, "v",
		function()
			feign.widget.visualizer.toggle()
		end,
		{description = "toggle visualizer", group = "mpd"}),
	awful.key({ modkey, "Shift" }, "v",
		function()
			feign.widget.fluidsim.toggle()
		end,
		{description = "toggle fluid simulation", group = "custom"}),
    -- User programs
    awful.key({ modkey }, "q",
		function ()
			awful.spawn(prefs.browser, {maximized = false})
		end,
              {description = "run browser", group = "launcher"}),
    awful.key({ modkey }, "a",
		function ()
			os.execute("rofi -show window -disable-history");
		end,
              {description = "run rofi", group = "launcher"}),
	awful.key({ modkey }, "e",
		function ()
			awful.spawn("flatpak run com.todoist.Todoist")
		end,
			{description = "run todoist", group = "launcher"}),
	-- Change popup program location
	awful.key({ modkey, altkey, "Control"}, "Up",
		function()
			local popupPlacement = awful.placement.top+awful.placement.center_horizontal
			for _, c in ipairs(client.get()) do
				if c.above and c.sticky then
					popupPlacement(c)
				end
			end
		end,
		{description = "move popups up"}),
	awful.key({ modkey, altkey, "Control"}, "Down",
		function()
			local popupPlacement = awful.placement.bottom+awful.placement.center_horizontal
			for _, c in ipairs(client.get()) do
				if c.above and c.sticky then
					popupPlacement(c)
				end
			end
		end,
		{description = "move popups down"}),
    -- Prompt
    awful.key({ modkey }, "r",
		function ()
			os.execute("dmenu_run -nb '#000000' -sb '#428ff4'");
		end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey }, "x",
		function ()
			awful.prompt.run {
				prompt = "Run: ",
				hooks = {
					{{}, "Return", function(cmd)
						return helpers.parse_for_special_run_commands(cmd)
					end}
				},
				textbox = awful.screen.focused().mypromptbox.widget,
				history_path = gears.filesystem.get_dir("cache") .. "/history",
				completion_callback = awful.completion.shell,
				exe_callback = function(cmd)
					awful.spawn.with_shell("source $HOME/.zshrc && " .. cmd)
				end
			}
		end,
              {description = "run prompt", group = "launcher"})
)

-- laptop specific shortcuts
local laptopkeys = gears.table.join(
	-- launch calculator
	awful.key({}, "XF86Launch2",
		function ()
			for _, c in ipairs(client.get()) do
				if c.name == "WP34s" then
					c:kill()
					return
				end
			end

			awful.spawn("/home/avery/Documents/Applications/wp-34s/wp-34s/WP-34s", {
				titlebarsenabled = false
			})
		end,
        {description = "open wp34s calculator emulator", group = "custom"}),
	-- lock screen
	awful.key({}, "XF86Launch1",
        function ()
			os.execute("light-locker-command -l");
        end,
        {description = "lock screen", group = "custom"}),
	-- hibernate
	awful.key({ modkey, altkey }, "XF86Display",
        function ()
			os.execute("systemctl hibernate");
        end,
        {description = "hibernate", group = "custom"}),
    -- brightness
    awful.key({ }, "XF86MonBrightnessUp",
		function ()
			awful.util.spawn("xbacklight -inc 5")
		end,
		{description = "+5%", group = "hotkeys"}),

    awful.key({ }, "XF86MonBrightnessDown",
		function ()
			awful.util.spawn("xbacklight -dec 5")
		end,
		{description = "-5%", group = "hotkeys"}),
	-- mute microphone
	awful.key({}, "XF86AudioMicMute",
        function ()
			os.execute("pactl set-source-mute 1 toggle")
        end,
        {description = "toggle microphone mute", group = "hotkeys"}),

    awful.key({ modkey }, "g",
		function ()
			awful.spawn("env GDK_SCALE=2 steam")
		end,
              {description = "start steam with GTK dpi adjust", group = "launcher"}),
    awful.key({ altkey }, "XF86Tools",
		function ()
			awful.spawn.easy_async_with_shell('xinput enable $(xinput list | grep -oP "Synaptics.*id=\\K(\\d+)")', function () end)
		end,
              {description = "enable trackpad", group = "custom"}),
    awful.key({ }, "XF86Tools",
		function ()
			awful.spawn.easy_async_with_shell('xinput disable $(xinput list | grep -oP "Synaptics.*id=\\K(\\d+)")', function () end)
		end,
              {description = "disable trackpad", group = "custom"}),
	awful.key({ modkey, altkey }, "b",
		function()
			awful.prompt.run {
				prompt = "Brightness: ",
				textbox = awful.screen.focused().mypromptbox.widget,
				exe_callback = function(cmd)
					os.execute("xbacklight -set " .. cmd)
				end
			}
		end,
			  {description = "brightness prompt", group = "custom"})
)

-- pc specific shortcuts
local pckeys = gears.table.join(
	-- launch calculator
	awful.key({}, "XF86Calculator",
		function ()
			for _, c in ipairs(client.get()) do
				if c.name == "WP34s" then
					c:kill()
					return
				end
			end

			awful.spawn("/home/avery/Documents/Applications/wp-34s/wp-34s/WP-34s", {
				titlebarsenabled = false
			})
		end,
        {description = "open wp34s calculator emulator", group = "custom"}),
	-- lock screen
	awful.key({}, "XF86Favorites",
        function ()
			os.execute("light-locker-command -l")
        end,
        {description = "lock screen", group = "custom"}),
	-- hibernate
	awful.key({ modkey }, "XF86Favorites",
        function ()
			os.execute("systemctl hibernate")
        end,
        {description = "hibernate system", group = "custom"}),
	-- toggle mpd
	awful.key({}, "XF86AudioPlay",
        function ()
			awful.spawn("playerctl play-pause")
        end,
        {description = "playerctl play-pause", group = "custom"}),
	awful.key({ altkey }, "XF86AudioMute",
        function ()
			theme.volume.toggle_mic_mute()
        end,
        {description = "mpd volume down", group = "mpd"}),
    awful.key({ modkey }, "g",
		function ()
			awful.spawn("steam")
		end,
              {description = "start steam", group = "launcher"})
)

-- client keys
keys.clientkeys = gears.table.join(
    awful.key({ modkey }, "f",
        function (c)
			c.fullscreen = not c.fullscreen
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift" }, "f",
        function (c)
			c.fullscreen = false
        end,
        {description = "disable fullscreen", group = "client"}),
	awful.key({ modkey, "Control" }, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c.fullscreen = not c.fullscreen
		end,
		{description = "reload window geometry", group = "client"}),
	awful.key({modkey, "Control" }, "t",
		function (c)
			awful.titlebar.toggle(c)
		end,
		{description = "toggle titlebar", group = "custom"}),
    awful.key({ modkey }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",
		function (c)
			awful.client.floating.toggle()
			c.ontop = true
		end,
              {description = "toggle floating", group = "client"}),
	awful.key({ modkey, altkey }, "s",
		function(c)
			c.sticky = not c.sticky
		end,
			  {description = "toggle sticky", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey }, "m",
        function (c)

			local opacity = c.maximized and 1 or 0
			c.maximized = not c.maximized
			c:raise()
			for _, client in ipairs(c.screen.clients) do
				if client ~= c and awful.client.focus.filter(client) then
					client.opacity = opacity
				end
			end
        end ,
        {description = "toggle maximized", group = "client"}),

    awful.key({ modkey, "Shift" }, "m",
        function (c)

			local opacity = c.maximized and 1 or 0
			c.maximized = false
			c:raise()
			for _, client in ipairs(c.screen.clients) do
				if client ~= c and awful.client.focus.filter(client) then
					client.opacity = opacity
				end
			end
        end ,
        {description = "unmaximize", group = "client"}),
	awful.key({ modkey }, "i",
		function (c)

			local float_properties = {
				placement = awful.placement.top+awful.placement.center_horizontal,
				above = true,
				sticky = true,
				skip_taskbar = true,
				floating = true,
				width = c.screen.geometry.width * 0.94,
				height = c.screen.geometry.height * 0.42
			}

			local normal_properties = {
				placement = awful.placement.top+awful.placement.center_horizontal,
				above = false,
				sticky = false,
				skip_taskbar = false,
				floating = false
			}

			if c.above and c.sticky then
				awful.rules.execute(c, normal_properties)
				awful.rules.apply(c)
			else
				awful.rules.execute(c, float_properties)
				awful.rules.execute(c, float_properties)
			end
		end,
		{description = "toggle client as popup", group = "custom"}),
	awful.key({ modkey, altkey}, "h",
		function (c)

			local tags = c.screen.tags
			local lasttag
			for _, t in ipairs(tags) do
				if t ~= c.tag then
					lasttag = t
				else

				end
			end
		end,
	{description = "switch to previous blank tag", group = "tag"}),

	awful.key({ modkey, altkey}, "l",
		function (c)

		end,
	{description = "switch to next blank tag", group = "tag"})
)

keys.taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

keys.tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 2, function()
		local instance = nil

		return function ()
			if instance and instance.wibox.visible then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ theme = { width = 250 } })
			end
		end
	end),
	awful.button({ }, 3, function(c)
		c:kill()
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
	end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

local tag_keys = {
	"1", "2", "3", "4", "5", "6", "7", "8", "9",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
	"XF86AudioMute", "XF86AudioLowerVolume", "XF86AudioRaiseVolume", "XF86AudioMicMute",
	"XF86MonBrightnessDown", "XF86MonBrightnessUp", "XF86Display", "XF86WLAN",
	"XF86Tools", "XF86Bluetooth", "XF86Launch2", "XF86Launch1"
}

for i, k in ipairs(tag_keys) do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 or i == 10 or i == 21 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client to tag #", group = "tag"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
    end
	if i > 21 then
		i = i - 12
	end

    keys.globalkeys = gears.table.join(keys.globalkeys,
        -- View tag only.
        awful.key({ modkey }, k,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Toggle tag display.
        awful.key({ modkey, "Control"}, k,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, k,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, k,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
    )
end

keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- append platform shortcuts
if not prefs.laptop then
	root.keys(gears.table.join(keys.globalkeys, pckeys))
	keys.globalkeys = gears.table.join(keys.globalkeys, pckeys)
else
	keys.globalkeys = gears.table.join(keys.globalkeys, laptopkeys)
end

-- {{{ Mouse bindings
-- buttons for the titlebar
keys.titlebar_buttons = gears.table.join(
	awful.button({ }, 1, function()
		local c = mouse.object_under_pointer()
		c:emit_signal("request::activate", "titlebar", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({ }, 3, function()
		local c = mouse.object_under_pointer()
		c:emit_signal("request::activate", "titlebar", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

keys.root_buttons = gears.table.join(
    awful.button({ }, 3, function () feign.widget.main_menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)
-- }}}

-- set keys
root.keys(keys.globalkeys)
root.buttons(keys.root_buttons)

return keys

-- }}}