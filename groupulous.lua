local awful = require("awful")
local print = print
local ipairs = ipairs
local screen = screen
local client = client
local table = table

module("groupulous")

local groupdef

function group()
  for i = 1, screen.count() do
    groupdef = awful.client.visible(i)
  end
end

function focus(c)
  if groupdef ~= nil and awful.util.table.hasitem(groupdef, c) then
    for i,c in ipairs(groupdef) do
      if c ~= nil then
	c:raise()
      end
    end

    client.focus = c

  end
end

function unmanage(c)
  if groupdef ~= nil and awful.util.table.hasitem(groupdef, c) then
    for i,cc in ipairs(groupdef) do
      if cc == c then
	table.remove(groupdef, i)
      end
    end
  end
end
