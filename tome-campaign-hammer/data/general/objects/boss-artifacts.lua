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

-- Norgos's Pelt T1
-- Weirdling Wraps gloves T2 

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

-- The Blank Book tool T3
-- <urkis> T3
-- <rod of annulment> + crystal core
-- <rope belt of thaloren>
-- Turtle's Robe - flat DR and ice, bit of lightning T5
