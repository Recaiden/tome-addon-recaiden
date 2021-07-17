return {
	name = "Dark Crypt",
	level_range = {25, 40},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
	persistent = "zone",
	all_remembered = true,
	color_shown = {0.6, 0.6, 0.6, 1},
	color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
	ambient_music = "Challenge.ogg",
	min_material_level = 3,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 5,
			rooms = {"random_room", {"money_vault",5}},
			lite_room_chance = 20,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 20},
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
	special_level_faction = "fearscape",
	post_process = function(level)
		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "fearscape" end
	end,
	on_enter = function(lev)
		if lev == 1 and not game.level.data.hammer_visited_crypt then
			game.level.data.hammer_visited_crypt = true
			game.level.turn_counter = 20 * 10
			game.level.max_turn_counter = 20 * 10
			game.level.turn_counter_desc = _t"The cultists are about to sacrifice the woman. Protect them while they finish the ritual."
			game.party:learnLore("kryl-feijan-altar-demon")
		end
	end,
	on_turn = function(self)
		if game.level.turn_counter then
			-- spawn a hero
			if (game.level.turn_counter % 80) == 40 then
				local spot = game.level:pickSpot{type="pop", subtype="hero"}
				if not game.level.map(spot.x, spot.y, game.level.map.ACTOR) then
					local m = game.zone:makeEntity(
						game.level, "actor",
						{
							special_rarity="humanoid_random_boss", subtype="human",
							random_boss={
								nb_classes=1,
								rank=3.2, ai = "tactical",
								life_rating=function(v) return v * 1.4 + 3 end,
								loot_quality = "store",
								loot_quantity = 1,
								no_loot_randart = true,
								rnd_boss_final_adjust = function() end,
							}
						}, nil, true)
					if m then
						game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)

						targets = {}
						for uid, e in pairs(game.level.entities) do
							if e.define_as and e.define_as == "ACOLYTE" then
								targets[#targets+1] = e
							end
						end
						if #targets then
							local acolyte = rng.table(targets)
							m:setTarget(acolyte)
							m.ai_state.target_last_seen = {x=acolyte.x, y=acolyte.y, turn=game.turn}
						end
					else
						print("[CRYPT] could not create actor")
					end
				end
			end
			
			game.level.turn_counter = game.level.turn_counter - 1
			game.player.changed = true
			if game.level.turn_counter < 0 then
				game.level.turn_counter = nil
				require("engine.ui.Dialog"):simpleLongPopup(_t"Crypt", _t"The woman lets out a sudden ear-splitting scream that turns from pain to horror as her stomach is ripped open from within by long dark claws. A towering black demon arises, rending her flesh to shreds, and replacing her dying scream with a terrifying roar.", 400)
				for uid, e in pairs(game.level.entities) do
					if e.define_as and e.define_as == "MELINDA" then
						local x, y = e.x, e.y
						e:die()

						local g = game.zone:makeEntityByName(game.level, "terrain", "ALTAR_SPLATTER")
						game.zone:addEntity(game.level, g, "terrain", x, y)

						local m = game.zone:makeEntityByName(game.level, "actor", "KRYL_FEIJAN")
						if m then
							game.zone:addEntity(game.level, m, "actor", x, y)
							game.level.map:particleEmitter(x, y, 1, "blood")
						end
						game.player:setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "help-k")

						game.level.map:particleEmitter(x, y, 3, "corpse_explosion", {radius=3})

						local spot = game.level:pickSpot{type="locked-door", subtype="locked-door"}
						local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
						game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
						break
					end
				end
			end
		end
	end,
	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end

		local melinda
		for uid, e in pairs(game.level.entities) do if e.define_as and e.define_as == "MELINDA" then melinda = e end end
		if melinda and not melinda.dead and core.fov.distance(game.player.x, game.player.y, melinda.x, melinda.y) > 1 then
			require("engine.ui.Dialog"):simplePopup(_t"Crypt", _t"You cannot abandon Melinda here!")
			return nil, nil, true
		end

		local g = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
		if melinda and not melinda.dead and not game.player:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "help-k") and g and g.change_level then
			world:gainAchievement("MELINDA_SAVED", game.player)
			game.player:setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "saved-melinda")
		end
	end,

	levels =
	{
		[1] = {
			width = 90,
			height = 40,
			no_level_connectivity = true,
			no_worldport = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/crypt-kryl-feijan",
				},
				actor = {
					area = {x1=25, x2=85, y1=0, y2=49},
					nb_npc = {25, 25},
				},
				object = { nb_object = {0, 0}, },
				trap = { nb_trap = {0, 0}, },
			},
		},
	},
}
