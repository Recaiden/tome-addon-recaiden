load("/data/general/npcs/aquatic_demon.lua", rarity(99))
load("/data/general/npcs/aquatic_critter.lua", rarity(0))
load("/data/general/npcs/naga.lua", rarity(0))
load("/data/general/npcs/yaech.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_AQUATIC_DEMON", define_as = "WALROG_HAMMER",
	name = "Walrog, Terror of the Seas", color=colors.DARK_SEA_GREEN, unique=true,
	desc = _t"Walrog, the lord of Water, is fearsome to behold. The water writhes around him as if trying to escape, making his form indistinct. He does not seem surprised to see you.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/aquatic_demon_walrog.png", display_h=2, display_y=-1}}},
	level_range = {20, 30}, exp_worth = 1,
	rarity = 50,
	rank = 3.5,
	life_rating = 16,
	soul_regen = 5,
	mana_regen = 10,
	faction = "fearscape",
	autolevel = "warriormage",
	combat_armor = 45, combat_def = 0,
	combat_dam = 55,
	combat = {damtype=DamageType.ICE},

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resists={[DamageType.COLD] = resolvers.mbonus(50, 30)},

	resolvers.talents{
		[Talents.T_ICE_SHARDS]=4,
		[Talents.T_GLACIAL_VAPOUR]=4,
		[Talents.T_TIDAL_WAVE]=4,
		
		[Talents.T_FREEZE]=5,
		[Talents.T_FROZEN_GROUND]=5,
		[Talents.T_UTTERCOLD]=5,

		[Talents.T_BLASTWAVE]=5,
		[Talents.T_BURNING_WAKE]=5,
		[Talents.T_CLEANSING_FLAMES]=5,
		[Talents.T_WILDFIRE]=5,

		[Talents.T_WATER_JET]=3,
		[Talents.T_WATER_BOLT]=3,
		[Talents.T_BLACK_ICE]=3,

		[Talents.T_SOUL_LEECH]=10,
		[Talents.T_CONSUME_SOUL]=10,
		[Talents.T_TORTURE_SOULS]=10,
		[Talents.T_REAPING]=10,

		[Talents.T_RIGOR_MORTIS]=5,
	},
	resolvers.sustains_at_birth(),

	can_talk = "campaign-hammer+walrog",
	on_death_lore = "walrog",
	
	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "death-w")
	end,
}
