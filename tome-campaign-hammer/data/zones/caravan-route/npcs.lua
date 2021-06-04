load("/data/general/npcs/canine.lua", rarity(1))
load("/data/general/npcs/troll.lua", rarity(2))
load("/data/general/npcs/bear.lua", rarity(2))
load("/data/general/npcs/plant.lua", rarity(3))

newEntity{
	define_as = "BASE_CARAVANEER",
	type = "humanoid", subtype = "human", image="npc/humanoid_human_spectator02.png",
	display = "p", color=colors.DARK_KHAKI,
	faction = "allied-kingdoms",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=2, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	
	emote_random = {chance=10, _t"To arms!", _t"Demon!", _t"Die!", _t"Monster!", _t"Protect the caravan!"},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_MERCHANT",
	name = "caravan merchant", color=colors.KHAKI, image="npc/humanoid_human_spectator02.png",
	subtype = "human",
	desc = _t[[A caravan merchant.]],
	level_range = {1, 10}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,50), life_rating = 7,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
	},
	make_escort = {
		{name="caravan guard", number=3},
		{name="caravan porter", number=4},
	},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_GUARD",
	name = "caravan guard", color=colors.KHAKI, image="npc/humanoid_human_spectator.png",
	subtype = "human",
	desc = _t[[A caravan guard.]],
	rarity = 2,
	level_range = {5, 20}, exp_worth = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=2, every=10, max=6}, },
	make_escort = {
		{name="war dog", number=2},
		{name="caravan guard", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_PORTER",
	name = "caravan porter", color=colors.KHAKI, image="npc/humanoid_human_spectator03.png",
	subtype = "human",
	desc = _t[[A caravan porter.]],
	level_range = {1, 8}, exp_worth = 1,
	max_life = resolvers.rngavg(60,70), life_rating = 8,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
	},
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "WAR_DOG",
	name = "war dog", color=colors.KHAKI, image="npc/canine_dw.png",
	desc = _t[[This is a large dog, bred and trained for fighting.]],
	level_range = {15, 30}, exp_worth = 1,
	max_life = resolvers.rngavg(60,100), life_rating = 10,
	combat_armor = 4, combat_def = 7,
	combat = { dam=resolvers.levelup(30, 1, 1), atk=resolvers.levelup(25, 1, 1), apr=15 },
	resolvers.talents{
		[Talents.T_RUSH]=2,
		[Talents.T_GRAPPLING_STANCE]=2,
		[Talents.T_CLINCH]=2,
	},
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "CORRUPTED_WAR_DOG",
	name = "corrupted war dog", color=colors.BLACK, image="npc/canine_dw.png",
	desc = _t[[This is a large dog, bred and trained for fighting. Something about the way it moves doesn't look normal.]],
	level_range = {15, 30}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=resolvers.levelup(30, 1, 1), atk=resolvers.levelup(25, 1, 1), apr=15 },
	resolvers.talents{ [Talents.T_RUSH]=2, },
	resolvers.talents{ [Talents.T_GRAPPLING_STANCE]=2, },
	resolvers.talents{ [Talents.T_CLINCH]=2, },

	make_escort = {
		{name="war dog", number=4, no_subescort=true},
	},
}
