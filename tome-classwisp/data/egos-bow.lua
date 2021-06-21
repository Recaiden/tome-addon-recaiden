local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

newEntity{
	power_source = {psionic=unknwon},
	name = "voyaging ", prefix=true, instant_resolve=true,
	keywords = {voyaging=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	resolvers.charmt(Talents.T_REK_GLR_SHOT_VOYAGE, {2,3,4,5}, 10),
	wielder = {
		lite = resolvers.mbonus_material(3, 3),
		blind_immune = resolvers.mbonus_material(50, 25, function(e, v) v=v/100 return 0, v end),
	},
	combat = {
		ranged_project = { 
			[DamageType.NATURE] = resolvers.mbonus_material(20, 5),
		},
		burst_on_crit = {
			[DamageType.NATURE] = resolvers.mbonus_material(40, 5),
		}
	}
}

newEntity{
	power_source = {technique=true},
	name = "harpstrung ", prefix=true, instant_resolve=true,
	keywords = {recurse=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 40,
	resolvers.generic(function(e)
		e.combat.range = math.max(e.combat.range - 1, 3)
	end),
	combat = {
		attack_recurse = 1,
		dam_mult=0.45,
		ranged_project = { 
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	}
}

newEntity{
	power_source = {psionic=true},
	name = "idol's ", prefix=true, instant_resolve=true,
	keywords = {idol=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
		wielder = {
			combat_mindpower = resolvers.mbonus_material(10, 2),
			life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
	}
}

newEntity{
	power_source = {arcane=true},
	name = " of the fiend", suffix=true, instant_resolve=true,
	keywords = {darkness=true, fire=true, acid=true},
	level_range = {10, 50},
	rarity = 15,
	cost = 18,
	combat = {
		ranged_project={[DamageType.DARKNESS] = resolvers.mbonus_material(20, 5)},
		ranged_project={[DamageType.FIRE] = resolvers.mbonus_material(20, 5)},
		ranged_project={[DamageType.ACID] = resolvers.mbonus_material(20, 5)},
	},
}
