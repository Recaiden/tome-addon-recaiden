newBirthDescriptor {
  type = 'subrace',
  name = 'Wight',
  locked = function()
     local id = world:getCurrentAchievementDifficultyId(game, "EVENT_OLDBATTLEFIELD")
     return world:hasAchievement(id)
  end,
  locked_desc = "In forests dark the dead still sleep, waiting for one to dig too deep.",
  desc = {
     "Wights are undead that arise spontaneously in places of great slaughter.",
     "They have access to #GOLD#special undead talents#WHITE# and a wide range of undead abilities:",
     "- poison immunity",
     "- bleeding immunity",
     "- fear immunity",
     "- absorb energy",
     "- teleport through walls",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution',
     '#LIGHT_BLUE# * +2 Magic, +5 Willpower, +0 Cunning',
     '#GOLD#Life per level:#LIGHT_BLUE# 11',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +15%'},
  moddable_attachement_spots = "race_human",
  cosmetic_options = {
     skin = {
        {name="Bright Spectral Skin", file="wight_hollow_bright"},
        {name="Crimson Spectral Skin", file="wight_hollow_crimson"},
        {name="Violet Spectral Skin", file="wight_hollow_purple"},
        {name="Demonic Spectral Skin", file="wight_hollow_demonic", unlock="cosmetic_red_skin"}
     },
     hairs = {
        {name="Hair 1", file="wight_hair_01"},
        {name="Hair 2", file="wight_hair_02"},
        {name="Hair 3", file="wight_hair_03"},
        {name="Hair 4", file="wight_hair_04", only_for={sex="Female"}},
        {name="Hair 5", file="wight_hair_05", only_for={sex="Female"}},
        {name="Hair 6", file="wight_hair_06", only_for={sex="Female"}},
        {name="Redhead 1", file="wight_hair_redhead_01", unlock="cosmetic_race_human_redhead"},
        {name="Redhead 2", file="wight_hair_redhead_02", unlock="cosmetic_race_human_redhead"},
        {name="Redhead 3", file="wight_hair_redhead_03", unlock="cosmetic_race_human_redhead"},
        {name="Redhead 4", file="wight_hair_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
        {name="Redhead 5", file="wight_hair_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
        {name="Redhead 6", file="wight_hair_redhead_06", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
     },
     horns = {
        {name="Minotaur Horns", file="horns_01", unlock="cosmetic_doomhorns"},
        {name="Ram Horns", file="horns_02", unlock="cosmetic_doomhorns"},
        {name="Demonic Horns", file="horns_03", unlock="cosmetic_doomhorns"},
        {name="Demonic Bull Horns", file="horns_04", unlock="cosmetic_doomhorns"},
	{name="Demonic Longhorns", file="horns_05", unlock="cosmetic_doomhorns"},
	{name="Branching Horns 1", file="horns_06", unlock="cosmetic_doomhorns"},
	{name="Branching Horns 2", file="horns_07", unlock="cosmetic_doomhorns"},
	{name="Branching Horns 3", file="horns_08", unlock="cosmetic_doomhorns"},
     },
     facial_features = {
        {name="Beard 1", file="wight_beard_01", only_for={sex="Male"}},
        {name="Beard 2", file="wight_beard_02", only_for={sex="Male"}},
        {name="Beard 3", file="wight_beard_03", only_for={sex="Male"}},
        {name="Beard 4", file="wight_beard_04", only_for={sex="Male"}},
        {name="Beard 5", file="wight_beard_05", only_for={sex="Male"}},
        {name="Redhead Beard 1", file="wight_beard_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 2", file="wight_beard_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 3", file="wight_beard_redhead_03", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 4", file="wight_beard_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 5", file="wight_beard_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Mustache 1", file="wight_face_mustache_01", only_for={sex="Male"}},
        {name="Mustache 2", file="wight_face_mustache_02", only_for={sex="Male"}},
        {name="Redhead Mustache 1", file="wight_face_mustache_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Mustache 2", file="wight_face_mustache_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
     },
  },
  descriptor_choices =
     {
	sex =
	   {
	      __ALL__ = "disallow",
	      Male = "allow",
	   },
     },
  inc_stats = { str = 0, dex = 3, con = 0, mag = 2, wil = 5, cun = 0 },
  experience = 1.15,
  talents_types = {
     ["undead/wight"]={true, 0.1},
  },
  talents = {
     [ActorTalents.T_REK_WIGHT_FURY]=1,
  },
  copy = {
     type = "undead", subtype="wight",
     default_wilderness = {"playerpop", "forest-undead"},
     life_rating=11,
     poison_immune = 1,
     cut_immune = 1,
     fear_immune = 1,
     no_breath = 1,
     moddable_tile = "human_#sex#",
     moddable_tile_base = "wight_hollow_blue.png",
     starting_zone = "rek-wight-ancient-battlefield",
     starting_level = 1, starting_level_force_down = true,
     starting_quest = "start-wight",
     starting_intro = "wight",
    } 
}

getBirthDescriptor("race", "Undead").descriptor_choices.subrace['Wight'] = "allow"
