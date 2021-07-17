local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_REANIMATED",
	type = "undead", subtype = "ghoul",
	display = "z", color=colors.BLUE,

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	drops = resolvers.drops{chance=100, nb=3, {type="money"}, {} },
	autolevel = "ghoul",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
	stats = { str=14, dex=12, mag=10, con=12 },
	rank = 2,
	size_category = 3,
	infravision = 10,

	resolvers.racial(),
	resolvers.inscriptions(1, "stormshield rune"),

	open_door = true,

	blind_immune = 1,
	see_invisible = 2,
	undead = 1,
	ingredient_on_death = "GHOUL_FLESH",
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_REANIMATED",
	name = "reanimated", color=colors.BLUE,
	desc = _t[[Metal bolts and vanes extend through the skin of this recently dead corpse, which crackles with lightning.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 2, combat_def = 7,
	resolvers.talents{
		[Talents.T_STUN]={base=1, every=10, max=5},
		[Talents.T_CHARGED_STRIKE]={base=1, every=10, max=5},
		[Talents.T_LIGHTNING]={base=1, every=10, max=5},
		[Talents.T_BITE_POISON]={base=1, every=10, max=5},
		[Talents.T_ROTTING_DISEASE]={base=1, every=10, max=5},
	},
	ai_state = { talent_in=3, },

	combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
}

newEntity{ base = "BASE_NPC_REANIMATED",
	name = "stormbound", color=colors.LIGHT_BLUE,
	desc = _t[[This walking corpse is surrounded by a living storm, and bolts of lightning crackle across its flesh as it moves.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 2, combat_def = 8,
	ai_state = { talent_in=3, },

	combat = { dam=resolvers.levelup(17, 1, 1.1), atk=resolvers.levelup(6, 1, 1), apr=3, dammod={str=0.6} },

	resolvers.talents{
		[Talents.T_STUN]={base=2, every=9, max=5},
		[Talents.T_BITE_POISON]={base=2, every=9, max=5},
		[Talents.T_ROTTING_DISEASE]={base=2, every=9, max=5},
		[Talents.T_DECREPITUDE_DISEASE]={base=2, every=9, max=5},
		[Talents.T_LIGHTNING]={base=4, every=10, max=8},
		[Talents.T_SHOCK]={base=3, every=10, max=7},
	},
}

newEntity{ base = "BASE_NPC_REANIMATED",
	name = "sparkdriven", color=colors.DARK_BLUE,
	desc = _t[[A headless figure, with arcs of electricity constantly spouting from the exposed base of its spine]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 3, combat_def = 10,
	ai_state = { talent_in=1, ai_pause=20 },

	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat = { dam=resolvers.levelup(30, 1, 1.2), atk=resolvers.levelup(8, 1, 1), apr=4, dammod={str=0.6} },

	resolvers.talents{
		[Talents.T_STUN]={base=3, every=9, max=7},
		[Talents.T_BITE_POISON]={base=3, every=9, max=7},
		[Talents.T_ROTTING_DISEASE]={base=4, every=9, max=7},
		[Talents.T_DECREPITUDE_DISEASE]={base=3, every=9, max=7},
		[Talents.T_WEAKNESS_DISEASE]={base=3, every=9, max=7},
		[Talents.T_SHOCK]={base=4, every=7},
		[Talents.T_HURRICANE]={base=3, every=7},
		[Talents.T_CHAIN_LIGHTNING]={base=3, every=7},
		[Talents.T_THUNDERSTORM]={base=4, every=7},
	},
	resolvers.sustains_at_birth(),
	talent_cd_reduction = {
		[Talents.T_CHAIN_LIGHTNING]=5,
	},
}

newEntity{ base = "BASE_NPC_REANIMATED",
	display = "z", color=colors.GREY, image="npc/undead_ghoul_ghoul.png",
	name = "risen corpse",
	desc = _t[[A body raised through dark magic.]],
	exp_worth = 1,
	combat_armor = 5, combat_def = 3,
	resolvers.equip{
		{type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_STUN]={base=3, every=9, max=7},
		[Talents.T_BITE_POISON]={base=3, every=9, max=7},
		[Talents.T_ROTTING_DISEASE]={base=4, every=9, max=7},
		},
}
