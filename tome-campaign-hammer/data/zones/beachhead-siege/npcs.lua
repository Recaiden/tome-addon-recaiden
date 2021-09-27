rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/plant.lua", rarityWithLoot(0))
load("/data/general/npcs/canine.lua", rarityWithLoot(3))
load("/data/general/npcs/bear.lua", rarityWithLoot(3))
load("/data/general/npcs/demon-major.lua", switchRarity("demons"))
load("/data/general/npcs/demon-minor.lua", switchRarity("demons"))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_THALORE_SOLDIER",
	type = "humanoid", subtype = "thalore",
	display = "p", color=colors.WHITE,
	faction = "thalore",
	anger_emote = _t"Catch @himher@!",
	exp_worth = 0,
	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	--resolvers.racial(),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	resolvers.drops{chance=45, nb=1, {}}
}

newEntity{ base = "BASE_NPC_THALORE_SOLDIER",
	name = "thalore hunter", color=colors.LIGHT_UMBER,
	desc = _t[[A stern-looking elven soldier, he will not let you survive.]],
	level_range = {1, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_BOW_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SHOOT]=1,
	},
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longbow", not_properties={"unique"}, autoreq=true},
		{type="ammo", subtype="arrow", not_properties={"unique"}, autoreq=true},
	},
	--resolvers.racial(),

	make_escort = {
		{name="thalore hunter", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_THALORE_SOLDIER",
	name = "thalore wilder", color=colors.GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_thalore_thalore_wilder.png", display_h=2, display_y=-1}}},
	desc = _t[[A tall elf, skin covered in green moss.]],
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
	--resolvers.racial(),
	make_escort = {
		{name="thalore hunter", number=1, no_subescort=true},
		{name="treant", number=2, no_subescort=true},
	},
}

newEntity{
	base="BASE_NPC_THALORE_SOLDIER", define_as = "THALORE_LEADER",
	unique = true,
	name = "Nessilla Tantaelen", female = true,
	color=colors.GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_thalore_ziguranth_summoner.png"}}},
	desc = _t[[The ancient leader of the Thaloren, said to be the wisest of elves.]],
	killer_message = _t" and made into compost",
	level_range = {30, nil}, exp_worth = 2,
	max_life = 220, life_rating = 11, fixed_rating = true,
	equilibrium_regen = -3,
	stats = { str=10, dex=10, cun=20, wil=20, mag=10, con=10 },
	rank = 5,
	size_category = 3,
	instakill_immune = 1,

	resolvers.equip{
		{type="weapon", subtype="mindstar", force_drop=true, tome_drops="boss", autoreq=true},
		{type="weapon", subtype="mindstar", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="belt", defined="ROPE_BELT_OF_THE_THALOREN", random_art_replace={chance=50}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", autoreq=true},
		{type="charm", subtype="totem"}
	},
	resolvers.drops{chance=100, nb=7, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_NATURE_TOUCH]={base=5, every=6, max=7},

		[Talents.T_BELLOWING_ROAR]={base=7, every=6, max=10},
		
		[Talents.T_RITCH_FLAMESPITTER]={base=10, every=6, max=12},
		[Talents.T_WAR_HOUND]={base=10, every=6, max=12},
		[Talents.T_MINOTAUR]={base=10, every=6, max=12},		
		[Talents.T_RAGE]={base=5, every=6, max=7},
		[Talents.T_RESILIENCE]={base=5, every=6, max=7},
		[Talents.T_MASTER_SUMMONER]={base=1, every=6, max=7},
		[Talents.T_WILD_SUMMON]={base=5, every=6, max=7},
		[Talents.T_GRAND_ARRIVAL]={base=2, every=18, max=4},

		[Talents.T_WEAPON_COMBAT]={base=3, every=8, max=5},
		[Talents.T_PSIBLADES]={base=3, every=8, max=5},
		[Talents.T_THORN_GRAB]={base=3, every=8, max=5},
		[Talents.T_LEAVES_TIDE]={base=3, every=8, max=5},

		-- [Talents.T_STONE_VINES]={base=3, every=8, max=5},
		-- [Talents.T_ELDRITCH_VINES]={base=3, every=8, max=5},
		-- [Talents.T_ROCKWALK]={base=3, every=8, max=5},
		-- [Talents.T_ROCKSWALLOW]={base=3, every=8, max=5},

		-- [Talents.T_HEALING_NEXUS]={base=3, every=8, max=5},

		[Talents.T_ARMOUR_TRAINING]=3,

		[Talents.T_DRACONIC_BODY]=1,
		-- [Talents.T_FUNGAL_BLOOD]=1,
	},
	resolvers.inscriptions(4, "infusion"),
	resolvers.sustains_at_birth(),
	resolvers.racial(),

	auto_classes={
		{class="Oozemancer", start_level=40, level_rate=50},
		{class="Summoner", start_level=40, level_rate=50},
	},

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	make_escort = {
		{name="thalore hunter", number=2, no_subescort=true},
		{name="thalore wilder", number=1, no_subescort=true},
		{name="treant", number=5, no_subescort=true},
	},

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "thalore")
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-siege", engine.Quest.COMPLETED, "victory")
	end,
}
