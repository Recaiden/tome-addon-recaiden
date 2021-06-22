load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/mountain.lua", function(e) if e.image == "terrain/rocky_ground.png" then e.image = "terrain/snowy_grass.png" end end)
load("/data/general/grids/lava.lua")
load("/data/general/grids/burntland.lua")
load("/data/general/grids/malrok_walls.lua")


newEntity{
	define_as = "BURNT_DOWN2",
	type = "floor", subtype = "burnt",
	name = "way to the next level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "BURNT_DOWN4",
	type = "floor", subtype = "burnt",
	name = "way to the next level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "BURNT_DOWN8",
	type = "floor", subtype = "burnt",
	name = "way to the next level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "BURNT_UP2",
	type = "floor", subtype = "burnt",
	name = "way to the previous level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "BURNT_UP6",
	type = "floor", subtype = "burnt",
	name = "way to the previous level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "BURNT_UP8",
	type = "floor", subtype = "burnt",
	name = "way to the previous level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
