load("/data/general/grids/basic.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/lava.lua", function(e) e.on_stand = nil end)

newEntity{
	define_as = "MONOLITH",
	type = "wall", subtype = "cave",
	name = "monolith", image = "terrain/cave/cave_floor_1_01.png",
	display = '&', color={r=0,g=255,b=255}, back_color=colors.OLIVE_DRAB,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	can_pass = {pass_wall=1},
	add_displays = {mod.class.Grid.new{image="terrain/darkgreen_moonstone_0"..rng.range(1,8)..".png", display_y=-1, display_h=2, z=18}},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	grow = nil,
	dig = nil,
	special = true,
	autoexplore_ignore = true,
	is_monolith = true,
}

newEntity{
	define_as = "CAVE_LADDER_ON",
	type = "floor", subtype = "cave",
	name = "way up into the mountains", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_stairs_up_1_02.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
