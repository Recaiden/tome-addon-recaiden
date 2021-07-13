rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=85, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=2, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/rodent.lua", rarityWithLoot(5))
load("/data/general/npcs/vermin.lua", rarityWithLoot(2))
load("/data/general/npcs/canine.lua", rarityWithLoot(0))
load("/data/general/npcs/troll.lua", rarityWithLoot(1))
load("/data/general/npcs/thieve.lua", rarityWithLoot(1))
load("/data/general/npcs/snake.lua", rarityWithLoot(3))
load("/data/general/npcs/plant.lua", rarityWithLoot(0))
load("/data/general/npcs/swarm.lua", rarityWithLoot(3))
load("/data/general/npcs/bear.lua", rarityWithLoot(1))

load("/data/general/npcs/all.lua", rarityWithLoot(4, 35))


local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_BEAR", define_as = "MAGRIN",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Magrin, the Guardian",
	display = "q", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_bear_norgos_the_guardian.png", display_h=2, display_y=-1}}},
	desc = _t[[In the wake of Norgos's madness, a new guardian beast has emerged to protect the western woods.]],
	killer_message = _t"and was feasted upon by wolves",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=15, cun=8, mag=10, wil=20, con=20 },
	tier1 = true,
	rank = 4,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={str=1.2} },

	resists = { [DamageType.COLD] = 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=2, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STUN]={base=1, every=6, max=6},
		[Talents.T_RUSH]={base=5, every=6, max=10},
		[Talents.T_DOUBLE_STRIKE]={base=1, every=6, max=4},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	resolvers.auto_equip_filters("Brawler"),
	auto_classes={{class="Brawler", start_level=18, level_rate=50}},

	-- Override the recalculated AI tactics to avoid problematic kiting in the early game
	low_level_tactics_override = {escape=0},

	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-landing", engine.Quest.COMPLETED, "landing")
		local Chat = require "engine.Chat"
		local chat = Chat.new("campaign-hammer+escort-category", {name=_t"Memory Crystals"}, game.player)
		chat:invoke()
	end,
}
