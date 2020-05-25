--[[

     Awesome WM configuration template
     github.com/lcpz

--]]

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- Slightly different configs for different machines
configs = {
	"elrond", -- 1
	"aragorn" -- 2
}
selectedConfig = configs[1]

doSloppyFocus = true
keyboardLayouts = {"default", "celeste"}
selectedKeyboardLayout = 1
numKeyboardLayouts = 2
shaders = {"transparent", "grayscale", "crt-pi", "crt-aperture", "none"}
selectedShader = 1
numShaders = 5

--local battery = require("awesome-upower-battery")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- check if a window is focusable - used in automatic tag hiding

function focusable(clients)
	local out_clients = {}
	for _, c in ipairs(clients) do
		if awful.client.focus.filter(c) then
			table.insert(out_clients, c)
		end
	end
	return out_clients
end

-- {{{ Variable definitions

local themes = {
    "blackburn",       -- 1
    "copland",         -- 2
    "dremora",         -- 3
    "holo",            -- 4
    "multicolor",      -- 5
    "powerarrow",      -- 6
    "powerarrow-dark", -- 7
    "rainbow",         -- 8
    "steamburn",       -- 9
    "vertex",          -- 10
}

local chosen_theme = themes[5]
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "urxvt"
local editor       = "vim"
local gui_editor   = "gvim"
local browser      = "firefox"
local guieditor    = "atom"
local scrlocker    = "xlock"

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)

awful.util.terminal = terminal
awful.util.tagnames = { "ff(1)", "term(2)", "3", "4", "5" }
awful.layout.layouts = {
    awful.layout.suit.tile,
	awful.layout.suit.tile,
	awful.layout.suit.tile,
	awful.layout.suit.tile,
	awful.layout.suit.tile
}

-- {{{ Special run prompt commands
-- Convert to string to terminal emulator syntax if in terminal_programs
-- Also sets the instance of program to the command name; may need changing if terminal ~= urxvt(c)
local function terminal_program(cmd)
	local program = cmd:match("^([^ ]+)")
	return terminal .. " -name " .. program .. " -e " .. cmd
end

local function popup_program(cmd)
	return terminal .. " -name popup -bg black -geometry 160x20 -e zsh -c \"source ~/.zshrc && " .. cmd .. "\""
end

local function popup_when_no_args(cmd)
	if cmd:match(" ") then
		return cmd
	else
		return popup_program(cmd)
	end
end

local special_run_commands = {
	{"ncmpcpp", terminal_program},
	{"n", popup_program},
	{"t", popup_program},
	{"sym", popup_program},
	{"vim", terminal_program},
	{"htop", terminal_program},
	{"top", terminal_program},
	{"man", terminal_program},
	{"m", popup_when_no_args},
	{"mp", popup_when_no_args},
	{"tx", popup_program},
	{"td", popup_program},
}

local function parse_for_special_run_commands(in_cmd)
	local command = in_cmd:match("^([^ ]+)")
	for _, cmd in ipairs(special_run_commands) do
		if command == cmd[1] then
			return cmd[2](in_cmd)
		end
	end
	return in_cmd
end
-- }}} Special run prompt commands

-- {{{ Helper functions
local function client_instance_exists(clients, instance)
	for _, c in ipairs(clients) do
		if c.instance == instance then
			return c
		end
	end
	return false
end

function focusable(clients)
	local out_clients = {}
	for _, c in ipairs(clients) do
		if awful.client.focus.filter(c) then
			table.insert(out_clients, c)
		end
	end
	return out_clients
end

-- {{{ Helper functions
local function client_instance_exists(clients, instance)
	for _, c in ipairs(clients) do
		if c.instance == instance then
			return c
		end
	end
	return false
end

-- Accepts rules; however, the current release (4.2) applies rules in a weird order: rules won't work
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.easy_async_with_shell(string.format("pgrep -u $USER -x '%s' > /dev/null", cmd[1]),
			function(stdout, stderr, reason, exit_code)
				if exit_code ~= 0 then
					awful.spawn(parse_for_special_run_commands(cmd[1]), cmd[2])
				end
			end
		)
	end
end

run_once({
	{"thunderbird"},
	--{"redshift -r"},
	{"firefox"},
	{"discord"},
	{"unclutter --timeout 5"},
	{"mpd"},
	{"compton --backend glx --force-win-blend --use-damage --glx-fshader-win '\
		uniform float opacity;\
		uniform bool invert_color;\
		uniform sampler2D tex;\
		void main() {\
			vec4 c = texture2D(tex, gl_TexCoord[0].xy);\
			if (!invert_color) { // Hack to allow compton exceptions\
				// Change the vec4 to your desired key color\
				//vec4 vdiff = abs(vec4(0.0039, 0.0039, 0.0039, 1.0) - c); // #010101\
				vec4 vdiff = abs(vec4(0, 0.0039, 0.0078, 1.0) - c); // #000102\
				float diff = max(max(max(vdiff.r, vdiff.g), vdiff.b), vdiff.a);\
				// Change the vec4 to your desired output color\
				if (diff < 0.001)\
					c = vec4(0.0, 0.0, 0.0, 0.7); // #000000E3\
					//c = vec4(0.0, 0.0, 0.0, 0.890196); // #000000E3\
			}\
			c *= opacity;\
			gl_FragColor = c;\
		}'\
	 "};
})

-- append platform run_once
if selectedConfig == "elrond" then
	run_once({
		{"light-locker"}
	})
elseif selectedConfig == "aragorn" then
	run_once({
		{"NetworkManager"},
		{"nm-applet"}
	})
end

awful.util.taglist_buttons = gears.table.join(
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

awful.util.tasklist_buttons = gears.table.join(
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
end))

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}
awful.util.mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or 16,
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

client.connect_signal("focus", function(c)
	c.opacity=1
	for _, client in ipairs(c.screen.clients) do
		if not c.floating and client.maximized and client ~= c and client.name ~= "sh" then
			client.opacity=0
		end
	end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
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
			os.execute("scrot -e 'mv $f ~/Pictures/Screenshots/'") 
			naughty.notify({text = "screenshot taken"})
		end,
        {description = "take a scrot screenshot", group = "hotkeys"}),

	awful.key({ modkey }, "s", function() 
		awful.spawn.with_shell("sleep 0.2;scrot -sfe 'mv $f ~/Pictures/Screenshots/';zsh;")
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
			awful.spawn.with_shell(terminal ..
				" -cd \"$([ -f " .. term_id .. " ] && \
				readlink -e /proc/$(cat " .. term_id .. ")/cwd || \
				echo $HOME)\""
			)

		end,
        	  {description = "new terminal w/ same directory", group = "launcher"}),
	-- Toggle redshift with Mod+Shift+t
    awful.key({ modkey, "Shift" }, "t", 
		function () 
			lain.widget.contrib.redshift:toggle() 
		end,
		{description = "task popup", group = "widgets"}),
	--Task prompt
	awful.key({ altkey, modkey}, "t", 
		function ()
			lain.widget.contrib.task.prompt()
		end
	),
	--Toggle task popup
	awful.key({ altkey, modkey}, "u", 
		function () 
			lain.widget.contrib.task.show(scr) 
		end),

	--Toggle widgets with 1-5 macro keys
	awful.key({}, "XF86Launch5", 
		function ()
			lain.widget.contrib.task.show(scr) 
        end,
        {description = "task popup", group = "widgets"}),
	awful.key({}, "XF86Launch6", 
		function ()
			if not cal.notification then
				cal.show(0)
			else
				naughty.destroy(cal.notification)
				cal.hide()
			end

		end,
		  {description = "show cal", group = "widgets"}),
    awful.key({}, "XF86Launch7", 
		function () 
			if beautiful.weather then 
				if not beautiful.weather.notification then
					beautiful.weather.show(0)
				else
					naughty.destroy(beautiful.weather.notification)
					beautiful.weather.hide()
				end
			end 
		end,
        {description = "show weather", group = "widgets"}),
    awful.key({}, "XF86Launch8", 
		function () 
			if beautiful.fs then 
				if not beautiful.fs.notification then
					beautiful.fs.show(0)
				else
					naughty.destroy(beautiful.fs.notification)
					beautiful.fs.hide()
				end
			end 
		end,
              {description = "show filesystem", group = "widgets"}),
	--Task prompt
	awful.key({}, "XF86Launch9", 
		function ()
			lain.widget.contrib.task.prompt()
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
    awful.key({ modkey,           }, "y",      hotkeys_popup.show_help,
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

    -- Default client focus
	-- (This has been modified to be the opposite of the default)
    awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus left index", group = "client"}
    ),
	-- (This has been modified to be the opposite of the default)
    awful.key({ altkey,           }, "k",
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
    awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
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
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end,
              {description = "add new tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
              {description = "rename tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Left", 
		function () 
			local current_tag = awful.screen.focused().selected_tag
			local current_name = current_tag.name
			local old_index = current_tag.index
			lain.util.move_tag(-1) 
			local new_tag = awful.screen.focused().tags[old_index]

			if current_tag and new_tag then
				current_tag.name = new_tag.name
				new_tag.name = current_name
			end

			if t then

			end
		end,
              {description = "move tag to the left", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Right", 
		function () 
			local current_tag = awful.screen.focused().selected_tag
			local current_name = current_tag.name
			local old_index = current_tag.index
			lain.util.move_tag(1) 
			local new_tag = awful.screen.focused().tags[old_index]

			if current_tag and new_tag then
				current_tag.name = new_tag.name
				new_tag.name = current_name
			end

			if t then

			end
		end,
              {description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
              {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
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
    awful.key({ modkey,           }, "space", 
		function ()
			awful.layout.inc(1)
		end,
              {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", 
		function ()
			awful.layout.inc(-1)
		end,
              {description = "select previous layout", group = "layout"}),

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
			if theme.mytextclock then
				theme.mytextclock:force_update()
			end

			if not cal.notification then
				cal.show(0)
			else
				naughty.destroy(cal.notification)
				cal.hide()
			end

		end,
              {description = "show cal", group = "widgets"}),
    awful.key({ altkey, modkey}, "f", 
		function () 
			if beautiful.fs then 
				if not beautiful.fs.notification then
					beautiful.fs.show(0)
				else
					naughty.destroy(beautiful.fs.notification)
					beautiful.fs.hide()
				end
			end 
		end,
              {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey, modkey}, "w", 
		function () 
			if beautiful.weather then 
				if not beautiful.weather.notification then
					beautiful.weather.show(0)
				else
					naughty.destroy(beautiful.weather.notification)
					beautiful.weather.hide()
				end
			end 
		end,
        {description = "show weather", group = "widgets"}),
    -- Pulse volume control
	awful.key({}, "XF86AudioRaiseVolume",
        function ()
			os.execute(string.format("pactl set-sink-volume %d +2%%", theme.volume.device))
			theme.volume.update()
        end,
        {description = "volume up", group = "hotkeys"}),

	awful.key({}, "XF86AudioLowerVolume", 
		function ()
			os.execute(string.format("pactl set-sink-volume %d -2%%", theme.volume.device))
			theme.volume.update()
        end,
        {description = "volume down", group = "hotkeys"}),
	awful.key({}, "XF86AudioMute",
        function ()
			os.execute(string.format("pactl set-sink-mute %d toggle", theme.volume.device))
			theme.volume.update()
        end,
        {description = "toggle mute", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "m",
        function ()
           os.execute(string.format("amixer -D pulse set Master toggle"))
            beautiful.volume.update()
        end,
        {description = "volume 100%", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "0",
        function ()
            os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        {description = "volume 0%", group = "hotkeys"}),

    -- MPD control
    awful.key({ altkey }, "'",
        function ()
            awful.spawn.with_shell("mpc toggle")
            beautiful.mpd.update()
        end,
        {description = "mpc toggle", group = "mpd"}),
    awful.key({ altkey }, ";",
        function ()
            awful.spawn.with_shell("mpc stop")
            beautiful.mpd.update()
        end,
        {description = "mpc stop", group = "mpd"}),
    awful.key({ altkey }, "[",
        function ()
            awful.spawn.with_shell("mpc prev")
            beautiful.mpd.update()
        end,
        {description = "mpc prev", group = "mpd"}),
    awful.key({ altkey }, "]",
        function ()
            awful.spawn.with_shell("mpc next")
            beautiful.mpd.update()
        end,
        {description = "mpc next", group = "mpd"}),
    awful.key({ altkey }, "=",
        function ()
            awful.spawn.with_shell("mpc seek +10")
            beautiful.mpd.update()
        end,
        {description = "mpc seek +10", group = "mpd"}),
    awful.key({ altkey }, "-",
        function ()
            awful.spawn.with_shell("mpc seek -10")
            beautiful.mpd.update()
        end,
        {description = "mpc seek -10", group = "mpd"}),   
	awful.key({ altkey }, "0",
        function ()
			os.execute("mpc seek 0")
        end,
        {description = "restart song", group = "mpd"}),
	awful.key({ modkey }, "Up",
        function ()
			os.execute("mpc volume +5")
            beautiful.mpd.update()
        end,
        {description = "mpd volume up", group = "mpd"}),   
	awful.key({ modkey }, "Down",
        function ()
			os.execute("mpc volume -5")
            beautiful.mpd.update()
        end,
        {description = "mpd volume down", group = "mpd"}),
	awful.key({ modkey }, "v",
		function()
			local s = awful.screen.focused()
			local c = client_instance_exists(s.all_clients, "vis")
			if c then
				c:kill()	
			else -- Terminal basically has to be urxvt here
				beautiful.spawn_visualizer(s, terminal)
			end
		end,
		{description = "toggle visualizer", group = "mpd"}),
    -- User programs
    awful.key({ modkey }, "q", 
		function () 
			awful.spawn(browser, {maximized = false}) 
		end,
              {description = "run browser", group = "launcher"}),
    awful.key({ modkey }, "a", 
		function () 
			os.execute("rofi -show window -disable-history");
		end,
              {description = "run browser not maximized", group = "launcher"}),

    awful.key({ modkey }, "`", 
		function () 
			selectedKeyboardLayout = selectedKeyboardLayout + 1

			if selectedKeyboardLayout > numKeyboardLayouts then
				selectedKeyboardLayout = selectedKeyboardLayout - numKeyboardLayouts
			end

			-- load custom layout
			local cmd = "xmodmap ~/.config/xmodmap/" .. keyboardLayouts[selectedKeyboardLayout] .. ".xmodmap"

			-- also reload home layout if default is selected
			if keyboardLayouts[selectedKeyboardLayout] == "default" then
				cmd = cmd .. " ~/.Xmodmap"
			end

			os.execute(cmd)

			naughty.notify({text = "Keyboard layout '" .. keyboardLayouts[selectedKeyboardLayout] .. "' selected"})
		end,
              {description = "change keyboard layout", group = "custom"}),
	-- work-in-progress shader changer
	awful.key({ modkey }, "\\",
		function() 
			selectedShader = selectedShader + 1

			if selectedShader > numShaders then
				selectedShader = selectedShader - numShaders
			end
			--os.execute("pkill compton && compton --backend glx --force-win-blend --unredir-if-possible --glx-no-stencil --glx-no-rebind-pixmap --use-damage --sw-opti --glx-fshader-win '$(cat ~/Documents/shaders/" .. shaders[selectedShader] .. ")'")
			if shaders[selectedShader] ~= "none" then
				--naughty.notify({text = "pkill compton && compton --backend glx --force-win-blend --unredir-if-possible --glx-no-stencil --glx-no-rebind-pixmap --use-damage --sw-opti --glx-fshader-win '$(cat ~/Documents/shaders/" .. shaders[selectedShader] .. ".glsl)'"})
				--os.execute("pkill compton && sleep 2 && sh -c 'compton --backend glx --force-win-blend --unredir-if-possible --glx-no-stencil --glx-no-rebind-pixmap --use-damage --sw-opti --glx-fshader-win \"$(cat ~/Documents/shaders/" .. shaders[selectedShader] .. ")\"'")
				naughty.notify({text = "Shader " .. shaders[selectedShader] .. " selected"})
			else
				--os.execute("pkill compton && sleep 1 && compton")
				naughty.notify({text = "Shaders disabled"})
			end
		end,
			{description = "change shader", group = "custom"}),
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

    awful.key({ modkey }, "x", 
		function ()
			awful.prompt.run {
				prompt = "Run: ",
				hooks = {
					{{}, "Return", function(cmd)
						return parse_for_special_run_commands(cmd)
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
laptopkeys = gears.table.join(
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
	awful.key({}, "XF86Tools",
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
    awful.key({ }, "XF86Display",
		function ()
			os.execute('xinput enable $(xinput list | grep -oP "Synaptics TM3276.*id=\\K(\\d+)")')
		end,
              {description = "enable trackpad", group = "custom"}),
    awful.key({ }, "XF86Bluetooth",
		function ()
			os.execute('xinput disable $(xinput list | grep -oP "Synaptics TM3276.*id=\\K(\\d+)")')
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
pckeys = gears.table.join(
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
            awful.spawn.with_shell("mpc toggle")
            beautiful.mpd.update()
        end,
        {description = "mpc toggle", group = "mpd"}),
	awful.key({ modkey }, "XF86AudioMute",
        function ()
			os.execute("mpc volume 100")
            beautiful.mpd.update()
        end,
        {description = "mpd volume down", group = "mpd"}),
    awful.key({ modkey }, "g",
		function ()
			awful.spawn("steam")
		end,
              {description = "start steam", group = "launcher"})
)

-- client keys
clientkeys = gears.table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client,
              {description = "magnify client", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)

			local opacity = c.fullscreen and 1 or 0
			c.screen.mywibox.visible = c.fullscreen
			c.fullscreen = not c.fullscreen
			c:raise()
			for _, client in ipairs(c.screen.clients) do
				if client ~= c and awful.client.focus.filter(client) then
					client.opacity = opacity
				end
			end
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift" }, "f",
        function (c)

			c.fullscreen = false
			local opacity = 1
			c.screen.mywibox.visible = true
			c:raise()
			for _, client in ipairs(c.screen.clients) do
				if client ~= c and awful.client.focus.filter(client) then
					client.opacity = opacity
				end
			end
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

    globalkeys = gears.table.join(globalkeys,
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

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- append platform shortcuts
if selectedConfig == "elrond" then
	root.keys(gears.table.join(globalkeys, pckeys))
elseif selectedConfig == "aragorn" then
	root.keys(gears.table.join(globalkeys, laptopkeys))
end
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
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
      properties = { maximized = false, titlebars_enabled = false}
    },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized = true } },

    { rule = { class = "Thunderbird" },
      properties = { tag = beautiful.tagnames[2], titlebars_enabled = false } },

    { rule = { class = "discord" },
      properties = { screen = 1, tag = beautiful.tagnames[3] } },

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
	rule = { class = "URxvt", instance = "popup" },
		properties = {
			placement = awful.placement.top+awful.placement.center_horizontal,
			above = true,
			sticky = true,
			skip_taskbar = true,
			floating = true
		}
	},
}
-- }}}

--	Custom borders (secretly a titlebar)

local titlebar_position = "top"

function border_adjust(c)
	if c.floating then
		return
	end
	awful.titlebar.hide(c, "top")
	awful.titlebar.hide(c, "bottom")
	awful.titlebar.hide(c, "left")
	awful.titlebar.hide(c, "right")

	local s = awful.screen.focused()

	local titlebar_size = beautiful.titlebar_size

	if c.x - s.workarea["x"] - beautiful.titlebar_size <= 0 then
		titlebar_position = "left"
	elseif c.x - s.workarea["x"] + c.width - s.workarea["width"] + beautiful.titlebar_size + 10 >= 0 then
		titlebar_position = "right"
	else
		titlebar_position = "top"
	end

	if #focusable(awful.screen.focused().clients) > 1 and not c.maximized then
		awful.titlebar(c, {
			size = titlebar_size,
			position = titlebar_position
		})
	end
end

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
	local l = awful.layout.get(c.screen)

	if not (l.name == "floating" or c.floating) then
		awful.titlebar.hide(c)
	else
		c.ontop = true
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and doSloppyFocus
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Custom borders
client.connect_signal("focus", border_adjust)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized then -- no borders if only 1 client visible
            c.border_width = 0
        elseif #awful.screen.focused().clients > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
