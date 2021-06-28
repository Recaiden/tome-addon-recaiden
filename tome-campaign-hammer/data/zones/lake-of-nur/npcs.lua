load("/data/general/npcs/aquatic_critter.lua", function(e) if e.rarity then e.water_rarity, e.rarity = e.rarity, nil end end)
load("/data/general/npcs/aquatic_demon.lua", function(e) if e.rarity then e.water_rarity, e.rarity = e.rarity, nil end end)
load("/data/general/npcs/horror_aquatic.lua", function(e) if e.rarity then e.horror_water_rarity, e.rarity = e.rarity, nil end end)
load("/data/general/npcs/horror.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/plant.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	base = "BASE_NPC_HORROR_AQUATIC", define_as = "SWARMING_ABYSSAL_HORROR",
	name = "Swarming Abyss", color=colors.BLACK,
	desc = "This pitch black form is shrouded in darkness and swarming with tiny horrors. All you can make out are a pair of deep red eyes, hidden behind a mass of tentacles.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_abyssal_horror.png"}}},
	level_range = {10, nil}, exp_worth = 2,
	instakill_immune = 1,
	rank = 4,
	size_category = 4,
	autolevel = "wildcaster",
	max_life = 80, life_rating = 10, fixed_rating = true,
	hate_regen=4,
	combat_armor = 0, combat_def = 16,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BELT=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="mindstar", autoreq=true, force_drop=true},
		{type="weapon", subtype="mindstar", autoreq=true, force_drop=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	combat = {
		dam=15,
		atk=12, apr=4,
		dammod={mag=0.8, wil=0.2}, physcrit = 6,
		damtype=engine.DamageType.DARKNESS,
	},
	
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=4, ally_compassion=0 },
	
	resists = {[DamageType.DARKNESS] = 25, [DamageType.LIGHT] = -25},
	resolvers.auto_equip_filters("Oozemancer"),
	auto_classes={{class="Oozemancer", start_level=20, level_rate=35}},
	summon = {{type="horror", subtype="aquatic", name="swarming horror", number=2, special_rarity="horror_water_rarity", hasxp=false}, },
	-- Override the recalculated AI tactics to avoid problematic kiting
	low_level_tactics_override = {escape=0},
	
	on_die = function(self, who)
		who:grantQuest("campaign-hammer+demon-caravan")
		local Chat = require "engine.Chat"
		local chat = Chat.new("campaign-hammer+memory-crystals-tactics", {name=_t"Memory Crystals"}, game.player)
		chat:invoke()
	end,
	resolvers.talents{
		[Talents.T_CREEPING_DARKNESS]=3,
		[Talents.T_DARK_VISION]=5,
		[Talents.T_SUMMON]=1,
		
		[Talents.T_ABYSSAL_SHROUD]=1,
		
		[Talents.T_TENTACLE_GRAB]=3,
	},
	resolvers.sustains_at_birth(),
}
