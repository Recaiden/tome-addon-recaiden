return {
	name = "Daikara",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Shasshhiy'Kaish's Sanctum" end
		return "Daikara Mountains"
	end,
	level_range = {25, 40},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 55, height = 55,
	persistent = "zone",
	color_shown = {0.5, 1, 0.7, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.7*0.6, 0.6},
	ambient_music = "World of Ice.ogg",
	min_material_level = 2,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {2,8},
			rooms = {"forest_clearing", "rocky_snowy_trees", {"lesser_vault",7}},
			rooms_config = {forest_clearing={pit_chance=5, filters={{}}}},
			lesser_vaults_list = {"snow-giant-camp", "perilous-cliffs"},
			['.'] = is_volcano and function() if rng.percent(5 + game.level.level * 6) then return "LAVA_FLOOR" else return "ROCKY_GROUND" end end or "ROCKY_GROUND",
			['T'] = "ROCKY_SNOWY_TREE",
			['#'] = "MOUNTAIN_WALL",
			up = "ROCKY_UP2",
			down = "ROCKY_DOWN8",
			door = "ROCKY_GROUND",
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
			all_remembered = true,
			all_lited = true,
			day_night = false,
			generator = { 
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/daikara-sanctum",
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
		[2] = {
			generator = { 
				map = { up = "CAVE_LADDER_UP_WILDERNESS",}, 
				actor = {class = "engine.generator.actor.Random" },
			},
		},
	},
	
	post_process = function(level)
		game.state:makeAmbientSounds(level, {
																	 dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
		})
	end,
}
