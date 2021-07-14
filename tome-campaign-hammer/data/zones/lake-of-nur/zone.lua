return {
	name = "Lake of Nur",
	display_name = function(x, y)
		if game.level.level == 1 then return "Lake of Nur" end
		if game.level.level == 2 then return "Lake of Nur" end
		return "Yiilkgur Excavation Site"
	end,
	level_range = {10, 20},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 38, height = 38,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 2,
	max_material_level = 3,
	is_flooded = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room"},
			lite_room_chance = 0,
			['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
			['#'] = "WATER_WALL",
			up = "WATER_UP",
			down = "WATER_DOWN",
			door = "WATER_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 25},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			underwater = true,
			effects = {"EFF_ZONE_AURA_UNDERWATER"},
			generator = {
				map =  {
					rooms = {"random_room",{"lesser_vault",7}},
					lesser_vaults_list = {"flooded-prison"},
					up = "WATER_UP_WILDERNESS",
				},
				actor = {
					filters = {{special_rarity="water_rarity"}},
				},
			},
		},
		[2] = {
			underwater = is_flooded,
			effects = {"EFF_ZONE_AURA_UNDERWATER"},
			generator =  {
				map = {
					rooms = {"random_room",{"lesser_vault",5}},
					lesser_vaults_list = {"flooded-prison"},
					['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
				},
				actor = {
					filters = {{special_rarity="water_rarity"},{special_rarity="horror_water_rarity"}},
					nb_npc = {25, 30},
				},
			},
		},
		[3] = {
			underwater = is_flooded,
			generator =  {
				map = {
					rooms = {"random_room",{"lesser_vault",5}},
					lesser_vaults_list = {"flooded-prison"},
					['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
					['#'] = {"MALROK_WALL"},
					['+'] = {"MALROK_WATER_DOOR"},
					effects = {"EFF_ZONE_AURA_UNDERWATER"},
				},
				actor = {
					filters = {{special_rarity="water_rarity"},{special_rarity="horror_water_rarity"}},
					nb_npc = {25, 30},
					guardian = "SWARMING_ABYSSAL_HORROR",
				},
			},
		},
	},
	post_process = function(level)
		if level.level == 1 then
			game.state:makeWeather(level, 6, {max_nb=3, chance=1, dir=110, speed={0.1, 0.6}, alpha={0.4, 0.6}, particle_name="weather/dark_cloud_%02d"})
		end

		if level.level == 3 then
			game.state:makeAmbientSounds(level, {
				horror={ chance=400, volume_mod=1.5, files={"ambient/horror/ambient_horror_sound_01","ambient/horror/ambient_horror_sound_02","ambient/horror/ambient_horror_sound_03","ambient/horror/ambient_horror_sound_04","ambient/horror/ambient_horror_sound_05","ambient/horror/ambient_horror_sound_06"}},
			})
		end
	end,

	on_enter = function(lev)
		if game and game.player and lev == 1 and not game.level.data.hammer_visited_nur then
			game.player:setEffect(game.player.EFF_HAMMER_DEMONIC_WATERBREATHING, 5, {})
			game.level.data.hammer_visited_nur = true
		end
	end,
}
