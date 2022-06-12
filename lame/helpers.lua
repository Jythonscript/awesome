local awful = require("awful")
local prefs = require("prefs")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local helpers = {}

-- {{{ Special run prompt commands
-- Convert to string to terminal emulator syntax if in terminal_programs
-- Also sets the instance of program to the command name; may need changing if terminal ~= urxvt(c)
local function terminal_program(cmd)
	local program = cmd:match("^([^ ]+)")
	return (prefs.popupterm or prefs.terminal) .. " -name " .. program .. " -e " .. cmd
end

local function popup_program(cmd)
	return (prefs.popupterm or prefs.terminal) .. " -name popup -bg black -geometry 160x20 -e zsh -c \"source ~/.func.zsh && " .. cmd .. "\""
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
	{"ncs", popup_program},
	{"t", popup_program},
	{"sym", popup_program},
	{"vim", terminal_program},
	{"htop", terminal_program},
	{"top", terminal_program},
	{"man", terminal_program},
	{"m", popup_when_no_args},
	{"mp", popup_when_no_args},
	{"shaders", popup_when_no_args},
	{"tx", popup_program},
	{"ved", popup_program},
	{"td", popup_program},
	{"q", popup_when_no_args},
	{"jpc", popup_program},
}

helpers.parse_for_special_run_commands = function(in_cmd)
	local command = in_cmd:match("^([^ ]+)")
	for _, cmd in ipairs(special_run_commands) do
		if command == cmd[1] then
			return cmd[2](in_cmd)
		end
	end
	return in_cmd
end

local function clip_and_notify(stdout)
	stdout = stdout:gsub("[\n\r]", "")
	local cmd1 = "echo '"..stdout.."' | tr -d '\\n' | nohup xclip -selection clipboard > /dev/null"
	local cmd2 = "echo '"..stdout.."' | tr -d '\\n' | nohup xclip -selection primary > /dev/null"
	awful.spawn.with_shell(cmd1)
	awful.spawn.with_shell(cmd2)
	naughty.notify { text = stdout }
end

local line_callback_commands = {
	{"sym", clip_and_notify},
	{"q", clip_and_notify},
}

helpers.parse_for_line_callback_commands = function(in_cmd)
	local command = in_cmd:match("^([^ ]+)")
	for _, cmd in ipairs(line_callback_commands) do
		if command == cmd[1] then
			return cmd[2]
		end
	end
	return nil
end

-- }}} Special run prompt commands

