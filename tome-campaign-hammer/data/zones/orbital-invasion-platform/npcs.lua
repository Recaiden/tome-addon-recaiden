local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/losgoroth.lua", function(e)
			 e.combat_def = 0; e.inc_damage = {all=-70}
			 e.bonus_loot = resolvers.drops{chance=66, nb=1, {}} -- less than normal because of the crossfire
			 e.bonus_arts = resolvers.drops{chance=2, nb=1, {tome_drops="boss"}}
end)
load("/data/general/npcs/demon-major.lua", rarity(20))
load("/data/general/npcs/demon-minor.lua", rarity(10))

newEntity{
	define_as = "BASE_NPC_PLATFORM",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "allied-kingdoms",
	exp_worth = 0,
	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_PLATFORM",
	name = "escaped demonologist", color=colors.LIGHT_UMBER,
	desc = _t[[In the chaos, this human has somehow turned against his controller and conditioning.  Best to kill him.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_arcane_blade.png"}}},
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", not_properties={"unique"}, autoreq=true, never_drop=true},
		{type="armor", subtype="shield", not_properties={"unique"}, autoreq=true, never_drop=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, [Talents.T_OSMOSIS_SHIELD]=1, [Talents.T_ARMOUR_TRAINING]=2, },
	resolvers.drops{chance=100, nb=3, {}},
}

newEntity{
	base="BASE_NPC_LOSGOROTH", define_as = "VOID_VORTEX",
	unique = true,
	name = "Corrupted Vortex",
	color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_void_losgoroth_corrupted_greater.png", display_h=2, display_y=-1}}},
	desc = _t[[A vast aether elemental, bloated with the power of the fearscape.]],
	killer_message = _t"and drained of every scrap of vim",
	level_range = {5, nil}, exp_worth = 2,
	max_life = 150, life_rating = 10, fixed_rating = true,
	mana_regen = 7,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	tier1 = true,
	size_category = 6,
	infravision = 10,
	instakill_immune = 1,
	can_pass = {pass_void=0},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	equipment = resolvers.equip{
		{defined="VOID_STAR", autoreq=true},
	},
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_VOID_BLAST]={base=1, every=7, max=7},
		[Talents.T_DARKFIRE]={base=1, every=7, max=7},
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_FLAME_OF_URH_ROK]={base=3, every=5, max=8},
	},
	talent_cd_reduction = {
		[Talents.T_DARKFIRE]=5,
	},
	slow_projectiles_outgoing = 50,
	resolvers.inscriptions(1, {"manasurge rune"}),
	resolvers.sustains_at_birth(),

	low_level_tactics_override = {escape=0},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_added = function(self, level, x, y)
		if engine.Map.tiles.nicer_tiles then
			local ps = self:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=40, vortex="shockbolt/terrain/planar_demon_vortex"}))
			ps.dy = -0.35
			ps.dx = -0.07
		end
	end,
	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("campaign-hammer+start-demon", engine.Quest.COMPLETED, "secured")
	end,
}

newEntity{
	define_as = "BASE_NPC_MODERATE_DEMON",
	type = "demon", subtype = "major",
	display = "U", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=22, dex=10, mag=20, con=13 },
	combat_armor = 1, combat_def = 1,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",

	resolvers.inscriptions(1, "rune"),
}

newEntity{
	base = "BASE_NPC_MODERATE_DEMON",
	name = "stampeding dolleg", color=colors.GREEN,
	faction = "enemies",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_dolleg.png", display_h=2, display_y=-1}}},
	desc = _t"This injured, panicked warbeast is running out of control.  Perhaps you should put it down, but mind the thorns!",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	rank = 2,
	autolevel = "warrior",
	combat_armor = 5, combat_def = 0,
	combat = resolvers.easy_combat_table{
		dam = {8, 95},
		atk = {10, 150},
		apr = 0,
		dammod = {str=1},
		physcrit = 12,
	},

	resists={[DamageType.ACID] = resolvers.mbonus(30, 20)},
	inc_damage = {all=-45},

	hates_everybody = 1,
	hated_by_everybody = 1,

	confusion_immune = 1,
	stun_immune = 1,

	resolvers.talents{
		[Talents.T_ACIDIC_SKIN]={base=1, every=5, max=10},
		[Talents.T_SLIME_SPIT]={base=2, every=5, max=8},
	},

	resolvers.drops{chance=100, nb=2, {}},
}
