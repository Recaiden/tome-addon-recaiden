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
	change_level_check = function(self)
		local player = game:getPlayer(true)
	
		game:changeLevel(1, ("campaign-hammer+derthfields-landing-site"), {direct_switch=true})
		player:grantQuest("campaign-hammer+demon-landing")

		local a = require("engine.Astar").new(game.level.map, player)

		local sx, sy = util.findFreeGrid(player.x, player.y, 20, true, {[engine.Map.ACTOR]=true})
		while not sx do
			sx, sy = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
			if game.level.map(sx, sy, engine.Map.ACTOR) or not a:calc(player.x, player.y, sx, sy) then sx, sy = nil, nil end
		end

		game.level.map:particleEmitter(player.x, player.y, 1, "demon_teleport")

		game:onLevelLoad("wilderness-1", function(zone, level, data)
			local list = {}
			for i = 0, level.map.w - 1 do for j = 0, level.map.h - 1 do
				local idx = i + j * level.map.w
				if level.map.map[idx][engine.Map.TERRAIN] and level.map.map[idx][engine.Map.TERRAIN].change_zone == data.from then
					list[#list+1] = {i, j}
				end
			end end
			if #list > 0 then
				game.player.wild_x, game.player.wild_y = unpack(rng.table(list))
			end
		end, {from=game.zone.short_name})

		if player.hammer_killed_dolleg then
			player.hammer_killed_dolleg = nil
		else
			world:gainAchievement("HAMMER_SAVE_DOLLEG", player)
		end
		
		require("engine.ui.Dialog"):simplePopup(_t"Onward!", _t"You made it to Eyal! Now you must clear this area, which will be the beachhead for the demon invasion.  Kill everything you find.")
		return true
	end,
}
