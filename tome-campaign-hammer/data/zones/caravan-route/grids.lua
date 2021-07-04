load("/data/general/grids/basic.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/cave.lua")


newEntity{ base = "GRASS", define_as = "FIELDS",
	name="cultivated fields",
	display=';', image="terrain/cultivation.png"
}

newEntity{ base = "FLOOR", define_as = "COBBLESTONE",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{
	define_as = "COBBLESTONE_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/stone_road1.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "COBBLESTONE_UP8",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "COBBLESTONE_UP2",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "COBBLESTONE_UP4",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "COBBLESTONE_UP6",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "COBBLESTONE_DOWN8",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "COBBLESTONE_DOWN2",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "COBBLESTONE_DOWN4",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "COBBLESTONE_DOWN6",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/stone_road1.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