-- Accepts rules; however, the current release (4.2) applies rules in a weird order: rules won't work
helpers.run_once = function(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		-- allows different pgrep from command
		local cmdname = cmd[3] or cmd[1]
		awful.spawn.easy_async_with_shell(string.format("pgrep -u $USER -f '%s' > /dev/null", cmdname),
		function(stdout, stderr, reason, exit_code)
			if exit_code ~= 0 then
				awful.spawn(helpers.parse_for_special_run_commands(cmd[1]), cmd[2])
			end
		end
		)
	end

	helpers.client_instance_exists = function(clients, instance)
		for _, c in ipairs(clients) do
			if c.instance == instance then
				return c
			end
		end
		return false
	end
end

helpers.focusable = function(clients)
	local out_clients = {}
	for _, c in ipairs(clients) do
		if awful.client.focus.filter(c) then
			table.insert(out_clients, c)
		end
	end
	return out_clients
end

-- {{{ Borders
helpers.get_border_position = function(c)
	local s = awful.screen.focused()

	local titlebar_size = beautiful.titlebar_size

	local titlebar_position = "top"

	if c.x - s.workarea["x"] - beautiful.titlebar_size <= 0 then
		titlebar_position = "left"
	elseif c.x - s.workarea["x"] + c.width - s.workarea["width"] + beautiful.titlebar_size + 10 >= 0 then
		titlebar_position = "right"
	end

	return titlebar_position
end

helpers.border_adjust = function(c)
	if c.floating then
		return
	end

	local border_position = helpers.get_border_position(c)

	pcall(function()
		local top_titlebar_margin = c._private.titlebars["top"].drawable:get_children_by_id("active_margin")[1]
		top_titlebar_margin:set_left(0)
		top_titlebar_margin:set_right(0)

		if #helpers.focusable(awful.screen.focused().clients) > 1 and not c.maximized then
			if border_position == "left" then
				top_titlebar_margin:set_left(beautiful.titlebar_size)
			elseif border_position == "right" then
				top_titlebar_margin:set_right(beautiful.titlebar_size)
			end
		end
	end)

	awful.titlebar.hide(c, "bottom")
	awful.titlebar.hide(c, "left")
	awful.titlebar.hide(c, "right")

	if #helpers.focusable(awful.screen.focused().clients) > 1 and not c.maximized then
		awful.titlebar(c, {
			size = beautiful.titlebar_size,
			position = border_position
		})
	end
end
-- }}} Borders

-- sets up the given client to not have picom active when it is focused
helpers.no_picom_when_focused_setup = function(c)
	c:connect_signal("focus",
	function(c2)
		awful.spawn("killall " .. prefs.compositor)
	end)

	c:connect_signal("unfocus",
	function(c2)
		awful.spawn(prefs.compositor)
	end)
end

helpers.add_tag = function(layout)
	awful.prompt.run {
		prompt       = "New tag name: ",
		textbox      = awful.screen.focused().mypromptbox.widget,
		exe_callback = function(name)
			if not name or #name == 0 then return end
			awful.tag.add(name, { screen = awful.screen.focused(), layout = layout or awful.layout.suit.tile }):view_only()
		end
	}
end

helpers.rename_tag = function()
	awful.prompt.run {
		prompt       = "Rename tag: ",
		textbox      = awful.screen.focused().mypromptbox.widget,
		exe_callback = function(new_name)
			if not new_name or #new_name == 0 then return end
			local t = awful.screen.focused().selected_tag
			if t then
				if new_name == " " then
					t.name = theme.tagnames[t.index]
				else
					t.name = theme.tagnames[t.index] .. "-" .. new_name
				end
			end
		end
	}
end

helpers.move_tag = function(pos)
	local tag = awful.screen.focused().selected_tag
	if tonumber(pos) <= -1 then
		tag.index = tag.index - 1
	else
		tag.index = tag.index + 1
	end
end

helpers.delete_tag = function()
	local t = awful.screen.focused().selected_tag
	if not t then return end
	t:delete()
end

helpers.unminimize = function()
	local c = awful.client.restore()
	if c then
		client.focus = c
		c:raise()
	end
end

helpers.swap_tag_subnames = function(t1, t2, swapnames)
	if not swapnames then swapnames = false end
	local idx1 = string.find(t1.name, "-")
	local idx2 = string.find(t2.name, "-")
	local sub1 = ""
	local sub2 = ""
	local name1 = t1.name
	local name2 = t2.name

	if idx1 then
		sub1 = string.sub(name1, idx1)
		name1 = string.sub(name1, 0, idx1-1)
	end
	if idx2 then
		sub2 = string.sub(name2, idx2)
		name2 = string.sub(name2, 0, idx2-1)
	end

	if swapnames then
		t1.name = name2 .. sub1
		t2.name = name1 .. sub2
	else
		t1.name = name1 .. sub2
		t2.name = name2 .. sub1
	end
end

helpers.move_tag_left = function()
	local current_tag = awful.screen.focused().selected_tag
	local old_index = current_tag.index
	helpers.move_tag(-1)
	local new_tag = awful.screen.focused().tags[old_index]
	helpers.swap_tag_subnames(current_tag, new_tag, true)
end

helpers.move_tag_right = function()
	local current_tag = awful.screen.focused().selected_tag
	local old_index = current_tag.index
	helpers.move_tag(1)
	local new_tag = awful.screen.focused().tags[old_index]
	helpers.swap_tag_subnames(current_tag, new_tag, true)
end

helpers.swap_monitor_tags = function()
	local clienttables = {}
	local idx = 1
	local prevtag
	local t = nil
	for s in screen do
		prevtag = t
		t = s.selected_tag
		if prevtag then
			helpers.swap_tag_subnames(t, prevtag, false)
		end
		local c = t:clients()
		clienttables[idx] = c
		idx = idx + 1
	end
	for _, clients in ipairs(clienttables) do
		for _, c in ipairs(clients) do
			c:move_to_screen()
		end
	end
end

helpers.view_tag_index = function(i)
	local screen = awful.screen.focused()
	local tag = screen.tags[i]
	if tag then
		tag:view_only()
	end
end

helpers.toggle_tag_index = function(i)
	local screen = awful.screen.focused()
	local tag = screen.tags[i]
	if tag then
		awful.tag.viewtoggle(tag)
	end
end

helpers.move_client_to_tag_index = function(i)
	if client.focus then
		local tag = client.focus.screen.tags[i]
		if tag then
			client.focus:move_to_tag(tag)
		end
	end
end

helpers.toggle_client_in_tag_index = function(i)
	if client.focus then
		local tag = client.focus.screen.tags[i]
		if tag then
			client.focus:toggle_tag(tag)
		end
	end
end

helpers.stacknext = function()
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
end

helpers.stackprev = function()
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
end

helpers.terminal_same_directory = function()
	local term_id = "/run/user/$(id --user)/urxvtc_ids/" .. client.focus.window
	awful.spawn.with_shell(prefs.terminal ..
	" -cd \"$([ -f " .. term_id .. " ] && \
	readlink -e /proc/$(cat " .. term_id .. ")/cwd || \
	echo $HOME)\""
	)
end

helpers.capture = function(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

if not prefs.laptop then
	helpers.keypress = function(key, window)
		if not window then window = client.focus.window end
		awful.spawn("xdotool key --window " .. tostring(window).." '"..key.."'")
	end
else
	helpers.keypress = function(key, window)
		awful.spawn.with_shell("sleep 0.15 && xdotool key '"..key.."'")
	end
end

helpers.rrect = function(radius)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

helpers.vertical_pad = function(height)
    return wibox.widget{
        forced_height = height,
        layout = wibox.layout.fixed.vertical
    }
end

return helpers
