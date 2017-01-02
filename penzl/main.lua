local lgi = require 'lgi'
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local cairo = lgi.cairo

local window, header, stack_switcher, stack, bottom_bar, coord_label, refresh_button
info_bar = nil
canvas = nil
surface = nil
local editor

local state = {
  cursor_x = 0,
  cursor_y = 0
}

require 'penzl.info_utils'

local commands = require 'penzl.commands'
draw = require 'penzl.draw' -- was local

info_bar = Gtk.InfoBar {
  show_close_button = true,
  no_show_all = true
}

function info_bar:on_response(r_id)
  print('response_id', r_id)
  if r_id == -7 then
    self:hide()
  end
end

canvas = Gtk.DrawingArea {
  width = 300,
  height = 300,
}

function canvas:on_configure_event(e)
  local allocation = self.allocation
  surface = self.window:create_similar_surface('COLOR', allocation.width, allocation.height)
  local cr = cairo.Context.create(surface)
  cr:set_source_rgb(1, 1, 1)
  cr:paint()
  -- draw:init(canvas,surface)
  draw:init()
  return true
end

function canvas:on_button_press_event(e)
  if e.button == Gdk.BUTTON_PRIMARY then
    print('mouse primary', e.x, e.y)
  end
  return true
end

function canvas:on_motion_notify_event(e)
  local _, x, y, state = e.window:get_device_position(e.device)
  if state.BUTTON1_MASK then
    print('mouse down',x,y)
  end
  state.cursor_x = x
  state.cursor_y = y
  bottom_bar:queue_draw() -- TODO fix
  return true
end

function canvas:on_draw(cr)
  cr:set_source_surface(surface, 0, 0)
  cr:paint()
  return true
end

canvas:add_events(Gdk.EventMask {
  'LEAVE_NOTIFY_MASK',
  'BUTTON_PRESS_MASK',
  'POINTER_MOTION_MASK',
  'POINTER_MOTION_HINT_MASK'
})

stack = Gtk.Stack {}

stack_switcher = Gtk.StackSwitcher {
  stack = stack
}

refresh_button = Gtk.ToolButton {
  icon_name = "view-refresh-symbolic"
}

function refresh_button:on_clicked()
  load(editor.buffer.text)()
end

header = Gtk.HeaderBar {
  title = 'penzl',
  show_close_button = true,
  custom_title = stack_switcher,
  refresh_button
}

editor = Gtk.TextView {
  top_margin = 5,
  left_margin = 5,
}

bottom_bar = Gtk.ActionBar {}

coord_label = Gtk.Label {
  label = string.format("%s : %s", state.cursor_x, state.cursor_y)
}

bottom_bar:pack_end(coord_label)

main_box = Gtk.Box {
  orientation = "VERTICAL",
  info_bar,
  Gtk.Paned {
    orientation = 'HORIZONTAL',
    Gtk.ScrolledWindow {
      width = 200,
      editor
    },
    Gtk.ScrolledWindow {
      expand = true,
      Gtk.Fixed {
        canvas
      }
    },
  },
  bottom_bar
}

log_box = Gtk.Box {
  orientation = 'VERTICAL',
  Gtk.ScrolledWindow {
    Gtk.TextView {
      id = 'log_view',
      editable = false
    }
  }
}

docs_box = Gtk.Box {
  orientation = 'VERTICAL',
  Gtk.ScrolledWindow {
    Gtk.TextView {
      id = 'docs_view',
      editable = false
    }
  }
}

stack:add_titled(main_box, "main_box", "Canvas")
stack:add_titled(log_box, "log_box", "Log")
stack:add_titled(docs_box, "docs_box", "Docs")

window = Gtk.Window {
  default_width = 800,
  default_height = 600,
  stack,
}

window:set_titlebar(header)

function window:on_destroy()
  Gtk.main_quit()
end

function canvas:on_key_press_event(e) -- turn back to window: ?
  local ctrl_on = e.state.CONTROL_MASK
  local shift_on = e.state.SHIFT_MASK
  return true
end

window:show_all()

Gtk:main()
