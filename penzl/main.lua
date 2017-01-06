local lgi = require 'lgi'
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local cairo = lgi.cairo
local GtkSource = lgi.GtkSource

local window, header, stack_switcher, stack
local bottom_bar, coord_label, mode_label
local refresh_button, open_button, save_button, save_as_button
local export_button, document_properties_button, new_button
local editor

local style_scheme_manager = GtkSource.StyleSchemeManager()
local language_manager = GtkSource.LanguageManager()

info_bar = nil
canvas = nil
surface = nil

local commands = require 'penzl.commands'
local draw = require 'penzl.draw'
local modes = require 'penzl.modes'

local state = {
  filename = nil,
  cursor_x = 0,
  cursor_y = 0,
  preview = {
    points = {}
  },
  mode = modes.poly
}


info_bar = Gtk.InfoBar {
  no_show_all = true,
  buttons = {
    { Gtk.STOCK_OK, Gtk.ResponseType.OK },
    { Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL }
  },
  message_type = "WARNING",
  on_response = function (b,r)
    print('ResponseType',r)
    if r == Gtk.ResponseType.OK then
      state.filename = nil
      editor.buffer.text = ""
    end
    b:hide()
  end
}

info_bar:get_content_area():add(Gtk.Label {
  label = "Begin with new file?"
})

canvas = Gtk.DrawingArea {
  width = 300,
  height = 300,
}

function canvas:on_configure_event(e)
  local allocation = self.allocation
  surface = self.window:create_similar_surface('COLOR', allocation.width, allocation.height)
  local cr = cairo.Context.create(surface)
  cr:set_source_rgba(1, 1, 1, 1)
  cr:paint()
  draw:init()
  return true
end

