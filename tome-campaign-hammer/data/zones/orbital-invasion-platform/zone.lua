return {
	name = "Orbital Invasion Platform",
	level_range = {1, 10},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Straight Into Ambush.ogg",
	effects = {"EFF_ZONE_AURA_FEARSCAPE"},
	min_material_level = 1,
	max_material_level = 1,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 16,
			min_floor = 1100,
			floor = "MALROK_FLOOR",
			wall = "MALROK_WALL",
			up = "PORTAL_PREV",
			down = "PORTAL_NEXT",
			door = "MALROK_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
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
		[3] = {
			generator = {
				map = {
					down = "PORTAL_EYAL",
					force_last_stair = true,
				},
			},
		},
		[1] = {
			generator = {
				map = {
					up = "MALROK_FLOOR",
				},
			},
		},
		},

	-- Place a lore note on each level
	post_process = function(level)
		game:placeRandomLoreObject("NOTE")
	end,
}
