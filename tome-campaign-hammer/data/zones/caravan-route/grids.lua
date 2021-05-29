load("/data/general/grids/basic.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/cave.lua")

newEntity{
	define_as = "TO_CAVE", image = "terrain/sandfloor.png", add_mos = {{image="terrain/stair_down.png"}},
	type = "floor", subtype = "sand",
	name = "Stair to the ruins",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
