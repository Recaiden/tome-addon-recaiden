load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/lava.lua", function(e) if e.define_as == "LAVA_FLOOR" then e.on_stand = nil end end)
load("/data/general/grids/malrok_walls.lua")
load("/data/general/grids/void.lua", function(e) if e.image then e.image = e.image:gsub("^terrain/floating_rocks", "terrain/red_floating_rocks") end end)
load("/data/general/grids/burntland.lua", function(e) if e.image == "terrain/grass_burnt1.png" then e.image = "terrain/red_floating_rocks05_01.png" end end)
load("/data/general/grids/gothic.lua", function(e) if e.image == "terrain/gothic_walls/marble_floor.png" then e.image = "terrain/red_floating_rocks05_01.png" end end)

newEntity{
	define_as = "PORTAL_NEXT", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	type = "floor", subtype = "floor",
	name = "portal to the next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "PORTAL_PREV", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	type = "floor", subtype = "floor",
	name = "portal to the previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

