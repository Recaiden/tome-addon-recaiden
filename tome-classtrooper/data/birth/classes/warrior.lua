newBirthDescriptor{
   type = "subclass",
   name = "Deeprock Trooper",
   desc = {
      "With pickaxe and laser in hand, the Deeprock Trooper resolves problems with traditional dwarven simplicity.",
      "What they can't solve with advanced weaponry, their mastery of rock and stone will handle.",
      "Their most important stats are Strength and Constitution.",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +2 Strength, +3 Constitution",
      "#LIGHT_BLUE# * -5 Magic, +3 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +2",
   },
   power_source = {technique=true, technique_ranged=true, occult=true},
	 not_on_random_boss = true,
   stats = { str=2, con=3, mag=-5, cun=3 },
   talents_types = {
		 --Class
		 --new base talents
		 ["occultech/carbine"]={true, 0.3},
		 ["occultech/voidsuit"]={true, 0.3},
		 --["technique/psychic-marksman"]={true, 0.3},
		 --["technique/psychic-shots"]={true, 0.3},
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
   birth_example_particles = "darkness_shield",
   talents = {
		 -- 3 class talents
		 [ActorTalents.T_WEAPON_COMBAT] = 1,
		 -- 1 other generic
   },
   
   copy = {
		 max_life = 110,
		 resolvers.equipbirth{ id=true,
													 --todo craete pickaxe
													 --todo start with shot
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
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
