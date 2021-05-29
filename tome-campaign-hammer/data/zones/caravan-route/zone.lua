return {
	name = "Caravan",
	level_range = {15, 20},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
	ambient_music = {"Bazaar of Tal-Mashad.ogg", "weather/jungle_base.ogg"},
	all_lited = true,
	day_night = true,
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {30, 40},
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
	levels =
	{
		[1] = {
			
			width = 90, height = 90,
			generator = { 
				map = {
					class = "engine.generator.map.Forest",
					edge_entrances = {8,2},
					zoom = 6,
					sqrt_percent = 40,
					noise = "fbm_perlin",
					floor = "SAND",
					down = "SAND",
					wall = "PALMTREE",
					up = "SAND_UP_WILDERNESS",
					realdown = "TO_CAVE",
					
					nb_rooms = {8+3, 8+5},
					required_rooms = {"!oasis1", "!oasis2", "!oasis3", "!oasis4", "!ruins1", "!ruins2", "!ruins3", "!ruins4", },
					rooms = {"!ruins3", "!ruins4", "!ruins3", "!ruins4", "greater_vault"},
					greater_vaults_list = {"dragon_lair"},
					lite_room_chance = 100,
				},
				actor = {
					filters = {  },
					nb_npc = {40, 45},
				},
			},
		},
		[2] = {
			color_shown = {0.6, 0.6, 0.6, 1},
			color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
			width = 40, height = 40,
			generator = { 
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 19,
					lacunarity = 20,
					min_floor = 600,
					floor = "CAVEFLOOR",
					wall = "CAVEWALL",
					up = "CAVE_LADDER_UP",
					down = "CAVE_LADDER_DOWN",
				},
				actor = {
					filters = { {type="horror"}, },
					nb_npc = {12, 12},
				},
			},
		},
		[3] = {
			color_shown = {0.6, 0.6, 0.6, 1},
			color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
			width = 40, height = 40,
			generator = { 
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 19,
					lacunarity = 20,
					min_floor = 600,
					floor = "CAVEFLOOR",
					wall = "CAVEWALL",
					up = "CAVE_LADDER_UP",
					down = "CAVE_LADDER_DOWN",
				},
				actor = {
					filters = { {type="horror"}, },
					nb_npc = {12, 12},
				},
			},
		},
	},

	post_process = function(level)
	end,

	on_enter = function(lev, old_lev, newzone)
	end
}
