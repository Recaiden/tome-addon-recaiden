return {
	name = "Scintillating Caverns",
	level_range = {20, 30},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + e:getRankLevelAdjust() + 1 end,
	width = 30, height = 30,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Mystery.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 1 end,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 5,
			rooms = {"random_room", {"money_vault",5}, {"lesser_vault",8}},
			lesser_vaults_list = {"amon-sul-crypt","skeleton-mage-cabal","crystal-cabal","snake-pit"},
			lite_room_chance = 20,
			['.'] = "CRYSTAL_FLOOR",
			['#'] = {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",},
			up = "CRYSTAL_LADDER_UP",
			down = "CRYSTAL_LADDER_DOWN",
			door = "CRYSTAL_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {12, 16},
			filters = { {max_ood=2}, },
			guardian = "SPELLBLAZE_CRYSTAL",
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
					map = {
						up = "CRYSTAL_LADDER_UP_WILDERNESS",
					},
				},
			},
			[5] = {
				width = 50, height = 50,
				generator =  {
					map = {
						class = "engine.generator.map.Cavern",
						zoom = 14,
						min_floor = 700,
						floor = "FLOOR",
						wall = {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",},
						up = "CRYSTAL_LADDER_UP",
						down = "CRYSTAL_LADDER_DOWN",
						door = "CRYSTAL_FLOOR",
					},
					actor = {
						class = "mod.class.generator.actor.Random",
						nb_npc = {20, 30},
						filters = { {max_ood=2}, },
						guardian = "CRYSTAL_INQUISITOR",
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
			},
		},
	
	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE")
	end,

	foreground = function(level, dx, dx, nb_keyframes)
		local tick = core.game.getTime()
		local sr, sg, sb
		sr = 4 + math.sin(tick / 2000) / 2
		sg = 3 + math.sin(tick / 2700)
		sb = 3 + math.sin(tick / 3200)
		local max = math.max(sr, sg, sb)
		sr = sr / max
		sg = sg / max
		sb = sb / max

		level.map:setShown(sr, sg, sb, 1)
		level.map:setObscure(sr * 0.6, sg * 0.6, sb * 0.6, 1)
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		if game.player:isQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "crystals") then
			require("engine.ui.Dialog"):simpleLongPopup("Crystals", [[With the Rhaloren out of the way, the fearscape's mages move in to investigate the crystals.  Soon enough, demonic crystal beings are rampaging out of control, consuming the elven lands.  Your work here is done.]], 500)
			game.player:resolveSource():setQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "crystals-2")
		end

		if game.player:isQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "crystals") or game.player:isQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "rhalore")then
			local Chat = require "engine.Chat"
			local chat = Chat.new("campaign-hammer+crystal-power", {name=_t"Spellblaze Crystals"}, game.player)
			chat:invoke()
			game.player:grantQuest("campaign-hammer+demon-siege")
		end
	end,
}
