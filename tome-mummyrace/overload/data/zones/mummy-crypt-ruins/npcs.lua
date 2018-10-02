-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/rodent.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(0))
load("/data/general/npcs/mummy.lua", rarity(0))
load("/data/general/npcs/horror-undead.lua", function(e) e.rarity = nil end)

load("/data/general/npcs/all.lua", rarity(5, 35))

newEntity{ define_as = "GOLEMGUARD",
	type = "construct", subtype = "golem",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Guardian Golem",
	display = "p", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/alchemist_golem.png", display_h=1, display_y=0}}},
	desc = [[A fragment of memory - you built this now-crumbling machine to protect you and your experiments.  But now it doesn't recognize you.  It will have to be deactivated by force.]],
	killer_message = "and thrown in with the other failed experiments",
	level_range = {5, nil}, exp_worth = 2,
	max_life = 200, life_rating = 10, fixed_rating = true,
	max_vim = 85,
	max_negative = 200,
	negative_regen = 1,
	stats = { str=20, dex=15, cun=10, mag=15, wil=10, con=15 },
	tier1 = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={str=1.2} },

	resists = { [DamageType.DARKNESS] = 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="CLOAK_DECEPTION"} },

	resolvers.talents{
		[Talents.T_GOLEM_ARCANE_PULL]={base=1, every=10},
		[Talents.T_GOLEM_KNOCKBACK]={base=1, every=10},
		[Talents.T_GOLEM_CRUSH]={base=1, every=10},
		[Talents.T_GOLEM_POUND]={base=1, every=10},
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "rune"),

	on_die = function(self, who)
	   game.player:resolveSource():setQuestStatus("start-mummy", engine.Quest.COMPLETED)
	end,
}

-- DG's mummy minions with tweaked lore and weaker abilities
newEntity{ base = "BASE_NPC_MUMMY",
	name = "ancient elven mummy", color=colors.ANTIQUE_WHITE,
	desc = [[A mindless animated corpse in mummy wrappings.  A failed experiment]],
	level_range = {1, 1}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,140),
	ai_state = { talent_in=4, },
	stats = { mag=25, wil=20, },
	infravision = 10,

	resolvers.equip{
		{type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="mummy", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_STUNNING_BLOW]={base=1, every=7, max=6},
		[Talents.T_CRUSH]={base=1, every=7, max=7},
	},
	resolvers.inscriptions(1, "rune"),
	resolvers.drops{chance=70, nb=1, {tome={money=1}} },
}

newEntity{ base = "BASE_NPC_MUMMY",
	name = "animated mummy wrappings", color=colors.SLATE, display='[', image="object/mummy_wrappings.png",
	desc = [[An animated set of mummy wrappings; without a body inside, it seems like it can barely move.  An incomplete experiment.]],
	level_range = {1, 1}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(20,40), life_rating=4,
	ai_state = { talent_in=2, },
	never_move = 1,
	infravision = 10,

	resolvers.equip{
		{type="armor", subtype="mummy", force_drop=true, forbid_power_source={antimagic=true}, autoreq=true},
	},
	autolevel = "caster",
	resolvers.talents{
		[Talents.T_FREEZE]={base=1, every=7, max=7},
		[Talents.T_STRIKE]={base=1, every=7, max=7},
	},
	resolvers.inscriptions(1, "rune"),
}

newEntity{ base = "BASE_NPC_MUMMY",
	name = "rotting mummy", color=colors.TAN,
	desc = [[A poorly preserved animated corpse in tattered mummy wrappings.  A failed experiment.]],
	level_range = {1, 1}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(60,80), life_rating=7,
	ai_state = { talent_in=4, },
	infravision = 10,

	resolvers.equip{
		{type="armor", subtype="mummy", forbid_power_source={antimagic=true}, autoreq=true},
	},
	autolevel = "ghoul",
	resolvers.talents{
		[Talents.T_WEAKNESS_DISEASE]={base=1, every=7, max=5},
		[Talents.T_BITE_POISON]={base=1, every=7, max=7},
	},
	combat = { dam=8, atk=10, apr=0, dammod={str=0.7} },
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "fleshy experiment", color=colors.DARK_GREEN,
	desc ="This pile of decayed flesh twitches and makes horrid noises.",
	level_range = {1, 5}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 2,
	combat_armor = 0, combat_def = 0,
	max_life=10, life_rating=10,
	disease_immune = 1,
	never_move = 1,
	stats = { str=5, dex=5, wil=5, mag=5, con=5, cun=5 },
	ai = nil, ai_tactic = nil, ai_state = nil,
	
	combat = {
		dam=resolvers.levelup(5, 1, 1.2),
		atk=15, apr=0,
		dammod={mag=1.3}, physcrit = 5,
		damtype=engine.DamageType.BLIGHT,
	},
	
	autolevel = "caster",
	
	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]={base=1, every=5, max=5},
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "boney experiment", color=colors.WHITE,
	desc ="This pile of bones appears to move on its own, but it can't seem to organise itself into something dangerous.",
	level_range = {1, 5}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 2,
	combat_armor = 0, combat_def = 0,
	max_life=10, life_rating = 10,
	disease_immune = 1,
	cut_immune = 1,
	never_move = 1,
	stats = { str=5, dex=5, wil=5, mag=5, con=5, cun=5 },
	ai = nil, ai_tactic = nil, ai_state = nil,
	
	combat = {
		dam=resolvers.levelup(5, 1, 1.2),
		atk=10, apr=0,
		dammod={mag=1, str=0.5}, physcrit = 5,
		damtype=engine.DamageType.PHYSICALBLEED,
	},
	
	autolevel = "warriormage",
		
	resolvers.talents{
		[Talents.T_BONE_GRAB]={base=1, every=5, max=5},
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "sanguine experiment", color=colors.RED,
	desc ="It looks like a giant blood clot. That can't have been what you intended.",
	level_range = {1, 5}, exp_worth = 1,
	rarity = 1,
	rank = 2, life_rating = 10,
	size_category = 2,
	combat_armor = 0, combat_def = 0,
	max_life=10,
	never_move = 1,
	stats = { str=5, dex=5, wil=5, mag=5, con=5, cun=5 },
	ai = nil, ai_tactic = nil, ai_state = nil,
	
	lifesteal=15,
	
	combat = {
		dam=resolvers.levelup(5, 1, 1.2),
		atk=10, apr=0,
		dammod={mag=1.1}, physcrit = 5,
		damtype=engine.DamageType.CORRUPTED_BLOOD,
	},
	
	autolevel = "caster",
	
	resolvers.talents{
		[Talents.T_BLOOD_GRASP]={base=1, every=5, max = 5},
	},
	
	resolvers.sustains_at_birth(),
}
