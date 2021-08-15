return {
	name = "Shellsea Shores",
	level_range = {25, 40},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 55, height = 55,
	persistent = "zone",
	color_shown = {0.5, 1, 0.7, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.7*0.6, 0.6},
	ambient_music = "Inside a dream.ogg",
	min_material_level = 3,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 16,
			min_floor = 1100,
			floor = "CAVEFLOOR",
			wall = "CAVEWALL",
			up = "CAVE_LADDER_UP",
			down = "CAVE_LADDER_DOWN",
			door = "CAVEFLOOR",
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
	levels =
	{
		[1] = {
			generator = { 
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/shellsea-shore",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {0, 0},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {1, 3},
				},
			},
		},
		[2] = {
			all_remembered = true,
			all_lited = true,
			day_night = false,
			generator = { 
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/shellsea-deeps",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {0, 0},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
			},
		},
		[3] = {
			underwater = true,
			effects = {"EFF_ZONE_AURA_UNDERWATER"},
			generator = {
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 16,
					min_floor = 1200,
					floor = "DEEP_WATER",
					wall = {"CORAL1", "CORAL2", "CORAL3"},
					up = "DEEP_WATER_UP",
					down = "CORAL1",
					door = "CORAL2",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {20, 25},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {6, 9},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {6, 9},
				},
			},
		}
	},

	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
		})
	end,
}
