all:
	lua penzl/main.lua examples/basic.lua
render:
	lua penzl/main.lua examples/basic.lua 500 500 examples/output.png
install:
	luarocks install 'penzl-dev-3.rockspec'
remove:
	luarocks remove penzl
