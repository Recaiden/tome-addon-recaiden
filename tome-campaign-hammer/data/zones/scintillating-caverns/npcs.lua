alter = function(add, mult)
	add = add or 0
	mult = mult or 1
	return function(e)
		if e.rarity then
			e.rarity = math.ceil(e.rarity * mult + add)
			e.name = rng.table{_t"crystalline ", _t"shining ", _t"scintillating "}..e:getName()
			e.make_escort = e.make_escort or {}
			e.make_escort[#emake_escort+1] = {
				{type="immovable", subtype="crystal", number=3, no_subescort=true},
			}
			e.faction = "rhalore"
		end
	end
end

alterCrystals = function(add, mult)
	add = add or 0
	mult = mult or 1
	return function(e)
		if e.rarity then
			e.rarity = math.ceil(e.rarity * mult + add)
			e.faction = "rhalore"
		end
	end
end

load("/data/general/npcs/crystal.lua", alterCrystals(15))

load("/data/general/npcs/rodent.lua", alter(5))
load("/data/general/npcs/vermin.lua", alter(2))
load("/data/general/npcs/snake.lua", alter(3))
load("/data/general/npcs/bear.lua", alter(2))
load("/data/general/npcs/elven-warrior.lua", alter(0))
load("/data/general/npcs/elven-caster.lua", alter(0))

load("/data/general/npcs/all.lua", alter(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "CRYSTAL_INQUISITOR",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "shalore", unique = true,
	name = "Crystalline Inquisitor",
	display = "p", color=colors.VIOLET, female = true,
	desc = _t[[This elven battlemage is encased in a shell of living crystal, shining with shimmering blight energies as she moves.]],
	faction = "rhalore",
	killer_message = _t"and sealed in the crystals for eternity",
	level_range = {25, nil}, exp_worth = 2,
	max_life = 1500, life_rating = 15, fixed_rating = true,
	rank = 4,
	tier1 = true,
	size_category = 3,
	infravision = 10,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, auto_req=true}, {type="armor", subtype="light", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.drops{chance=100, nb=1, {defined="ROD_OF_ANNULMENT", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]=3,
		[Talents.T_ARCANE_COMBAT]=3,
		[Talents.T_RUSH]=6,
		
		[Talents.T_BONE_GRAB]={base=3, every=6},
		[Talents.T_BONE_SHIELD]={base=3, every=6},
		
		[Talents.T_BURNING_HEX]={base=3, every=6},
		[Talents.T_EMPATHIC_HEX]={base=3, every=6},
		
		[Talents.T_VIRULENT_DISEASE]={base=3, every=6},
		[Talents.T_CYST_BURST]={base=3, every=6},
		[Talents.T_CATALEPSY]={base=3, every=6},
		
		[Talents.T_REND]={base=3, every=6},
		[Talents.T_RUIN]={base=3, every=6},
		[Talents.T_DARK_SURPRISE]={base=3, every=6},
		[Talents.T_ACID_STRIKE]={base=1, every=6},
		
		[Talents.T_CORRUPTED_STRENGTH]={base=3, every=6},
		[Talents.T_BLOODLUST]={base=3, every=6},
		[Talents.T_ACID_BLOOD]={base=3, every=6},
		[Talents.T_SOUL_ROT]={base=3, every=6},

		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]={base=4, every=10},
		[Talents.T_ARMOUR_TRAINING]={base=5, every=6},
	},
	resolvers.inscriptions(1, {"shielding rune", "speed rune"}),
	resolvers.inscriptions(1, {"manasurge rune"}),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },

	auto_classes={{class="Arcane Blade", start_level=30, level_rate=75}},
}
