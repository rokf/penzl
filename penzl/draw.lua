
local lgi = require 'lgi'
local Gdk = lgi.Gdk
local cairo = lgi.cairo

-- drawing module
local _D = {}

function _D:init(widget,surface)
  self.widget = widget
  self.surface = surface
end

function _D:rectangle(x,y,width,height)
  local rect = Gdk.Rectangle {
    x = x, y = y,
    width = width, height = height
  }
  assert(self.surface,"Surface is nil")
  local cr = cairo.Context(self.surface) -- expect global surface
  cr:rectangle(rect)
  cr:set_source_rgb(0,0,0)
  cr:fill()
  self.widget.window:invalidate_rect(rect, false)
end

function _D:line()

end

return _D
