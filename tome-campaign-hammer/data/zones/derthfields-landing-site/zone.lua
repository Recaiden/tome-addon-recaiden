return {
	name = _t"Derthfields Landing Site",
	level_range = {5, 15},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + e:getRankLevelAdjust() + 1 end,
	width = 65, height = 40,
	all_lited = true,
	day_night = true,
	tier1 = true,
	tier1_escort = 2,
	persistent = "zone",
	ambient_music = "Rainy Day.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 5 or 1 end,
	is_flooded = true,
	nicer_tiler_overlay = "DungeonWallsGrass",
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 7,
			sqrt_percent = 30,
			sqrt_percent2 = 25,
			noise = "fbm_perlin",
			floor2 = function() if rng.chance(20) then return "BOGWATER_MISC" else return "BOGWATER" end end,
			floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
			wall = "BOGTREE",
			up = "GRASS",
			down = "GRASS_DOWN6",
			door = "BOGWATER",
			road = "GRASS_ROAD_DIRT",
			add_road = true,

			nb_rooms = {0,1},
			rooms = {"lesser_vault"},
			lesser_vaults_list = {"honey_glade", "forest-ruined-building1", "forest-ruined-building2", "forest-ruined-building3", "snake-pit", "mage-hideout", "collapsed-tower"},
			lite_room_chance = 100,
		},
		actor = {
			class = "mod.class.generator.actor.OnSpots",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			nb_spots = 2, on_spot_chance = 35,
			guardian = "MAGRIN",
		},
		object = {
			class = "engine.generator.object.OnSpots",
			nb_object = {6, 9},
			nb_spots = 2, on_spot_chance = 80,
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
			}, },
		},
		[2] = {
			width = 150, height = 12,
			generator =  {
				map = {
					class = "mod.class.generator.map.GenericTunnel",
					start = 6,
					stop = 6,
					['#'] = "AUTUMN_TREE",
					['.'] = "AUTUMN_GRASS",
					up = "AUTUMN_GRASS_UP4",
					down = "AUTUMN_GRASS_DOWN6",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {40, 40},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {6, 9},
					filters = { {type="gem"} }
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
		},
		[3] = {
			generator =  {
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 10,
					end_road = true,
					down = "ROCKY_UP_WILDERNESS",
					force_last_stair = true,
					edge_entrances = {4,6},
					rooms = {"forest_clearing"},
					['.'] = "ROCKY_GROUND",
					['#'] = {"ROCKY_SNOWY_TREE","ROCKY_SNOWY_TREE2","ROCKY_SNOWY_TREE3","ROCKY_SNOWY_TREE4","ROCKY_SNOWY_TREE5","ROCKY_SNOWY_TREE6","ROCKY_SNOWY_TREE7","ROCKY_SNOWY_TREE8","ROCKY_SNOWY_TREE9","ROCKY_SNOWY_TREE10","ROCKY_SNOWY_TREE11","ROCKY_SNOWY_TREE12","ROCKY_SNOWY_TREE13","ROCKY_SNOWY_TREE14","ROCKY_SNOWY_TREE15","ROCKY_SNOWY_TREE16","ROCKY_SNOWY_TREE17","ROCKY_SNOWY_TREE18","ROCKY_SNOWY_TREE19","ROCKY_SNOWY_TREE20",},
					up = "ROCKY_UP6",
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
		}
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)

		if level.level == 2 and config.settings.tome.weather_effects then
			local Map = require "engine.Map"
			level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end

		-- Some clouds floating happily
		game.state:makeWeather(level, 7, {max_nb=1, speed={0.5, 1.6}, shadow=true, alpha={0.23, 0.35}, particle_name="weather/grey_cloud_%02d"})
		game.state:makeAmbientSounds(level, {
			wind={ chance=120, volume_mod=1.5, pitch=0.9, files={"ambient/forest/wind1","ambient/forest/wind2","ambient/forest/wind3","ambient/forest/wind4"}},
			bird={ chance=600, volume_mod=0.75, files={"ambient/forest/bird1","ambient/forest/bird2","ambient/forest/bird3","ambient/forest/bird4","ambient/forest/bird5","ambient/forest/bird6","ambient/forest/bird7"}},
			cricket={ chance=1200, volume_mod=0.75, files={"ambient/forest/cricket1","ambient/forest/cricket2"}},
		})
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)

		if nb_keyframes > 10 then return end
		if nb_keyframes > 0 and rng.chance(400 / nb_keyframes) then local s = game:playSound("ambient/horror/ambient_horror_sound_0"..rng.range(1, 6)) if s then s:volume(s:volume() * 1.5) end end
	end,

	on_enter = function(lev, old_lev, newzone) end,
}
