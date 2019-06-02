newBirthDescriptor{
   type = "subclass",
   name = "Fallen",
   locked = function() return profile.mod.allow_build.divine end,
   locked_desc = "....",
   desc = {
      "Once, you had a code, a calling.  You carried the light into the darkness.",
      "In the darkness, you faltered.  Whether it was greed, for love, or simple cowardice, you broke your oath; now you are fallen from grace.",
      "And yet, the sun still shines as brightly as ever.",
      "Fueled by their own misery and twisted solar magics, Fallen are devastating melee combatants.",
      "Their most important stats are Strength and willpower.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
      "#LIGHT_BLUE# * +2 Magic, +2 Willpower, +0 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +2",
   },
   power_source = {arcane=true},
   stats = { str=5, wil=2, mag=2 },
   talents_types = {
      --Class
      --new base talents
      ["cursed/bloodstained"]={true, 0.3},
      ["celestial/darkside"]={true, 0.3},
      --old base talents
      ["cursed/shadows"]={true, 0.1},
      ["cursed/gloom"]={false, 0.1},
      ["celestial/combat"]={true, 0.3},

      --advanced talents
      ["cursed/crimson-templar"]={false, 0.3},
      ["celestial/black-sun"]={false, 0.3},
      ["cursed/suffering-shadows"]={false, 0.3},

      --new generics
      ["celestial/dirge"]={true, 0.3},
      ["cursed/self-hatred"]={true, 0.3},
      --old generics
      ["celestial/light"]={true, 0.1},
      ["technique/combat-training"]={true, 0.3},      
   },
   birth_example_particles = "darkness_shield",
   talents = {
      [ActorTalents.T_WEAPONS_MASTERY] = 1,
      [ActorTalents.T_WEAPON_COMBAT] = 1,
      [ActorTalents.T_ARMOUR_TRAINING] = 2,
      [ActorTalents.T_HEALING_LIGHT] = 1,
      [ActorTalents.T_WEAPON_OF_LIGHT] = 1,
      [ActorTalents.T_FLN_DIRGE_ACOLYTE] = 1,
      [ActorTalents.T_FLN_DARKSIDE_SLAM] = 1,
      [ActorTalents.T_FLN_BLOODSTAINED_RUSH] = 1,
   },
   
   copy = {
      max_life = 110,
      resolvers.equipbirth{ id=true,
			    {type="weapon", subtype="greatsword", name="bloodstained iron greatsword", autoreq=true, ego_chance=-1000},
			    {type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
      },
   },
   copy_add = {
      life_rating = 2,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Fallen"] = "allow"
