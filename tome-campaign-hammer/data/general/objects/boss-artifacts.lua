local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_KNIFE",
	power_source = {arcane=true},
	unique = true,
	name = "Crystallized Aether Shard", image = "object/artifact/spellblaze_shard.png",
	unided_name = _t"crystalline purple dagger",
	moddable_tile = "special/%s_spellblaze",
	moddable_tile_big = true,
	desc = _t[[This jagged crystal glows with an unearthly light. A strip of tanned human hide is wrapped around one end, as a handle.]],
	level_range = {1, 15},
	rarity = 200,
	require = { stat = { dex=12 }, },
	cost = 250,
	metallic = false,
	material_level = 1,
	combat = {
		dam = 12,
		apr = 10,
		physcrit = 15,
		dammod = {dex=0.5,mag=0.5,},
		melee_project = {
			[DamageType.ARCANE] = 20,
		},
	},
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 5,},
		cancel_damage_chance = 10,
		resists = {[DamageType.BLIGHT] = 10, [DamageType.ARCANE] = 10},
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Norgos's Pelt", image = "object/artifact/behemoth_skin.png",
	moddable_tile = "special/behemoth_skin",
	unided_name = _t"bear-hide armor",
	desc = _t[[A barbarian's garb, made from the hide of a giant bear.  Despite the fur, it remains constantly cool to the touch.]],
	color = colors.BROWN,
	level_range = {5, 18},
	rarity = 230,
	require = { stat = { str=14 }, },
	cost = 250,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 15 },

		resists = {[DamageType.COLD] = 15},

		combat_armor = 5,
		combat_def = 3,
		combat_def_ranged = 10,

		max_encumber = 20,
		stamina_regen = 1,
		fatigue = 10,
		max_stamina = 45,
		talent_on_hit = { [Talents.T_STUN] = {level=1, chance=10} },
	},
}

newEntity{ base = "BASE_GLOVES",
	power_source = {unknown=true},
	unique = true,
	name = "Weirdling Wraps", image = "object/artifact/gloves_of_the_firm_hand.png",
	unided_name = _t"heavy gloves",
	desc = _t[[Less a pair of gloves, and more a tangle of tentacles that you wrap over your hands to cushion them; when you touch these hand-wraps, you feel like they are deliberately touching you back.]],
	level_range = {10, 25},
	rarity = 210,
	cost = 150,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 10},
		resists = { all = 10, },
		combat_armor = 5,
		stun_immune = 0.2,
		combat = {
			dam = 18,
			apr = 1,
			physcrit = 10,
			talent_on_hit = { T_TENTACLE_GRAB = {level=3, chance=20}, T_MAIM = {level=3, chance=10}, T_TAKE_DOWN = {level=3, chance=10} },
			dammod = {dex=0.3, str=-0.7, cun=0.3, con=0.4 },
		},
	},
}


newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Captain's Cutter", image = "object/artifact/anima.png", define_as = "HAMMER_CAPTAIN_SWORD",
	unided_name = _t"red-hot blade",
	moddable_tile = "special/%s_anmalice",
	moddable_tile_big = true,
	desc = _t[[This dwarven-steel blade is inscribed with old-fashioned heat runes, searing the edge of the blade to incredible temperatures while it's held.]],
	level_range = {10, 30},
	rarity = 250,
	require = { stat = { dex=20 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 28,
		apr = 24,
		physcrit = 3.5,
		dammod = {str=1},
		melee_project = {[DamageType.FIRE]=35},
		talent_on_hit = { {chance=10, talent=Talents.T_FLAMESHOCK, level=1} },
	},
	wielder = {
		inc_damage={
			[DamageType.FIRE] = 25,
		},
	},
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {psionic=true},
	unique=true, rarity=240,
	type = "charm", subtype="wand",
	name = "Blank Book", image = "object/spellbook.png",
	unided_name = _t"leather-bound tome",desc = _t[[An untitled book, bound in leather, stained now with blood of men, elves, and dogs.  There are no markings on any of the pages, but just remembering the feel of the paper is intoxicating.]],
	color = colors.SLATE,
	level_range = {15, 30},
	encumber = 5,
	not_in_stores = true,
	cost = 500,
	material_level = 3,
	wielder = {
		resists={[DamageType.MIND] = 20,},
		inc_damage={[DamageType.MIND] = 25,},
		combat_mindpower=15,
		combat_atk=15,
		fear_immune=-0.5,
	},
	max_power = 20, power_regen = 1,
	use_no_energy = true,
	use_talent = { id = Talents.T_MENTAL_SHIELDING, level = 3, power = 20 },
}


newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Turthel's Robe", color = colors.RED, image = "object/artifact/robe_of_the_archmage.png",
	unided_name = _t"ancient robe",
	desc = _t[[A plain wool robe, rustling with energy, still as perfect as the day it was made, thousands of years ago.]],
	level_range = {40, 50},
	rarity = 290,
	cost = resolvers.rngrange(500,750),
	material_level = 5,
	moddable_tile = "special/robe_of_the_archmage",
	moddable_tile_big = true,
	wielder = {
		inc_damage = {all=15},
		combat_def = 10,
		combat_armor = 10,
		inc_stats = { [Stats.STAT_MAG] = 10, [Stats.STAT_WIL] = 10},
		combat_spellpower = 15,
		combat_spellresist = 20,
		combat_spellcrit = -10,
		combat_critical_power = 50,
		resists={[DamageType.LIGHTNING] = 25,[DamageType.COLD] = 15},
		resists_pen = {[DamageType.LIGHTNING]=20}
		mana_regen = 2,
	},
	talents_add_levels_filters = {
		{desc=_t"+1 to all lightning damage spells", filter=function(who, t, lvl)
			if t.is_spell and t.tactical and (
				table.has(t.tactical, "attack", "LIGHTNING") or
				table.has(t.tactical, "attackarea", "LIGHTNING")
			) then
				return lvl + 1
			end
		end},
	},
}
