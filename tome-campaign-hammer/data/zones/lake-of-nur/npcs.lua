local Talents = require("engine.interface.ActorTalents")

rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/aquatic_critter.lua", function(e)
			 e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
			 e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
			 if e.rarity then e.water_rarity, e.rarity = e.rarity, nil end
end)
load(
	"/data/general/npcs/aquatic_demon.lua",
	function(e)
		if e.rarity then e.water_rarity, e.rarity = e.rarity, nil end
		if e.name == "water imp" then
			e.name = "devolved water imp"
			e.corrupt_talents = resolvers.talents{ [Talents.T_TENTACLE_GRAB]=3 }
			e.desc = e.desc.._t" You're fairly sure it's not supposed to look like that."
		end
	end
)
load("/data/general/npcs/horror_aquatic.lua", function(e)
			 			 e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
						 e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
						 if e.rarity then e.horror_water_rarity, e.rarity = e.rarity, nil end
end)
load("/data/general/npcs/horror.lua", rarityWithLoot(0))
load("/data/general/npcs/snake.lua", rarityWithLoot(3))
load("/data/general/npcs/plant.lua", rarityWithLoot(3))

newEntity{
	base = "BASE_NPC_HORROR_AQUATIC", define_as = "SWARMING_ABYSSAL_HORROR",
	name = "Swarming Abyss", color=colors.BLACK,
	desc = "This pitch black form is shrouded in darkness and swarming with tiny horrors. All you can make out are a pair of deep red eyes, hidden behind a mass of tentacles.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_abyssal_horror.png"}}},
	level_range = {10, nil}, exp_worth = 2,
	instakill_immune = 1,
	rank = 4,
	size_category = 5,
	autolevel = "wildcaster",
	max_life = 80, life_rating = 10, fixed_rating = true,
	hate_regen=4,
	combat_armor = 0, combat_def = 16,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BELT=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="mindstar", autoreq=true, force_drop=true},
		{type="weapon", subtype="mindstar", autoreq=true, force_drop=true},
	},
	resolvers.drops{chance=100, nb=2, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },
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
	-- Don't run away
	low_level_tactics_override = {escape=0},
	
	on_die = function(self, who)
		local p = game.player
		if p and p.hasEffect and p:hasEffect(p.EFF_HAMMER_DEMONIC_WATERBREATHING) then
			world:gainAchievement("HAMMER_AIR_YES", p)
		elseif p and p.air < p.max_air then
			world:gainAchievement("HAMMER_AIR_NO", p)
		end
		
		if not game.player:resolveSource():hasQuest("campaign-hammer+demon-caravan") then
			game.player:resolveSource():grantQuest("campaign-hammer+demon-caravan")
		end
		game.player:resolveSource():grantQuest("campaign-hammer+demon-allies")
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-main", engine.Quest.COMPLETED, "waterimp")
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
