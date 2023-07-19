newBirthDescriptor {
  type = 'subrace',
  name = 'Blackhoof',
  locked = function() return true end,
  locked_desc = [[Ever running, seeking the spark.  You've risen high while others fell in the dark.]],
  desc = {
     "The next generation of Minotaurs adopted into the demonic military complex.",
     "Feeding on the dark magic of the fearscape, they can take heavy punishment.",
     "They possess the #GOLD#Blackhooves#WHITE# talent which lets them move at dazing speeds.",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +2 Constitution',
     '#LIGHT_BLUE# * +2 Magic, +0 Willpower, +3 Cunning',
     '#GOLD#Life Rating:#LIGHT_BLUE# 13',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +15%'},
  moddable_attachement_spots = "race_whitehoof",
  descriptor_choices = {
		sex =
			{
				__ALL__ = "disallow",
				Male = "allow",
				Female = "allow",
			},
	},
  inc_stats = { str = 3, dex = 0, con = 2, mag = 5, wil = 0, cun = 1 },
  experience = 1.15,
  talents_types = {
		["race/blackhoof"]={true, 0},
  },
  talents = {
		[ActorTalents.T_REK_BLACKHOOF_MOVEMENT]=1,
  },
	cosmetic_options = {},
	default_cosmetics = { {"horns", "Demonic Horns 2"} },
  copy = {
		type = "giant", subtype="minotaur",
		life_rating=13,
		moddable_tile = "whitehoof_male",
		moddable_tile_base = "blackhoof_01.png",
	} 
}

getBirthDescriptor("race", "Giant").descriptor_choices.subrace["Blackhoof"] = "allow"
