load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/mountain.lua", function(e) if e.image == "terrain/rocky_ground.png" then e.image = "terrain/snowy_grass.png" end end)
load("/data/general/grids/lava.lua")
load("/data/general/grids/burntland.lua")
load("/data/general/grids/malrok_walls.lua")


newEntity{
	define_as = "MALROK_BURNT_DOOR",
	type = "wall", subtype = "rocks",
	name = "door", image = "terrain/malrok_wall/malrok_granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="MALROK_BURNT_DOOR_VERT", west_east="MALROK_BURNT_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "MALROK_BURNT_DOOR_OPEN",
	dig = "FLOOR",
	can_pass = {pass_wall=1},
}
newEntity{
	define_as = "MALROK_BURNT_DOOR_OPEN",
	type = "wall", subtype = "rocks",
	name = "open door", image="terrain/malrok_wall/malrok_granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	door_closed = "MALROK_BURNT_DOOR",
}
newEntity{ base = "MALROK_BURNT_DOOR", define_as = "MALROK_BURNT_DOOR_HORIZ", image = "terrain/grass_burnt1.png", add_mos={{image = "terrain/malrok_wall/malrok_wall_closed_doors1.png"}}, add_displays = {class.new{image="terrain/malrok_wall/malrok_wall_top_block1.png", z=18, display_y=-1}}, door_opened = "MALROK_BURNT_DOOR_HORIZ_OPEN"}
newEntity{ base = "MALROK_BURNT_DOOR_OPEN", define_as = "MALROK_BURNT_DOOR_HORIZ_OPEN", image = "terrain/grass_burnt1.png", add_mos={{image = "terrain/malrok_wall/malrok_wall_open_doors1.png"}}, add_displays = {class.new{image="terrain/malrok_wall/malrok_wall_top_block1.png", z=18, display_y=-1}}, door_closed = "MALROK_BURNT_DOOR_HORIZ"}
newEntity{ base = "MALROK_BURNT_DOOR", define_as = "MALROK_BURNT_DOOR_VERT", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/malrok_wall/malrok_wall_door1_vert.png", z=17}, class.new{image="terrain/malrok_wall/malrok_wall_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "MALROK_BURNT_DOOR_OPEN_VERT"}
newEntity{ base = "MALROK_BURNT_DOOR_OPEN", define_as = "MALROK_BURNT_DOOR_OPEN_VERT", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/malrok_wall/malrok_wall_door1_open_vert.png", z=17}, class.new{image="terrain/malrok_wall/malrok_wall_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "MALROK_BURNT_DOOR_VERT"}

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
