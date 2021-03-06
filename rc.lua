-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
local blingbling = require("blingbling")

-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "urxvt"
-- terminal = "terminology"
terminal = "gnome-terminal"

editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
function edit_in_terminal(path)
  return terminal .. " -e '" .. editor .. " " .. path .. "'"
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", edit_in_terminal(awesome.conffile) },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- Initialize vicious widget
datewidget = awful.widget.textclock()

cpulabel=wibox.widget.textbox()
cpulabel:set_text("Cpu")

cpu=blingbling.line_graph.new()
cpu:set_height(32)
cpu:set_width(60)
cpu:set_h_margin(1)
cpu:set_v_margin(4)
cpu:set_rounded_size(0.4)
cpu:set_show_text(true)
cpu:set_background_color(beautiful.bg_normal)
cpu:set_graph_background_color("#000000")
vicious.register(cpu, vicious.widgets.cpu, '$1',2)

mycore1=blingbling.progress_graph.new()
mycore1:set_height(30)
mycore1:set_width(6)
--mycore1:set_filled(true)
mycore1:set_h_margin(1)
mycore1:set_v_margin(4)
--mycore1:set_filled_color("#00000033")
vicious.register(mycore1, vicious.widgets.cpu, "$2", 2)

mycore2=blingbling.progress_graph.new()
mycore2:set_height(30)
mycore2:set_width(6)
--mycore1:set_filled(true)
mycore2:set_h_margin(1)
mycore2:set_v_margin(4)
--mycore1:set_filled_color("#00000033")
vicious.register(mycore2, vicious.widgets.cpu, "$3", 2)

mycore3=blingbling.progress_graph.new()
mycore3:set_height(30)
mycore3:set_width(6)
--mycore1:set_filled(true)
mycore3:set_h_margin(1)
mycore3:set_v_margin(4)
--mycore1:set_filled_color("#00000033")
vicious.register(mycore3, vicious.widgets.cpu, "$4", 2)

mycore4=blingbling.progress_graph.new()
mycore4:set_height(30)
mycore4:set_width(6)
mycore4:set_h_margin(1)
mycore4:set_v_margin(4)
vicious.register(mycore4, vicious.widgets.cpu, "$5", 2)

memlabel=wibox.widget.textbox()
memlabel:set_text('Mem')

mem=blingbling.line_graph.new()
mem:set_height(32)
mem:set_width(60)
mem:set_h_margin(1)
mem:set_v_margin(4)
mem:set_rounded_size(0.4)
mem:set_show_text(true)
mem:set_background_color(beautiful.bg_normal)
mem:set_graph_background_color("#000000")
vicious.register(mem, vicious.widgets.mem, '$1',2)

--disklabel=blingbling.text_box.new({text = "Disk"})
--disklabel:set_padding(4)
--disklabel:set_rounded_size(0.4)
--disklabel:set_background_color(beautiful.bg_normal)

--disk=blingbling.progress_graph.new()
--disk:set_height(22)
--disk:set_width(24)
--disk:set_h_margin(1)
--disk:set_show_text(true)
--vicious.register(disk, vicious.widgets.fs, "${/ used_p}", 120)

batlabel = wibox.widget.textbox()
vicious.register(batlabel, vicious.widgets.bat, "$1", 2, "BAT1")

bat=blingbling.progress_graph.new()
bat:set_height(32)
bat:set_width(28)
bat:set_h_margin(4)
bat:set_v_margin(6)
bat:set_show_text(true)
vicious.register(bat, vicious.widgets.bat, "$2", 2, "BAT1")

eth0 = wibox.widget.textbox()
vicious.register(eth0, vicious.widgets.net, "<span color='#7FB219'>${eth0 down_kb}KB/s</span> <span color='#CC6666'>${eth0 up_kb}KB/s</span>", 2)

margin_bar = wibox.layout.margin()
margin_bar:set_right(8)

