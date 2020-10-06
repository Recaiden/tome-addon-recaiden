newBirthDescriptor{
   type = "subclass",
   name = "Harrower",
   locked = function() return profile.mod.allow_build.psionic_mindslayer end,
   locked_desc = "I do not shoot with my hand; he who shoots with his hand has forgotten the face of his father. I shoot with my mind.",
   desc = {
      "There's something inside you, something terrible and strong.  But you've got it under control.  Your mental discipline allows you to use its power for constructive purposes.",
      "It's all perfectly safe.",
      "Send arrows zooming forward with telekinetic speed while controlling the perceptions of your enemies and reshaping the matter of the battlefield.",
      "Their most important stats are Willpower and Dexterity.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +3 Dexterity, -2 Constitution",
      "#LIGHT_BLUE# * +5 Willpower, +3 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +0",
   },
   power_source = {psionic=true, technique=true, technique_ranged=true},
   stats = { dex=3, con=-2, wil=5, cun=3 },
   talents_types = {
      --Class
      --new base talents
		 ["psionic/idol"]={true, 0.3},
		 ["psionic/noumena"]={true, 0.3},
		 ["technique/psychic-marksman"]={true, 0.3},
		 ["technique/psychic-shots"]={true, 0.3},
      --old base talents

      --advanced talents
      --["psionic/unleash-nightmare"]={false, 0.3},

      --new generics
      --old generics
			["psionic/augmented-mobility"]={true, 0.3},      
      ["technique/combat-training"]={true, 0.3},      
   },
   birth_example_particles = "darkness_shield",
   talents = {
      [ActorTalents.T_WEAPON_COMBAT] = 1,
      --[ActorTalents.T_ARMOUR_TRAINING] = 2,
      --[ActorTalents.T_HEALING_LIGHT] = 1,
			[ActorTalents.T_REK_GLR_MARKSMAN_ACCELERATE] = 1,
			[ActorTalents.T_REK_GLR_SHOT_DRILL] = 1,
			[ActorTalents.T_REK_GLR_NOUMENA_UNSEEN_GUARDIAN] = 1,
      [ActorTalents.T_SKATE] = 1,
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
      life_rating = 0,
   },
}

-- Add to metaclass
getBirthDescriptor("class", "Psionic").descriptor_choices.subclass["Harrower"] = "allow"
