return {
	name = "Buried Kingdom",
	level_range = {40, 50},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	ambient_music = "Bazaar of Tal-Mashad.ogg",
	persistent = "zone",
	max_material_level = 5,
	no_random_lore = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {4,6},
			rooms = {"forest_clearing"},
			lite_room_chance = 90,
			rooms_config = {forest_clearing={pit_chance=3, filters={{type="horror", subtype="eldritch", max_ood=2}}}},
			['.'] = "UNDERGROUND_SAND",
			['#'] = "SANDWALL_STABLE",
			up = "SAND_LADDER_UP",
			down = "SAND_LADDER_DOWN",
			door = "UNDERGROUND_SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {15, 26},
			filters = { {max_ood=2}, },
			randelite = 0,
			guardian = "BURIED_FORGOTTEN",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {0, 0},
		},
	},
	levels =
		{
			[1] = {
				generator = {
					map = {
						up = "SAND_LADDER_UP_WILDERNESS",
					},
				},
			},
		},
}
