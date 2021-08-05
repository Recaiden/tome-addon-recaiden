load("/data/general/npcs/telugoroth.lua", rarity(0))
load("/data/general/npcs/horror_temporal.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SHASSY",
	type = "demon", subtype = "major",
	display = 'U',
	name = "Shasshhiy'Kaish", color=colors.VIOLET, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_shasshhiy_kaish.png", display_h=2, display_y=-1}}},
	desc = _t[[This demon would be very attractive if not for the hovering crown of flames, the three tails and sharp claws. As you watch her you can almost feel pain digging in your flesh. She wants you to suffer.]],
	killer_message = _t"and used for her perverted desires",
	level_range = {25, nil}, exp_worth = 2,
	female = 1,
	faction = "fearscape",
	rank = 4,
	size_category = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=25, dex=25, cun=32, mag=26, con=14 },
	move_others=true,
	
	instakill_immune = 1,
	stun_immune = 0.5,
	blind_immune = 0.5,
	combat_armor = 0, combat_def = 0,
	
	open_door = true,
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, "rune"),
	
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	
	combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },
	
	resolvers.drops{chance=100, nb=15, {tome_drops="boss"} },
	
	resolvers.talents{
		[Talents.T_METEOR_RAIN]={base=4, every=5, max=7},
		[Talents.T_INNER_DEMONS]={base=4, every=5, max=7},
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
		[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
		[Talents.T_SPELLCRAFT]=5,
	},
	resolvers.sustains_at_birth(),
	can_talk = "campaign-hammer+shassy",

	inc_damage = {all=90},

	on_die = function(self)
		game.player:setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "death-s")
		world:gainAchievement("ASHES_OLD_ONES", p, {name="Shasshhiy'Kaish")
	end,
}

newEntity{
	define_as = "CULTIST",
	type = "humanoid", subtype = "shalore", image = "npc/humanoid_shalore_elven_corruptor.png",
	name = _t"Cultist",
	desc = _t[[An elven cultist. He doesn't seem to mind you.]],
	display = "p", color=colors.ORCHID,
	faction = "fearscape",
	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,
	life_rating = 11,
	rank = 3,
	size_category = 3,
	open_door = true,
	silence_immune = 0.5,
	resolvers.racial(),
	autolevel = "caster",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",
	stats = { str=10, dex=8, mag=20, con=16 },
	level_range = {5, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(100, 110),
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=1, every=10, max=5},
		[Talents.T_BONE_SHIELD]={base=2, every=10, max=5},
		[Talents.T_BLOOD_SPRAY]={base=2, every=10, max=7},
		[Talents.T_DRAIN]={base=2, every=10, max=7},
		[Talents.T_SOUL_ROT]={base=2, every=10, max=7},
		[Talents.T_BLOOD_GRASP]={base=2, every=10, max=6},
		[Talents.T_BONE_SPEAR]={base=2, every=10, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(1, "rune"),
}

newEntity{ define_as = "SHASSY_ABOMINATION",
	type = "demon", subtype = "major",
	display = 'U',
	name = "Shasshhiy'Kaish, the Abomination", color=colors.VIOLET, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_shasshhiy_kaish.png", display_h=2, display_y=-1}}},
	desc = _t[[This demon would be very attractive if not for the way she stutters and flows, glitching in and out of reality.  As you watch her you can feel sorrow overcoming you.]],
	killer_message = _t"and used for her perverted desires",
	level_range = {25, nil}, exp_worth = 2,
	female = 1,
	faction = "enemies",
	rank = 3.5,
	size_category = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=25, dex=25, cun=32, mag=26, con=14 },
	move_others=true,
	
	instakill_immune = 1,
	stun_immune = 0.5,
	blind_immune = 0.5,
	combat_armor = 0, combat_def = 0,
	
	open_door = true,
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, "rune"),
	
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	
	combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },
	
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	
	resolvers.talents{
		[Talents.T_METEOR_RAIN]={base=4, every=5, max=7},
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
		[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
		[Talents.T_SPELLCRAFT]=5,

		[Talents.T_HASTE]=3,
		[Talents.T_TEMPORAL_BOLT]={base=3, every=10, max=6},
		[Talents.T_ECHOES_FROM_THE_PAST]={base=3, every=10, max=6},
	},
	resolvers.sustains_at_birth(),

	inc_damage = {all=90},

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "help-s")
		require("engine.ui.Dialog"):simplePopup(_t"Back to the Present", _t"As you kill the temporally-displaced demon, the edges of the rift snap, and the anomaly loses its anchor in your timeline.  The rift overhead begins to vanish, receding in a direction that you can't quite see, and the mountaintops begin to reemerge from the otherworldly morass.")
	end,
}

