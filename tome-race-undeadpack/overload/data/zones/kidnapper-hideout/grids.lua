load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/autumn_forest.lua")
load("/data/general/grids/water.lua")
newEntity { define_as = "REK_DECO_FLOOR_BANSHEE_GRAVE",
	    image="terrain/grass2.png",
	    add_displays = {class.new{z=3, image="terrain/rek_banshee_grave.png", display_y=-1, display_h=2, display_w=1}},
	    name = "unmarked grave"}
