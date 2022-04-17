load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/void.lua")

newEntity{
	define_as = "TIMESHELL",
	type = "void", subtype = "void",
	name = "temporal void",
	display = ' ',
	_noalpha = false,
	always_remember = true,
	does_block_move = true,
	pass_projectile = true,
	air_level = -40,
	is_void = true,
	can_pass = {pass_void=1},
}
