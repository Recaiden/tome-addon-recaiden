newBirthDescriptor{
	type = "subclass",
	name = "Demolisher",
	locked = function() return true end,
	locked_desc = _t"I wish to have no connection with any vehicle that does not go fast; for I intend to go in harm's way.",
	desc = {
		_t"A demolisher turns their mastery of technology to two important tasks: going fast and blowing stuff up.",
		_t"Steamtech drones handle weapons, crowd control, and defense, so the demolisher can concentrate on placing explosives and piloting their steam buggy.",
		_t"Their most important stat is Cunning.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +4 Dexterity, +5 Cunning",
		_t"#GOLD#Life rating:#LIGHT_BLUE# -5 (special)",
	},
	power_source = {steam=true, technique=true, technique_ranged=true},
	stats = { dex=4, cun=5 },
	talents_types = {
      --Class
      --new base talents
      ["steamtech/battle-machinery"]={true, 0.3},
      ["steamtech/explosives"]={true, 0.3},
			["steamtech/drones"]={true, 0.3},
      ["steamtech/pilot"]={true, 0.3},
      ["steamtech/demo-engine"]={true, 0.3},
      
      --advanced talents
      ["steamtech/automation"]={false, 0.3},
      ["steamtech/battlewagon"]={false, 0.3},
			["steamtech/pyromaniac"]={false, 0.3},

      --old generics
			["technique/combat-training"]={true, 0.0},
			["cunning/survival"]={false, 0.0},
      ["steamtech/physics"]={true, 0.3},
      ["steamtech/chemistry"]={true, 0.3},
			["steamtech/blacksmith"]={false, 0.0},
			["steamtech/engineering"]={true, 0.3},
   },
   birth_example_particles = "wildfire",
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
      life_rating = -5,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Tinker").descriptor_choices.subclass["Demolisher"] = "allow"
