rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=85, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=2, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/demon-major.lua", rarity(1))
load("/data/general/npcs/demon-minor.lua", rarity(0))
load("/data/general/npcs/plant.lua", rarity(50))
load("/data/general/npcs/all.lua", rarity(20, 50))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_LAST_HOPE",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "allied-kingdoms",
	exp_worth = 1,
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
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=12, dex=8, mag=6, con=10 },
	resolvers.drops{chance=85, nb=1, {}}
}

newEntity{ base = "BASE_NPC_LAST_HOPE",
	name = "last hope guard", color=colors.LIGHT_UMBER,
	desc = _t[[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", not_properties={"unique"}, autoreq=true},
		{type="armor", subtype="shield", not_properties={"unique"}, autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
	make_escort = {
		{name="human citizen", number=1},
		{name="halfling citizen", number=1},
	},
}

newEntity{ base = "BASE_NPC_LAST_HOPE",
	name = "halfling guard", color=colors.UMBER,
	subtype = "halfling",
	desc = _t[[A Halfling, with a sling. Beware.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=2, },
	autolevel = "slinger",
	resolvers.equip{
		{type="weapon", subtype="sling", not_properties={"unique"}, autoreq=true}, 
		{type="ammo", subtype="shot", not_properties={"unique"}, autoreq=true}
	},
	make_escort = {
		{name="human citizen", number=1},
		{name="halfling citizen", number=1},
	},
}

newEntity{ base = "BASE_NPC_LAST_HOPE",
	name = "shadowblade", color_r=resolvers.rngrange(0, 10), color_g=resolvers.rngrange(0, 10), color_b=resolvers.rngrange(100, 120),
	desc = _t[[These rogues are not who you'd usually expect to save the kingdom.  But having everyone dragged to hell is bad for business.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 4,
	combat_armor = 3, combat_def = 50,
	combat_critical_power = 50,
	resolvers.auto_equip_filters("Rogue"),
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.talents{
		[Talents.T_LETHALITY]={base=1, every=6, max=5},
		[Talents.T_KNIFE_MASTERY]={base=0, every=6, max=6},
		[Talents.T_WEAPON_COMBAT]={base=0, every=6, max=6},
		[Talents.T_STEALTH]={base=3, every=5, max=8},
		[Talents.T_DUAL_WEAPON_MASTERY]={base=2, every=6, max=6},
		[Talents.T_TEMPO]={base=2, every=6, max=6},
		[Talents.T_DUAL_STRIKE]={base=1, every=6, max=6},
		[Talents.T_SHADOWSTEP]={base=2, every=6, max=6},
		[Talents.T_LETHALITY]={base=5, every=6, max=8},
		[Talents.T_SHADOW_LEASH]={base=1, every=6, max=6},
		[Talents.T_SHADOW_AMBUSH]={base=1, every=6, max=6},
		[Talents.T_SHADOW_COMBAT]={base=1, every=6, max=6},
		[Talents.T_SHADOW_VEIL]={last=20, base=0, every=6, max=6},
		[Talents.T_INVISIBILITY]={last=30, base=0, every=6, max=6},
	},
	max_life = resolvers.rngavg(120,140),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
	power_source = {technique=true, arcane=true},
}

-- bonus shalore
newEntity{
	define_as = "BASE_NPC_ELVEN_HERO",
	type = "humanoid", subtype = "shalore",
	display = "p", color=colors.UMBER,
	faction = "allied-kingdoms",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=3, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=0, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {technique=true},
}

newEntity{ base = "BASE_NPC_ELVEN_HERO",
	name = "scarred elven warrior", color=colors.UMBER,
	desc = _t[[A elven refugee from Elvala, taking any opportunity to fight back against the demon hordes.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	combat_armor = 20, combat_def = 26,
	resolvers.talents{
		[Talents.T_SHIELD_PUMMEL]={base=2, every=10, max=7},
		[Talents.T_ASSAULT]={base=3, every=7, max=7},
		[Talents.T_BLEEDING_EDGE]={base=3, every=7, max=7},
	},
	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(2, {"heroism infusion", "biting gale rune"}),
}

-- bonus thalore
newEntity{
	define_as = "BASE_NPC_THALORE_HERO",
	type = "humanoid", subtype = "thalore",
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
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	resolvers.drops{chance=85, nb=1, {}}
}

newEntity{ base = "BASE_NPC_THALORE_HERO",
	name = "thalore hunter", color=colors.LIGHT_UMBER,
	desc = _t[[An elven refugee from Shatur, taking any opportunity to fight back againt the demon hordes.]],
	level_range = {15, nil}, exp_worth = 0,
	rarity = 5,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_MASTER_MARKSMAN]={base=1, every=10, max=5},
		[Talents.T_FLARE]={base=1, every=10, max=5},
		[Talents.T_STEADY_SHOT]={base=1, every=10, max=5},
		[Talents.T_PIN_DOWN]={base=1, every=10, max=5},
		[Talents.T_HEADSHOT]={base=1, every=10, max=5},
		[Talents.T_SHOOT]=1,
	},
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longbow", not_properties={"unique"}, autoreq=true},
		{type="ammo", subtype="arrow", not_properties={"unique"}, autoreq=true},
	},
	resolvers.racial(),

	make_escort = {
		{name="thalore hunter", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_THALORE_HERO",
	name = "thalore wilder", color=colors.GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_thalore_thalore_wilder.png", display_h=2, display_y=-1}}},
	desc = _t[[An elven refugee from Shatur, taking any opportunity to fight to save Eyal.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	autolevel = "wildcaster",
	resolvers.talents{
		[Talents.T_RIMEBARK]={base=1, every=5, max=10},
		[Talents.T_WAR_HOUND]={base=1, every=5, max=10},
	},
	resolvers.inscriptions(3, "infusion"),
	resolvers.racial(),
	make_escort = {
		{name="thalore hunter", number=1, no_subescort=true},
		{name="treant", number=2, no_subescort=true},
	},
}

-- civilians
newEntity{ base = "BASE_NPC_LAST_HOPE",
	name = "human citizen", color=colors.WHITE,
	desc = _t[[A clean-looking Human resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = false,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 0,
}

newEntity{ base = "BASE_NPC_LAST_HOPE",
	name = "halfling citizen", color=colors.WHITE,
	subtype = "halfling",
	desc = _t[[A clean-looking Halfling resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = false,
	max_life = resolvers.rngavg(30,40),
}

newEntity{
	define_as = "TOLAK",
	type = "humanoid", subtype = "human",
	name = "King Tolak the Fair",
	display = "@", color=colors.BROWN,
	faction = "allied-kingdoms",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_tolak.png", display_h=2, display_y=-1}}},

	desc = _t[[This Higher man is the ruler of the Allied Kingdoms and a symbol of unity to the people of Maj'Eyal.  Though he ruled in a time of relative peace, he has decades of experience and the best equipment dwarves could forge.]],
	level_range = {75, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 42, fixed_rating = true,
	max_stamina = 1000,
	stamina_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=60, dex=45, con=50, cun=30, mag=30, wil=40 },

	see_invisible = 100,
	instakill_immune = 1,
	
	confusion_immune = 0.5,
	blind_immune = 1,

	combat_def = 20,

	no_auto_resists = true,
	resists = { all = 45, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, HEAD=1, HANDS=1 },
	resolvers.auto_equip_filters("Bulwark"),
	resolvers.auto_equip_filters{
		BODY = {type="armor", special=function(e) return e.subtype=="massive" end},
	},
	resolvers.equip{
		{type="weapon", subtype="longsword", force_drop=true,  forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="weapon", subtype="shield", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="feet", name="pair of voratun boots", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", defined="CROWN_TOLAK", autoreq=true},
		{type="armor", subtype="hands", name="voratun gauntlets", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	--resolvers.drops{chance=100, nb=1, {defined="PEARL_LIFE_DEATH"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_HIGHER_HEAL]=5,
		[Talents.T_OVERSEER_OF_NATIONS]=5,
		[Talents.T_BORN_INTO_MAGIC]=5,
		[Talents.T_HIGHBORN_S_BLOOM]=5,
		[Talents.T_HALFLING_LUCK]=5,
		[Talents.T_DUCK_AND_DODGE]=5,
		[Talents.T_MILITANT_MIND]=5,
		[Talents.T_INDOMITABLE]=5,
		
		[Talents.T_WEAPON_COMBAT]={base=5, every=10},
		[Talents.T_ARMOUR_TRAINING]={base=5, every=6},
		[Talents.T_WEAPONS_MASTERY]={base=5, every=10},
		
		[Talents.T_RUSH]={base=5, every=6},

		[Talents.T_SHIELD_PUMMEL]={base=4, every=6, max=6},
		[Talents.T_SHIELD_SLAM]={base=4, every=6, max=6},
		[Talents.T_RIPOSTE]={base=4, every=6, max=6},
		[Talents.T_ASSAULT]={base=3, every=6, max=6},
		[Talents.T_SHIELD_WALL]={base=5, every=6},
		[Talents.T_SHIELD_EXPERTISE]={base=5, every=6},
		[Talents.T_OVERPOWER]={base=5, every=6},
		
		[Talents.T_BATTLE_CALL]={base=5, every=6},
		[Talents.T_SHATTERING_SHOUT]={base=5, every=6},
		[Talents.T_BATTLE_CRY]={base=5, every=6},
		[Talents.T_SHATTERING_IMPACT]={base=5, every=6},
		[Talents.T_JUGGERNAUT]={base=5, every=6},
		
		[Talents.T_UNSTOPPABLE]={base=5, every=6},
		[Talents.T_MORTAL_TERROR]={base=3, every=6, max=6},
		[Talents.T_BLOODBATH]={base=5, every=6},
		
		[Talents.T_ETERNAL_GUARD]=1,
		[Talents.T_UNBREAKABLE_WILL]=1,
		[Talents.T_GIANT_LEAP]=1,
	},
	resolvers.sustains_at_birth(),

	talent_cd_reduction = {
		[Talents.T_JUGGERNAUT]=20,
		[Talents.T_UNBREAKABLE_WILL]=2,
	},

	resolvers.auto_equip_filters("Bulwark"),
	auto_classes={
		{class="Bulwark", start_level=77, level_rate=100},
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", sense_radius=25, ai_target="target_simple_or_player_radius" },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(5, {"healing infusion", "stormshield rune", "heroism infusion", "movement infusion", "wild infusion"}),

	on_die = function(self, who)
		if not game.player:resolveSource():hasQuest("campaign-hammer+demon-main") then
			game.player:resolveSource():grantQuest("campaign-hammer+demon-main")
		end
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "last-hope")
		game.level.data.no_worldport = nil
		game.player:hasQuest("campaign-hammer+demon-main"):win("tolak")
	end,
}

newEntity{
	define_as = "MERENAS", type = "humanoid", subtype =	"human",
	name = "Herald Meranas", display = "p", color=colors.RED,
	faction = "angolwen", resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_meranas__herald_of_angolwen.png"}}},
	desc = _t[[The herald of Angolwen, a mage sent here to aid the Kingdom in its fight for survival.]],
	level_range = {75, nil}, exp_worth = 15,
	max_life = 500, life_rating = 31, fixed_rating = true,
	max_mana = 1500,
	mana_regen = 10,
	rank = 4,
	size_category = 3,
	stats = { str=40, dex=30, con=30, cun=30, mag=60, wil=40 },

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 0.5,
	confusion_immune = 0.5,
	blind_immune = 1,

	combat_def = 20,

	no_auto_resists = true,
	resists = { all = 40, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1 },
	resolvers.auto_equip_filters("Archmage", true),
	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="feet", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=5, every=8},
		[Talents.T_ARMOUR_TRAINING]=1,
		[Talents.T_STONE_SKIN]={base=7, every=6},
		[Talents.T_SPELLCRAFT]={base=7, every=6},
		[Talents.T_ARCANE_POWER]={base=7, every=6},
		[Talents.T_ESSENCE_OF_SPEED]={base=7, every=6},

		[Talents.T_FLAME]={base=7, every=6},
		[Talents.T_FREEZE]={base=5, every=6},
		[Talents.T_LIGHTNING]={base=7, every=6},
		[Talents.T_MANATHRUST]={base=7, every=6},
		[Talents.T_FLAMESHOCK]={base=7, every=6},
		[Talents.T_STRIKE]={base=7, every=6},
		[Talents.T_HEAL]={base=7, every=6},
		[Talents.T_REGENERATION]={base=7, every=6},
		[Talents.T_ILLUMINATE]={base=7, every=6},
		[Talents.T_METAFLOW]={base=7, every=6},
		[Talents.T_PHASE_DOOR]={base=7, every=6},

		[Talents.T_CAUSTIC_MIRE]={base=7, every=6},
		[Talents.T_FIRE_STORM]={base=7, every=6},
		[Talents.T_FLASH_FREEZE]={base=7, every=6},
	},
	resolvers.sustains_at_birth(),

	auto_classes={
		{class="Archmage", start_level=77, level_rate=100,
			max_talent_types = 1,  -- Don't waste points on extra elemental trees or learn 20000 sustains
			banned_talents = {
				T_INVISIBILITY=true,
				T_PROBABILITY_TRAVEL=true,
				T_DISRUPTION_SHIELD=true,
			},
		},
	},
	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", sense_radius=25, ai_target="target_simple_or_player_radius" },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(4, {"regeneration infusion", "shielding rune", "stormshield rune", "wild infusion"}),

	on_die = function(self, who)
	end,
}

--final fight allies
newEntity{ base="BASE_NPC_MAJOR_DEMON", define_as = "KRYL_FEIJAN_REBORN",
	name = "Kryl-Feijan", color=colors.VIOLET, unique = "Kryl-Feijan Last Hope Help",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_kryl_feijan.png", display_h=2, display_y=-1}}},
	desc = _t[[A huge demon, he keeps himself shrouded in magical darkness, nothing visible but his massive claws.]],
	killer_message = _t"and devoured as a demonic breakfast",
	level_range = {56, nil}, exp_worth = 2,
	faction = "fearscape",
	rank = 5,
	size_category = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=42, mag=16, con=14 },
	move_others=true,
	vim_regen = 20,

	stun_immune = 0.5,
	never_anger = true,
	instakill_immune = 1,
	poison_immune = 1,
	blind_immune = 1,
	combat_armor = 0, combat_def = 15,

	open_door = true,
	
	no_auto_resists = true,
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		--[Talents.T_DARKFIRE]={base=4, every=5, max=7},
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_SOUL_ROT]={base=5, every=5, max=8},
		[Talents.T_BLOOD_BOIL]={base=5, every=5, max=8},
		[Talents.T_FLAME]={base=5, every=5, max=8},
		--[Talents.T_BURNING_WAKE]={base=5, every=5, max=8},
		[Talents.T_WILDFIRE]={base=5, every=5, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max=8},
		--[Talents.T_DARKNESS]={base=3, every=5, max=6},
		[Talents.T_EVASION]={base=5, every=5, max=8},
		[Talents.T_VIRULENT_DISEASE]={base=3, every=5, max=6},
		[Talents.T_DRAIN]={base=3, every=5, max=6},
		[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
		[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
		[Talents.T_BONE_SHIELD]=5,
		[Talents.T_THICK_SKIN]=5,
		--don't give him bloodspring
	},
	auto_classes={
		{class="Corruptor", start_level=57, level_rate=50},
		{class="Archmage", start_level=57, level_rate=50},
	},
	resolvers.sustains_at_birth(),
}

newEntity{
	define_as = "DOOMBRINGER_MELINDA",
	name = _t"Melinda", color=colors.LIGHT_BLUE, unique = "Demonic Melinda Last Hope Help",
	type = "humanoid", subtype = "human", female=true,
	display = "@", image = "player/cornac_female_redhair.png",
	moddable_tile = "human_female",
	moddable_tile_base = "base_04.png",
	moddable_tile_hair = "hair_redhead_melinda",
	desc = _t[[You saved her from the depth of a cultists' lair and brought her back to the Fearscape for instruction.  Now she has been sent to use the powers of Kryl'Feijan against her former home.]],
	autolevel = "warriormage",
	ai = "tactical",
	stats = { str=8, dex=7, mag=18, con=12 },
	faction = "fearscape",
	never_anger = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="feet", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="head", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	lite = 10, infravision = 10,
	rank = 5,
	level_range = {56, nil}, exp_worth = 2,
	
	max_life = 220, life_rating = 20, fixed_rating = true,
	combat_armor = 3, combat_def = 3,

	max_life = 250, life_rating = 27, 

	move_others=true,
	vim_regen = 10,
	instakill_immune = 1,
	blind_immune = 1,
	open_door = true,
	no_auto_resists = true,
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(3, {}),

	combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=0.4} },

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_SOUL_ROT]={base=5, every=5, max=8},
		[Talents.T_BLOOD_BOIL]={base=5, every=5, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max=8},
		[Talents.T_VIRULENT_DISEASE]={base=3, every=5, max=6},
		[Talents.T_DRAIN]={base=3, every=5, max=6},
		[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
		[Talents.T_BONE_SHIELD]=5,
		[Talents.T_THICK_SKIN]=5,
		[Talents.T_CURSE_OF_DEFENSELESSNESS]=5,
		[Talents.T_CURSE_OF_VULNERABILITY]=5,
		[Talents.T_CURSE_OF_DEATH]=5,

	},
	auto_classes={
		{class="Corruptor", start_level=57, level_rate=50},
		{class="Archmage", start_level=57, level_rate=50},
	},
	resolvers.sustains_at_birth(),
}
