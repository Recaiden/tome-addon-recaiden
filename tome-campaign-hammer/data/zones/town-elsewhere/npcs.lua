rarityWithoutXP = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.exp_worth = 0
		e.no_drops = true
		e.rank = 2
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/all.lua", rarityWithoutXP(0, 30))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ELSEWHERE_TOWN",
	type = "unknown", subtype = "unknown",
	display = "?", color=colors.WHITE,
	blood_color = colors.PINK,
	faction = "realm-divers",
	anger_emote = "<<confusion>>",
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	life_rating = 7,
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={mag=0.5,wil=0.7} },
	max_life = resolvers.rngavg(70,90),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	random_name_def = "demon",
	exp_worth = 0,
	no_drops = true,
}

newEntity{ base = "BASE_NPC_ELSEWHERE_TOWN",
	name = "bell visitor", color=colors.GREEN,
	desc = _t"A shimmering wisp that you can barely perceive.  It is waiting patiently.",
	level_range = {1, nil}, 
	max_life = resolvers.rngavg(40,60),
	rarity = 2,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.ARCANE},

	resolvers.talents{
		[Talents.T_MANATHRUST]={base=1, every=3, max=8},
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_ELSEWHERE_TOWN",
	name = "bell operator", color=colors.BLUE,
	desc = _t"A shimmering form of interlocking hedrons that you can barely perceive.  It is busily revolving.",
	level_range = {1, nil}, 
	max_life = resolvers.rngavg(40,60),
	rarity = 2,
	rank = 2,
	size_category = 2,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.ARCANE},

	slow_projectiles_outgoing = 50,

	resolvers.talents{
		[Talents.T_MANATHRUST]={base=1, every=3, max=8},
		[Talents.T_SUNDER_MIND]={base=1, every=3, max=8},
		[Talents.T_PHASE_DOOR]=4,
	},
}

newEntity{ base = "BASE_NPC_ELSEWHERE_TOWN",
  define_as = "BELL_ARCHON",
	name = "bell archon", color=colors.UMBER,
	desc = _t"An eerily beautiful elf surrounded by a shimmering haze that you can barely perceive.  It is looking straight through you.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil},
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "caster",
	combat_armor = 10, combat_def = 100,

	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},
	
	resolvers.talents{
		[Talents.T_MANATHRUST]={base=1, every=3, max=8},
		[Talents.T_SUNDER_MIND]={base=1, every=3, max=8},
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_SEVER_LIFELINE]=1,
	},

	can_talk = "campaign-hammer+bell-archon",
}
