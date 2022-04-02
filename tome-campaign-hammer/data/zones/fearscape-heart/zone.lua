return {
	name = "Goedalath",
	display_name = function(x, y)
		if game.level.level == 6 then return _t"Goedalath: Heart of the Fearscape" end
		if game.level.level == 5 then return _t"Goedalath: Citadel of Urh'Rok" end
		return ("Goedalath (%d)"):tformat(game.level.level)
	end,
	level_range = {55, 90},
	level_scheme = "player",
	max_level = 6,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 40, height = 40,
	all_lited = true,
	day_night = true,
	no_worldport = true,
	persistent = "zone",
	ambient_music = function()
		if game.level.level == 6 then return "Through the Dark Portal.ogg" end
		if game.level.level == 5 then return "For the king and the country!.ogg" end
		return "Hold the Line.ogg"
	end,
	min_material_level = 4,
	max_material_level = 5,
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
				{type="demon", subtype="major", random_boss={rank = 3.5, loot_quantity = 2,}},
				{type="demon", subtype="minor", random_boss={rank = 3.5, loot_quantity = 2,}},
			},
			nb_npc = {30, 45},
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
					up = "BURNT_GROUND",
				},
			},
		},
		[2] = {
			width = 25, height = 25,
			generator = {
				map = {
					up = "BURNT_GROUND",
				},
			},
			actor = {
				nb_npc = {15, 25},
			},
		},
		[3] = {
			generator = {
				map = {
					floor = {"GRASS", "BURNT_GROUND", "BURNT_GROUND"},
					wall = {"TREE", "BURNT_TREE"},
					up = "BURNT_GROUND",
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
					up = "GRASS",
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
			e.faction = e.hard_faction or "fearscape"
		end
	end,
	
	on_enter = function(lev)
		if game and game.player and lev == 6 then
			local happyWalrog = game.player:hasQuest("campaign-hammer+demon-allies") and game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("eyal-w") and not game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("death-w")
			local happyShassy = game.player:hasQuest("campaign-hammer+demon-allies") and game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("eyal-s") and not game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("death-s") and not game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("angry-s")
			local happyKryl = game.player:hasQuest("campaign-hammer+demon-allies") and game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("eyal-k") and not game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("death-k")
			local corruptMelinda = game.player:hasQuest("campaign-hammer+demon-allies") and game.player:hasQuest("campaign-hammer+demon-allies"):isCompleted("saved-melinda")
			-- Walrog kills the random enemies that initially populate the room.
			if happyWalrog then
				require("engine.ui.Dialog"):simplePopup(_t"The Battle for Last Hope", _t"As you approach the center of the citadel, a chill fills the artificial air, and the shadowflames flicker out.  All around you, demons have their lives snuffed out by dark magic, but you stand unharmed.")
				for uid, e in pairs(game.level.entities) do
					if e.faction == "fearscape" and e.rank < 4 then
						e:die()
					end
				end
			end
			-- Shasshy'kaish gives you an extra defense
			if happyShassy then
				game.player:setEffect(game.player.EFF_HAMMER_CULTIST_REVIVE, 99, {})
			end
			-- Kryl'Feijan joins the fight like Aeryn
			if happyKryl then
				local x, y = util.findFreeGrid(game.player.x, game.player.y, 5, true, {[engine.Map.ACTOR]=true})
				local kryl = game.zone:makeEntityByName(game.level, "actor", "KRYL_FEIJAN_REBORN")
				if kryl then
					game.zone:addEntity(game.level, kryl, "actor", x, y)
					game.logPlayer(game.player, "The air is split open by a burning portal, and Kryl'Feijan appears next to you!")
					for uid, e in pairs(game.level.entities) do
						if e.define_as and (e.define_as == "KHULMANAR") then
							e:setTarget(kryl)
						end
					end
				end
			end
			-- TODO should be a non-demon version
			-- Melinda is weaker than Kryl, and doesn't tank hits at the start, but may still help.
			if corruptMelinda then
				local x, y = util.findFreeGrid(game.player.x, game.player.y, 5, true, {[engine.Map.ACTOR]=true})
				local mel = game.zone:makeEntityByName(game.level, "actor", "DOOMBRINGER_MELINDA")
				if mel then
					game.zone:addEntity(game.level, mel, "actor", x, y)
					game.logPlayer(game.player, "The air is split open by a burning portal, and Melinda appears next to you, wreathed in the flames of the fearscape")
				end
			end
		end
	end,	
}
