newBirthDescriptor {
  type = 'subrace',
  name = 'Banshee',
--  locked = function()
--     return profile.mod.allow_build.undead_banshee
  --  end,
  locked = function() return profile.mod.allow_build.undead end,
  locked_desc = "Tower's lord, master of all, free the dead with master's fall",
  desc = {
     "Banshees are vengeful undead spirits with terrifying voices, thought to be harbingers of death.",
     "They have access to #GOLD#special undead talents#WHITE# and a wide range of undead abilities:",
     "- silence immunity",
     "- bleeding immunity",
     "- fear immunity",
     "- confuse and doom enemies",
     "- walk through walls",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution',
     '#LIGHT_BLUE# * +2 Magic, +5 Willpower, +0 Cunning',
     '#GOLD#Life per level:#LIGHT_BLUE# 9',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +20%'},
  moddable_attachement_spots = "race_human",
  descriptor_choices =
     {
	sex =
	   {
	      __ALL__ = "disallow",
	      Male = "allow",
	   },
     },
  inc_stats = { str = 0, dex = 3, con = 0, mag = 2, wil = 5, cun = 0 },
  experience = 1.2,
  talents_types = {
     ["undead/banshee"]={true, 0.1},
  },
  talents = {
     [ActorTalents.T_REK_BANSHEE_WAIL]=1,
  },
  copy = {
     type = "undead", subtype="banshee",
     default_wilderness = {"playerpop", "mid-undead"},
     life_rating=9,
     silence_immune = 1,
     cut_immune = 1,
     fear_immune = 1,
     moddable_tile = "human_#sex#",
     moddable_tile_base = "base_banshee_01.png",
     starting_zone = "kidnapper-hideout",
     starting_level = 3, starting_level_force_down = true,
     starting_quest = "start-banshee",
     starting_intro = "banshee",
    } 
}

getBirthDescriptor("race", "Undead").descriptor_choices.subrace['Banshee'] = "allow"
