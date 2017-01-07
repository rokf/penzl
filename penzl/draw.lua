
local lgi = require 'lgi'
local Gdk = lgi.Gdk
local cairo = lgi.cairo

local colors = require 'penzl.colors'

local _D = {}

function _D:init()
  self.cr = cairo.Context(surface)
end

function _D:color(r,g,b,a)
  if type(r) == "string" then
    local c = colors[r]
    self.cr:set_source_rgb(c[1]/255,c[2]/255,c[3]/255)
  elseif type(r) == "number" then
    self.cr:set_source_rgba(r/255,g/255,b/255,(a or 100)/100)
  end
end

function _D:clear()
  self.cr:set_source_rgba(1,1,1,1)
  self.cr:paint()
end

function _D:poly(arg,fill) -- polygon
  for i=1, #arg, 2 do
    if i==1 then
      print('move',arg[i],arg[i+1])
      self.cr:move_to(arg[i],arg[i+1])
    else
      print('line',arg[i],arg[i+1])
      self.cr:line_to(arg[i],arg[i+1])
    end
  end
  if fill then self.cr:fill() else self.cr:stroke() end
end

function _D:linew(w) -- line width
  if type(w) == "number" then
    self.cr.line_width = w
  end
end

function _D:rect(x,y,width,height,fill)
  local r = Gdk.Rectangle {
    x = x, y = y,
    width = width, height = height
  }
  assert(surface,"Surface is nil")
  self.cr:rectangle(r)
  if fill then self.cr:fill() else self.cr:stroke() end
end

return _D
