rarityWithoutXP = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.exp_worth = 0
		e.no_drops = true
	end
end

load("/data/general/npcs/major-demon.lua")
load("/data/general/npcs/minor-demon.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_FEARSCAPE_TOWN",
	type = "demon", subtype = "minor",
	display = "u", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	anger_emote = "Catch @himher@!",
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	life_rating = 7,
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(70,90),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 2,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",
	exp_worth = 0,
	no_drops = true,
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN",
	name = "demonic clerk", color=colors.BLUE,
	desc = _t"A small ruby, tasked with the logistics of the invasion",
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(40,60),
	rarity = 2,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.FIRE},

	slow_projectiles_outgoing = 50,

	resolvers.talents{
		[Talents.T_FLAME]={base=1, every=3, max=8},
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN",
	name = "mutilator", color=colors.UMBER,
	desc = _t"A demon with 3 arms, ready to mutilate eyalite captives. For experiment. Not for fun. Nope.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,

	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},
	
	resolvers.talents{
		[Talents.T_RECKLESS_STRIKE]={base=1, every=3, max=8},
		[Talents.T_RUSH]={base=1, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN",
	name = "investigator", color=colors.DARK_UMBER,
	desc = _t"This demon is dedicated to #{italic}#extracting#{normal}# information from #{italic}#willing#{normal}# subjects.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_ABDUCTION]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
	},
}

newEntity{ base = "BASE_NPC_FEARSCAPE_TOWN", define_as = "PLANAR_CONTROLLER_TOWN",
	name = "Planar Controller", color=colors.VIOLET, unique = true, subtype = "major",
	desc = _t"A towering demonic machine; it is in charge of maintaining a portal link to the surface.",
	killer_message = _t"and teleported to Mal'Rok for more experiments",

	resolvers.nice_tile{tall=1},
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	rank = 4,
	size_category = 4,
	autolevel = "warriormage",
	combat_armor = 3, combat_def = 0,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,
	vim_regen = 3,

	resolvers.auto_equip_filters{MAINHAND = {type="weapon", not_properties={"command_staff"}, properties={"twohanded"}}},
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_FEARSCAPE_SHIFT]=1,
		[Talents.T_FEARSCAPE_AURA]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
		[Talents.T_WEAPON_COMBAT]=1,
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON", define_as = "SMITH",
	name = "Forge-Giant Smith", color=colors.WHITE,
	desc = _t[[A burning biomechanical giant wielding a forge hammer of Urh-Rok in each hand.  Disturb them at your peril.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_forge_giant_talkative.png", display_h=2, display_y=-1}}},
	level_range = {47, nil}, exp_worth = 0,	no_drops = true,
	rarity = 8,
	rank = 3,
	global_speed_base = 1,
	size_category = 5,
	autolevel = "warriormage",
	life_rating = 30,
	combat_armor = 32, combat_def = 40,
	mana_regen = 1, positive_regen = 1, negative_regen = 1, equilibrium_regen = -1, vim_regen = 1, stamina_regen = 1,

	ai = "tactical",

	resolvers.auto_equip_filters("Reaver"),
	resolvers.equip{ {type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true}, },

	resists={[DamageType.PHYSICAL] = resolvers.mbonus(15, 10), [DamageType.FIRE] = 100},
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(25, 25)},
	melee_project = {[DamageType.FIRE]=resolvers.mbonus(25, 35)},

	stun_immune = 1,
	knockback_immune = 1,

	resolvers.talents{
		[Talents.T_CORRUPTED_STRENGTH]={base=5, every=8, max=8},
		[Talents.T_DUAL_WEAPON_TRAINING]={base=1, every=8, max=6},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=5, every=8, max=8},
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=7},
		[Talents.T_THROW_BOULDER]={base=5, every=8, max=14},
		[Talents.T_FIREBEAM]={base=5, every=8, max=8},
		[Talents.T_WILDFIRE]={base=5, every=8, max=8},
		[Talents.T_INFERNO]={base=5, every=8, max=8},
		[Talents.T_FLAME]={base=5, every=8, max=10},
		[Talents.T_FLAMESHOCK]={base=5, every=8, max=10},
		[Talents.T_FIREFLASH]={base=5, every=8, max=10},
		[Talents.T_BURNING_WAKE]={base=5, every=8, max=10},
		[Talents.T_CLEANSING_FLAMES]={base=5, every=8, max=10},
	},
	resolvers.sustains_at_birth(),

	can_talk = "campaign-hammer+forge-giant",
}

newEntity{ define_as="TRAINING_DUMMY",
	type = "training", subtype = "dummy",
	name = "Training Dummy", color=colors.GREY,
	desc = _t"Training dummy.", image = "npc/lure.png",
	level_range = {1, 1}, exp_worth = 0,
	rank = 3,
	max_life = 300000, life_rating = 0,
	life_regen = 300000,
	immune_possession = 1,
	never_move = 1,
	knockback_immune = 1,
	training_dummy = 1,
	on_takehit = function(self, value, src, infos)
		local data = game.zone.training_dummies
		if not data then return value end

		if not data.start_turn then data.start_turn = game.turn end

		data.total = data.total + value
		if infos and infos.damtype then
			data.damtypes.changed = true
			data.damtypes[infos.damtype] = (data.damtypes[infos.damtype] or 0) + value
		end
		data.changed = true

		if data.total > 1000000 then
			world:gainAchievement("TRAINING_DUMMY_1000000", game.player)
		end

		return value
	end,
}
