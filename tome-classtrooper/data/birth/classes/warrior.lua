newBirthDescriptor{
   type = "subclass",
   name = "Deeprock Trooper",
   desc = {
      "With pickaxe and laser in hand, the Deeprock Trooper resolves problems with traditional dwarven simplicity.",
      "What they can't handle with advanced weaponry, their mastery of stone will clear away.",
      "Their most important stats are Strength and Constitution.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +2 Strength, +3 Constitution",
      "#LIGHT_BLUE# * -5 Magic, +3 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +2",
   },
	 special_check = function(birth)
		 if birth.descriptors_by_type.race ~= "Dwarf" then return false end
		 return true
	 end,
   power_source = {technique=true, technique_ranged=true, occult=true},
	 not_on_random_boss = true,
   stats = { str=2, con=3, mag=-5, cun=3 },
   talents_types = {
		 --Class
		 --new base talents
		 ["occultech/carbine"]={true, 0.3},
		 ["occultech/voidsuit"]={true, 0.3},
		 ["technique/trooper"]={true, 0.3},
		 ["technique/dwarven-legacy"]={true, 0.3},
		 --old base talents
		 ["wild-gift/dwarven-nature"]={true, 0.1},
		 
		 --advanced talents
		 --["psionic/unleash-abomination"]={false, 0.3},
		 --["psionic/unleash-nightmare"]={false, 0.3},
		 --["technique/arrowstorm"]={false, 0.3},
		 
		 --new generics
		 --["psionic/mindshaped-material"]={true, 0.3},
		 --old generics
		 ["technique/combat-training"]={true, 0.3},
		 ["technique/conditioning"]={true, 0.3},
		 ["cunning/survival"]={true, 0.0},
   },
   birth_example_particles = "darkness_shield", --todo
   talents = {
		 -- 3 class talents
		 [ActorTalents.T_REK_OCLT_TOOL_RESERVE] = 1,
		 [ActorTalents.T_WEAPON_COMBAT] = 1,
		 -- 1 other generic
   },
   
   copy = {
		 resolvers.auto_equip_filters{
			 MAINHAND = {type="tool", subtype="digger"},
			 OFFHAND = {special=shield_special},
			 BODY = {type="armor", special=function(e, filter)
								 if e.subtype=="heavy" or e.subtype=="massive" then return true end
								 local who = filter._equipping_entity
								 if who then
									 local body = who:getInven(who.INVEN_BODY)
									 return not (body and body[1])
								 end
			 end},
		 },
		 resolvers.equipbirth{
			 id=true,
			 {type="tool", subtype="digger", name="iron pickaxe", autoreq=true, ego_chance=-1000, do_wear=true, force_inven="MAINHAND"},
			 {type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			 {type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		 },
			resolvers.generic(function(e)
													e.auto_shoot_talent = e.T_SHOOT
												end),
   },
   copy_add = {
      life_rating = 2,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Deeprock Trooper"] = "allow"
