return {
	name = "Derth",
	display_name = function(x, y)
		if game.level.level == 1 then return "Fields Outside Derth" end
		if game.level.level == 2 then return "Derth River" end
		return "Town of Derth"
	end,
	level_range = {20, 30},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"Virtue lost.ogg", "weather/town_small_base.ogg"},
	min_material_level = 2,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 4,
			sqrt_percent = 30,
			noise = "fbm_perlin",
			floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
				wall = "TREE",
				up = "GRASS_UP4",
				down = "GRASS_DOWN6",
				door = "GRASS",
				road = "GRASS_ROAD_DIRT",
				add_road = true,
				do_ponds = {
					nb = {0, 2},
					size = {w=25, h=25},
					pond = {{0.6, "DEEP_WATER"}, {0.8, "DEEP_WATER"}},
				},
				
				nb_rooms = {0,1},
				rooms = {"lesser_vault"},
				lesser_vaults_list = {"honey_glade", "forest-ruined-building1", "forest-ruined-building2", "mage-hideout", "collapsed-tower"},
				lite_room_chance = 100,
		},
		actor = {
			class = "mod.class.generator.actor.OnSpots",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			nb_spots = 2, on_spot_chance = 35,
			guardian = "URKIS_IN_TOWN",
		},
		object = {
			class = "engine.generator.object.OnSpots",
			nb_object = {6, 9},
			nb_spots = 2, on_spot_chance = 80,
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},	
	levels =
		{
			[1] = {
				generator = {
					map = {
						up = "ROCKY_UP_WILDERNESS",
					},
					actor = {
						class = "engine.generator.actor.Random",
						filters = { {type="animal"}, {type="humanoid"},},
						nb_npc = {20, 25},
					},
			},
		},
		[2] = {
			generator = {
				map = {
				},
				actor = {
					class = "engine.generator.actor.Random",
					filters = { {type="humanoid"}, {type="elemental"}, {type="undead"},},
					nb_npc = {20, 25},
				},
			},
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/derth",
				},
				actor = {
					class = "engine.generator.actor.Random",
					filters = { {type="elemental"}, {type="dragon"}, {type="giant"}, {type="undead"},},
					nb_npc = {20, 25},
				},
			},
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)

		if config.settings.tome.weather_effects then
			local Map = require "engine.Map"
			level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end
		game.state:makeWeather(level, 7, {max_nb=5, speed={0.5, 1.6}, shadow=true, alpha={0.15, 0.3}, particle_name="weather/grey_cloud_%02d"})
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
