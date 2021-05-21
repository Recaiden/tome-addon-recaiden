return {
	name = "Daikara",
	display_name = function(x, y)
		if game.level.level == 1 then return "Daikara (1)" end
		if game.level.level == 2 then return "Daikara (2)" end
		if game.level.level == 3 then return "Daikara (3)" end
		return "Shasshhiy'Kaish's Sanctum"
	end,
	level_range = {35, 40},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 55, height = 55,
	persistent = "zone",
	color_shown = {0.5, 1, 0.7, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.7*0.6, 0.6},
	ambient_music = {"orcs/ureslak.ogg","weather/dungeon_base.ogg"},
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
			guardian = "SHASSY",
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
