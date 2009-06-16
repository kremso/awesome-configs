-- default rc.lua for shifty
--
-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- shifty - dynamic tagging library
require("shifty")

require("wicked")

require("calendar")

require("markup")

-- useful for debugging, marks the beginning of rc.lua exec
print("Entered rc.lua: " .. os.time())

function focusclient(name)
  for i,c in ipairs(client.get()) do
    if c.name:lower():find(name:lower()) or c.class:lower():find(name:lower()) then
      awful.tag.viewmore(c:tags(), c.screen);
      client.focus = c
    end
  end
end

function clientautocomplete(text, cur_pos, ncomp)
  local cname = text:sub(1, cur_pos)
  for i,c in ipairs(client.get()) do
    if c.name:lower():find(cname:lower()) then
      return c.name, c.name:len() + 1
    end

    if c.class:lower():find(cname:lower()) then
      return c.class, c.class:len() + 1
    end
  end

  return text, cur_pos
end

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- The default is a dark theme
theme_path = "/usr/share/awesome/themes/default/theme.lua"
-- Uncommment this for a lighter theme
-- theme_path = "/usr/share/awesome/themes/sky/theme"

-- Actually load theme
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
browser = "firefox"
mail = "thunderbird3"
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.floating
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

--{{{ SHIFTY: configured tags
shifty.config.tags = {
    ["1:init"] =     { layout = awful.layout.suit.max,          mwfact=0.60, exclusive = false, solitary = false, position = 1, init = true, screen = 1, slave = true } ,
    ["2:web"] =    { layout = awful.layout.suit.tile.bottom,  mwfact=0.65, exclusive = false , solitary = true , position = 2, spawn = browser  } ,
    ["3:term"] = {layout = awful.layout.suit.tile, position = 3 }, 
    ["4:chat"] = {layout = awful.layout.suit.tile.left, position = 4, ncol = 2, mwfact=0.2, spawn = "pidgin"},
    ["7:mail"] =   { layout = awful.layout.suit.tile,         mwfact=0.55, exclusive = false, solitary = false, position = 7, spawn = mail, slave = true     } ,
    ["8:media"] =  { layout = awful.layout.suit.float,                     exclusive = false, solitary = false, position = 8 } ,
    ["9:office"] = { layout = awful.layout.suit.tile, position = 9} ,
}
--}}}

--{{{ SHIFTY: application matching rules
-- order here matters, early rules will be applied first
shifty.config.apps = {
         { match = { "Navigator","Vimperator","Gran Paradiso"              } , tag = "2:web"    } ,
         { match = { "Shredder.*","Thunderbird","mutt"                     } , tag = "7:mail"   } ,
         { match = { "thunar"                                              } , slave = true   } ,
         { match = { "OpenOffice.*", "Abiword", "Gnumeric"                 } , tag = "9:office" } ,
         { match = { "Mplayer.*","Mirage","gimp","gtkpod","Ufraw","easytag"} , tag = "8:media", nopopup = true, } ,
         { match = { "MPlayer",                                            } , float = true   } ,
         { match = { "Pidgin",                                             } , tag = "4:chat", slave = true },
         { match = { terminal                                              } , tag = "3:term", honorsizehints = false, slave = true   } ,
}
--}}}

--{{{ SHIFTY: default tag creation rules
-- parameter description
--  * floatBars : if floating clients should always have a titlebar
--  * guess_name : wether shifty should try and guess tag names when creating new (unconfigured) tags
--  * guess_position: as above, but for position parameter
--  * run : function to exec when shifty creates a new tag
--  * remember_index: ?
--  * all other parameters (e.g. layout, mwfact) follow awesome's tag API
shifty.config.defaults={  
  layout = awful.layout.suit.tile, 
  ncol = 1, 
  mwfact = 0.60,
  floatBars=true,
  guess_name=true,
  guess_position=true,
  run = function(tag) 
    local stitle = "Shifty Created: "
    stitle = stitle .. (awful.tag.getproperty(tag,"position") or shifty.tag2index(mouse.screen,tag))
    stitle = stitle .. " : "..tag.name
    naughty.notify({ text = stitle })
  end,
}
--}}}

-- {{{ Wibox

widget_spacer_l = widget({type = "textbox", name = "widget_spacer", align = "left" })
widget_spacer_l.width = 5

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                        { "open terminal", terminal }
                                      }
                            })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c)
                                          if not c:isvisible() then
                                              awful.tag.viewonly(c:tags()[1])
                                          end
                                          client.focus = c
                                          c:raise()
                                      end),
                       button({ }, 3, function () if instance then instance:hide() instance = nil else instance = awful.menu.clients({ width=250 }) end end),
                       button({ }, 4, function ()
                                          awful.client.focus.byidx(1)
                                          if client.focus then client.focus:raise() end
                                      end),
                       button({ }, 5, function ()
                                          awful.client.focus.byidx(-1)
                                          if client.focus then client.focus:raise() end
                                      end) }

