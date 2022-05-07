load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/autumn_forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/mountain.lua", function(e) if e.image == "terrain/rocky_ground.png" then e.image = "terrain/snowy_grass.png" end end)

local grass_editer = { method="borders_def", def="grass"}

newEntity{ base = "FLOOR", define_as = "DIRT",
	name="dirt road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

local grass_editer = { method="borders_def", def="grass"}

newEntity{
	define_as = "BOGTREE",
	type = "wall", subtype = "water",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color=colors.DARK_BLUE,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "BOGWATER",
	nice_tiler = { method="replace", base={"BOGTREE", 100, 1, 20}},
	shader = "water",
}
for i = 1, 20 do
	newEntity(class:makeNewTrees({base="BOGTREE", define_as = "BOGTREE"..i, image = "terrain/water_grass_5_1.png"}, {
		{"small_willow", {"shadow", "trunk", "foliage_bare"}},
		{"small_willow_moss", {"shadow", "trunk", "foliage_bare"}},
		{"willow", {tall=-1, "shadow", "trunk", "foliage_bare"}},
		{"willow_moss", {tall=-1, "shadow", "trunk", "foliage_bare"}},
		{"small_willow", {"shadow", "trunk", "foliage_spring"}},
		{"small_willow_moss", {"shadow", "trunk", "foliage_spring"}},
		{"willow", {tall=-1, "shadow", "trunk", "foliage_spring"}},
		{"willow_moss", {tall=-1, "shadow", "trunk", "foliage_spring"}},
	}, 1))
end

newEntity{ base="WATER_BASE",
	define_as = "BOGWATER",
	name = "bog water",
	image="terrain/water_grass_5_1.png",
}

newEntity{ base="BOGWATER",
	define_as = "BOGWATER_MISC",
	nice_tiler = { method="replace", base={"BOGWATER_MISC", 100, 1, 7}},
}
for i = 1, 7 do newEntity{ base="BOGWATER_MISC", define_as = "BOGWATER_MISC"..i, add_displays={class.new{image="terrain/misc_bog"..i..".png"}}} end


local treesdef = {
	{"small_dreamy_mushroom_01", {"trunk", {"head_%02d", 1, 2}}},
	{"small_dreamy_mushroom_02", {"trunk", {"head_%02d", 1, 6}}},
	{"small_dreamy_mushroom_03", {"trunk", {"head_%02d", 1, 5}}},
	{"small_dreamy_mushroom_04", {"trunk", {"head_%02d", 1, 3}}},
	-- {"dreamy_mushroom_01", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
	-- {"dreamy_mushroom_02", {tall=-1, "trunk", {"head_%02d", 1, 3}}},
	-- {"dreamy_mushroom_03", {tall=-1, "trunk", {"head_%02d", 1, 3}}},
	-- {"dreamy_mushroom_04", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
	-- {"dreamy_mushroom_05", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
	{"dreamy_mushroom_06", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
	{"dreamy_mushroom_07", {tall=-1, "trunk", {"head_%02d", 1, 4}}},
	{"dreamy_mushroom_08", {tall=-1, "trunk", {"head_%02d", 1, 4}}},
	{"dreamy_mushroom_09", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
	{"dreamy_mushroom_10", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
	{"dreamy_mushroom_11", {tall=-1, "trunk", {"head_%02d", 1, 2}}},
}


newEntity{
	define_as = "EXO_TREE",
	type = "wall", subtype = "rock",
	name = "peculiar tree",
	image = "terrain/tree.png",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"EXO_TREE", 100, 1, 30}},
	dig = "ROCKY_GROUND",
}
for i = 1, 30 do
	--newEntity(class:makeNewTrees({base="EXO_TREE", define_as = "EXO_TREE"..i, image = "terrain/rocky_ground.png"}, treesdef, nil, "terrain/mushrooms/"))
	newEntity(class:makeNewTrees({base="EXO_TREE", define_as = "EXO_TREE"..i, image = "terrain/snowy_grass.png", nice_tiler = false}, treesdef, nil, "terrain/mushrooms/"))
	
end


newEntity{
	define_as = "GRASS_DOWN6_LANDING",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
	change_level_check = function(self)
		game.zone.hammer_visited_autumn = true
		return false
	end,
}

newEntity{
	define_as = "AUTUMN_GRASS_DOWN6_LANDING",
	type = "floor", subtype = "autumn_grass",
	name = "way to the next level", image = "terrain/grass/autumn_grass_main_01.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = autumn_grass_editer,
	change_level_check = function(self)
		game.zone.hammer_visited_winter = true
		return false
	end,
}
