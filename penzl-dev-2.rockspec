package = "penzl"
version = "dev-2"

source = {
  url = "git://github.com/rokf/penzl.git"
}

description = {
  summary = "A Lua and mouse combo GTK3 vector drawing application",
  homepage = "https://github.com/rokf/penzl",
  maintainer = "Rok Fajfar <snewix7@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lgi",
  "serpent"
}

build = {
  type = "builtin",
  modules = {
    ["penzl.main"] = "penzl/main.lua",
    ["penzl.draw"] = "penzl/draw.lua",
    ["penzl.colors"] = "penzl/colors.lua",
    ["penzl.modes"] = "penzl/modes.lua",
  },
  install = {
    bin = { "bin/penzl" }
  }
}
