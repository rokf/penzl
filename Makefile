all:
	lua penzl/main.lua
interactive:
	GTK_DEBUG=interactive lua penzl/main.lua
config:
	mkdir -p ~/.config/penzl
	touch ~/.config/penzl/conf.lua
	echo 'return { font_name = "Monospace 10" }' > ~/.config/penzl/conf.lua
install:
	luarocks install 'penzl-dev-2.rockspec'
remove:
	luarocks remove penzl
