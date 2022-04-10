load("/data/general/grids/basic.lua")
load("/data/general/grids/void.lua")

newEntity{
	define_as = "CLOUD",
	type = "floor", subtype = "cloud",
	name = "floor", image = "terrain/clouds/cloud_normal_002.png",
	display = '~', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	shader = "cloud_anim",
}
