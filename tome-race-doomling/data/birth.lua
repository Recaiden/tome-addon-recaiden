newBirthDescriptor {
  type = 'subrace',
  name = 'Doomling',
  locked = function() return profile.mod.allow_build.race_doomelf end,
  locked_desc = "The demons of Mal'Rok would never bless you!
Three could tell them of the horrors you wrought.
One rages and torments in deep oceans blue,
one fights for the third with the cultists she taught.
Silence these beings, maintain your deception,
and then witness a new halfling's conception...",
  desc = {
     "Doomlings are not a real race, they are Halflings that have been taken by demons and transformed into harbingers of doom",
     "They enjoy stalking lone foes and afflicting them with torments",
     "They possess the #GOLD#Curse of the Little Folk#WHITE# talent which allows them to reduce an enemy's saving throws and damage.",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * -3 Strength, +3 Dexterity, +1 Constitution',
     '#LIGHT_BLUE# * +2 Magic, +0 Willpower, +1 Cunning',
     '#GOLD#Life Rating:#LIGHT_BLUE# 12',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
  moddable_attachement_spots = "race_halfling",
  cosmetic_options = {
     -- skin = {
     --    {name="Bright Spectral Skin", file="wight_hollow_bright"},
     --    {name="Crimson Spectral Skin", file="wight_hollow_crimson"},
     --    {name="Violet Spectral Skin", file="wight_hollow_purple"},
     --    {name="Demonic Spectral Skin", file="wight_hollow_demonic", unlock="cosmetic_red_skin"}
     -- },
     -- hairs = {
     --    {name="Hair 1", file="wight_hair_01"},
     --    {name="Hair 2", file="wight_hair_02"},
     --    {name="Hair 3", file="wight_hair_03"},
     --    {name="Hair 4", file="wight_hair_04", only_for={sex="Female"}},
     --    {name="Hair 5", file="wight_hair_05", only_for={sex="Female"}},
     --    {name="Hair 6", file="wight_hair_06", only_for={sex="Female"}},
     --    {name="Redhead 1", file="wight_hair_redhead_01", unlock="cosmetic_race_human_redhead"},
     --    {name="Redhead 2", file="wight_hair_redhead_02", unlock="cosmetic_race_human_redhead"},
     --    {name="Redhead 3", file="wight_hair_redhead_03", unlock="cosmetic_race_human_redhead"},
     --    {name="Redhead 4", file="wight_hair_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
     --    {name="Redhead 5", file="wight_hair_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
     --    {name="Redhead 6", file="wight_hair_redhead_06", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
     -- },
     -- horns = {
     --    {name="Minotaur Horns", file="horns_01", unlock="cosmetic_doomhorns"},
     --    {name="Ram Horns", file="horns_02", unlock="cosmetic_doomhorns"},
     --    {name="Demonic Horns", file="horns_03", unlock="cosmetic_doomhorns"},
     --    {name="Demonic Bull Horns", file="horns_04", unlock="cosmetic_doomhorns"},
		 -- 		{name="Demonic Longhorns", file="horns_05", unlock="cosmetic_doomhorns"},
		 -- 		{name="Branching Horns 1", file="horns_06", unlock="cosmetic_doomhorns"},
		 -- 		{name="Branching Horns 2", file="horns_07", unlock="cosmetic_doomhorns"},
		 -- 		{name="Branching Horns 3", file="horns_08", unlock="cosmetic_doomhorns"},
     -- },
     -- facial_features = {
     --    {name="Beard 1", file="wight_beard_01", only_for={sex="Male"}},
     --    {name="Beard 2", file="wight_beard_02", only_for={sex="Male"}},
     --    {name="Beard 3", file="wight_beard_03", only_for={sex="Male"}},
     --    {name="Beard 4", file="wight_beard_04", only_for={sex="Male"}},
     --    {name="Beard 5", file="wight_beard_05", only_for={sex="Male"}},
     --    {name="Redhead Beard 1", file="wight_beard_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     --    {name="Redhead Beard 2", file="wight_beard_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     --    {name="Redhead Beard 3", file="wight_beard_redhead_03", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     --    {name="Redhead Beard 4", file="wight_beard_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     --    {name="Redhead Beard 5", file="wight_beard_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     --    {name="Mustache 1", file="wight_face_mustache_01", only_for={sex="Male"}},
     --    {name="Mustache 2", file="wight_face_mustache_02", only_for={sex="Male"}},
     --    {name="Redhead Mustache 1", file="wight_face_mustache_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     --    {name="Redhead Mustache 2", file="wight_face_mustache_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     -- },
  },
  descriptor_choices =
     {
	sex =
	   {
	      __ALL__ = "disallow",
	      Male = "allow",
	   },
     },
  inc_stats = { str = -1, dex = 3, con = 1, mag = 2, wil = 0, cun = 1 },
  experience = 1.10,
  talents_types = {
     ["race/doomling"]={true, 0},
  },
  talents = {
     [ActorTalents.T_REK_DOOMLING_LUCK]=1,
  },
  copy = {
     type = "halfling", subtype="doomling",
     _forbid_start_override = true,
     default_wilderness = {"zone-pop", "angolwen-portal"},
     starting_zone = "ashes-urhrok+searing-halls",
     starting_quest = "ashes-urhrok+start-ashes",
     ashes_urhrok_race_start_quest = "start-allied",
     faction = "allied-kingdoms",
     starting_intro = "ashes-urhrok",
     life_rating=12,
     moddable_tile = "halfling_#sex#",
     moddable_tile_base = "demonic_01.png",
    } 
}

getBirthDescriptor("race", "Halfling").descriptor_choices.subrace['Doomling'] = "allow"
