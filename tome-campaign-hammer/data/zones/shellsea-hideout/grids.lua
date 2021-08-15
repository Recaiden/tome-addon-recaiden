load("/data/general/grids/basic.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/underground.lua")

newEntity{ base = "DEEP_WATER",
	define_as = "WATER_DEEP_DEEP",
	type = "water", subtype = "deep",
	name = "deep deep water", 
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	can_pass = {pass_deep_water=1},
	does_block_move = true,
	block_sight = false,
	z = 3,
	air_level = -20, air_condition="water",
}

newEntity{ base = "SAND",
	define_as = "NOTSAND",
	type = "floor", subtype = "sand",
	name = "sandy ocean floor", 
	display = 's', color=colors.BROWN, back_color=colors.BLACK,
	air_level = -5, air_condition="water",
}

newEntity{
	define_as = "CORAL1",
	type = "coral", subtype = "giant",
	name = "giant coral", image = "terrain/water_grass_5_1.png", add_displays = {class.new{image = "terrain/underground_tree_alpha4.png"}},
	display = 'C', color=colors.ORANGE, back_color=colors.BLUE,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20, air_condition="water",
	dig = "WATER_DEEP_DEEP",
	shader = "water",
}

newEntity{
	define_as = "CORAL2",
	type = "coral", subtype = "giant",
	name = "giant coral", image = "terrain/water_grass_5_1.png", add_displays = {class.new{image = "terrain/underground_tree_alpha9.png"}},
	display = 'C', color=colors.LIGHT_BROWN, back_color=colors.BLUE,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20, air_condition="water",
	dig = "WATER_DEEP_DEEP",
	shader = "water",
}
newEntity{
	define_as = "CORAL3",
	type = "coral", subtype = "giant",
	name = "giant coral", image = "terrain/water_grass_5_1.png", add_displays = {class.new{image = "terrain/underground_tree_alpha10.png"}},
	display = 'C', color=colors.BROWN, back_color=colors.BLUE,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20, air_condition="water",
	dig = "WATER_DEEP_DEEP",
	shader = "water",
}

newEntity{
	define_as = "UNDERSEA_CLIFFS",
	type = "rockwall", subtype = "rock",
	name = "undersea cliffs", image = "terrain/rocky_mountain.png",
	display = '#', color=colors.BLUE, back_color=colors.LIGHT_BLUE,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	dig = "WATER_FLOOR",
	nice_editer = mountain_editer,
	nice_tiler = { method="replace", base={"UNDERSEA_CLIFFS", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="UNDERSEA_CLIFFS", define_as = "UNDERSEA_CLIFFS"..i, image = "terrain/mountain5_"..i..".png"} end

newEntity{
	define_as = "HARDUNDERSEA_CLIFFS",
	type = "rockwall", subtype = "rock",
	name = "hard undersea cliffs", image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
	nice_editer = mountain_editer,
	nice_tiler = { method="replace", base={"HARDUNDERSEA_CLIFFS", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="HARDUNDERSEA_CLIFFS", define_as = "HARDUNDERSEA_CLIFFS"..i, image = "terrain/mountain5_"..i..".png"} end

newEntity{
	define_as = "ABYSSAL_CAVES",
	name = "way to the caves",
	display = '>', color_r=255, color_g=255, color_b=0, image = "terrain/water_grass_5_1.png", add_displays = {class.new{image = "terrain/underwater/subsea_cave_entrance_01.png"}},
	notice = true,
	always_remember = true,
	change_level = 1,
	air_level = -5, air_condition="water",
	
	shader = "water",
}

newEntity{
	define_as = "DEEP_WATER_UP",
	type = "floor", subtype = "water",
	image = "terrain/water_grass_5_1.png", add_displays = {class.new{image = "terrain/underwater/subsea_cave_entrance_01.png"}},
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	air_level = -5, air_condition="water",
	shader = "water",
}

newEntity{
	define_as = "DEEP_WATER_DOWN",
	type = "floor", subtype = "water",
	image = "terrain/water_grass_5_1.png", add_displays = {class.new{image = "terrain/underwater/subsea_cave_entrance_01.png"}},
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	air_level = -5, air_condition="water",
	shader = "water",
}
