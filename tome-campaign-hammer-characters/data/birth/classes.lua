newBirthDescriptor{
   type = "subclass",
   name = "Impling",
   locked = function() return profile.mod.allow_build.corrupter_corruptor end,
   locked_desc = "Let our vengeance burn bright and everlasting.",
   desc = {
      "Infused with the everburning flames of the fearscape, the impling sets the entire battlefield ablaze and rains down fireballs on their enemies.",
      "Their most important stats are Magic and Dexterity.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +3 Dexterity, -2 Constitution",
      "#LIGHT_BLUE# * +5 Magic, +3 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +1",
   },
   power_source = {arcane=true, technique=true, technique_ranged=true},
   stats = { dex=3, con=-2, mag=5, cun=3 },
   talents_types = {
		 --Class
		 --new base talents
		 -- ["psionic/idol"]={true, 0.3},
		 -- ["psionic/noumena"]={true, 0.3},
		 -- ["technique/psychic-marksman"]={true, 0.3},
		 -- ["technique/psychic-shots"]={true, 0.3},
		 -- --old base talents
		 
		 -- --advanced talents
		 -- ["psionic/unleash-abomination"]={false, 0.3},
		 -- ["psionic/unleash-nightmare"]={false, 0.3},
		 -- ["technique/arrowstorm"]={false, 0.3},
		 
		 --new generics
		 ["corruption/imp-claws"]={true, 0.3},
		 -- --old generics
		 -- ["psionic/augmented-mobility"]={true, 0.3},      
		 -- ["technique/combat-training"]={true, 0.3},
		 -- ["cunning/survival"]={true, 0.0},
		 -- ["psionic/mindprison"]={false, 0.3},
   },
   birth_example_particles = "darkness_shield",
   talents = {
		 [ActorTalents.T_WEAPON_COMBAT] = 1,
		 [ActorTalents.T_ARMOUR_TRAINING] = 1, 
		 [ActorTalents.T_REK_IMP_ETERNAL_FLAME] = 1,
			-- [ActorTalents.T_REK_GLR_SHOT_DRILL] = 1,
			-- [ActorTalents.T_REK_GLR_NOUMENA_UNSEEN_GUARDIAN] = 1,
      -- [ActorTalents.T_SKATE] = 1,
   },
   
   copy = {
      max_life = 110,
      resolvers.equipbirth{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
													},
			resolvers.generic(function(e)
													e.auto_shoot_talent = e.T_SHOOT
												end),
   },
   copy_add = {
      life_rating = 1,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Defiler").descriptor_choices.subclass["Impling"] = "allow"