--netwidget = blingbling.net({interface = "eth0", show_text = true})
--netwidget:set_ippopup()

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mylayoutbox[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
      right_layout:add(margin_bar)
      right_layout:add(eth0)
      right_layout:add(margin_bar)
      right_layout:add(cpulabel)
      right_layout:add(cpu)
      --right_layout:add(mycore1)
      --right_layout:add(mycore2)
      --right_layout:add(mycore3)
      --right_layout:add(mycore4)
      right_layout:add(margin_bar)
      right_layout:add(memlabel)
      right_layout:add(mem)
      right_layout:add(margin_bar)
      right_layout:add(batlabel)
      right_layout:add(bat)
      right_layout:add(margin_bar)
      --right_layout:add(disklabel)
      --right_layout:add(disk)
      right_layout:add(wibox.widget.systray())
    end
    right_layout:add(datewidget)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function notes_completion(command, cur_pos, ncomp, shell)
  prefix = "vim /home/jan/Yunio/notes/"
  cmd = prefix .. command
  cur_pos = cur_pos + prefix:len()

  str, cur_pos, output = awful.completion.shell(cmd, cur_pos, ncomp, 'zsh')

  str = str:gsub(prefix, '')
  cur_pos = cur_pos - prefix:len()

  return str, cur_pos, output
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, ",",      awful.tag.viewprev       ),
    awful.key({ modkey,           }, ".",      awful.tag.viewnext       ),

    awful.key({ modkey, "Shift"   }, ".",
      function ()
        local idx = awful.tag.getidx()
        if idx == 9 then
          awful.client.movetotag(tags[client.focus.screen][1])
        else
          awful.client.movetotag(tags[client.focus.screen][idx+1])
        end
      end),
    awful.key({ modkey, "Shift"   }, ",",
      function ()
        local idx = awful.tag.getidx()
        if idx == 1 then
          awful.client.movetotag(tags[client.focus.screen][9])
        else
          awful.client.movetotag(tags[client.focus.screen][idx-1])
        end
      end),

    awful.key({ modkey,           }, "Tab",    awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    --awful.key({ modkey,           }, "e", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "s", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Shift"   }, "s", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "w", function () awful.screen.focus(1) end),
    awful.key({ modkey,           }, "e", function () awful.screen.focus(screen.count()) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal .. " -e /home/jan/scripts/tmux_tasks") end),
    awful.key({ modkey,           }, "m",      function () awful.util.spawn(terminal .. " -e mc") end),
    awful.key({ modkey, "Shift"   }, "m",      function () awful.util.spawn("nautilus") end),
    awful.key({ modkey,           }, "t",      function () awful.util.spawn(edit_in_terminal("/home/jan/Yunio/notes/jan.org")) end),
    awful.key({ modkey, "Shift"   }, "t",      function () awful.util.spawn(edit_in_terminal("/home/jan/Yunio/notes/worklog.org")) end),
    awful.key({ modkey,           }, "c",      function () awful.util.spawn(edit_in_terminal(awesome.conffile)) end),
    awful.key({ modkey,           }, "q", awesome.restart),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey, "Shift"   }, "q",     function () awful.util.spawn("gnome-session-quit --power-off") end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey,           }, "=",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey,           }, "-",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Shift"   }, "=",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Shift"   }, "-",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.set(awful.layout.suit.tile) end),
    awful.key({ modkey,           }, "f",     function (c) awful.layout.set(awful.layout.suit.max) end),
    awful.key({ modkey, "Control" }, "l",     function () awful.util.spawn("gnome-screensaver-command -l") end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.util.spawn("xscreensaver-command -lock") end),

    --awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey, "Shift"   }, "p",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    awful.key({ modkey }, "d",
              function ()
                  awful.prompt.run({ prompt = "Copy to clipboard: " },
                  mypromptbox[mouse.screen].widget,
                  function (...)
                    awful.util.spawn("/home/jan/scripts/args2clipboard.sh " .. ...)
                  end,
                  nil,
                  awful.util.getdir("cache") .. "/history_clipboard")
              end),

    awful.key({ modkey, "Shift" }, "d",
              function ()
                  awful.prompt.run({ prompt = "Lookup password: " },
                  mypromptbox[mouse.screen].widget,
                  function (...)
                    awful.util.spawn("/home/jan/scripts/password2clipboard.sh " .. ...)
                  end,
                  nil,
                  "/dev/null")
              end),

    awful.key({ modkey }, "n",
              function ()
                  awful.prompt.run({ prompt = "Write note: " },
                  mypromptbox[mouse.screen].widget,
                  function (...)
                    awful.util.spawn(edit_in_terminal("/home/jan/Yunio/notes/" .. ...))
                  end,
                  notes_completion,
                  awful.util.getdir("cache") .. "/history_notes")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "'",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Shift"   }, "'",      function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 2, --beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     size_hints_honor = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    --{ rule = { class = "URxvt" },
      --properties = { opacity = 0.9 } },
    { rule = { class = "Chromium" },
      properties = { tag = tags[1][1] } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
    { rule = { class = "Steam" },
      properties = { floating = true } },
    { rule = { instance = "exe" },
      properties = { floating = true } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Litecoin-qt" },
      properties = { floating = true } },
    { rule = { class = "Bitcoin-qt" },
      properties = { floating = true } },
    { rule = { class = "Hotot-qt" },
      properties = { floating = true, border_width = 0 } },
    { rule = { class = "Choqok" },
      properties = { floating = true, border_width = 0 } },
    { rule = { class = "Goldendict" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Shutter" },
      properties = { floating = true } },
    { rule = { class = "Hipchat" },
      properties = { screen = screen.count(), tag = tags[screen.count()][2], border_width = 0 } },
    { rule = { class = "Pidgin" },
      properties = { floating = true, screen = screen.count(), tag = tags[screen.count()][9] } },
    { rule = { class = "Skype" },
      properties = { floating = true, screen = screen.count(), tag = tags[screen.count()][9] } },
    { rule = { class = "Chromium", role = "pop-up" },
      properties = { floating = true } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
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
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus",
  function(c)
    c.border_color = beautiful.border_focus
    --c.opacity = 1
  end)
client.connect_signal("unfocus",
  function(c)
    c.border_color = beautiful.border_normal
    --c.opacity = 0.9
  end)

