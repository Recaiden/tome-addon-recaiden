load("/data/general/npcs/ritch.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(0))
load("/data/general/npcs/ant.lua", rarity(2))
load("/data/general/npcs/jelly.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_RITCH_REL",
	type = "insect", subtype = "ritch",
	display = "I", color=colors.RED,
	desc = _t[[Ritches are giant insects native to the arid wastes of the southern parts of the Far East.
Vicious predators, they inject corrupting diseases into their foes, and their sharp claws cut through most armours.]],
	killer_message = _t", who incubated her eggs in the corpse,",

	combat = { dam=resolvers.rngavg(10,32), atk=0, apr=4, damtype=DamageType.BLIGHT, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 1,
	rank = 2,

	autolevel = "slinger",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=15, dex=15, mag=8, con=10 },

	poison_immune = 0.5,
	disease_immune = 0.5,
	ingredient_on_death = "RITCH_STINGER",
	resists = { [DamageType.BLIGHT] = 20, [DamageType.FIRE] = 40 },
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "ritch flamespitter", color=colors.DARK_RED,
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 5,
	life_rating = 3,
	lite = 1,

	rank = 2,

	ai_state = { ai_move="move_complex", talent_in=1, },
	resolvers.talents{
		[Talents.T_RITCH_FLAMESPITTER_BOLT]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH_REL", define_as = "BURIED_FORGOTTEN",
	unique = true, female = true,
	name = "Ritch Great Hive Mother", image = "npc/insect_ritch_ritch_hive_mother.png",
	display = "I", color=colors.VIOLET,
	desc = _t[[This huge ritch seems to be the mother of all those here. Her sharp, fiery, claws dart toward you!]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 120, life_rating = 14, fixed_rating = true,
	equilibrium_regen = -50,
	infravision = 10,
	stats = { str=15, dex=10, cun=8, mag=16, wil=16, con=10 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	tier1 = true,
	rank = 4,
	size_category = 4,

	combat = { dam=30, atk=22, apr=7, dammod={str=1.1} },

	resists = { [DamageType.BLIGHT] = 40 },

	body = { INVEN = 10, BODY=1, HANDS=1 },

	inc_damage = {all=-70},

	resolvers.equip{{defined="FLAMEWROUGHT", random_art_replace={chance=75}, autoreq=true}},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_SHRIEK]=2,
		[Talents.T_WEAKNESS_DISEASE]=1,
		[Talents.T_RITCH_FLAMESPITTER_BOLT]=2,
		[Talents.T_SPIT_BLIGHT]=2,
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="insect", subtype="ritch", number=1, hasxp=false},
	},

	autolevel = "dexmage",
	ai = "tactical", ai_state = { talent_in=2, },

	auto_classes={{class="Summoner", start_level=12, level_rate=75},},

	-- Override the recalculated AI tactics to avoid problematic kiting in the early game
	low_level_tactics_override = {escape=0},
	
	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "ritch")
	end,
}
