local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local prefs = require("prefs")
local helpers = require("lame.helpers")
local lame = require("lame")
local mouse = mouse
local os = os
local beautiful = require("beautiful")

local prefs = require("prefs")

local modkey       = "Mod4"
local altkey       = "Mod1"

local keys = {}

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
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
    awful.key({ modkey, "Shift" }, "Return",
		helpers.terminal_same_directory,
		{description = "new terminal w/ same directory", group = "launcher"}),
	-- Toggle redshift with Mod+Shift+t
    awful.key({ modkey, "Shift" }, "t",
		function ()
			lame.widget.redshift:toggle()
		end,
		{description = "toggle redshift", group = "widgets"}),
	-- train popup
	awful.key({ altkey, modkey}, "t",
		function ()
			cmd = "source $HOME/.extra.zsh && trains"
			awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
				naughty.notify({text = stdout})
			end)
		end
	),
	--Toggle widgets with 1-5 macro keys
	awful.key({}, "XF86Launch5",
		function ()
			lame.widget.task.show()
        end,
        {description = "task popup", group = "widgets"}),
	awful.key({}, "XF86Launch6",
		function ()
			lame.widget.cal.toggle()
		end,
		  {description = "show cal", group = "widgets"}),
    awful.key({}, "XF86Launch7",
		function ()
			lame.widget.weather.toggle()
		end,
        {description = "toggle weather popup", group = "widgets"}),
    awful.key({}, "XF86Launch8",
		function ()
			lame.widget.fs.toggle()
		end,
              {description = "show filesystem", group = "widgets"}),
	--Task prompt
	awful.key({}, "XF86Launch9",
		function ()
			lame.widget.task.prompt()
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
    awful.key({ modkey, "Shift" }, "y",
		hotkeys_popup.show_help,
		{description = "show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey }, "Left",
		awful.tag.viewprev,
		{description = "view previous", group = "tag"}),
    awful.key({ modkey }, "Right",
		awful.tag.viewnext,
		{description = "view next", group = "tag"}),
    awful.key({ modkey }, "Escape",
		awful.tag.history.restore,
		{description = "go back", group = "tag"}),
	awful.key({ altkey }, "h",
		awful.tag.viewprev,
		{description = "view previous", group = "tag"}),
    awful.key({ altkey }, "l",
		awful.tag.viewnext,
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
    awful.key({ modkey, altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus left index", group = "client"}
    ),
	-- (This has been modified to be the opposite of the default)
    awful.key({ modkey, altkey }, "k",
        function ()
            awful.client.focus.byidx(1)
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
			lame.widget.main_menu:toggle()
		end,
		{description = "show main menu", group = "awesome"}),
	-- key modes
	awful.key({ altkey }, "f",
		function ()
			root.keys(keys.quick_keys)
			lame.widget.keymodebox.set_text("- QUICK -")
		end,
		{description = "enable quick key mode", group = "hotkeys"}),
	awful.key({ modkey }, "f",
		function ()
			root.keys(keys.quick_keys)
			lame.widget.keymodebox.set_text("- QUICK -")
		end,
		{description = "enable quick key mode", group = "hotkeys"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",
		function ()
			awful.client.swap.byidx(-1)
		end,
		{description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",
		function ()
			awful.client.swap.byidx(1)
		end,
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
		awful.tag.history.restore,
        {description = "switch to previous tag", group = "tag"}),

    awful.key({ modkey }, "]",
		helpers.stacknext,
		{description = "cycle forward between minimized windows", group = "client"}),
    awful.key({ modkey }, "[",
		helpers.stackprev,
		{description = "cycle backwards between minimized windows", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
            end
        end,
        {description = "toggle wibox", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "b", function ()
            for s in screen do
                s.mywibox.visible = true
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
		helpers.move_tag_left,
		{description = "move tag to the left", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Right",
		helpers.move_tag_right,
		{description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, "Shift" }, "d",
		helpers.delete_tag,
		{description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey }, "Return",
		function ()
			awful.spawn(prefs.terminal)
		end,
		{description = "open a terminal", group = "launcher"}),
    awful.key({ altkey }, "Return",
		function ()
			awful.spawn(prefs.terminal)
		end,
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
    awful.key({ modkey, "Shift" }, "h",
		function ()
			awful.tag.incnmaster( 1, nil, true)
		end,
		{description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift" }, "l",
		function ()
			awful.tag.incnmaster(-1, nil, true)
		end,
		{description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",
		function ()
			awful.tag.incncol( 1, nil, true)
		end,
		{description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",
		function ()
			awful.tag.incncol(-1, nil, true)
		end,
		{description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey }, "space",
		function ()
			awful.layout.set(awful.layout.suit.tile)
		end,
		{description = "switch between tile left and tile above", group = "layout"}),
    awful.key({ modkey, "Control" }, "n",
		helpers.unminimize,
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
			lame.widget.cal.toggle()
		end,
              {description = "toggle cal", group = "widgets"}),
    awful.key({ altkey, modkey}, "f",
		function ()
			lame.widget.fs.toggle()
		end,
              {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey, modkey}, "w",
		function ()
			lame.widget.weather.toggle()
		end,
        {description = "toggle weather popup", group = "widgets"}),
    -- Pulse volume control
	awful.key({}, "XF86AudioRaiseVolume", lame.widget.volume.inc,
		{description = "volume up", group = "hotkeys"}),
	awful.key({}, "XF86AudioLowerVolume", lame.widget.volume.dec,
        {description = "volume down", group = "hotkeys"}),
	awful.key({}, "XF86AudioMute", lame.widget.volume.toggle_mute,
        {description = "toggle mute", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "m", lame.widget.volume.toggle_mute,
        {description = "toggle mute", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "0", lame.widget.volume.set,
        {description = "volume 0%", group = "hotkeys"}),

    -- MPD control
	awful.key({ altkey, "Shift" }, "'",
		function ()
			awful.spawn("playerctl play-pause")
		end,
		{description = "playerctl play-pause", group = "custom"}),
    awful.key({ altkey }, "'", lame.widget.mpd.toggle,
        {description = "mpc toggle", group = "mpd"}),
    awful.key({ altkey }, ";", lame.widget.mpd.stop,
        {description = "mpc stop", group = "mpd"}),
    awful.key({ altkey }, "[",
        function ()
			lame.widget.mpd.prev()
        end,
        {description = "mpc prev", group = "mpd"}),
    awful.key({ altkey }, "]",
        function ()
			lame.widget.mpd.next()
        end,
        {description = "mpc next", group = "mpd"}),
    awful.key({ altkey }, "=",
        function ()
			lame.widget.mpd.seek(10)
        end,
        {description = "mpc seek +10", group = "mpd"}),
    awful.key({ altkey }, "-",
        function ()
			lame.widget.mpd.seek(-10)
        end,
        {description = "mpc seek -10", group = "mpd"}),
	awful.key({ altkey }, "0",
        function ()
			lame.widget.mpd.seek(0)
        end,
        {description = "restart song", group = "mpd"}),
	awful.key({ modkey }, "Up",
        function ()
			lame.widget.mpd.volume(5)
        end,
        {description = "mpd volume up", group = "mpd"}),
	awful.key({ modkey }, "Down",
        function ()
			lame.widget.mpd.volume(-5)
        end,
        {description = "mpd volume down", group = "mpd"}),
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
				keypressed_callback = function(mod, key, cmd)
					if mod.Control and key == "v" then
						clip = helpers.capture("xclip -out -selection clipboard")
						return true, cmd .. clip
					end
				end,
				hooks = {
					{{}, "Return", function(cmd)
						return helpers.parse_for_special_run_commands(cmd)
					end}
				},
				textbox = awful.screen.focused().mypromptbox.widget,
				history_path = gears.filesystem.get_dir("cache") .. "/history",
				completion_callback = awful.completion.shell,
				exe_callback = function(cmd)
					local call = helpers.parse_for_line_callback_commands(cmd)
					local command = "source $HOME/.func.zsh && "..cmd
					if not call then
						awful.spawn.with_shell(command)
					else
						awful.spawn.easy_async_with_shell(command, call)
					end
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
		lame.widget.brightness.increase,
		{description = "brightness up", group = "hotkeys"}),

    awful.key({ }, "XF86MonBrightnessDown",
		lame.widget.brightness.decrease,
		{description = "brightness down", group = "hotkeys"}),
	awful.key({ modkey, altkey }, "b",
		lame.widget.brightness.prompt ,
		{description = "brightness prompt", group = "custom"}),
	-- mute microphone
	awful.key({}, "XF86AudioMicMute",
        function ()
			lame.widget.volume.toggle_mic_mute()
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
              {description = "disable trackpad", group = "custom"})
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
			lame.widget.volume.toggle_mic_mute()
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
	awful.key({ modkey }, "v",
		function (c)
			c.fullscreen = not c.fullscreen
		end,
		{description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift" }, "v",
        function (c)
			c.fullscreen = false
        end,
        {description = "disable fullscreen", group = "client"}),
	awful.key({ modkey, "Control" }, "v",
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
	end),
	awful.button({ }, 8, helpers.stackprev),
	awful.button({ }, 9, helpers.stacknext)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

local tag_keys = {}

if not prefs.laptop then
	tag_keys = {
		"1", "2", "3", "4", "5", "6", "7", "8", "9",
		"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"
	}
else
	tag_keys = {
		"1", "2", "3", "4", "5", "6", "7", "8", "9",
		{"F1",  "XF86AudioMute"},         {"F2",  "XF86AudioLowerVolume"},
		{"F3",  "XF86AudioRaiseVolume"},  {"F4",  "XF86AudioMicMute"},
		{"F5",  "XF86MonBrightnessDown"}, {"F6",  "XF86MonBrightnessUp"},
		{"F7",  "XF86Display"},           {"F8",  "XF86WLAN"},
		{"F9",  "XF86Tools"},             {"F10", "XF86Bluetooth"},
		{"F11", "XF86Launch2"},           {"F12", "XF86Launch1"}
	}
end

local create_num_keys = function(key_func, keymaps)
	if not keymaps then keymaps = tag_keys end
	local keytable = {}

	for i, k in ipairs(keymaps) do
		-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
		local descr_view, descr_toggle, descr_move, descr_toggle_focus
		if i == 1 or i == 9 or i == 10 or i == 21 then
			descr_view = {description = "view tag #", group = "tag"}
			descr_toggle = {description = "toggle tag #", group = "tag"}
			descr_move = {description = "move focused client to tag #", group = "tag"}
			descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
		end

		local key_list = {}
		if type(k) == "table" then
			key_list = k
		else
			key_list[1] = k
		end

		for _, key in ipairs(key_list) do
			local temp = key_func(i, key, descr_view, descr_toggle, descr_move, descr_toggle_focus)
			for _, x in ipairs(temp) do
				keytable = gears.table.join(keytable, x)
			end

			-- Only show first in list for help
			descr_view = nil
			descr_toggle = nil
			descr_move = nil
			descr_toggle_focus = nil
		end

	end

	return keytable
end

keys.globalkeys = gears.table.join(keys.globalkeys, create_num_keys(
	function (i, key, descr_view, descr_toggle, descr_move, descr_toggle_focus)
		return {
			-- View tag only.
			awful.key({ modkey }, key,
			function () helpers.view_tag_index(i) end,
			descr_view),
			-- Toggle tag display.
			awful.key({ modkey, "Control"}, key,
			function () helpers.toggle_tag_index(i) end,
			descr_toggle),
			-- Move client to tag.
			awful.key({ modkey, "Shift" }, key,
			function () helpers.move_client_to_tag_index(i) end,
			descr_move),
			-- Toggle tag on focused client.
			awful.key({ modkey, "Control", "Shift" }, key,
			function () helpers.toggle_client_in_tag_index(i) end,
			descr_toggle_focus)
		}
end))

keys.mode_keys = gears.table.join(
	awful.key({}, "Escape",
		function ()
			root.keys(keys.globalkeys)
			lame.widget.keymodebox.set_text("")
		end
	),
	awful.key({}, "f",
		function ()
			root.keys(keys.quick_keys)
			lame.widget.keymodebox.set_text("- QUICK -")
		end)
)

keys.quickrun_keys = gears.table.join(
	awful.key({}, "t",
		function () awful.spawn(prefs.terminal) end),
	awful.key({ "Shift" }, "t",
		helpers.terminal_same_directory),
	awful.key({}, "q",
		function () awful.spawn(prefs.browser) end),
	awful.key({}, "d",
		function () awful.spawn("discord") end),
	awful.key({}, "c",
		function () awful.spawn("chromium") end),
	awful.key({}, "g",
		function () awful.spawn("steam") end),
	awful.key({}, "e",
		function () awful.spawn("flatpak run com.todoist.Todoist") end),
	awful.key({}, "r",
		function () awful.spawn("dmenu_run -nb '#000000' -sb '#428ff4'") end),
	awful.key({}, "s",
		function () awful.spawn("flatpak run com.github.IsmaelMartinez.teams_for_linux") end),
	awful.key({}, "b",
		function () awful.spawn("bitwarden") end),
	awful.key({}, "v", lame.widget.visualizer.toggle),
	awful.key({ "Shift" }, "v", lame.widget.fluidsim.toggle)
)

keys.quickmove_keys = gears.table.join(
	awful.key({}, "a",
		function () awful.client.swap.byidx(-1) end),
	awful.key({}, "d",
		function () awful.client.swap.byidx(1) end),
	awful.key({}, "q",
		helpers.move_tag_left),
	awful.key({}, "e",
		helpers.move_tag_right),
	awful.key({}, "s",
		function () client.focus:move_to_screen() end),
	awful.key({ "Shift" }, "s",
		function ()
			helpers.swap_monitor_tags()
		end)
)

keys.quickresize_keys = gears.table.join(
	awful.key({}, "w",
		function () awful.tag.incnmaster(1,nil,true) end),
	awful.key({}, "a",
		function () awful.tag.incmwfact(-0.1) end),
	awful.key({}, "s",
		function () awful.tag.incnmaster(-1,nil,true) end),
	awful.key({}, "d",
		function () awful.tag.incmwfact(0.1) end),
	awful.key({}, "Tab",
		function ()
			awful.tag.setmwfact(0.5)
			awful.screen.focused().selected_tag.master_count = 1
		end)
)

keys.quickfirefox_keys = gears.table.join(
	awful.key({}, "e",
		function ()
			helpers.keypress("Ctrl+e")
		end),
	awful.key({}, "w",
		function ()
			helpers.keypress("Ctrl+Shift+Tab")
		end),
	awful.key({}, "a",
		function ()
			helpers.keypress("Ctrl+Shift+Tab")
		end),
	awful.key({}, "s",
		function ()
			helpers.keypress("Ctrl+Tab")
		end),
	awful.key({}, "d",
		function ()
			helpers.keypress("Ctrl+Tab")
		end),
	awful.key({}, "q",
		function ()
			helpers.keypress("F1")
		end),
	awful.key({}, "x",
		function ()
			helpers.keypress("Ctrl+w")
		end),
	awful.key({ "Shift" }, "x",
		function ()
			helpers.keypress("Ctrl+Shift+t")
		end),
	awful.key({}, "r",
		function ()
			helpers.keypress("Ctrl+r")
		end),
	awful.key({}, "t",
		function ()
			helpers.keypress("Ctrl+t")
		end)
)

keys.quickmedia_keys = gears.table.join(
	awful.key({}, "s",
		lame.widget.mpd.toggle),
	awful.key({}, "w",
		lame.widget.mpd.stop),
	awful.key({}, "d",
		lame.widget.mpd.next),
	awful.key({}, "a",
		lame.widget.mpd.prev),
	awful.key({}, "q",
		function () lame.widget.mpd.seek(-10) end),
	awful.key({}, "e",
		function () lame.widget.mpd.seek(10) end),
	awful.key({}, "1",
		lame.widget.volume.dec),
	awful.key({}, "2",
		lame.widget.volume.inc),
	awful.key({ "Shift" }, "s",
		function () awful.spawn("playerctl play-pause") end),
	awful.key({ "Shift" }, "w",
		function () awful.spawn("playerctl stop") end),
	awful.key({ "Shift" }, "d",
		function () awful.spawn("playerctl next") end),
	awful.key({ "Shift" }, "a",
		function () awful.spawn("playerctl previous") end),
	awful.key({ "Shift" }, "q",
		function () awful.spawn("playerctl position -10") end),
	awful.key({ "Shift" }, "e",
		function () awful.spawn("playerctl position +10") end),
	awful.key({ "Shift" }, "1",
		function () lame.widget.mpd.volume(-5) end),
	awful.key({ "Shift" }, "2",
		function () lame.widget.mpd.volume(5) end)
)

keys.quick_keys = gears.table.join(
	awful.key({}, "a",
		awful.tag.viewprev),
	awful.key({}, "d",
		awful.tag.viewnext),
	awful.key({}, "q",
		function () awful.screen.focus_bydirection("left") end),
	awful.key({}, "e",
		function () awful.screen.focus_bydirection("right") end),
	awful.key({}, "t",
		function () awful.spawn(prefs.terminal) end),
	awful.key({ "Shift" }, "a",
		function () awful.client.focus.byidx(-1) end),
	awful.key({ "Shift" }, "d",
		function () awful.client.focus.byidx(1) end),
	awful.key({ "Shift" }, "q",
		helpers.stackprev),
	awful.key({ "Shift" }, "e",
		helpers.stacknext),
	awful.key({ "Shift" }, "f",
		function ()
			local c = client.focus
			if c then
				c.fullscreen = not c.fullscreen
			end
		end),
	awful.key({}, "Tab",
		awful.tag.history.restore),
	awful.key({}, "z",
		function ()
			local c = client.focus
			if c then
				c.minimized = true
			end
		end),
	awful.key({ "Shift" }, "z",
		helpers.unminimize),
	awful.key({}, "v",
		function ()
			root.keys(keys.quickmove_keys)
			lame.widget.keymodebox.set_text("- MOVE -")
		end),
	awful.key({}, "r",
		function ()
			root.keys(keys.quickrun_keys)
			lame.widget.keymodebox.set_text("- RUN -")
		end),
	awful.key({ "Shift" }, "r",
		function ()
			root.keys(keys.quickresize_keys)
			lame.widget.keymodebox.set_text("- RESIZE -")
		end),
	awful.key({}, "g",
		function ()
			root.keys(keys.quickmedia_keys)
			lame.widget.keymodebox.set_text("- MEDIA-")
		end),
	awful.key({}, "c",
		function ()
			local jointable = nil;
			local mode_text;
			local c = client.focus
			if not c then return end
			if c.class == "firefox" then
				jointable = keys.quickfirefox_keys
				mode_text = "- FIREFOX -"
			end

			if jointable then
				root.keys(keys.quickfirefox_keys)
				lame.widget.keymodebox.set_text(mode_text)
			end
		end)
)

-- add tag number shortcuts
keys.quick_keys = gears.table.join(keys.quick_keys, create_num_keys(
	function (i, key)
		return {
			-- view tag
			awful.key({}, key,
				function ()
					helpers.view_tag_index(i)
				end),
			awful.key({ "Shift" }, key,
				function ()
					helpers.toggle_tag_index(i)
				end)
		}
	end
))

keys.quickmove_keys = gears.table.join(keys.quickmove_keys, create_num_keys(
	function (i, key)
		return {
			-- move client to tag
			awful.key({}, key,
				function ()
					helpers.move_client_to_tag_index(i)
				end),
			awful.key({ "Shift" }, key,
				function ()
					helpers.move_client_to_tag_index(i)
					helpers.view_tag_index(i)
				end)
		}
	end
))

keys.quickfirefox_keys = gears.table.join(keys.quickfirefox_keys, create_num_keys(
	function (i,key)
		return {
			awful.key({}, key,
			function ()
				helpers.keypress("Alt+"..key)
			end)
		}
	end, {"1","2","3","4","5","6","7","8","9"}
))

-- join quick key tables ahead of time
keys.quick_keys = gears.table.join(keys.globalkeys, keys.quick_keys, keys.mode_keys)
keys.quickrun_keys = gears.table.join(keys.globalkeys, keys.quickrun_keys, keys.mode_keys)
keys.quickmove_keys = gears.table.join(keys.globalkeys, keys.quickmove_keys, keys.mode_keys)
keys.quickresize_keys = gears.table.join(keys.globalkeys, keys.quickresize_keys, keys.mode_keys)
keys.quickfirefox_keys = gears.table.join(keys.globalkeys, keys.quickfirefox_keys, keys.mode_keys)
keys.quickmedia_keys = gears.table.join(keys.globalkeys, keys.quickmedia_keys, keys.mode_keys)

keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- append platform shortcuts
if not prefs.laptop then
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
    awful.button({ }, 3, function () lame.widget.main_menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)
-- }}}

-- set keys
root.keys(keys.globalkeys)
root.buttons(keys.root_buttons)

return keys

-- }}}
