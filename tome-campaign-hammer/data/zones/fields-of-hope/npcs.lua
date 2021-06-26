load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(5))
load("/data/general/npcs/faeros.lua", rarity(2))
load("/data/general/npcs/gwelgoroth.lua", rarity(2))
load("/data/general/npcs/elven-caster.lua", rarity(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_LAST_HOPE_TOWN",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "allied-kingdoms",
	anger_emote = _t"Catch @himher@!",
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
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "last hope guard", color=colors.LIGHT_UMBER,
	desc = _t[[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", not_properties={"unique"}, autoreq=true},
		{type="armor", subtype="shield", not_properties={"unique"}, autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
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
		{type="ammo", subtype="shot", not_properties={"unique"}, autoreq=true} },
	}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "human citizen", color=colors.WHITE,
	desc = _t[[A clean-looking Human resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 0,
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "halfling citizen", color=colors.WHITE,
	subtype = "halfling",
	desc = _t[[A clean-looking Halfling resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
}



newEntity{
	define_as = "TOLAK",
	type = "humanoid", subtype = "human",
	name = "King Tolak the Fair",
	display = "@", color=colors.BROWN,
	faction = "allied-kingdoms",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_argoniel.png", display_h=2, display_y=-1}}},

	desc = _t[[This Higher man is the ruler of the Allied Kingdoms and a symbol of unity to the people of Maj'Eyal.  Though he ruled in a time of relative peace, he has decades of experience and the best equipment dwarves could forge.]],
	level_range = {75, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 42, fixed_rating = true,
	max_stamina = 1000,
	stamina_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=60, con=50, cun=30, mag=30, wil=40 },

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 0.5,
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
		{type="armor", subtype="head", name="voratun helm", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="hands", name="voratun gauntlets", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="ARGONIEL_ATHAME"} },
	resolvers.drops{chance=100, nb=1, {defined="PEARL_LIFE_DEATH"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_RUSH]=6,
		[Talents.T_BONE_GRAB]={base=7, every=6},
		[Talents.T_BONE_SHIELD]={base=7, every=6},
		[Talents.T_BURNING_HEX]={base=7, every=6},
		[Talents.T_EMPATHIC_HEX]={base=7, every=6},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=7, every=6},
		[Talents.T_CURSE_OF_DEATH]={base=7, every=6},
		[Talents.T_VIRULENT_DISEASE]={base=7, every=6},
		[Talents.T_CYST_BURST]={base=7, every=6},
		[Talents.T_CATALEPSY]={base=7, every=6},
		[Talents.T_EPIDEMIC]={base=7, every=6},
		[Talents.T_REND]={base=7, every=6},
		[Talents.T_RUIN]={base=7, every=6},
		[Talents.T_DARK_SURPRISE]={base=7, every=6},
		[Talents.T_CORRUPTED_STRENGTH]={base=7, every=6},
		[Talents.T_BLOODLUST]={base=7, every=6},
		[Talents.T_ACID_BLOOD]={base=7, every=6},
		[Talents.T_SOUL_ROT]={base=7, every=6},
		[Talents.T_ACID_STRIKE]={base=7, every=6},
		[Talents.T_ELEMENTAL_DISCORD]={base=7, every=6},
		[Talents.T_BLOOD_SPLASH]={base=7, every=15},

		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]={base=4, every=10},
		[Talents.T_ARMOUR_TRAINING]={base=5, every=6},

		[Talents.T_ENDLESS_WOES]=1,
	},
	resolvers.sustains_at_birth(),

	resolvers.auto_equip_filters("Bulwark"),
	auto_classes={
		{class="Bulwark", start_level=77, level_rate=100},
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", sense_radius=25, ai_target="target_simple_or_player_radius" },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(5, {"regeneration infusion", "shielding rune", "heroism infusion", "movement infusion", "wild infusion"}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "last-hope")
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
		[Talents.T_HYMN_OF_SHADOWS]={base=7, every=6},

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

		[Talents.T_MOONLIGHT_RAY]={base=7, every=6},
		[Talents.T_STARFALL]={base=7, every=6},
		[Talents.T_TWILIGHT_SURGE]={base=7, every=6},
	},
	resolvers.sustains_at_birth(),

	-- L75ish Normal
	-- L97-99 Insane
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
	resolvers.inscriptions(5, {"regeneration infusion", "shielding rune", "invisibility rune", "movement infusion", "wild infusion"}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("high-peak", engine.Quest.COMPLETED, "elandar-dead")
	end,
}
