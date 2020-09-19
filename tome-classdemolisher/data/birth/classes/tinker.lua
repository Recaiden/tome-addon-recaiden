newBirthDescriptor{
   type = "subclass",
   name = "Demolisher",
   locked = function() return true end,
   locked_desc = "...",
   desc = {
      "A demolisher turns their mastery of technology to two important tasks: going fast and blowing stuff up.",
      "Their most important stat is Cunning.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
      "#LIGHT_BLUE# * +0 Magic, +0 Willpower, +5 Cunning",
      "#GOLD#Life rating:#LIGHT_BLUE# -4",
   },
   power_source = {steam=true},
   stats = { dex=3, cun=5 },
   talents_types = {
      --Class
      --new base talents
      ["steamtech/battle-machinery"]={true, 0.3},
      ["steamtech/explosives"]={true, 0.3},
			["steamtech/drones"]={true, 0.3},
      ["steamtech/pilot"]={true, 0.3},
      ["steamtech/engine"]={true, 0.3},
      
      --advanced talents
      ["steamtech/automation"]={false, 0.3},
      ["steamtech/battlewagon"]={false, 0.3},
			["steamtech/pyromaniac"]={false, 0.3},

      --old generics
      ["cunning/survival"]={true, 0.0},
      ["steamtech/physics"]={true, 0.3},
      ["steamtech/chemistry"]={true, 0.3},
   },
   --birth_example_particles = "darkness_shield",
   talents = {
		 [ActorTalents.T_EXPLOSIVE_STEAM_ENGINE] = 1,
		 [ActorTalents.T_REK_DEML_EXPLOSIVE_REMOTE_CHARGE] = 1,
		 [ActorTalents.T_REK_DEML_PILOT_AUTOMOTOR] = 1,
		 
		 [ActorTalents.T_THERAPEUTICS] = 1,
		 [ActorTalents.T_SMITH] = 1,
   },
   
   copy = {
      max_life = 105,
      resolvers.auto_equip_filters{
				QS_MAINHAND = {type="weapon", subtype="sling"},
				QUIVER={properties={"archery_ammo"}, special=function(e, filter) -- must match the MAINHAND weapon, if any
						local mh = filter._equipping_entity and filter._equipping_entity:getInven(filter._equipping_entity.INVEN_QS_MAINHAND)
						mh = mh and mh[1]
						if not mh or mh.archery == e.archery_ammo then return true end
																										 end},
                                  },
			resolvers.equipbirth{
				id=true,
				{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
				{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
				{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
													},	
   },
   copy_add = {
      life_rating = -4,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Tinker").descriptor_choices.subclass["Demolisher"] = "allow"
