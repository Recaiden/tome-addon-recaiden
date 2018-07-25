newBirthDescriptor{
   type = "subclass",
   name = "Astromancer",
   locked = function() return profile.mod.allow_build.divine end,
   locked_desc = "....",
   desc = {
      "Celestial mages that use the power of the wandering stars to call forth elementals.",
      "...",
      "They use: Magic and Cunning.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
      "#LIGHT_BLUE# * +4 Magic, +0 Willpower, +4 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +0",
   },
   power_source = {arcane=true},
   stats = { mag=4, cun=4 },
   talents_types = {
      --Class
      --new trees
      ["celestial/kolal"]={true, 0.3},
      ["celestial/luxam"]={true, 0.3},
      ["celestial/ponx"]={true, 0.3},
      ["celestial/terrestrial_unity"]={true, 0.3},
      --high level
      ["celestial/meteor"]={false, 0.3},
      ["chronomancy/morass"]={false, 0.3},
      --Generics
      --core
      ["celestial/chants"]={true, 0.3},
      ["celestial/paeans"]={true, 0.3},
      ["celestial/light"]={false, 0.1},
      ["spell/staff-combat"]={true, 0.3},
      ["cunning/survival"]={false, 0.1},
      --["celestial/astronomy"]={false, 0.3},
   },
   birth_example_particles = "darkness_shield",
   talents = {
      --more starting talents go here
      [ActorTalents.T_HEALING_LIGHT] = 1,
      [ActorTalents.T_WANDER_SUMMON_LIGHTNING] = 1,
      [ActorTalents.T_WANDER_SUMMON_FIRE] = 1,
      [ActorTalents.T_WANDER_SUMMON_ICE] = 1,

   },
   
   copy = {
      max_life = 95,
      resolvers.equipbirth{ id=true,
			    {type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			    {type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
      },
      resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Astromancer"] = "allow"
