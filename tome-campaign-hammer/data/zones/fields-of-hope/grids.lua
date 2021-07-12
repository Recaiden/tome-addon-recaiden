load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/burntland.lua")
load("/data/general/grids/mountain.lua")

newEntity{
	define_as = "FLOOR_ROAD_STONE",
	type = "floor", subtype = "floor", road="oldstone",
	name = "old road", image = "terrain/marble_floor.png",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer2 = { method="roads_def", def="oldstone" },
}
