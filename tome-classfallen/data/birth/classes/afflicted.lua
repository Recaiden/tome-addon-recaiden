newBirthDescriptor{
   type = "subclass",
   name = "Fallen",
   locked = function() return profile.mod.allow_build.divine_sun_paladin end,
   locked_desc = "The sun rises in the east in full glory, but in the end passes west, into darkness",
   desc = {
      "Once, they had a code, a calling.  They carried the light into the darkness.",
      "In the darkness, they faltered.  Whether it was greed, for love, or simple cowardice, they broke the oath; now they are Fallen from grace.",
      "And yet, the sun still shines as brightly as ever.",
      "Fueled by their own misery and twisted solar magics, the Fallen are devastating melee combatants.",
      "Their most important stats are Strength, Magic, and Willpower.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
      "#LIGHT_BLUE# * +2 Magic, +2 Willpower, +0 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +2",
   },
   power_source = {arcane=true},
   stats = { str=5, wil=2, mag=2 },
   not_on_random_boss = true,
   talents_types = {
      --Class
      --new base talents
      ["cursed/bloodstained"]={true, 0.3},
      ["celestial/darkside"]={true, 0.3},
      ["cursed/solar-shadows"]={true, 0.3},
      --old base talents
      ["cursed/gloom"]={false, 0.3},
      ["celestial/combat"]={true, 0.3},

      --advanced talents
      ["cursed/crimson-templar"]={false, 0.3},
      ["celestial/black-sun"]={false, 0.3},
      ["cursed/suffering-shadows"]={false, 0.3},

      --new generics
      ["celestial/dirge"]={true, 0.3},
      ["cursed/hatred"]={true, 0.3},
      --old generics
      ["celestial/light"]={true, 0.0},
      ["technique/combat-training"]={true, 0.3},      
   },
   birth_example_particles = "dirge_shield",
   talents = {
      [ActorTalents.T_WEAPONS_MASTERY] = 1,
      [ActorTalents.T_WEAPON_COMBAT] = 1,
      [ActorTalents.T_ARMOUR_TRAINING] = 2,
      [ActorTalents.T_HEALING_LIGHT] = 1,
      [ActorTalents.T_WEAPON_OF_LIGHT] = 1,
      [ActorTalents.T_BRUTALIZE] = 1,
      [ActorTalents.T_BLOOD_RUSH] = 1,
      [ActorTalents.T_SELF_SACRIFICE] = 1,
   },
   
   copy = {
      max_life = 110,
      resolvers.equipbirth{ id=true,
			    {type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000},
			    {type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
      },
   },
   copy_add = {
      life_rating = 2,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Fallen"] = "allow"
