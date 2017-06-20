package = "penzl"
version = "dev-3"

source = {
  url = "git://github.com/rokf/penzl.git"
}

description = {
  summary = "Draw with Lua code",
  homepage = "https://github.com/rokf/penzl",
  maintainer = "Rok Fajfar <snewix7@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lgi"
}

build = {
  type = "builtin",
  modules = {
    ["penzl.main"] = "penzl/main.lua",
  },
  install = {
    bin = { "bin/penzl" }
  }
}
