rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

alter = function(add, mult)
	add = add or 0
	mult = mult or 1
	return function(e)
		if e.rarity then
			e.rarity = math.ceil(e.rarity * mult + add)
			if e.faction ~= "fearscape" then
				e.desc = (e.desc or "").._t[[ This creature is completely in thrall to the demonic invaders.]]
				e.faction = "fearscape"
			end
		end
		e.bonus_loot = resolvers.drops{chance=85, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=2, nb=1, {tome_drops="boss"}}
	end
end

load("/data/general/npcs/major-demon.lua", rarity(1))
load("/data/general/npcs/minor-demon.lua", rarity(0))
load("/data/general/npcs/all.lua", alter(20, 50))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "KHULMANAR_HAMMER",
	type = "demon", subtype = "major",
	name = "General Khulmanar",
	display = "D",
	color=colors.DARK_RED, unique=true,
	faction = "fearscape",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_general_of_urh_rok.png", display_h=2, display_y=-1}}},

	desc = _t[[A towering demonic war-mech, custom made for the greatest tactical mind of the age.  The general stands tall above a legion of lesser demons, holding his signature blackened flaming battleaxe.  He does not appear to be in a mood for calm discussion.]],
	level_range = {75, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 42, fixed_rating = true,
	max_stamina = 1000,
	stamina_regen = 50,
	vim_regen = 50,
	mana_regen = 50,
	rank = 5,
	size_category = 5,
	stats = { str=80, dex=45, con=50, cun=60, mag=50, wil=40 },

	combat_armor = 50, combat_def = 40, combat_atk=50,

	see_invisible = 100,
	instakill_immune = 1,
	
	confusion_immune = 0.5,
	blind_immune = 1,
	knockback_immune = 1,

	combat_def = 20,

	no_auto_resists = true,
	resists = { all = 45, [DamageType.FIRE] = 70},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, HEAD=1, HANDS=1 },
	resolvers.auto_equip_filters{MAINHAND = {properties = {"twohanded"}}, },
	resolvers.equip{ {type="weapon", subtype="battleaxe", defined="KHULMANAR_WRATH", random_art_replace={chance=30}, autoreq=true, force_drop=true}, },

	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(25, 25)},
	melee_project = {[DamageType.FIRE]=resolvers.mbonus(50, 35)},
	
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	summon = {
		{type="demon", number=5, hasxp=false},
	},
	make_escort = {
		{type="demon", no_subescort=true, number=resolvers.mbonus(4, 4)},
	},

	--todo resolver.racial for onyx
	resolvers.talents{
		[Talents.T_SUMMON]=1,
		
		[Talents.T_WEAPON_COMBAT]={base=8, every=5, max=12},
		[Talents.T_WEAPONS_MASTERY]={base=8, every=8, max=12},
		[Talents.T_RUSH]={base=5, every=7, max=8},
		[Talents.T_BATTLE_CRY]={base=4, every=5, max=9},
		[Talents.T_BATTLE_CALL]={base=2, every=3, max=8},
		[Talents.T_STUNNING_BLOW]={base=5, every=8, max=7},
		[Talents.T_KNOCKBACK]={base=4, every=4, max=8},
		
		[Talents.T_FIRE_STORM]={base=4, every=6, max=8},
		[Talents.T_WILDFIRE]={base=3, every=8, max=6},
		[Talents.T_FLAME]={base=5, every=8, max=10},
		
		[Talents.T_INFERNAL_BREATH]={base=3, every=5, max=7},

		[Talents.T_ELEMENTAL_SURGE]=1,
		[Talents.T_SPELL_FEEDBACK]=1,
		
		[Talents.T_WEAPON_COMBAT]={base=5, every=10},
		[Talents.T_ARMOUR_TRAINING]={base=5, every=5},
		[Talents.T_WEAPONS_MASTERY]={base=5, every=5},
		
		[Talents.T_RUSH]={base=5, every=6},

		[Talents.T_DEMON_BLADE]={base=5, every=6},
		
		[Talents.T_UNBREAKABLE_WILL]=1,
		[Talents.T_GIANT_LEAP]=1,
	},
	resolvers.sustains_at_birth(),

	talent_cd_reduction = {
		[Talents.T_DEMON_BLADE]=5,
		[Talents.T_UNBREAKABLE_WILL]=2,
	},

	auto_classes={
		{class="Doombringer", start_level=77, level_rate=100},
	},

	inc_damage = {all=50},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", sense_radius=25, ai_target="target_simple_or_player_radius" },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(5, {"healing infusion", "stormshield rune", "acid wave rune", "movement infusion", "shatter afflictions rune"}),

	on_die = function(self, who)
		if not game.player:resolveSource():hasQuest("campaign-hammer+hero-main") then
			game.player:resolveSource():grantQuest("campaign-hammer+hero-main")
		end
		game.player:resolveSource():setQuestStatus("campaign-hammer+hero-main", engine.Quest.COMPLETED, "khulmanar-dead")
		game.level.data.no_worldport = nil
		game.player:hasQuest("campaign-hammer+hero-main"):win("khulmanar")
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
