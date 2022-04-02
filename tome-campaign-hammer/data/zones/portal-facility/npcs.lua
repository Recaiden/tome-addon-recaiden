rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/major-demon.lua", rarityWithLoot(1))
load("/data/general/npcs/minor-demon.lua", rarityWithLoot(2))
load("/data/general/npcs/ghost.lua", rarityWithLoot(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "DRAEBOR_RESEARCHER",
	type = "demon", subtype = "minor", unique = true,
	name = "Portal Expert Draebor",
	display = "u", color=colors.VIOLET,
	desc = _t[[An intensely irritating git of a monster.]],
	faction = "fearscape",
	level_range = {35, nil}, exp_worth = 2.5,
	max_life = 300, life_rating = 22, fixed_rating = true,
	rank = 4,
	size_category = 5,
	infravision = 30,

	mana_regen = 100,
	life_regen = 10,
	stats = { str=20, dex=15, cun=35, mag=25, con=20 },
	poison_immune = 1,
	stun_immune = 1,
	instakill_immune = 1,
	no_breath = 1,
	move_others=true,
	demon = 1,

	on_melee_hit = { [DamageType.FIRE] = 50, [DamageType.DARKNESS] = 50, },
	resists = { [DamageType.FIRE] = 50, [DamageType.DARKNESS] = 50, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET = 1 },
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },
	equipment = resolvers.equip{
		{type="armor", subtype="feet", defined="BOOTS_OF_PHASING", random_art_replace={chance=75}, autoreq=true},
	},

	summon = {
		{type="demon", number=1, hasxp=false},
	},

	talent_cd_reduction={[Talents.T_FLAME]=2, [Talents.T_BLOOD_GRASP]=4, [Talents.T_SUMMON]=-10, },

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_FLAME]={base=5, every=5, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max=8},
		[Talents.T_WILDFIRE]={base=5, every=5, max=8},
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=5, max=8},
		[Talents.T_BONE_SHIELD]={base=3, every=10, max=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),
}
