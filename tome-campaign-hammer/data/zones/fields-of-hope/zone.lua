return {
	name = "Fields of Hope",
	display_name = function(x, y)
		if game.level.level == 6 then return _t"Last Hope: Throne Room" end
		if game.level.level == 5 then return _t"Last Hope" end
		return ("Fields of Hope (%d)"):tformat(game.level.level)
	end,
	level_range = {45, 90},
	level_scheme = "player",
	max_level = 6,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 40, height = 40,
	all_lited = true,
	day_night = true,
	no_worldport = true,
	persistent = "zone",
	ambient_music = "Through the Dark Portal.ogg",
	--ambient_music = {"For the king and the country!.ogg"},
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 4,
			sqrt_percent = 45,
			noise = "fbm_perlin",
			floor = "BURNT_GROUND",
			wall = "BURNT_TREE",
			up = "BURNT_UP4",
			down = "BURNT_DOWN6",
			do_ponds =  {
				nb = {0, 2},
				size = {w=25, h=25},
				pond = {{0.6, "LAVA"}, {0.8, "LAVA"}},
			},
		},
		actor = {
			class = "mod.class.generator.actor.RandomStairGuard",
			guard = {
				{special_rarity="humanoid_random_boss", random_boss={rank = 3.5, loot_quantity = 2,}},
				{type="humanoid", subtype="human", random_boss={rank = 3.5, loot_quantity = 2,}},
				{type="humanoid", subtype="halfling", random_boss={rank = 3.5, loot_quantity = 2,}},
			},
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =	{
		[1] = {
			generator = {
				map = {
					up = "BURNT_UP_WILDERNESS",
				},
			},
		},
		[2] = {
			width = 25, height = 25,
		},
		[3] = {
			generator = {
				map = {
					floor = {"GRASS", "BURNT_GROUND", "BURNT_GROUND"},
					wall = {"TREE", "BURNT_TREE"},
					up = "BURNT_UP4",
					down = "GRASS_DOWN6",
					do_ponds =  {
						nb = {0, 2},
						size = {w=25, h=25},
						pond = {{0.6, "LAVA"}, {0.8, "WATER"}},
					},
				},
			},
		},
		[4] = {
			generator = {
				map = {
					floor = "GRASS",
					wall = "TREE",
					up = "GRASS_UP4",
					down = "GRASS_DOWN6",
					do_ponds =  {
						nb = {0, 2},
						size = {w=25, h=25},
						pond = {{0.6, "WATER"}, {0.8, "WATER"}},
					},
				},
			},
		},
		[5] = {
			width = 196, height = 80,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/hope-city",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {8, 14},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
		},
		[6] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/hope-castle",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {0, 0},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
		},
	},

	post_process = function(level)
		for uid, e in pairs(level.entities) do
			if e.type ~= "demon" then
				e.faction = e.hard_faction or "allied-kingdoms"
			end
		end
	end,
	
	on_enter = function(lev)
		if game and game.player and lev == 1 and not game.level.data.hammer_visited_hope then
			game.level.data.hammer_visited_hope = true
			require("engine.ui.Dialog"):simplePopup(_t"The Battle for Last Hope", _t"Meteors and catapult-stones rain down, sling-stones and fireballs fill the air.  Champions of Urh'rok wade through the fray as wretchlings die in droves.  In the confusion of battle, you could slip through to the city...")
		end
	end,
	
}
