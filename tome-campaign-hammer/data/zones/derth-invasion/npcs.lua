load("/data/general/npcs/gwelgoroth.lua", rarity(0))
load("/data/general/npcs/xorn.lua", rarity(2))
load("/data/general/npcs/snow-giant.lua", rarity(0))
load("/data/general/npcs/storm-drake.lua", rarity(1))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "URKIS_IN_TOWN",
	type = "humanoid", subtype = "human", unique = true,
	name = "Urkis, the High Tempest",
	display = "p", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_urkis__the_high_tempest.png", display_h=2, display_y=-1}}},
	desc = _t[[Lightning crackles around this middle-aged man. He radiates power.]],
	killer_message = _t"and used in mad electrical reanimation experiments",
	level_range = {17, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_mana = 850, mana_regen = 40,
	rank = 4,
	size_category = 2,
	infravision = 10,
	stats = { str=10, dex=12, cun=14, mag=25, con=16 },

	instakill_immune = 1,
	blind_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	resists = { [DamageType.LIGHTNING] = 100, },

	resolvers.talents{
		[Talents.T_STAFF_MASTERY]= {base=2, every=8, max=6},
		[Talents.T_FREEZE]={base=4, every=8, max=6},
		[Talents.T_ICE_SHARDS]={base=4, every=8, max=6},
		[Talents.T_LIGHTNING]={base=5, every=6, max=8},
		[Talents.T_SHOCK]={base=4, every=6, max=8},
		[Talents.T_HURRICANE]={base=4, every=6, max=7},
		[Talents.T_NOVA]={base=4, every=6, max=7},
		[Talents.T_THUNDERSTORM]={base=5, every=6, max=8},
		[Talents.T_TEMPEST]={base=5, every=6, max=6},
	},

	auto_classes={
		{class="Archmage", start_level=17, level_rate=30},
	},

	make_escort = {
		{type="dragon", name="storm wyrm", number=1},
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
	end,
}
