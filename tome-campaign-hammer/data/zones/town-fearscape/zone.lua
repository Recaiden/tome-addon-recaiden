return {
	name = "Invasion Beachhead",
	level_range = {1, 15},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 2,
	width = 50, height = 50,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	-- all_remembered = true,
	-- all_lited = true,
	-- day_night = true,
	ambient_music = {"orcs/krukpride.ogg"},
	allow_respec = "limited",
	tier1 = true,

	max_material_level = 2,
	store_levels_by_restock = { 8, 18, 35, 50 },
	nicer_tiler_overlay = "DungeonWallsGrass",

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "campaign-hammer+towns/fearscape",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			filters = {{max_ood=2}},
			nb_npc = {10, 10},
			rate = 0.27,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	levels = {
		[1] = { all_remembered = true, all_lited = true, day_night = true, },
		[2] = { width = 200, height = 25, all_lited = true, generator = {
			map = {
				class = "engine.generator.map.CavernousTunnel",
				start = 15,
				stop = 15,
				['.'] = "CAVEFLOOR",
				['#'] = "CAVEWALL",
				up = "CAVE_LADDER_UP",
				down = "WEAKNESS",
				force_last_stair = true,
			},
			actor = {
				class = "engine.generator.actor.Random",
				filters = {{max_ood=2, special_rarity="attack_rarity"}},
				guardian = "FRALOR", guardian_spot = "default_down",
			},
		} },
	},

	post_process = function(level)
		if level.level ~= 1 then return end
		
		game.state:makeWeather(level, 7, {max_nb=1, speed={0.5, 1.6}, shadow=true, alpha={0.3, 0.45}, particle_name="weather/grey_cloud_%02d"})
	end,

	on_enter = function(lev)
		local q = game.player:hasQuest("campaign-hammer+demon-siege")
		if q and not q:isCompleted("victory") then
			game:changeLevel(1, "beachhead-siege")
		end
	end,
}