newEntity{
	define_as = "CULTIST_ABOMINATION",
	type = "humanoid", subtype = "shalore", image = "npc/humanoid_shalore_elven_corruptor.png",
	name = _t"Cultic Abomination",
	desc = _t[[A warped elven cultist, with stars in his eyes and ten thousand years on his shoulder. He raises his staff to destroy you without even looking your way.]],
	display = "p", color=colors.ORCHID,
	faction = "enemies",
	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,
	life_rating = 11,
	rank = 3,
	rarity = 2,
	size_category = 3,
	open_door = true,
	silence_immune = 0.5,
	resolvers.racial(),
	autolevel = "caster",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",
	stats = { str=10, dex=8, mag=20, con=16 },
	level_range = {5, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(100, 110),
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=1, every=10, max=5},
		[Talents.T_BONE_SHIELD]={base=2, every=10, max=5},
		[Talents.T_BLOOD_SPRAY]={base=2, every=10, max=7},
		[Talents.T_DRAIN]={base=2, every=10, max=7},
		[Talents.T_REPULSION_BLAST]={base=1, every=10, max=6},
		[Talents.T_GRAVITY_SPIKE]={base=1, every=10, max=6},
		[Talents.T_GRAVITY_WELL]={base=1, every=10, max=6},
		[Talents.T_GRAVITY_LOCUS]={base=1, every=10, max=6},
		[Talents.T_BONE_SPEAR]={base=2, every=10, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(1, "rune"),

	summon = {
	 	{type="humanoid", subtype = "shalore", define_as="CULTIST", number=1, hasxp=false},
	},
	on_die = function(self, who)
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[engine.Map.ACTOR]=true})
				local cultist = game.zone:makeEntityByName(game.level, "actor", "CULTIST")
				if cultist then
					game.zone:addEntity(game.level, cultist, "actor", x, y)
					game.logPlayer(game.player, "#VIOLET#As the temporal abomination dies, the original cultist drops through a hole in time, back to the present.")
				end
	end,

}

newEntity{
	define_as = "BASE_NPC_POINT_ZERO",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "point-zero-guardians",
	never_anger = 1,

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_POINT_ZERO", define_as = "DEFENDER_OF_REALITY",
	name = "guardian of reality", color=colors.YELLOW,
	image = resolvers.rngtable{"npc/humanoid_elf_star_crusader.png", "npc/humanoid_elf_anorithil.png"},
	female = resolvers.rngtable{false, true},
	subtype = resolvers.rngtable{"human", "shalore"},
	shader = "moving_transparency", shader_args = {a_min=0.2, a_max=0.8},
	desc = _t[[A stern-looking guardian, ever vigilant against the threats of the paradox.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 5,
	max_life = 1400,
	life_regen = 200,
	paradox_regen = -100,
	never_move = 1,
	cant_be_moved = 1,

	combat_spellpower = 300,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	talent_cd_reduction={[Talents.T_DUST_TO_DUST]=1},
	resolvers.talents{ [Talents.T_DUST_TO_DUST]=10, },
}
