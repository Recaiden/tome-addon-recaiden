load("/data/general/npcs/elven-caster.lua", rarity(0))
load("/data/general/npcs/elven-warrior.lua", rarity(0))
load("/data/general/npcs/minor-demon.lua", rarity(5))
load("/data/general/npcs/major-demon.lua", function(e) e.rarity = nil end)
load("/data/general/npcs/ogre.lua", function(e) e.faction = "rhalore" if e.rarity then e.rarity = e.rarity + 4 end end)

load("/data/general/npcs/humanoid_random_boss.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_MAJOR_DEMON", define_as = "KRYL_FEIJAN",
	allow_infinite_dungeon = true,
	name = "Kryl-Feijan", color=colors.VIOLET, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_kryl_feijan.png", display_h=2, display_y=-1}}},
	desc = _t[[This huge demon is covered in darkness. The ripped flesh of its "mother" still hangs from its sharp claws.]],
	killer_message = _t"and devoured as a demonic breakfast",
	level_range = {29, nil}, exp_worth = 2,
	faction = "fearscape",
	rank = 4,
	size_category = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=42, mag=16, con=14 },
	move_others=true,
	vim_regen = 20,

	instakill_immune = 1,
	poison_immune = 1,
	blind_immune = 1,
	combat_armor = 0, combat_def = 15,

	open_door = true,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, {}),
	resolvers.inscriptions(1, {"manasurge rune"}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_DARKFIRE]={base=4, every=5, max=7},
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_SOUL_ROT]={base=5, every=5, max=8},
		[Talents.T_BLOOD_BOIL]={base=5, every=5, max=8},
		[Talents.T_FLAME]={base=5, every=5, max=8},
		[Talents.T_BURNING_WAKE]={base=5, every=5, max=8},
		[Talents.T_WILDFIRE]={base=5, every=5, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max=8},
		[Talents.T_DARKNESS]={base=3, every=5, max=6},
		[Talents.T_EVASION]={base=5, every=5, max=8},
		[Talents.T_VIRULENT_DISEASE]={base=3, every=5, max=6},
		[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
		[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
	},
	auto_classes={
		{class="Corruptor", start_level=29, level_rate=50},
		{class="Archmage", start_level=29, level_rate=50},
	},	
	resolvers.sustains_at_birth(),

	on_die = function(self)
		game.player:setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "death-k")
		world:gainAchievement("ASHES_OLD_ONES", p, {name="Kryl-Feijan"})
	end,
}

newEntity{ define_as = "MELINDA",
	name = "Melinda",
	type = "humanoid", subtype = "human", female=true,
	display = "@", color=colors.LIGHT_BLUE,
	image = "terrain/woman_naked_altar.png",
	resolvers.generic(function(e) if engine.Map.tiles.nicer_tiles then e.display_w = 2 end end),
	desc = _t[[A female Human with twisted sigils scored into her naked flesh. Her wrists and ankles are sore and hurt by ropes and chains. You can discern great beauty beyond the stains of blood covering her skin.]],
	autolevel = "tank",
	ai = "summoned", ai_real = "move_complex", ai_state = { ai_target="target_player", talent_in=4, },
	stats = { str=8, dex=7, mag=8, con=12 },
	faction = "victim", hard_faction = "victim",
	never_anger = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 4,
	rank = 2,
	exp_worth = 0,

	max_life = 100, life_regen = 0,
	life_rating = 12,
	combat_armor = 3, combat_def = 3,
	inc_damage = {all=-50},

	on_added_to_level = function(self)
		self:setEffect(self.EFF_TIME_PRISON, 100, {})
	end,

	on_die = function(self)	end,
}

newEntity{ define_as = "ACOLYTE",
	name = "Acolyte of the Sect of Kryl-Feijan",
	type = "humanoid", subtype = "elf", image = "npc/humanoid_shalore_elven_corruptor.png",
	display = "p", color=colors.LIGHT_RED,
	desc = _t[[Black-robed Elves with a mad look in their eyes.]],
	autolevel = "caster",
	stats = { str=12, dex=17, mag=18, wil=22, con=12 },

	infravision = 10,
	move_others = true,
	never_anger = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	rank = 3,
	exp_worth = 2,

	max_life = 200, life_regen = 10,
	life_rating = 14,

	resolvers.talents{
		[Talents.T_SOUL_ROT]=4,
		[Talents.T_FLAME]=5,
		[Talents.T_MANATHRUST]=3,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_die = function(self, src)
		if src and src.resolveSource then src = src:resolveSource() end
		
		if not game.level.turn_counter then return end
		if self.summoner then return end
		game.level.turn_counter = game.level.turn_counter + 6 * 10

		local nb = 0
		local nb_hero = 0
		local melinda
		for uid, e in pairs(game.level.entities) do
			if e.define_as and e.define_as == "ACOLYTE" and not e.dead and not e.summoner then
				nb = nb + 1
				if src == game.player then
					e.never_anger = nil
				end
			end
			if e.crypt_hero then nb_hero = nb_hero + 1 end
			if e.define_as and e.define_as == "MELINDA" then melinda = e end
		end
		if nb == 0 then
			game.level.turn_counter = nil
			game.player:setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "death-k")

			local spot = game.level:pickSpot{type="locked-door", subtype="locked-door"}
			local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
			game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
		end
		if nb == 0 and nb_hero == 0 then
			if melinda then
				local g = game.zone:makeEntityByName(game.level, "terrain", "ALTAR_BARE")
				game.zone:addEntity(game.level, g, "terrain", melinda.x, melinda.y)

				melinda:removeEffect(melinda.EFF_TIME_PRISON)
				melinda.display_w = nil
				melinda.image = "npc/woman_redhair_naked.png"
				melinda:removeAllMOs()
				game.level.map:updateMap(melinda.x, melinda.y)
				require("engine.ui.Dialog"):simpleLongPopup(_t"Melinda", _t"The woman seems to be freed from her bonds.\nShe stumbles on her feet, her naked body still dripping in blood. 'Please get me out of here!'", 400)
				local Chat = require "engine.Chat"
				local chat = Chat.new("campaign-hammer+melinda-rescue", {name=_t"Damsel in Distress"}, game.player)
				chat:invoke()
			end
		end
	end,
}
