return {
	name = "Beachhead (Siege)",
	level_range = {30, 40},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"World of Ice.ogg", "weather/town_small_base.ogg"},
	min_material_level = 3,
	max_material_level = 5,
	generator =  {
		map = {
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "THALORE_LEADER",
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
					door = "MALROK_BURNT_DOOR",
					floor = "BURNT_GROUND",
					margin_w = 0, margin_h = 0,
					max_block_w = 15, max_block_h = 15,
					max_building_w = 5, max_building_h = 5,
					edge_entrances = {2,8},
					up = "BURNT_UP_WILDERNESS", --you can retreat, but can't get to town
					down = "BURNT_DOWN8",
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
					edge_entrances = {2,6},
					up = "BURNT_UP2",
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
					down = "ROCKY_GROUND",
					force_last_stair = true,
					edge_entrances = {4,6},
					rooms = {"forest_clearing"},
					['.'] = "ROCKY_GROUND",
					['#'] = {"ROCKY_SNOWY_TREE","ROCKY_SNOWY_TREE2","ROCKY_SNOWY_TREE3","ROCKY_SNOWY_TREE4","ROCKY_SNOWY_TREE5","ROCKY_SNOWY_TREE6","ROCKY_SNOWY_TREE7","ROCKY_SNOWY_TREE8","ROCKY_SNOWY_TREE9","ROCKY_SNOWY_TREE10","ROCKY_SNOWY_TREE11","ROCKY_SNOWY_TREE12","ROCKY_SNOWY_TREE13","ROCKY_SNOWY_TREE14","ROCKY_SNOWY_TREE15","ROCKY_SNOWY_TREE16","ROCKY_SNOWY_TREE17","ROCKY_SNOWY_TREE18","ROCKY_SNOWY_TREE19","ROCKY_SNOWY_TREE20",},
					up = "ROCKY_UP4",
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
		for uid, e in pairs(level.entities) do
			if e.type ~= "demon" then
				e.faction = e.hard_faction or "thalore"
			end
		end
		
		if level.level ~= 3 then return end

		game:placeRandomLoreObject("NOTE1")
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		if game.player:hasQuest("campaign-hammer+empty-memory") then
			game.player:resolveSource():setQuestStatus("campaign-hammer+empty-memory", engine.Quest.COMPLETED)
		end
	end,
}
