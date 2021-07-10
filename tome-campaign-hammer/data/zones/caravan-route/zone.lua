return {
	name = "Caravan",
	level_range = {10, 20},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 80, height = 28,
	persistent = "zone",
	ambient_music = {"Enemy at the gates.ogg", "weather/jungle_base.ogg"},
	all_lited = true,
	day_night = true,
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.MapScript",
			['<'] = "COBBLESTONE_UP4", ['>'] = "COBBLESTONE_DOWN6",
			['.'] = "FLOOR", ['+'] = "DOOR", ['#'] = "WALL",
			['_'] = "FLOOR", ['O'] = "WALL", 
			[';'] = "GRASS", ['T'] = "TREE",
			['='] = "COBBLESTONE",
			mapscript = "!main",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {30, 40},
			guardian = "CARAVAN_MASTER",
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
						['<'] = "COBBLESTONE_UP_WILDERNESS",
					},
				},
			},
			[3] = {
				width=28, height=80,
				generator = {
					map = {
						force_last_stair = true,
						['<'] = "COBBLESTONE_UP8",
						['>'] = "COBBLESTONE_UP_WILDERNESS",
					},
				},
			},
	},

	post_process = function(level)
	end,

	on_enter = function(lev, old_lev, newzone)
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "dwarves")
	end,
}
