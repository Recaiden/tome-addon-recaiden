newBirthDescriptor {
  type = 'subrace',
  name = 'Banshee',
--  locked = function()
--     return profile.mod.allow_build.undead_banshee
  --  end,
  locked = function() return profile.mod.allow_build.undead end,
  locked_desc = _t"Tower's lord, master of all, free the dead with master's fall",
  desc = {
     _t"Banshees are vengeful undead spirits with terrifying voices, thought to be harbingers of death.",
     _t"They have access to #GOLD#special undead talents#WHITE# and a wide range of undead abilities:",
     _t"- silence immunity",
     _t"- bleeding immunity",
     _t"- fear immunity",
     _t"- confuse and doom enemies",
     _t"- walk through walls",
     _t"#GOLD#Stat modifiers:",
     _t"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
     _t"#LIGHT_BLUE# * +2 Magic, +5 Willpower, +0 Cunning",
     _t"#GOLD#Life per level:#LIGHT_BLUE# 9",
     _t"#GOLD#Experience penalty:#LIGHT_BLUE# +10%"},
  moddable_attachement_spots = "race_human",
  cosmetic_options = {
     skin = {
        {name=_t"Ghostly Translucence", file="banshee_glow"},
        {name=_t"Pale Skin", file="banshee_01"},
        {name=_t"Pink Skin", file="banshee_02"},
        {name=_t"Tanned Skin", file="banshee_03"},
        {name=_t"White Skin", file="banshee_04"},
        {name=_t"Yellow Skin", file="banshee_05"},
        {name=_t"Dark Skin", file="banshee_06"},
        {name=_t"Brown Skin", file="banshee_07"},
        {name=_t"Black Skin", file="banshee_08"},
        {name=_t"Demonic Red Skin", file="demonic_01", unlock="cosmetic_red_skin"}
     },
     hairs = {
        {name=_t"Dark Hair 1", file="hair_cornac_01"},
        {name=_t"Dark Hair 2", file="hair_cornac_02"},
        {name=_t"Dark Hair 3", file="hair_cornac_03"},
        {name=_t"Dark Hair 4", file="hair_cornac_04", only_for={sex="Female"}},
        {name=_t"Dark Hair 5", file="hair_cornac_05", only_for={sex="Female"}},
        {name=_t"Dark Hair 6", file="hair_cornac_06", only_for={sex="Female"}},
        {name=_t"Blond Hair 1", file="hair_higher_01"},
        {name=_t"Blond Hair 2", file="hair_higher_02"},
        {name=_t"Blond Hair 3", file="hair_higher_03"},
        {name=_t"Blond Hair 4", file="hair_higher_04", only_for={sex="Female"}},
        {name=_t"Blond Hair 5", file="hair_higher_05", only_for={sex="Female"}},
        {name=_t"Blond Hair 6", file="hair_higher_06", only_for={sex="Female"}},
        {name=_t"Redhead 1", file="hair_redhead_01", unlock="cosmetic_race_human_redhead"},
        {name=_t"Redhead 2", file="hair_redhead_02", unlock="cosmetic_race_human_redhead"},
        {name=_t"Redhead 3", file="hair_redhead_03", unlock="cosmetic_race_human_redhead"},
        {name=_t"Redhead 4", file="hair_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
        {name=_t"Redhead 5", file="hair_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
        {name=_t"Redhead 6", file="hair_redhead_06", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
     },
     horns = {
        {name=_t"Minotaur Horns", file="horns_01", unlock="cosmetic_doomhorns"},
        {name=_t"Ram Horns", file="horns_02", unlock="cosmetic_doomhorns"},
        {name=_t"Demonic Horns", file="horns_03", unlock="cosmetic_doomhorns"},
        {name=_t"Demonic Bull Horns", file="horns_04", unlock="cosmetic_doomhorns"},
	{name=_t"Demonic Longhorns", file="horns_05", unlock="cosmetic_doomhorns"},
	{name=_t"Branching Horns 1", file="horns_06", unlock="cosmetic_doomhorns"},
	{name=_t"Branching Horns 2", file="horns_07", unlock="cosmetic_doomhorns"},
	{name=_t"Branching Horns 3", file="horns_08", unlock="cosmetic_doomhorns"},
     },
     facial_features = {
        {name=_t"Dark Beard 1", file="beard_cornac_01", only_for={sex="Male"}},
        {name=_t"Dark Beard 2", file="beard_cornac_02", only_for={sex="Male"}},
        {name=_t"Dark Beard 3", file="beard_cornac_03", only_for={sex="Male"}},
        {name=_t"Dark Beard 4", file="beard_cornac_04", only_for={sex="Male"}},
        {name=_t"Dark Beard 5", file="beard_cornac_05", only_for={sex="Male"}},
        {name=_t"Blonde Beard 1", file="beard_higher_01", only_for={sex="Male"}},
        {name=_t"Blonde Beard 2", file="beard_higher_02", only_for={sex="Male"}},
        {name=_t"Blonde Beard 3", file="beard_higher_03", only_for={sex="Male"}},
        {name=_t"Blonde Beard 4", file="beard_higher_04", only_for={sex="Male"}},
        {name=_t"Blonde Beard 5", file="beard_higher_05", only_for={sex="Male"}},
        {name=_t"Redhead Beard 1", file="beard_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name=_t"Redhead Beard 2", file="beard_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name=_t"Redhead Beard 3", file="beard_redhead_03", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name=_t"Redhead Beard 4", file="beard_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name=_t"Redhead Beard 5", file="beard_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name=_t"Dark Mustache 1", file="face_mustache_cornac_01", only_for={sex="Male"}},
        {name=_t"Dark Mustache 2", file="face_mustache_cornac_02", only_for={sex="Male"}},
        {name=_t"Blond Mustache 1", file="face_mustache_higher_01", only_for={sex="Male"}},
        {name=_t"Blond Mustache 2", file="face_mustache_higher_02", only_for={sex="Male"}},
        {name=_t"Redhead Mustache 1", file="face_mustache_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
        {name=_t"Redhead Mustache 2", file="face_mustache_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
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
