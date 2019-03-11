local Particles = require "engine.Particles"
local ActorInventory = require "engine.interface.ActorInventory"

local wyrm = getBirthDescriptor("subclass", "Wyrmic")

wyrm.talents_types = {
   -- Wilder generics, sets them up to get free Harmony, Fungus is major defense
   ["wild-gift/call"]={true, 0.2},
   ["wild-gift/harmony"]={false, 0.1},
   ["wild-gift/fungus"]={true, 0.1},
   
   -- Warrior stuff, option of 2-hand/2-weapon/S&B, but low mastery
   ["technique/shield-offense"]={false, 0.1},
   ["technique/2hweapon-assault"]={false, 0.1},
   ["technique/dualweapon-attack"]={false, 0.1},
   
   ["technique/combat-techniques-active"]={true, 0},
   ["technique/combat-training"]={true, 0},

   ["cunning/survival"]={false, 0},
   
   --new locked abilities
   ["wild-gift/prismatic-dragon"]={false, 0.3},
   
   ["wild-gift/wyrm-fire"]={true, 0.3},
   ["wild-gift/wyrm-ice"]={true, 0.3},
   ["wild-gift/wyrm-storm"]={true, 0.3},
   ["wild-gift/wyrm-sand"]={true, 0.3},
   ["wild-gift/wyrm-acid"]={true, 0.3},
   ["wild-gift/wyrm-venom"]={true, 0.3},

   --new basic abilities
   ["wild-gift/draconic-energy"]={true, 0.3},
   ["wild-gift/draconic-combat"]={true, 0.3},
   ["wild-gift/draconic-body"]={true, 0.3},
   ["wild-gift/draconic-utility"]={true, 0.3},
   --new generic abilities
   --["wild-gift/hoarding"]={true, 0.3},
   ["wild-gift/apex-predator"]={true, 0.3},	  
}

wyrm.talents  = {
   [ActorTalents.T_REK_WYRMIC_COMBAT_BITE] = 1,
   [ActorTalents.T_REK_WYRMIC_ELEMENT_SPRAY] = 1,
   [ActorTalents.T_REK_WYRMIC_BODY_WINGS] = 1,	    
   [ActorTalents.T_MEDITATION] = 1,
   [ActorTalents.T_WEAPONS_MASTERY] = 1,
   [ActorTalents.T_WEAPON_COMBAT] = 1,
}

wyrm.copy = {
   drake_touched = 2,
   max_life = 110,
   resolvers.equipbirth{ id=true,
			 {type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			 {type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
   },
   copy_add = {
      life_rating = 2,
   },
   equipdoll = "wyrmic"
}

ActorInventory.equipdolls.wyrmic = {
      w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64, doll_w=128, doll_h=128,
     list={
	PSIONIC_FOCUS = {{weight=1, x=48, y=48, subshift="left"}},
	MAINHAND = {{weight=2, x=48, y=120, subshift="left"}},
	OFFHAND = {{weight=3, x=48, y=192, subshift="left"}},
	BODY = {{weight=4, x=48, y=264, subshift="left"}},
	QUIVER = {{weight=5, x=48, y=336, subshift="left"}},
	FINGER = {{weight=6, x=48, y=408, subshift="left"}, {weight=7, x=124, y=408, text="bottom", subshift="left"}},
	LITE = {{weight=8, x=188, y=408, subshift="right"}},
	TOOL = {{weight=9, x=264, y=408, subshift="right", text="bottom"}},
	FEET = {{weight=10, x=264, y=336}},
	BELT = {{weight=11, x=264, y=264}},
	HANDS = {{weight=12, x=264, y=192}},
	CLOAK = {{weight=13, x=264, y=120}},
	NECK = {{weight=14, x=235, y=48, subshift="right", text="topright"}},
	HEAD = {{weight=15, x=150, y=35, subshift="left", text="bottom"}},
	REK_WYRMIC_GEM = {{weight=16, x=48, y=480}, {weight=5, x=124, y=480}},
     }
}

-- newBirthDescriptor{
--    type = "subclass",
--    name = "Neowyrmic",
--    locked = function() return profile.mod.allow_build.wilder_wyrmic end,
--    locked_desc = "Sleek, majestic, powerful... In the path of dragons we walk, and their breath is our breath. See their beating hearts with your eyes and taste their majesty between your teeth.",
--    desc = {
--       "Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
--       "They have access to talents normally belonging to the various kind of drakes.",
--       "Their most important stats are: Strength and Willpower",
--       "#GOLD#Stat modifiers:",
--       "#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +1 Constitution",
--       "#LIGHT_BLUE# * +0 Magic, +3 Willpower, +0 Cunning",
--       "#GOLD#Life per level:#LIGHT_BLUE# +2",
--    },
--    birth_example_particles = {
-- 	   function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, life=18, fade=-0.006, deploy_speed=14})) end end,
-- 	      function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="lightningwings", life=18, fade=-0.006, deploy_speed=14})) end end,
-- 		 function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="poisonwings", life=18, fade=-0.006, deploy_speed=14})) end end,
-- 		    function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="acidwings", life=18, fade=-0.006, deploy_speed=14})) end end,
-- 		       function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="sandwings", life=18, fade=-0.006, deploy_speed=14})) end end,
-- 			  function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="icewings", life=18, fade=-0.006, deploy_speed=14})) end end,
-- 	},
-- 	power_source = {nature=true, technique=true},
-- 	stats = { str=5, wil=3, con=1, },
--    talents_types = {
--       ["wild-gift/call"]={true, 0.2},
--       ["wild-gift/harmony"]={false, 0.1},
--       ["wild-gift/fungus"]={true, 0.1},
--       ["cunning/survival"]={false, 0},

--       -- Warrior stuff
--       ["technique/shield-offense"]={true, 0.1},
--       ["technique/2hweapon-assault"]={true, 0.1},
--       ["technique/combat-techniques-active"]={false, 0},
--       ["technique/combat-techniques-passive"]={true, 0},
--       ["technique/combat-training"]={true, 0},

--       --new locked abilities
--       ["wild-gift/prismatic-dragon"]={false, 0.3},
--       --new basic abilities
--       ["wild-gift/draconic-energy"]={true, 0.3},
--       ["wild-gift/draconic-combat"]={true, 0.3},
--       ["wild-gift/draconic-body"]={true, 0.3},
--       ["wild-gift/draconic-aspects"]={true, 0.3},	    
      
--    },
--    talents = {
--       [ActorTalents.T_REK_WYRMIC_MULTICOLOR] = 1,
--       [ActorTalents.T_REK_WYRMIC_COMBAT_BITE] = 1,
--       [ActorTalents.T_REK_WYRMIC_BODY_WINGS] = 1,	    
--       [ActorTalents.T_MEDITATION] = 1,
--       [ActorTalents.T_WEAPONS_MASTERY] = 1,
--       [ActorTalents.T_WEAPON_COMBAT] = 1,
--    },
   
--    copy = {
--       drake_touched = 2,
--       max_life = 110,
--       resolvers.equipbirth{ id=true,
-- 			    {type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
-- 			    {type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
--       },
--       copy_add = {
-- 	 life_rating = 2,
--       },
--    }
-- }

-- -- Add to metaclass
-- getBirthDescriptor("class", "Wilder").descriptor_choices.subclass["Neowyrmic"] = "allow"
