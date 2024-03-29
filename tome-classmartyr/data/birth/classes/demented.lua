newBirthDescriptor{
   type = "subclass",
   name = "Martyr",
   locked = function() return true end,
   locked_desc = "....",
   desc = {
      _t"You are a hero of the old ways, a noble #GREEN#monster#LAST# of honor. You stand alone against overwhelming odds, living by your code. You face the monsters and darkness of the world #GREEN#to pave our way#LAST#.",
      _t"Grind enemies down with #GREEN#our flesh#LAST# before finishing them with a flash of steel.",
      _t"#GREEN#Our#LAST# most important stats are Cunning and Strength.",
      _t"#GOLD#Stat modifiers:",
      _t"#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +0 Constitution",
      _t"#LIGHT_BLUE# * +0 Magic, +5 Willpower, +3 Cunning",
      _t"#GOLD#Life per level:#LIGHT_BLUE# +0",
   },
   power_source = {psionic=true},
   stats = { str=3, wil=5, cun=3 },
   not_on_random_boss = true,
   talents_types = {
      --Class
      --new base talents
      ["demented/chivalry"]={true, 0.3},
      ["demented/vagabond"]={true, 0.3},
      ["demented/unsettling"]={true, 0.3},
      ["demented/whispers"]={true, 0.3},
      ["demented/scourge"]={true, 0.3},
      ["demented/standard-bearer"]={true, 0.3},
      
      --advanced talents
      ["demented/revelation"]={false, 0.3},
      ["demented/moment"]={false, 0.3},
      ["psionic/crucible"]={false, 0.3},

      --new generics
      ["demented/polarity"]={true, 0.3},

      --old generics
      ["technique/combat-training"]={true, 0.3},
      ["psionic/feedback"]={true, 0.0},
      ["cunning/survival"]={true, 0.2},
   },
   birth_example_particles = "darkness_shield",
   talents = {
      [ActorTalents.T_SHOOT] = 1,
      [ActorTalents.T_WEAPONS_MASTERY] = 1,
      [ActorTalents.T_WEAPON_COMBAT] = 1,
			[ActorTalents.T_ARMOUR_TRAINING] = 1,
      [ActorTalents.T_REK_MTYR_WHISPERS_SLIPPING_PSYCHE] = 1,
      [ActorTalents.T_REK_MTYR_UNSETTLING_UNNERVE] = 1,
      [ActorTalents.T_REK_MTYR_POLARITY_DEEPER_SHADOWS] = 1,
   },
   
   copy = {
      max_life = 100,
      resolvers.auto_equip_filters{
         MAINHAND = {type="weapon", subtype="sling"},
         OFFHAND = {type="none"},
         QUIVER={properties={"archery_ammo"}, special=function(e, filter) -- must match the MAINHAND weapon, if any
               local mh = filter._equipping_entity and filter._equipping_entity:getInven(filter._equipping_entity.INVEN_MAINHAND)
               mh = mh and mh[1]
               if not mh or mh.archery == e.archery_ammo then return true end
                                                      end},
         QS_MAINHAND = {type="weapon", not_properties={"twohanded"}},
                                  },
      resolvers.equipbirth{ id=true,
                            {type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
                            {type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
														{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
                          },
      resolvers.inventorybirth{
         id=true, inven="QS_MAINHAND",
         {type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
                              },
      resolvers.generic(function(e)
                           e.auto_shoot_talent = e.T_SHOOT
                        end),
   },
   copy_add = {
      life_rating = 0,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Martyr"] = "allow"
