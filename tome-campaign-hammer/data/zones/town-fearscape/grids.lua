load("/data/general/grids/malrok_walls.lua")
load("/data/general/grids/void.lua", function(e) if e.image then e.image = e.image:gsub("^terrain/floating_rocks", "terrain/red_floating_rocks") end end)
load("/data/general/grids/burntland.lua", function(e) if e.image == "terrain/grass_burnt1.png" then e.image = "terrain/red_floating_rocks05_01.png" end end)

newEntity{
	define_as = "CRATER",
	type = "floor", subtype = "rocks",
	name = "impact crater", image = "terrain/red_floating_rocks05_01.png",
	add_displays = {
		class.new{z=4, image="terrain/impact_crater_lava.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5},
	},
	display = '*', color_r=255, color_g=255, color_b=0,
	_noalpha = false,
}

newEntity{
	define_as = "PORTAL_EYAL", 
	type = "floor", subtype = "floor",
	name = "portal to Eyal",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {
		class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
		class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
	},
	on_added = function(self, level, x, y)
		local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"}))
		ps.dy = -0.05
	end,
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "wilderness",
}
