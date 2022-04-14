load("/data/general/grids/basic.lua")
load("/data/general/grids/lava.lua", function(e) if e.define_as == "LAVA_FLOOR" then e.on_stand = nil end end)
load("/data/general/grids/malrok_walls.lua")
load("/data/general/grids/void.lua", function(e) if e.image then e.image = e.image:gsub("^terrain/floating_rocks", "terrain/red_floating_rocks") end end)
load("/data/general/grids/burntland.lua", function(e) if e.image == "terrain/grass_burnt1.png" then e.image = "terrain/red_floating_rocks05_01.png" end end)

newEntity{
	define_as = "PORTAL_NEXT", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	type = "floor", subtype = "floor",
	name = "portal to the next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "PORTAL_PREV", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	type = "floor", subtype = "floor",
	name = "portal to the previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "PORTAL_EXIT", 
	type = "floor", subtype = "floor",
	name = "portal onwards",
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
	change_level = 1, change_zone = "campaign-hammer+fearscape-heart",
}

newEntity{ base = "MALROK_FLOOR",
	define_as = "PORTAL_WIDGET",
	name = "portal stabilizer", image = "terrain/red_floating_rocks05_01.png", add_displays={class.new{z=6, image="terrain/pedestal_orb_03.png"}},
	display = '+', color=colors.RED,
	grow = table.NIL_MERGE,
	force_clone = true,
	always_remember = true,
	notice = true,
	special = true,
	special_minimap = colors.CRIMSON,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		self.add_displays[1] = self.add_displays[1]:cloneFull()
		self.add_displays[1].image = "terrain/pedestal_01.png"
		self:removeAllMOs()
		game.level.map:updateMap(x, y)
		game.player:resolveSource():setQuestStatus("campaign-hammer+hero-main", engine.Quest.COMPLETED, self.quest_tag)
		game.log("#PURPLE#You smash the portal stabilizer!")
	end,
}

newEntity{ base = "PORTAL_WIDGET",
	define_as = "PORTAL_WIDGET_1",
	quest_tag = "portals-1",
}
newEntity{ base = "PORTAL_WIDGET",
	define_as = "PORTAL_WIDGET_2",
	quest_tag = "portals-2",
}
newEntity{ base = "PORTAL_WIDGET",
	define_as = "PORTAL_WIDGET_3",
	quest_tag = "portals-3",
}
