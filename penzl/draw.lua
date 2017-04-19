
local lgi = require 'lgi'
local Gdk = lgi.Gdk
local cairo = lgi.cairo

local colors = require 'penzl.colors'

local D = {}

function D:init()
  self.cr = cairo.Context(surface)
end

function D:color(r,g,b,a) -- set color
  if type(r) == "string" then
    local c = colors[r]
    self.cr:set_source_rgb(c[1]/255,c[2]/255,c[3]/255)
  elseif type(r) == "number" then
    self.cr:set_source_rgba(r/255,g/255,b/255,(a or 100)/100)
  end
end

function D:clear() -- paint everything white
  self.cr:set_source_rgba(1,1,1,1)
  self.cr:paint()
end

function D:poly(arg,fill) -- polygon
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

function D:linew(w) -- line width
  if type(w) == "number" then
    self.cr.line_width = w
  end
end

function D:rect(x,y,width,height,fill) -- rectangle
  local r = Gdk.Rectangle {
    x = x, y = y,
    width = width, height = height
  }
  assert(surface,"Surface is nil")
  self.cr:rectangle(r)
  if fill then self.cr:fill() else self.cr:stroke() end
end

function D:circ(x,y,r,fill) -- circle
  self.cr:arc(x,y,r,0,math.rad(360))
  if fill then self.cr:fill() else self.cr:stroke() end
end

function D:arc(x,y,r,a,sa,fill)
  local start_a = 0
  if sa then start_a = math.rad(sa) end
  print('arc sa:',sa,'rad:',start_a)
  self.cr:arc(x,y,r,start_a,math.rad(a))
  if fill then self.cr:fill() else self.cr:stroke() end
end

function D:arcn(x,y,r,a,sa,fill)
  local start_a = 0
  if sa then local start_a = math.rad(sa) end
  print('arcn sa:',sa,'rad:',start_a)
  self.cr:arc_negative(x,y,r,start_a,math.rad(a))
  if fill then self.cr:fill() else self.cr:stroke() end
end

return D
