local awful = require("awful")
local prefs = require("prefs")
local beautiful = require("beautiful")
local gears = require("gears")

local helpers = {}

-- {{{ Special run prompt commands
-- Convert to string to terminal emulator syntax if in terminal_programs
-- Also sets the instance of program to the command name; may need changing if terminal ~= urxvt(c)
local function terminal_program(cmd)
	local program = cmd:match("^([^ ]+)")
	return prefs.terminal .. " -name " .. program .. " -e " .. cmd
end

local function popup_program(cmd)
	return prefs.terminal .. " -name popup -bg black -geometry 160x20 -e zsh -c \"source ~/.zshrc && " .. cmd .. "\""
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
	{"shaders", popup_when_no_args},
	{"tx", popup_program},
	{"td", popup_program},
	{"q", popup_program},
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
-- }}} Special run prompt commands

-- Accepts rules; however, the current release (4.2) applies rules in a weird order: rules won't work
helpers.run_once = function(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.easy_async_with_shell(string.format("pgrep -u $USER -f '%s' > /dev/null", cmd[1]),
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

helpers.move_tag_left = function()
	local current_tag = awful.screen.focused().selected_tag
	local current_name = current_tag.name
	local old_index = current_tag.index
	helpers.move_tag(-1)
	local new_tag = awful.screen.focused().tags[old_index]
	local new_name = new_tag.name

	if current_tag and new_tag then
		current_tag.name = theme.tagnames[current_tag.index]
		if string.find(current_name, "-") then
			current_tag.name = current_tag.name .. "-" .. string.sub(current_name,
			(string.find(current_name, "-") or string.len(current_name)) + 1)
		end

		new_tag.name = theme.tagnames[new_tag.index]
		if string.find(new_name, "-") then
			new_tag.name = new_tag.name .. "-" .. string.sub(new_name,
			(string.find(new_name, "-") or string.len(new_name)) + 1)
		end
	end
end

helpers.move_tag_right = function()
	local current_tag = awful.screen.focused().selected_tag
	local current_name = current_tag.name
	local old_index = current_tag.index
	helpers.move_tag(1)
	local new_tag = awful.screen.focused().tags[old_index]
	local new_name = new_tag.name

	if current_tag and new_tag then
		current_tag.name = theme.tagnames[current_tag.index]
		if string.find(current_name, "-") then
			current_tag.name = current_tag.name .. "-" .. string.sub(current_name,
			(string.find(current_name, "-") or string.len(current_name)) + 1)
		end

		new_tag.name = theme.tagnames[new_tag.index]
		if string.find(new_name, "-") then
			new_tag.name = new_tag.name .. "-" .. string.sub(new_name,
			(string.find(new_name, "-") or string.len(new_name)) + 1)
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

return helpers
