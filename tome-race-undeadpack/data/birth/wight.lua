newBirthDescriptor {
  type = 'subrace',
  name = 'Wight',
  locked = function()
		if profile.mod.allow_build.undead_wight then return true end
		if profile.mod and profile.mod.achievements and profile.mod.achievements.EVENT_OLDBATTLEFIELD then
			profile.mod.allow_build.undead_wight = true
			return true
		end
		return false
  end,
  locked_desc = _t"In forests dark the dead still sleep, waiting for one to dig too deep.",
  desc = {
		_t"Wights are undead that arise spontaneously in places of great slaughter.",
		_t"They have access to #GOLD#special undead talents#WHITE#:",
		_t"- poison, bleeding, and fear immunity",
		_t"- elemental blasts",
		_t"- draining aura",
		_t"- use infusion while undead",
		_t"- teleport through walls",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, +5 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 11",
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# +15%"},
	moddable_attachement_spots = "race_human",
	cosmetic_options = {
		skin = {
			{name=_t"Bright Spectral Skin", file="wight_hollow_bright"},
			{name=_t"Crimson Spectral Skin", file="wight_hollow_crimson"},
			{name=_t"Violet Spectral Skin", file="wight_hollow_purple"},
			{name=_t"Demonic Spectral Skin", file="wight_hollow_demonic", unlock="cosmetic_red_skin"}
		},
		hairs = {
			{name=_t"Hair 1", file="wight_hair_01"},
			{name=_t"Hair 2", file="wight_hair_02"},
			{name=_t"Hair 3", file="wight_hair_03"},
			{name=_t"Hair 4", file="wight_hair_04", only_for={sex="Female"}},
			{name=_t"Hair 5", file="wight_hair_05", only_for={sex="Female"}},
			{name=_t"Hair 6", file="wight_hair_06", only_for={sex="Female"}},
			{name=_t"Redhead 1", file="wight_hair_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead 2", file="wight_hair_redhead_02", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead 3", file="wight_hair_redhead_03", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead 4", file="wight_hair_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
			{name=_t"Redhead 5", file="wight_hair_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
			{name=_t"Redhead 6", file="wight_hair_redhead_06", unlock="cosmetic_race_human_redhead", only_for={sex="Female"}},
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
			{name=_t"Beard 1", file="wight_beard_01", only_for={sex="Male"}},
			{name=_t"Beard 2", file="wight_beard_02", only_for={sex="Male"}},
			{name=_t"Beard 3", file="wight_beard_03", only_for={sex="Male"}},
			{name=_t"Beard 4", file="wight_beard_04", only_for={sex="Male"}},
			{name=_t"Beard 5", file="wight_beard_05", only_for={sex="Male"}},
			{name=_t"Redhead Beard 1", file="wight_beard_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Redhead Beard 2", file="wight_beard_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Redhead Beard 3", file="wight_beard_redhead_03", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Redhead Beard 4", file="wight_beard_redhead_04", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Redhead Beard 5", file="wight_beard_redhead_05", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Mustache 1", file="wight_face_mustache_01", only_for={sex="Male"}},
			{name=_t"Mustache 2", file="wight_face_mustache_02", only_for={sex="Male"}},
			{name=_t"Redhead Mustache 1", file="wight_face_mustache_redhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Redhead Mustache 2", file="wight_face_mustache_redhead_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
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

local orcs_def = getBirthDescriptor("world", "Orcs")
if orcs_def then
   local old_start = orcs_def.copy.before_starting_zone
   getBirthDescriptor("race", "MinotaurUndead").descriptor_choices.subrace['Wight'] = "allow"
   
   local function new_start(self)
      if self.descriptor.subrace == "Wight" then
         self.faction = 'free-whitehooves'

         self.default_wilderness = {"playerpop", "yeti"}
         self.starting_zone = "orcs+vaporous-emporium"
         self.starting_quest = "orcs+start-orc"
         self.starting_intro = "orcs-wight"
				 self.starting_level_force_down = nil
      end
      if old_start then old_start(self) end
   end
   
   orcs_def.copy.before_starting_zone = new_start
end
