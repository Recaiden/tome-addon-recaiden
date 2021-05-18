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
