local Particles = require "engine.Particles"

local wyrm = getBirthDescriptor("subclass", "Wyrmic")

wyrm.talents_types = {
   -- Wilder generics, sets them up to get free Harmony, Fungus is major defense
   ["wild-gift/call"]={true, 0.2},
   ["wild-gift/harmony"]={false, 0.1},
   ["wild-gift/fungus"]={true, 0.1},
   
   -- Warrior stuff, option of 2-hand/2-weapon/S&B, but low mastery
   ["technique/shield-offense"]={true, 0.1},
   ["technique/2hweapon-assault"]={true, 0.1},
   ["technique/dualweapon-attack"]={true, 0.1},
   ["technique/combat-techniques-active"]={false, 0},
   ["technique/combat-techniques-passive"]={true, 0},
   ["technique/combat-training"]={true, 0},
   ["cunning/survival"]={false, 0},
   
   --new locked abilities
   ["wild-gift/prismatic-dragon"]={false, 0.3},
   --new basic abilities
   ["wild-gift/draconic-energy"]={true, 0.3},
   ["wild-gift/draconic-combat"]={true, 0.3},
   ["wild-gift/draconic-body"]={true, 0.3},
   ["wild-gift/draconic-aspects"]={true, 0.3},	      
}


wyrm.talents  = {
   [ActorTalents.T_REK_WYRMIC_MULTICOLOR] = 1,
   [ActorTalents.T_REK_WYRMIC_COMBAT_BITE] = 1,
   [ActorTalents.T_REK_WYRMIC_BODY_WINGS] = 1,	    
   [ActorTalents.T_MEDITATION] = 1,
   [ActorTalents.T_WEAPONS_MASTERY] = 1,
   [ActorTalents.T_WEAPON_COMBAT] = 1,
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
