load("/data/general/npcs/major-demon.lua")
load("/data/general/npcs/minor-demon.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_FEARSCAPE_TOWN",
	type = "demon", subtype = "minor",
	display = "u", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	anger_emote = "Catch @himher@!",
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	life_rating = 7,
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(70,90),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 2,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",
	resolvers.drops{chance=100, nb=2, {type="money"} },
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN",
	name = "demonic clerk", color=colors.BLUE,
	desc = _t"A small ruby, tasked with the logistics of the invasion",
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(40,60),
	rarity = 2,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.FIRE},

	slow_projectiles_outgoing = 50,

	resolvers.talents{
		[Talents.T_FLAME]={base=1, every=3, max=8},
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN",
	name = "mutilator", color=colors.UMBER,
	desc = _t"A demon with 3 arms, ready to mutilate eyalite captives. For experiment. Not for fun. Nope.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,

	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},
	
	resolvers.talents{
		[Talents.T_RECKLESS_STRIKE]={base=1, every=3, max=8},
		[Talents.T_RUSH]={base=1, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN",
	name = "investigator", color=colors.DARK_UMBER,
	desc = _t"This demon is dedicated to #{italic}#extracting#{normal}# information from #{italic}#willing#{normal}# subjects.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_ABDUCTION]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
	},
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN", define_as = "PLANAR_CONTROLLER_TOWN",
	name = "Planar Controller", color=colors.VIOLET, unique = true, subtype = "major",
	desc = _t"A towering demonic machine; it is in charge of maintaining a portal link to the surface.",
	killer_message = _t"and teleported to Mal'Rok for more experiments",

	resolvers.nice_tile{tall=1},
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	rank = 4,
	size_category = 4,
	autolevel = "warriormage",
	combat_armor = 3, combat_def = 0,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,
	vim_regen = 3,

	resolvers.auto_equip_filters{MAINHAND = {type="weapon", not_properties={"command_staff"}, properties={"twohanded"}}},
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_FEARSCAPE_SHIFT]=1,
		[Talents.T_FEARSCAPE_AURA]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
		[Talents.T_WEAPON_COMBAT]=1,
	},
}
