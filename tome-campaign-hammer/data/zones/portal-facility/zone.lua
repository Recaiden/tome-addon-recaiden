return {
	name = "Crossroads of Many Ways",
	level_range = {40, 50},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 38, height = 38,
	persistent = "zone",
	no_worldport = true,
	is_demon_plane = true,
	ambient_music = "Straight Into Ambush.ogg",
	max_material_level = 5,
	effects = {"EFF_ZONE_AURA_FEARSCAPE"},
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {4,6},
			rooms = {"forest_clearing"},
			lite_room_chance = 90,
			rooms_config = {forest_clearing={pit_chance=3, filters={{type="demon", subtype="major", max_ood=2}}}},
			['.'] = "FLOATING_ROCKS",
			['#'] = "MALROK_WALL",
			up = "PORTAL_PREV",
			down = "PORTAL_NEXT",
			door = "MALROK_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {9, 16},
			filters = { {max_ood=2}, },
			randelite = 0,
			guardian = "DRAEBOR_RESEARCHER",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {4, 6},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {0, 0},
		},
	},
	levels = {	
		[1] = {
			generator =  {
				map = {
					class = "engine.generator.map.Forest",
					edge_entrances = {2,8},
					zoom = 3,
					sqrt_percent = 30,
					noise = "fbm_perlin",
					floor = "LAVA_FLOOR",
					wall = "LAVA_WALL",
					up = "LAVA_FLOOR",
					do_ponds =  {
						nb = {2, 3},
						size = {w=25, h=25},
						pond = {{0.6, "LAVA"}, {0.8, "VOID"}},
					},
				},
			},
		},
		[2] = {
			generator =  {
				map = {
					class = "engine.generator.map.Forest",
					edge_entrances = {2,6},
					zoom = 3,
					sqrt_percent = 30,
					noise = "fbm_perlin",
					floor = "LAVA_FLOOR",
					wall = "LAVA_WALL",
					do_ponds =  {
						nb = {2, 3},
						size = {w=25, h=25},
						pond = {{0.6, "LAVA"}, {0.8, "LAVA"}},
					},
				},
			},
		},
		[3] = {
			generator =  {
				map = {
					['.'] = "LAVA_FLOOR",
					['#'] = "MALROK_WALL",
				},
			},
		},
		[5] = {
			generator =  {
				map = {
					force_last_stair = true,
					down = "PORTAL_EXIT",
				},
			},
		},
	},
	post_process = function(level)
		game:placeRandomLoreObject("NOTE"..level.level)	
	end,
	on_enter = function(lev, old_lev, newzone)
		game.player:attr("planetary_orbit", 1)

		if game and game.player and lev == 1 and not game.level.data.hammer_visited_fearscape then
			game.level.data.hammer_visited_fearscape = true
			require("engine.ui.Dialog"):simplePopup(_t"The End of Vengeance", _t"Down below, the remaining forces of Eyal fight fiercly to distract and occupy the demonic invaders, while you, alone, make your way towards the heart of the fearscape. You will only have one chance.  There can be no retreat here!")
		end
	end,
}
