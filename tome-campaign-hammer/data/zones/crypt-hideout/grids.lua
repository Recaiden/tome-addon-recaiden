load("/data/general/grids/basic.lua")

newEntity{
	define_as = "LOCK",
	type = "floor", subtype = "floor",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="LOCK_VERT", west_east="LOCK_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	does_block_move = true,
}
newEntity{ base = "LOCK", define_as = "LOCK_HORIZ", z=3, image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_y=0.1}}}}}
newEntity{ base = "LOCK", define_as = "LOCK_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}}}

newEntity{
	define_as = "PENTAGRAM",
	name = "demonic symbol",
	image = "terrain/marble_floor.png", add_mos = {{image="terrain/floor_pentagram.png"}},
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}

newEntity{
	define_as = "ALTAR_BARE",
	name = "altar",
	image = "terrain/marble_floor.png", z=3, add_mos = {{image="terrain/altar.png", display_w=2}},
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}

newEntity{
	define_as = "ALTAR_SPLATTER",
	name = "altar",
	image = "terrain/marble_floor.png", z=3, add_mos = {{image="terrain/woman_splatered_altar.png", display_w=2}},
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}
