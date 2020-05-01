local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/ghoul.lua")
load("/data/general/npcs/wight.lua")

newEntity{
   define_as = "REK_WIGHT_GRAVEROBBER",
   type = "humanoid", subtype = "cornac",
   unique = true,
   name = "Graverobber",
   display = "p", color=colors.GOLD,
   desc = [[An unscrupulous Cornac adventurer who knows a bit of fighting and a bit of magic. His body shows multiple scars from battle.]],
   resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_high_gladiator.png", display_h=1, display_y=0}}},
   
   combat = { dam=resolvers.rngavg(6,12), atk=3, apr=6, physspeed=2 },
   body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
   resolvers.drops{chance=100, nb=1, {type="weapon", tome_drops="boss"}},
   resolvers.drops{chance=100, nb=2, {type="money"} },
   resolvers.inscriptions(1, "shielding rune"),
   stun_immune = 0.4,
   life_rating = 40,
   rank = 3,
   infravision = 10,
   lite = 2,
   open_door = true,
   autolevel = "warrior",
   ai = "tactical", ai_state = { ai_move = "move_complex", talent_in = 1 },
   
   stats = { str=20, dex=20, mag=8, con=16 },
   
   level_range = {6, 21}, exp_worth = 2,
   rarity = false,
   max_life = resolvers.rngavg(100,130),
   resolvers.equip{
      {type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true},
      {type="armor", subtype="heavy", forbid_power_source={antimagic=true}, autoreq=true},
      {type="armor", subtype="feet", forbid_power_source={antimagic=true}, autoreq=true},
                  },
   resolvers.talents{
      [Talents.T_ARCANE_COMBAT]=2,
      [Talents.T_ARCANE_FEED]=2,
      [Talents.T_FLAME]=1,
      [Talents.T_ARMOUR_TRAINING] = 1,
      [Talents.T_WEAPON_COMBAT] = 2,
},
   
   on_die = function(self, who)
      game.player:resolveSource():setQuestStatus("start-wight", engine.Quest.COMPLETED)
      if game.level.turn_counter ~= nil then
         game.level.turn_counter = nil
         local spot = game.level:pickSpot{type="pop", subtype="undead"}
         local g = game.zone:makeEntityByName(game.level, "terrain", "CAVE_LADDER_UP_WILDERNESS")
         game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
         
         require("engine.ui.Dialog"):simpleLongPopup("Onslaught", "The battle is over. You notice a way to climb up you had not seen before in a wall nearby.", 400)
      end
   end,
}
