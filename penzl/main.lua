local lgi = require 'lgi'
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local cairo = lgi.cairo

local window, header, canvas, object_listbox, stack_switcher, stack, info_bar
local main_box, log_box, docs_box
local surface

require 'penzl.info_utils'

local layers = require 'penzl.layers'
local commands = require 'penzl.commands'
local draw = require 'penzl.draw'

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
  width = 100,
  height = 100,
}

function canvas:on_configure_event(e)
  local allocation = self.allocation
  surface = self.window:create_similar_surface('COLOR', allocation.width, allocation.height)
  local cr = cairo.Context.create(surface)
  cr:set_source_rgb(1, 1, 1)
  cr:paint()
  draw:init(canvas,surface) -- TODO rework?
  return true
end

function canvas:on_button_press_event(e)
  if e.button == Gdk.BUTTON_PRIMARY then
    print('mouse primary', e.x, e.y)
    draw:rectangle(10,10,20,20) -- TODO temporary, remove, draw all layers at once
  end
  return true
end

function canvas:on_motion_notify_event(e)
  local _, x, y, state = e.window:get_device_position(e.device)
  if state.BUTTON1_MASK then
    print('motion',x,y)
  end
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

object_listbox = Gtk.ListBox {
  width = 100,
  Gtk.ListBoxRow { -- tmp
    selectable = false,
    Gtk.Label {
      label = "Circle"
    }
  },
}

header = Gtk.HeaderBar {
  title = 'penzl',
  show_close_button = true,
  custom_title = stack_switcher
}

main_box = Gtk.Box {
  orientation = "VERTICAL",
  info_bar,
  Gtk.Paned {
    orientation = 'HORIZONTAL',
    Gtk.Paned {
      orientation = 'VERTICAL',
      object_listbox,
      Gtk.Frame {
        border_width = 0,
        Gtk.Label {
          label = "context menu" -- TODO implement
        }
      }
    },
    Gtk.ScrolledWindow {
      expand = true,
      canvas, -- canvas
    },
  },
  Gtk.ActionBar {
    Gtk.Entry {
      hexpand = true,
      margin = 5,
    }
  }
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
