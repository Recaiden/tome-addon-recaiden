return {
	name = _t"Angolwen",
	level_range = {60, 100},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 50, height = 50,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"Dreaming of Flying.ogg", "weather/town_medium_base.ogg"},
	allow_respec = "limited",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 3 end,
	store_levels_by_restock = { 10, 20, 35, 45, 50, 60 },

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/angolwen",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {10, 10},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			town_medium={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/town/town_medium1","ambient/town/town_medium2","ambient/town/town_medium3","ambient/town/town_medium4"}},
		})
	end,

	on_enter = function(lev, old_lev, zone)
		-- Update the stairs
		local spot = game.level:pickSpot{type="portal", subtype="back"}
		if spot then game.level.map(spot.x, spot.y, engine.Map.TERRAIN).change_zone = game.player.last_wilderness end
	end,
}
