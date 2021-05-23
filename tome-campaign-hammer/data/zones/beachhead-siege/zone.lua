return {
	name = "Beachhead",
	level_range = {30, 35},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"World of Ice.ogg", "weather/town_small_base.ogg"},
	min_material_level = 2,
	max_material_level = 4,
	generator =  {
		map = {
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels = {
		[1] = {
			width = 50, height = 50,
			generator = {
				map = {
					class = "engine.generator.map.Building",
					wall = "MALROK_WALL",
					floor = "BURNT_GROUND",
					margin_w = 1, margin_h = 1,
					max_block_w = 15, max_block_h = 15,
					max_building_w = 5, max_building_h = 5,
					down = "BURNT_DOWN6",
				},
			},
			actor = {
				nb_npc = {50, 50},
				filters = {{}, {}, {special_rarity="demons"}},
			},
		},
		[2] = {
			width = 70, height = 70,
			generator = {
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 12,
					min_floor = 1400,
					floor = "BURNT_GROUND",
					wall = "BURNT_TREE",
					up = "BURNT_UP4",
					down = "BURNT_DOWN6",
				},
			},
		},
		[3] = {
			width = 50, height = 50,
generator =  {
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 10,
					end_road = true,
					down = "ROCKY_UP_WILDERNESS",
					force_last_stair = true,
					edge_entrances = {4,6},
					rooms = {"forest_clearing"},
					['.'] = "ROCKY_GROUND",
					['#'] = {"ROCKY_SNOWY_TREE","ROCKY_SNOWY_TREE2","ROCKY_SNOWY_TREE3","ROCKY_SNOWY_TREE4","ROCKY_SNOWY_TREE5","ROCKY_SNOWY_TREE6","ROCKY_SNOWY_TREE7","ROCKY_SNOWY_TREE8","ROCKY_SNOWY_TREE9","ROCKY_SNOWY_TREE10","ROCKY_SNOWY_TREE11","ROCKY_SNOWY_TREE12","ROCKY_SNOWY_TREE13","ROCKY_SNOWY_TREE14","ROCKY_SNOWY_TREE15","ROCKY_SNOWY_TREE16","ROCKY_SNOWY_TREE17","ROCKY_SNOWY_TREE18","ROCKY_SNOWY_TREE19","ROCKY_SNOWY_TREE20",},
					up = "ROCKY_UP6",
					door = "ROCKY_GROUND",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {20, 30},
					filters = { {max_ood=2}, },
				},
				object = {
					class = "engine.generator.object.Random",
					class = "engine.generator.object.Random",
					nb_object = {6, 9},
					filters = { {} }
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
		},
	},

	post_process = function(level)
		if level.level ~= 3 then return end

		game:placeRandomLoreObject("NOTE1")

		local Map = require "engine.Map"
		local Particles = require "engine.Particles"
		level.data.background_particle2 = Particles.new("image", 1, {size=Map.viewport.mwidth * 1.2 * 64, image="shockbolt/terrain/observatory_bg_01"})

		local ps = {}
		for i = 1, 7 do
			local p = {max_nb=9, speed={0.5, 1.6}, alpha={0.4, 0.6}, particle_name="weather/grey_cloud_%02d", width = level.map.w*level.map.tile_w, height = level.map.h*level.map.tile_h}
			p.particle_name = p.particle_name:format(i)
			ps[#ps+1] = Particles.new("weather_storm", 1, p)
		end
		level.data.background_particle1 = ps
	end,

	background = function(level, x, y, nb_keyframes)
		if not level.data.background_particle1 then return end

		local Map = require "engine.Map"
		local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
		level.data.background_particle2.ps:toScreen(x + Map.viewport.mwidth * Map.tile_w / 2 - parx * 40, y + Map.viewport.mheight * Map.tile_h / 2 - pary * 40, true, 1)

		local dx, dy = level.map:getScreenUpperCorner() -- Display at map border, always, so it scrolls with the map
		for j = 1, #level.data.background_particle1 do
			level.data.background_particle1[j].ps:toScreen(dx, dy, true, 1)
		end
	end,
}
