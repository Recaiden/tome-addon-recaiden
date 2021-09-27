rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/canine.lua", rarityWithLoot(2))
load("/data/general/npcs/troll.lua", rarityWithLoot(3))
load("/data/general/npcs/bear.lua", rarityWithLoot(3))
load("/data/general/npcs/plant.lua", rarityWithLoot(4 ))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_CARAVANEER",
	type = "humanoid", subtype = "human", image="npc/humanoid_human_spectator02.png",
	display = "p", color=colors.DARK_KHAKI,
	faction = "allied-kingdoms",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=2, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	resolvers.drops{chance=25, nb=2, {}},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	
	emote_random = {chance=5, _t"To arms!", _t"Demon!", _t"Die!", _t"Monster!", _t"Protect the caravan!"},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_MERCHANT",
	name = "caravan merchant", color=colors.KHAKI, image="npc/humanoid_human_spectator02.png",
	subtype = "human",
	desc = _t[[A caravan merchant.]],
	level_range = {1, 30}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,50), life_rating = 7,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
	},
	make_escort = {
		{name="caravan guard", number=2},
		{name="caravan porter", number=4},
	},
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "CARAVAN_WAR_DOG",
	name = "guard dog", color=colors.KHAKI, image="npc/canine_dw.png",
	desc = _t[[This is a large dog, bred and trained for fighting.]],
	level_range = {5, 30}, exp_worth = 1,
	rarity = 12,
	faction = "allied-kingdoms",
	max_life = resolvers.rngavg(60,100), life_rating = 10,
	combat_armor = 4, combat_def = 7,
	combat = { dam=resolvers.levelup(30, 1, 1), atk=resolvers.levelup(25, 1, 1), apr=15 },
	resolvers.talents{
		[Talents.T_RUSH]=2,
		[Talents.T_GRAPPLING_STANCE]=2,
		[Talents.T_CLINCH]=2,
	},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_GUARD",
	name = "caravan guard", color=colors.KHAKI, image="npc/humanoid_human_spectator.png",
	subtype = "human",
	desc = _t[[A caravan guard.]],
	rarity = 1,
	level_range = {5, 30}, exp_worth = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=1, every=5, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=2, every=7, max=6},
		[Talents.T_RUSH]={base=1, every=10, max=4},
	},
	make_escort = {
		{name="guard dog", number=2},
		{name="caravan guard", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_PORTER",
	name = "caravan porter", color=colors.KHAKI, image="npc/humanoid_human_spectator03.png",
	subtype = "human",
	desc = _t[[A caravan porter.]],
	level_range = {1, 30}, exp_worth = 1,
	max_life = resolvers.rngavg(60,70), life_rating = 8,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="sling", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SHOOT]=1,
		[Talents.T_DISENGAGE]=2,
		[Talents.T_SLING_MASTERY]=1,
	},
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "CORRUPTED_CARAVAN_WAR_DOG",
	name = "corrupted guard dog", color=colors.BLACK, image="npc/canine_dw.png",
	desc = _t[[This is a large dog, bred and trained for fighting. Something about the way it moves doesn't look normal.]],
	level_range = {15, 30}, exp_worth = 1,
	rarity = 8,
	faction = "allied-kingdoms",
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=resolvers.levelup(30, 1, 1), atk=resolvers.levelup(25, 1, 1), apr=15 },
	resolvers.talents{ [Talents.T_RUSH]=2, [Talents.T_GRAPPLING_STANCE]=2, [Talents.T_CLINCH]=2, [Talents.T_GLOOM] = 2,},

	make_escort = {
		{name="guard dog", number=4, no_subescort=true},
	},
}

newEntity{ define_as = "CARAVAN_MASTER",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	faction = "allied-kingdoms",
	name = "Caravan Guard Captain",
	display = "h", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_golbug_the_destroyer.png", display_h=2, display_y=-1}}},
	desc = _t[[This was supposed to be an easy job.  Scare off the bears, fight a couple trolls,  make sure nothing funny went on.
He never signed up to fight off a demon invasion.
But that doesn't mean he's giving up!]],
	level_range = {18, nil}, exp_worth = 2,
	max_life = 180, life_rating = 16, fixed_rating = true,
	max_stamina = 145,
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	stats = { str=22, dex=19, cun=34, mag=10, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	resolvers.auto_equip_filters("Bulwark"),
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=12, {tome_drops="boss"} },
	stun_immune = 0.25,
	see_invisible = 5,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=3, every=6, max=8},
		[Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=5, max=6},
		[Talents.T_RUSH]={base=1, every=5, max=6},
		[Talents.T_RIPOSTE]={base=4, every=5, max=6},
		[Talents.T_BLINDING_SPEED]={base=1, every=5, max=6},
		[Talents.T_OVERPOWER]={base=1, every=5, max=5},
		[Talents.T_ASSAULT]={base=1, every=5, max=5},
		[Talents.T_SHIELD_WALL]={base=3, every=5, max=5},
		[Talents.T_SHIELD_EXPERTISE]={base=2, every=5, max=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warrior",
	auto_classes={
		{class="Bulwark", start_level=28, level_rate=50},
	},
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, "infusion"),

	make_escort = {
		{name="caravan merchant", number=2},
	},

	on_die = function(self, who)
		if not game.player:resolveSource():hasQuest("campaign-hammer+demon-caravan") then
			game.player:resolveSource():grantQuest("campaign-hammer+demon-caravan")
		end
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-caravan", engine.Quest.COMPLETED)

		local Chat = require "engine.Chat"
		local chat = Chat.new("campaign-hammer+caravan-power", {name=_t"Memory Crystals"}, game.player)
		chat:invoke()
	end,
}
