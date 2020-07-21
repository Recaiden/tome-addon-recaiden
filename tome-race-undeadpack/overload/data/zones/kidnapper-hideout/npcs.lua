local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/thieve.lua")
load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/vermin.lua")

newEntity{ define_as = "REK_BANSHEE_RINGLEADER",
	   type = "humanoid", subtype = "human",
	   unique = true,
	   name = "Bandit Ringleader",
	   display = "p", color=colors.VIOLET,
	   resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_assassin.png", display_h=1, display_y=0}}},
	   desc = [[The leader of the gang that killed you.]],
	   level_range = {1, 3}, exp_worth = 2,
	   max_life = 80, life_rating = 10, fixed_rating = true,
	   stats = { str=20, dex=15, cun=15, mag=10, wil=10, con=15 },
	   tier1 = true,
	   rank = 4,
	   size_category = 2,
	   infravision = 10,
	   instakill_immune = 1,
	   move_others=true,
	   
	   combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={str=1.2} },
	   	   
	   body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	   resolvers.equip{
	      {type="weapon", subtype="dagger", autoreq=true, force_drop=true, tome_drops="boss"},
	      {type="weapon", subtype="dagger", autoreq=true, force_drop=true, tome_drops="boss"},
	      {type="armor", subtype="light", autoreq=true, force_drop=true, tome_drops="boss"}
	   },
	   resolvers.drops{chance=100, nb=1, {defined="CLOAK_DECEPTION"} },
	   
	   resolvers.talents{
	      [Talents.T_WEAPON_COMBAT] = {base=1, every=8, max=5},
	      [Talents.T_KNIFE_MASTERY] = {base=1, every=8, max=5},
	      [engine.interface.ActorTalents.T_LETHALITY]={base=1, every=8, max=10},
	      [engine.interface.ActorTalents.T_SKULLCRACKER]={base=1, every=8, max=10},
	   },

	   inc_damage = {all=-40},
	   
	   autolevel = "warrior",
	   ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	   ai_tactic = resolvers.tactic"melee",
	   
	   on_die = function(self, who)
	      game.player:resolveSource():setQuestStatus("start-banshee", engine.Quest.COMPLETED)
	   end,
}
