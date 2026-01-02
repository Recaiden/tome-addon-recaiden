load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

newEntity{ base = "GRASS", define_as = "FIELDS",
	name="cultivated fields",
	display=';', image="terrain/cultivation.png"
}

newEntity{ base = "FLOOR", define_as = "COBBLESTONE",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{ base = "GRASS", define_as = "FIELDS",
	name="cultivated fields",
	display=';', image="terrain/cultivation.png",
	nice_tiler = { method="replace", base={"FIELDS", 100, 1, 4}},
}
for i = 1, 4 do newEntity{ base = "FIELDS", define_as = "FIELDS"..i, image="terrain/grass.png", add_mos={{image="terrain/cultivation0"..i..".png"}} } end
