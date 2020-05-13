newBirthDescriptor{
   type = "subclass",
   name = "Martyr",
   locked = function() return true end,
   locked_desc = "....",
   desc = {
      "You are a hero of the old ways, a noble #GREEN#monster#LAST# of honor. You stand alone against overwhelming odds, living by your code. You face the monsters and darkness of the world #GREEN#to pave our way#LAST#.",
      "Grind enemies down with #GREEN#our flesh#LAST# before finishing them with a flash of steel.",
      "#GREEN#Our#LAST# most important stats are Willpower and Strength.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +0 Constitution",
      "#LIGHT_BLUE# * +0 Magic, +5 Willpower, +3 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +1",
   },
   power_source = {psionic=true},
   stats = { str=3, wil=5, cun=3 },
   not_on_random_boss = true,
   talents_types = {
      --Class
      --new base talents
      ["demented/chivalry"]={true, 0.3},
      ["demented/unsettling"]={true, 0.3},
      ["demented/whispers"]={true, 0.3},
      ["demented/scourge"]={true, 0.3},

      --advanced talents

      --new generics
      ["demented/polarity"]={true, 0.3},

      --old generics
      ["technique/combat-training"]={true, 0.3},
      --["demented/beyond-sanity"]={true, 0.3},
      ["psionic/feedback"]={true, 0.0},
      ["cunning/survival"]={true, 0.2},
   },
   birth_example_particles = "darkness_shield",
   talents = {
      --[ActorTalents.T_WEAPONS_MASTERY] = 1,
      [ActorTalents.T_WEAPON_COMBAT] = 1,
      [ActorTalents.T_REK_MTYR_WHISPERS_SLIPPING_PSYCHE] = 1,
      [ActorTalents.T_REK_MTYR_UNSETTLING_UNNERVE] = 1,
      
      --[ActorTalents.T_ARMOUR_TRAINING] = 2,
   },
   
   copy = {
      max_life = 110,
      resolvers.equipbirth{ id=true,
			    {type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000},
			    {type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
      },
   },
   copy_add = {
      life_rating = 1,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Martyr"] = "allow"
