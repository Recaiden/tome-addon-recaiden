newBirthDescriptor{
	type = "race",
	name = "Demon",
	locked = function() return profile.mod.allow_build.race_doomelf end,
  locked_desc = [[A broken land, a father's command
Brought to the edge, all that's left is revenge]],
	desc = {
		_t"Demons are the inhabitants of the world of Mal'Rok.  With their home devastated by the Spellblaze, they  have dedicated themselves to revenge, making themselves into monsters to better wage war on all things Sher'tul.",
		_t"Demons can take many forms, from tiny animals to colossal warmachines to entities of living darkness.",
		_t"Alien to Eyal, demons generally cannot be Wilders.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
		},
		class =
		{
			Wilder = "disallow",
		},
		subclass =
		{
			Necromancer = "nolore",
			Archmage = "allow",
		},
	},
	talents = {
	},
	copy = {
		--resolvers.genericlast(function(e) e.faction = "fearscape" end),
		starting_quest = "campaign-hammer+start-demon",
		starting_intro = "doombringer", --todo write demon entry
		faction = "fearscape",
		demon = true,
		size_category = 1,
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=130}, 1),
		resolvers.inscription("RUNE:_SHATTER_AFFLICTIONS", {cooldown=18, shield=50}, 2),
		resolvers.inscription("RUNE:_BLINK", {cooldown=18, power=10, range=4,}, 3),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
	},

	cosmetic_options = {
		special = {
			{name=_t"Bikini / Mankini", birth_only=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name[birther.descriptors_by_type.sex == 'Female' and 'Bikini' or 'Mankini'] if not o then print("No bikini/mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull() actor.moddable_tile_nude = 1
				else actor:registerOnBirthForceWear(birther.descriptors_by_type.sex == 'Female' and "FUN_BIKINI" or "FUN_MANKINI") end
			end},
		},
	},
	
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor {
  type = 'subrace',
  name = 'Ruby',
  locked = function() return profile.mod.allow_build.race_doomelf end,
  locked_desc = [[A broken land, a father's command
Brought to the edge, all that's left is revenge]],
  desc = {
     "Bestial many-eyed demons, the children of Ruby are the most magically gifted of the Mal'Rokka.",
     "They flit about the battlefield raining down fire.",
     "They possess the #GOLD#Phase Step#WHITE# talent which allows them to instantly reposition, and eventually learn to conjure shadowflame.",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * -3 Strength, +1 Dexterity, +0 Constitution',
     '#LIGHT_BLUE# * +5 Magic, +0 Willpower, +1 Cunning',
     '#GOLD#Life Rating:#LIGHT_BLUE# 8',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
  moddable_attachement_spots = "race_halfling",
  descriptor_choices = {
		sex =
			{
				__ALL__ = "disallow",
				Male = "allow",
			},
	},
  inc_stats = { str = -3, dex = 1, con = 0, mag = 5, wil = 0, cun = 1 },
  experience = 1.10,
  talents_types = {
		["race/ruby"]={true, 0},
  },
  talents = {
		[ActorTalents.T_REK_RUBY_PHASE_STEP]=1,
  },
	cosmetic_options = {},
	default_cosmetics = { {"hairs", "Blond Hair 3"}, {"horns", "Demonic Horns 2"} },
  copy = {
		type = "demon", subtype="ruby",
		life_rating=8,
		moddable_tile = "halfling_male",
		moddable_tile_base = "ruby_01.png",
	} 
}

newBirthDescriptor {
  type = 'subrace',
  name = 'Emerald',
  locked = function() return profile.mod.allow_build.race_doomelf end,
  locked_desc = [[A broken land, a father's command
Brought to the edge, all that's left is revenge]],
  desc = {
     "Towering smooth-skinned demons, the children of Emerald are the most physically powerful of the Mal'Rokka.",
     "They wade into the fray, able to recover from any wound and overcome any obstacle.",
     "They possess the #GOLD#Seething Skin#WHITE# talent which allows them to instantly and sustainably heal.",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * +1 Strength, +0 Dexterity, +4 Constitution',
     '#LIGHT_BLUE# * +1 Magic, -2 Willpower, +1 Cunning',
     '#GOLD#Life Rating:#LIGHT_BLUE# 10',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
  moddable_attachement_spots = "race_yeek",
  descriptor_choices = {
		sex =
			{
	      __ALL__ = "disallow",
	      Male = "allow",
			},
	},
  inc_stats = { str = 1, con = 4, mag = 1, wil = -2, cun = 1 },
  experience = 1.10,
  talents_types = {
		["race/emerald"]={true, 0},
  },
  talents = {
		[ActorTalents.T_REK_EMERALD_SEETHING_SKIN]=1,
  },
	cosmetic_options = {
		skin = {
			{name="Ruddy Skin", file="emerald_01"},
			{name="Red Skin", file="emerald_02"},
			{name="Orange Skin", file="emerald_03"},
			{name="Brown Skin", file="emerald_04"},
			{name="Ashen Skin", file="emerald_05"},
		},
		tatoos = {
			{name="Green Whorls 1", file="whorl_01"},
			{name="Green Whorls 2", file="whorl_11"},
			{name="Green Whorls 3", file="whorl_21"},
			{name="Green Whorls 4", file="whorl_31"},
			
			{name="Red Whorls 1", file="whorl_02"},
			{name="Red Whorls 2", file="whorl_12"},
			{name="Red Whorls 3", file="whorl_22"},
			{name="Red Whorls 4", file="whorl_32"},

			{name="Pale Whorls 1", file="whorl_03"},
			{name="Pale Whorls 2", file="whorl_13"},
			{name="Pale Whorls 3", file="whorl_23"},
			
			{name="Bright Whorls 1", file="whorl_34"},
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
		}
	},
	default_cosmetics = { {"tatoos", "Green Whorls 1"}, {"skin", "Ruddy Skin"} },
  copy = {
		type = "demon", subtype="emerald",
		faction = "fearscape",
		life_rating=10,
		moddable_tile = "yeek",
		moddable_tile_base = "emerald_01.png",
	} 
}

newBirthDescriptor {
	type = 'subrace',
	name = 'Onyx',
	locked = function() return profile.mod.allow_build.race_doomelf end,
	locked_desc = [[A broken land, a father's command
Brought to the edge, all that's left is revenge]],
	desc = {
		"Strange stone-skinned demons, the children of Onyx are the most cunning of the Mal'Rokka.",
		"They excel at sudden violence.",
		"They possess the #GOLD#Impulse#WHITE# talent which allows them to speed up and break free of conditions.",
		'#GOLD#Stat modifiers:',
		'#LIGHT_BLUE# * +3 Strength, -3 Dexterity, +0 Constitution',
		'#LIGHT_BLUE# * +1 Magic, +0 Willpower, +3 Cunning',
		'#GOLD#Life Rating:#LIGHT_BLUE# 11',
		'#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
	moddable_attachement_spots = "race_runic_golem",
	descriptor_choices = {
		sex =
			{
				__ALL__ = "disallow",
				Male = "allow",
			},
	},
  inc_stats = { str = 3, dex = -3, con = 0, mag = 1, wil = 0, cun = 3 },
  experience = 1.10,
  talents_types = {
		["race/onyx"]={true, 0},
  },
  talents = {
		[ActorTalents.T_REK_ONYX_IMPULSE]=1,
  },
	cosmetic_options = {},
	default_cosmetics = { {"hairs", "Blond Hair 3"}, {"horns", "Demonic Horns 2"} },
  copy = {
		type = "demon", subtype="onyx",
		life_rating=11,
		moddable_tile = "runic_golem",
		moddable_tile_base = "onyx_01.png",
	} 
}

getBirthDescriptor("race", "Demon").descriptor_choices.subrace["Ruby"] = "allow"
getBirthDescriptor("race", "Demon").descriptor_choices.subrace["Emerald"] = "allow"
getBirthDescriptor("race", "Demon").descriptor_choices.subrace["Onyx"] = "allow"

getBirthDescriptor("world", "Demons").descriptor_choices.race.Demon = "allow"
