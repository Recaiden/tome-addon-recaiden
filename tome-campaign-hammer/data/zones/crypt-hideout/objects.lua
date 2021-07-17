load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic = true },
	unique = true,
	name = "Writhing Essence of Nightmares",
	desc = _t[[Whispers seem to ceaselessly emanate from this writhing mass of black tentacles, murmuring unspeakable horrors into the ears of any unfortunate enough to hear them.]],
	unided_name = _t"writhing mindstar",
	level_range = {20, 32},
	colors = colors.PURPLE , image = "object/artifact/writhing_essence_of_nightmares.png",
	rarity = 30,
	cost = 120,
	require= {stat = { wil=30 }, },
	material_level = 3,
	combat = {
		dam = 15,
		apr = 20,
		physcrit = 2,
		dammod = { wil=0.5, cun=0.3 },
		damtype=DamageType.DARKNESS,
	},
	wielder = {
		combat_mindpower = 15,
		combat_mindcrit =  3,
		inc_damage= {
			[DamageType.MIND] = 10,
			[DamageType.DARKNESS] = 10,
		},
		talents_types_mastery = {
			["cursed/fears"] = 0.2,
			["psionic/nightmare"] = 0.2,
		},
		inc_stats = { [Stats.STAT_WIL] = 2, [Stats.STAT_CUN] = 4, },
	},
	max_power = 40, power_regen=1,
	use_talent = { id = Talents.T_WAKING_NIGHTMARE , level = 2, power = 40},
}
