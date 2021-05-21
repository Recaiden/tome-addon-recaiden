load("/data/general/npcs/xorn.lua", rarity(4))
load("/data/general/npcs/snow-giant.lua", rarity(0))
load("/data/general/npcs/canine.lua", rarity(2))
load("/data/general/npcs/cold-drake.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SHASSY",
	type = "demon", subtype = "major",
	display = 'U',
	name = "Shasshhiy'Kaish", color=colors.VIOLET, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_shasshhiy_kaish.png", display_h=2, display_y=-1}}},
	desc = _t[[This demon would be very attractive if not for the hovering crown of flames, the three tails and sharp claws. As you watch her you can almost feel pain digging in your flesh. She wants you to suffer.]],
	killer_message = _t"and used for her perverted desires",
	level_range = {25, nil}, exp_worth = 2,
	female = 1,
	faction = "fearscape",
	rank = 4,
	size_category = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=25, dex=25, cun=32, mag=26, con=14 },
	move_others=true,
	
	instakill_immune = 1,
	stun_immune = 0.5,
	blind_immune = 0.5,
	combat_armor = 0, combat_def = 0,
	
	open_door = true,
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, "rune"),
	
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	
	combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },
	
	resolvers.drops{chance=100, nb=math.ceil(5 * scale), {tome_drops="boss"} },
	
	resolvers.talents{
		[Talents.T_METEOR_RAIN]={base=4, every=5, max=7},
		[Talents.T_INNER_DEMONS]={base=4, every=5, max=7},
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
		[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
		[Talents.T_SPELLCRAFT]=5,
	},
	resolvers.sustains_at_birth(),

	inc_damage = {all=90},
}