function canvas:on_button_press_event(e)
  if e.button == Gdk.BUTTON_PRIMARY then
    table.insert(state.preview.points, string.format("%d",state.cursor_x))
    table.insert(state.preview.points, string.format("%d",state.cursor_y))
    -- draw:color(0,0,0,20)
    -- draw:poly(state.preview.points,true)
    -- canvas:queue_draw()
  elseif e.button == Gdk.BUTTON_SECONDARY then
    -- local str = table.concat(state.preview.points,",")
    local str = modes[state.mode.name].format(state.preview.points)
    editor.buffer:insert_at_cursor(str, #str)
    state.preview.points = {}
    -- draw:clear()
    -- canvas:queue_draw()
  end
  return true
end

function canvas:on_motion_notify_event(e)
  local _, x, y, st = e.window:get_device_position(e.device)
  if st.BUTTON1_MASK then
    print('mouse down',x,y)
  end
  state.cursor_x = x
  state.cursor_y = y
  coord_label.label = string.format("%d : %d", state.cursor_x, state.cursor_y)
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

refresh_button = Gtk.ToolButton { icon_name = "view-refresh" }
new_button = Gtk.ToolButton { icon_name = "document-new" }
open_button = Gtk.ToolButton { icon_name = "document-open" }
save_as_button = Gtk.ToolButton { icon_name = "document-save-as" }
save_button = Gtk.ToolButton { icon_name = "document-save" }
document_properties_button = Gtk.ToolButton { icon_name = "document-properties" }
export_button = Gtk.ToolButton { icon_name = "image-x-generic" }

function refresh_button:on_clicked()
  local custom_env = {
    rect = function (x,y,w,h)
      draw:rect(x,y,w,h)
    end,
    color = function (r,g,b,a)
      draw:color(r,g,b,a)
    end,
    poly = function (...)
      draw:poly({...},false)
    end,
    polyf = function (...)
      draw:poly({...},true)
    end,
    linew = function (w)
      draw:linew(w)
    end
  }
  draw:clear()
  load(editor.buffer.text, "editor_chunk", "bt", custom_env)()
  canvas:queue_draw()
end

function new_button:on_clicked()
  info_bar:get_content_area():show_all()
  info_bar:show()
end

function open_button:on_clicked()
  local filename
  local open_dialog = Gtk.FileChooserDialog {
    title = "Open .lua file",
    action = Gtk.FileChooserAction.OPEN,
    transient_for = window,
    buttons = {
      { Gtk.STOCK_OPEN, Gtk.ResponseType.ACCEPT },
      { Gtk.STOCK_CLOSE, Gtk.ResponseType.CANCEL }
    },
    on_response = function (d,r)
      if r == Gtk.ResponseType.ACCEPT then
        filename = d:get_filename()
      else
        filename = nil
      end
    end
  }
  local filter = Gtk.FileFilter {}
  filter:add_pattern("*.lua")
  filter:set_name("Lua Scripts")
  open_dialog:add_filter(filter)
  open_dialog:run()
  if filename ~= nil then
    local file = io.open(filename, "r")
    local str = file:read("*all")
    file:close()
    editor.buffer.text = str
    state.filename = filename
  end
  open_dialog:destroy()
end

function save_button:on_clicked()
  if state.filename then
    local file = io.open(state.filename, "w")
    file:write(editor.buffer.text)
    file:close()
  end
end

function save_as_button:on_clicked()
  local filename
  local save_dialog = Gtk.FileChooserDialog {
    title = "Save .lua file",
    action = Gtk.FileChooserAction.SAVE,
    transient_for = window,
    buttons = {
      { Gtk.STOCK_SAVE, Gtk.ResponseType.ACCEPT },
      { Gtk.STOCK_CLOSE, Gtk.ResponseType.CANCEL }
    },
    on_response = function (d,r)
      if r == Gtk.ResponseType.ACCEPT then
        filename = d:get_filename()
      else
        filename = nil
      end
    end
  }
  local filter = Gtk.FileFilter {}
  filter:add_pattern("*.lua")
  filter:set_name("Lua Scripts")
  save_dialog:add_filter(filter)
  -- do not change state because it is save_as
  save_dialog:run()
  if filename ~= nil then
    local file = io.open(filename, "w")
    file:write(editor.buffer.text)
    file:close()
  end
  save_dialog:destroy()
end

function document_properties_button:on_clicked()
  local width_entry = Gtk.Entry { placeholder_text = "width" }
  local height_entry = Gtk.Entry { placeholder_text = "height" }
  local dialog = Gtk.Dialog {
    transient_for = window,
    modal = true,
    buttons = {
      { Gtk.STOCK_SAVE, Gtk.ResponseType.ACCEPT },
      { Gtk.STOCK_CLOSE, Gtk.ResponseType.CANCEL }
    },
    on_response = function (d,r)
      if r == Gtk.ResponseType.ACCEPT then
        canvas.width = tonumber(width_entry.text)
        canvas.height = tonumber(height_entry.text)
      end
    end
  }
  dialog:get_content_area():add(width_entry)
  dialog:get_content_area():add(height_entry)
  dialog:show_all()
  dialog:run()
  dialog:destroy()
end

function export_button:on_clicked()
  local filename
  local save_dialog = Gtk.FileChooserDialog {
    title = "Save .png file",
    action = Gtk.FileChooserAction.SAVE,
    transient_for = window,
    modal = true,
    buttons = {
      { Gtk.STOCK_SAVE, Gtk.ResponseType.ACCEPT },
      { Gtk.STOCK_CLOSE, Gtk.ResponseType.CANCEL }
    },
    on_response = function (d,r)
      if r == Gtk.ResponseType.ACCEPT then
        filename = d:get_filename()
      else
        filename = nil
      end
    end
  }
  local filter = Gtk.FileFilter {}
  filter:add_pattern("*.png")
  filter:set_name("PNG Image")
  save_dialog:add_filter(filter)
  save_dialog:show_all()
  save_dialog:run()
  if filename ~= nil then
    surface:write_to_png(filename)
  end
  save_dialog:destroy()
end

header = Gtk.HeaderBar {
  title = 'penzl',
  show_close_button = true,
  custom_title = stack_switcher,
  refresh_button,
  new_button,
  open_button,
  save_as_button,
  save_button
}

header:pack_end(document_properties_button)
header:pack_end(export_button)

editor = GtkSource.View {
  top_margin = 5,
  left_margin = 5,
  buffer = GtkSource.Buffer {
    language = language_manager.get_default():get_language("lua"),
    style_scheme = style_scheme_manager:get_scheme("kate")
  }
}

bottom_bar = Gtk.ActionBar {}

coord_label = Gtk.Label {
  label = string.format("%s : %s", state.cursor_x, state.cursor_y)
}

mode_label = Gtk.Label {
  label = state.mode.name
}

bottom_bar:pack_start(mode_label)
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
stack:add_titled(docs_box, "docs_box", "Docs")

window = Gtk.Window {
  default_width = 800,
  default_height = 600,
  stack,
}

function canvas:on_key_press_event(e)
  local ctrl_on = e.state.CONTROL_MASK
  local shift_on = e.state.SHIFT_MASK
  return true
end

window:set_titlebar(header)
function window:on_destroy() Gtk.main_quit() end
window:show_all()
Gtk:main()
