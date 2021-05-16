return {
	name = "Scintillating Caverns",
	level_range = {25, 30},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 80, height = 80,
	no_worldport = true,
--	all_remembered = true,
	-- all_lited = true,
	-- day_night = true,
	persistent = "zone",
	ambient_music = "orcs/Vaporous Emporium.ogg",
	min_material_level = 5,
	max_material_level = 5,
	generator = {
		map = {
			class = "engine.generator.map.Hexacle",
			segment_wide_chance = 70,
			nb_segments = 8,
			nb_layers = 6,
			segment_miss_percent = 10,
			['+'] = "CAVEDOOR",
			['.'] = "CAVEFLOOR",
			['#'] = "CAVEWALL",
			door = "CAVEFLOOR",
			up = "CAVE_LADDER_UP",
			down = "CAVE_LADDER_DOWN",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {25, 35},
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
				map = {up = "CAVEFLOOR",}, 
				actor = {class = "engine.generator.actor.Random" },
			},
		},
		[2] = {
			generator = { map = {
				nb_segments = 5,
			}, },
		},
		[3] = {
			generator = { map = {
				nb_segments = 7,
			}, },
		},
		[4] = {
			generator = { map = {
				nb_segments = 9,
			}, },
		},
		[5] = {
			generator = { actor = {
				area = {x1=0, x2=29, y1=0, y2=11},
				nb_npc = {15, 15},
			}, map = {
				class = "engine.generator.map.Static",
				map = "!final",
			}, },
		},
	},
	on_enter = function(lev)
		if lev == 1 then
			require("engine.ui.Dialog"):simpleLongPopup("Fall", "The end of the staircase was trapped, you fell for a long time, luckily not breaking anything. But you have no way back now...", 500)
		end
	end,

	post_process = function(level)
		if level.level <= 4 then game:placeRandomLoreObject("NOTE"..level.level) end
	end
}
