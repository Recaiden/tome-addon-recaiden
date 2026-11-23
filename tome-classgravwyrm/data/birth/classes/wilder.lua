local Particles = require "engine.Particles"

newBirthDescriptor{
   type = "subclass",
   name = "Gravity Wyrmic",
   locked = function() return profile.mod.allow_build.wilder_wyrmic end,
   locked_desc = "Sleek, majestic, powerful... In the path of dragons we walk, and their breath is our breath. See their beating hearts with your eyes and taste their majesty between your teeth.",
   desc = {
      "Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
      "You have focused on a very particular type of wyrm.",
      "Their most important stats are Willpower and Magic and Strength.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +3 STR, +3 WIL, +3 MAG",
      "#GOLD#Life per level:#LIGHT_BLUE# +2",
   },
   power_source = {arcane=true, technique=true, nature=true},
   stats = { str=3, mag=3, wil=3, },
   talents_types = {
		 --Class
		 --new base talents
		 --old base talents
		 ["wild-gift/sand-drake"]={true, 0.3},
		 ["chronomancy/gravity"]={true, 0.3},
		 ["chronomancy/temporal-combat"]={true, 0.3},

		 ["technique/shield-offense"]={true, 0.3},
		 ["technique/2hweapon-assault"]={true, 0.3},
		 ["technique/dualweapon-attack"]={true, 0.3},

		 --locked @ level 0
		 ["chronomancy/flux"]={false, 0.3},
		 ["technique/combat-techniques-active"]={false, 0.0},
		 ["chronomancy/entropy"]={false, 0.0},

		 --advanced talents
		 
		 --new generics
		 ["chronomancy/geosynchrony"]={true, 0.3},
		 --old generics
		 ["wild-gift/call"]={false, 0.3},
		 ["wild-gift/harmony"]={false, 0.0},
		 ["technique/combat-training"]={true, 0.3}, 
		 ["cunning/survival"]={true, 0.0},
		 ["wild-gift/fungus"]={true, 0.0},
   },
	 birth_example_particles = {
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="sandwings", life=18, fade=-0.006, deploy_speed=14})) end end,
	},
   talents = {
		 [ActorTalents.T_REPULSION_BLAST] = 1,
		 [ActorTalents.T_REK_GRV_CORE] = 1,
		 [ActorTalents.T_WEAPONS_MASTERY] = 1,
		 [ActorTalents.T_WEAPON_COMBAT] = 1,
		 [ActorTalents.T_ARMOUR_TRAINING] = 1,
   },
   
   copy = {
		 drake_touched = 2,
		 max_life = 110,
		 resolvers.auto_equip_filters{
			MAINHAND = {type="weapon", properties={"twohanded"}},
			OFFHAND = {special=function(e, filter) -- only allow if there is already a weapon in MAINHAND
									 local who = filter._equipping_entity
									 if who then
										 local mh = who:getInven(who.INVEN_MAINHAND) mh = mh and mh[1]
										 if mh and (not mh.slot_forbid or not who:slotForbidCheck(e, who.INVEN_MAINHAND)) then return true end
									 end
									 return false
			end},
		 },
		 resolvers.equipbirth{
			 id=true,
			 {type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			 {type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}		},
	 },
   copy_add = {
		 life_rating = 2,
   },
}

getBirthDescriptor("subclass", "Gravity Wyrmic").unlockable_talents_types = getBirthDescriptor("subclass", "Wyrmic").unlockable_talents_types or {}

-- Add to metaclass
getBirthDescriptor("class", "Wilder").descriptor_choices.subclass["Gravity Wyrmic"] = "allow"