-- {{{ -- DATE widget
datewidget = widget({
    type = 'textbox',
    name = 'datewidget',
    align = 'right',
})
 
datewidget.mouse_enter = function() calendar.add_calendar() end
datewidget.mouse_leave = function() calendar.remove_calendar() end
 
datewidget:buttons({
  button({ }, 4, function() calendar.add_calendar(-1) end),
  button({ }, 5, function() calendar.add_calendar(1) end),
})
wicked.register(datewidget, wicked.widgets.date,
   markup.fg(beautiful.fg_normal, '%a %b, %H:%M'))
 
-- }}}

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "right" })
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ position = "top", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { mylauncher,
                           mytaglist[s],
                           mytasklist[s],
                           mypromptbox[s],
                           datewidget,
                           widget_spacer_l,
                           mylayoutbox[s],
                           s == 1 and mysystray or nil }
    mywibox[s].screen = s
end
-- }}}

--{{{ SHIFTY: initialize shifty
-- the assignment of shifty.taglist must always be after its actually initialized 
-- with awful.widget.taglist.new()
shifty.taglist = mytaglist
shifty.init()
--}}}

-- {{{ Mouse bindings
root.buttons({
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
globalkeys =
{
  -- TAGS 
  key({ modkey,           }, "Left",   awful.tag.viewprev       ),
  key({ modkey,           }, "Right",  awful.tag.viewnext       ),
  key({ modkey,           }, "Escape", awful.tag.history.restore),

  -- SHIFTY: keybindings specific to shifty
  key({ modkey, "Shift" }, "d", shifty.del),      -- delete a tag
  key({ modkey, "Shift" }, "n", shifty.send_prev),-- move client to prev tag
  key({ modkey          }, "n", shifty.send_next),-- move client to next tag
  key({ modkey,"Control"}, "n", function() 
    shifty.tagtoscr(awful.util.cycle(screen.count(), mouse.screen +1))
  end),-- move client to next tag
  key({ modkey          }, "a",     shifty.add),  -- creat a new tag
  key({ modkey,         }, "r",  shifty.rename),  -- rename a tag
  key({ modkey, "Shift" }, "a",                   -- nopopup new tag
    function() 
      shifty.add({ nopopup = true }) 
    end),

  key({ modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
  key({ modkey,           }, "k",
    function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    key({ modkey,           }, "u", awful.client.urgent.jumpto),
    key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    key({ modkey, "Control" }, "r", awesome.restart),
    key({ modkey, "Shift"   }, "q", awesome.quit),

    key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),


    -- Launchers
    key({ modkey,           }, "b", function () awful.util.spawn(browser) end),
    key({ modkey,           }, "x", function () awful.util.spawn("thunar") end),
    key({ "Mod1",           }, "F2", function () awful.util.spawn("gmrun") end),


    -- Prompt
    key({ modkey }, "F1",
        function ()
            awful.prompt.run({ prompt = "Run: " },
            mypromptbox[mouse.screen],
            awful.util.spawn, awful.completion.shell,
            awful.util.getdir("cache") .. "/history")
        end),

    key({ modkey }, "F4",
        function ()
            awful.prompt.run({ prompt = "Run Lua code: " },
            mypromptbox[mouse.screen],
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
        end),

    key({ modkey }, "c",
      function ()
        awful.prompt.run({ prompt = "Focus client: " },
        mypromptbox[mouse.screen],
        focusclient, clientautocomplete,
        awful.util.getdir("cache") .. "/clientfocus")
      end),
}

--{{{ Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys =
{
    key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    key({ modkey }, "t", awful.client.togglemarked),
    key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
}
-- SHIFTY: assign client keys to shifty for use in
-- match() function (manage hook)
shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey
--}}}

-- Compute the maximum number of digit we need, limited to 9
for i=1, ( shifty.config.maxtags or 9 ) do
  table.insert(globalkeys, key({ modkey }, i, 
  function () 
    local t =  awful.tag.viewonly(shifty.getpos(i)) 
  end))
  table.insert(globalkeys, key({ modkey, "Control" }, i, 
  function () 
    local t = shifty.getpos(i)
    t.selected = not t.selected 
  end))
  table.insert(globalkeys, key({ modkey, "Control", "Shift" }, i, 
  function () 
    if client.focus then 
      awful.client.toggletag(shifty.getpos(i)) 
    end
  end))
  -- move clients to other tags
  table.insert(globalkeys, key({ modkey, "Shift" }, i,
    function () 
      if client.focus then 
        t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end 
    end))
end


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

--Placeholder: for end users who want to customize the behavior
-- of new client appearances. 
--
-- Otherwise shifty.lua provides a manage hook already.
--
awful.hooks.manage.register(function (c, startup)
  c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey }, 3, awful.mouse.client.resize)
    })

end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- }}}

-- {{{ Autostart

os.execute("unclutter &")
os.execute("/home/kremso/wallpapers/rotator.sh -s &")

--}}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80

