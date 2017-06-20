local lfs = require 'lfs'
local lgi = require 'lgi'
local Gtk = lgi.Gtk
local GLib = lgi.GLib
local Gdk = lgi.Gdk
local cairo = lgi.cairo

local modification_time = 0
local source_text = ''

local function render(cr)
  local r, err = load(source_text, 'source_chunk', 'bt', {
    col = function (r,g,b,a)
      cr:set_source_rgba(r,g,b,a or 1)
    end,
    rect = function (x,y,w,h)
      cr:rectangle(Gdk.Rectangle {
        x = x, y = y, width = w, height = h
      })
    end,
    circ = function (x,y,r)
      cr:arc(x,y,r,0,math.rad(360))
    end,
    poly = function (t)
      for i=1, #t, 2 do
        if i == 1 then
          cr:move_to(t[i],t[i+1])
        else
          cr:line_to(t[i],t[i+1])
        end
      end
    end,
    fill = function ()
      cr:fill()
    end,
    stroke = function ()
      cr:stroke()
    end
  })

  cr:set_source_rgb(0,0,0)

  if not r then
    print('error:', err)
  else
    r()
  end
end

local function show_preview(filename)
  local canvas = Gtk.DrawingArea {
    width = 500,
    height = 500
  }
  function canvas:on_draw(cr)
    render(cr)
    return true
  end
  local timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, function ()
    -- watch file for changes and update the view
    local mtime = lfs.attributes(filename, 'modification')
    if mtime > modification_time then
      print('modified, redrawing')
      local file = io.open(filename,'r')
      source_text = file:read('*all')
      file:close()
      canvas:queue_draw()
      modification_time = mtime
    end
    return true
  end)
  local window = Gtk.Window {
    title = 'penzl',
    width_request = 500,
    height_request = 500,
    canvas,
    on_destroy = function (_)
      GLib.source_remove(timer)
      Gtk.main_quit()
    end
  }
  window:show_all()
  Gtk:main()
end

if #arg == 1 then
  show_preview(arg[1])
else
  local surface = cairo.ImageSurface.create('ARGB32', tonumber(arg[2]), tonumber(arg[3]))
  local cr = cairo.Context.create(surface)

  local file = io.open(arg[1],'r')
  source_text = file:read('*all')
  file:close()

  render(cr)

  surface:write_to_png(arg[4])
end
