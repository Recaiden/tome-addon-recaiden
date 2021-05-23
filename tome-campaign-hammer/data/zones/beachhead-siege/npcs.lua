load("/data/general/npcs/plant.lua", rarity(0))
load("/data/general/npcs/canine.lua", rarity(3))
load("/data/general/npcs/bear.lua", rarity(3))
load("/data/general/npcs/demon-major.lua", switchRarity("demons"))
load("/data/general/npcs/demon-minor.lua", switchRarity("demons"))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_THALORE_SOLDIER",
	type = "humanoid", subtype = "thalore",
	display = "p", color=colors.WHITE,
	faction = "thalore",
	anger_emote = _t"Catch @himher@!",
	exp_worth = 0,
	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	--emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_THALORE_SOLDIER",
	name = "thalore hunter", color=colors.LIGHT_UMBER,
	desc = _t[[A stern-looking elven soldier, he will not let you survive.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_BOW_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SHOOT]=1,
	},
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longbow", not_properties={"unique"}, autoreq=true},
		{type="ammo", subtype="arrow", not_properties={"unique"}, autoreq=true},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_THALORE_SOLDIER",
	name = "thalore wilder", color=colors.GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_thalore_thalore_wilder.png", display_h=2, display_y=-1}}},
	desc = _t[[A tall elf, skin covered in green moss.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	autolevel = "wildcaster",
	resolvers.talents{
		[Talents.T_RIMEBARK]={base=1, every=5, max=10},
		[Talents.T_WAR_HOUND]={base=1, every=5, max=10},
	},
	resolvers.inscriptions(3, "infusion"),
}
