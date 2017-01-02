-- info_bar utils, uses global space

local lgi = require 'lgi'
local Gtk = lgi.Gtk

function info_show(msg,msg_type)
  assert(info_bar, "No info_bar in global space, can't call info_show.")
  assert(type(msg) == "string", "Argument msg has to be of type string.")
  info_bar:get_content_area():add(Gtk.Label {
    label = msg
  })
  info_bar.message_type = msg_type
  info_bar:show()
end
