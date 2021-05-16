return {
	name = "Derth",
	level_range = {20, 25},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "orcs/steam.ogg",
	min_material_level = 3,
	max_material_level = 5,
	generator = {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 16,
			min_floor = 1100,
			edge_entrances = {6,4},
			floor = "ROCKY_GROUND",
			wall = "SNOW_MOUNTAIN_WALL",
			['.'] = "ROCKY_GROUND",
			['#'] = "SNOW_MOUNTAIN_WALL",
			['+'] = "ROCK_VAULT",
			up = "ROCKY_UP6",
			down = "ROCKY_DOWN4",
			door = "ROCKY_GROUND",
			nb_rooms = 0,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "AUTOMATED_DEFENCE_SYSTEM3",
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
			generator = { map = {
				up = "ROCKY_UP_WILDERNESS",
				v = "STEAM_VALVE1",
				required_rooms = {"!valve1"},
			}, },
		},
		[2] = {
			generator = { map = {
				v = "STEAM_VALVE2",
				required_rooms = {"!valve2"},
			}, },
		},
		[3] = {
			generator = { map = {
				v = "STEAM_VALVE3",
				required_rooms = {"!valve3"},
			}, },
		},
	},

	post_process = function(level)
		if level.level == 2 then
			game:placeRandomLoreObject("SAW_STORM_SCHEMATIC") -- Not lore but it's useful
		end

		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)

		if config.settings.tome.weather_effects then
			local Map = require "engine.Map"
			level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end
		game.state:makeWeather(level, 7, {max_nb=5, speed={0.5, 1.6}, shadow=true, alpha={0.15, 0.3}, particle_name="weather/grey_cloud_%02d"})
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
