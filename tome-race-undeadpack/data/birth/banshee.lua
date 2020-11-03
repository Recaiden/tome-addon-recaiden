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
     '#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
  moddable_attachement_spots = "race_human",
  cosmetic_options = {
     skin = {
        {name="Ghostly Translucence", file="banshee_glow"},
        {name="Pale Skin", file="banshee_01"},
        {name="Pink Skin", file="banshee_02"},
        {name="Tanned Skin", file="banshee_03"},
        {name="White Skin", file="banshee_04"},
        {name="Yellow Skin", file="banshee_05"},
        {name="Dark Skin", file="banshee_06"},
        {name="Brown Skin", file="banshee_07"},
        {name="Black Skin", file="banshee_08"},
        {name="Demonic Red Skin", file="demonic_01", unlock="cosmetic_red_skin"}
     },
     hairs = {
        {name="Dark Hair 1", file="hair_cornac_01"},
        {name="Dark Hair 2", file="hair_cornac_02"},
        {name="Dark Hair 3", file="hair_cornac_03"},
        {name="Dark Hair 4", file="hair_cornac_04", only_for={sex="Female"}},
        {name="Dark Hair 5", file="hair_cornac_05", only_for={sex="Female"}},
        {name="Dark Hair 6", file="hair_cornac_06", only_for={sex="Female"}},
        {name="Blond Hair 1", file="hair_higher_01"},
        {name="Blond Hair 2", file="hair_higher_02"},
        {name="Blond Hair 3", file="hair_higher_03"},
        {name="Blond Hair 4", file="hair_higher_04", only_for={sex="Female"}},
        {name="Blond Hair 5", file="hair_higher_05", only_for={sex="Female"}},
        {name="Blond Hair 6", file="hair_higher_06", only_for={sex="Female"}},
        {name="Redhead 1", file="hair_redhead_01", unlock="cosmetic_race_human_redhead"},
        {name="Redhead 2", file="hair_redhead_02", unlock="cosmetic_race_human_redhead"},
        {name="Redhead 3", file="hair_redhead_03", unlock="cosmetic_race_human_redhead"},
        {name="Redhead 4", file="hair_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
        {name="Redhead 5", file="hair_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
        {name="Redhead 6", file="hair_redhead_06", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
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
        {name="Dark Beard 1", file="beard_cornac_01", only_for={sex="Male"}},
        {name="Dark Beard 2", file="beard_cornac_02", only_for={sex="Male"}},
        {name="Dark Beard 3", file="beard_cornac_03", only_for={sex="Male"}},
        {name="Dark Beard 4", file="beard_cornac_04", only_for={sex="Male"}},
        {name="Dark Beard 5", file="beard_cornac_05", only_for={sex="Male"}},
        {name="Blonde Beard 1", file="beard_higher_01", only_for={sex="Male"}},
        {name="Blonde Beard 2", file="beard_higher_02", only_for={sex="Male"}},
        {name="Blonde Beard 3", file="beard_higher_03", only_for={sex="Male"}},
        {name="Blonde Beard 4", file="beard_higher_04", only_for={sex="Male"}},
        {name="Blonde Beard 5", file="beard_higher_05", only_for={sex="Male"}},
        {name="Redhead Beard 1", file="beard_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 2", file="beard_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 3", file="beard_redhead_03", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 4", file="beard_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Beard 5", file="beard_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Dark Mustache 1", file="face_mustache_cornac_01", only_for={sex="Male"}},
        {name="Dark Mustache 2", file="face_mustache_cornac_02", only_for={sex="Male"}},
        {name="Blond Mustache 1", file="face_mustache_higher_01", only_for={sex="Male"}},
        {name="Blond Mustache 2", file="face_mustache_higher_02", only_for={sex="Male"}},
        {name="Redhead Mustache 1", file="face_mustache_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name="Redhead Mustache 2", file="face_mustache_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
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
     experience = 1.1,
     talents_types = {
        ["undead/banshee"]={true, 0.1},
     },
     talents = {
        [ActorTalents.T_REK_BANSHEE_WAIL]=1,
     },
     default_cosmetics = { {"hairs", "Dark Hair 1"} },
     copy = {
        type = "undead", subtype="banshee",
        default_wilderness = {"playerpop", "derth-undead"},
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


local orcs_def = getBirthDescriptor("world", "Orcs")
if orcs_def then
   local old_start = orcs_def.copy.before_starting_zone
   getBirthDescriptor("race", "MinotaurUndead").descriptor_choices.subrace['Banshee'] = "allow"
   
   local function new_start(self)
      if self.descriptor.subrace == "Banshee" then
         self.faction = 'free-whitehooves'

         self.default_wilderness = {"playerpop", "yeti"}
         self.starting_zone = "orcs+vaporous-emporium"
         self.starting_quest = "orcs+start-orc"
         self.starting_intro = "orcs-banshee"
				 self.starting_level = 1
				 self.starting_level_force_down = nil
      end
      if old_start then old_start(self) end
   end
   
   orcs_def.copy.before_starting_zone = new_start
end