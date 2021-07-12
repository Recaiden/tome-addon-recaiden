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
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", not_properties={"unique"}, autoreq=true},
		{type="armor", subtype="shield", not_properties={"unique"}, autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
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
		{type="ammo", subtype="shot", not_properties={"unique"}, autoreq=true} },
	}

newEntity{ base = "BASE_NPC_LAST_HOPE",
	name = "human citizen", color=colors.WHITE,
	desc = _t[[A clean-looking Human resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 0,
}

newEntity{ base = "BASE_NPC_LAST_HOPE",
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
	stats = { str=60, dex=45, con=50, cun=30, mag=30, wil=40 },

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
	resolvers.inscriptions(5, {"regeneration infusion", "shielding rune", "stormshield rune", "blink rune", "wild infusion"}),

	on_die = function(self, who)
	end,
}
