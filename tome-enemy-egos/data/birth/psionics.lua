newBirthDescriptor{
	name = "Terror", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {psionic=true},
	stats = { wil=5 },
	talents_types = {
		["cursed/fears"]={true, 0.3},
		["cursed/gloom"]={true, 0.3},
		["cursed/punishments"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_GLOOM] = 1,
		[ActorTalents.T_SANCTUARY] = 1,
		[ActorTalents.T_INSTILL_FEAR] = 1,
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Terror"] = "disallow"

newBirthDescriptor{
	name = "Haunted", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "mindstars",
	power_source = {psionic=true},
	stats = { wil=5 },
	talents_types = {
		["cursed/force-of-will"]={true, 0.3},
		["cursed/dark-sustenance"]={true, 0.3},
		["cursed/gestures"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_WILLFUL_STRIKE] = 1,
		[ActorTalents.T_DEFLECTION] = 1,
		[ActorTalents.T_FEED] = 1,
	},
	copy = {
		equipFilter_Mindstars
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Haunted"] = "disallow"

newBirthDescriptor{
	name = "Shadowed", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {psionic=true},
	stats = { wil=5 },
	talents_types = {
		["cursed/shadows"]={true, 0.3},
		["cursed/darkness"]={true, 0.3},
		["cursed/advanced-shadowmancy"]={false, 0.3},
		["cursed/one-with-shadows"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_CALL_SHDOWS] = 1,
		[ActorTalents.T_DARK_TORRENT] = 1,
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Shadowed"] = "disallow"

newBirthDescriptor{
	name = "Stalker", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {psionic=true, technique=true},
	stats = { str=5 },
	talents_types = {
		["cursed/strife"]={true, 0.3},
		["cursed/endless-hunt"]={true, 0.3},
		["cursed/predator"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_STALK] = 1,
		[ActorTalents.T_HARASS_PREY] = 1,
		[ActorTalents.T_DOMINATE] = 1,
		[ActorTalents.T_BLINDSIDE] = 1,
	},
	copy_add = { life_rating = 2 },
}
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Stalker"] = "disallow"

newBirthDescriptor{
	name = "Maniac", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {psionic=true, technique=true},
	stats = { str=5 },
	talents_types = {
		["cursed/slaughter"]={true, 0.3},
		["cursed/rampage"]={true, 0.3},
		["cursed/predator"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_RAMPAGE] = 1,
		[ActorTalents.T_SLASH] = 1,
		[ActorTalents.T_RECKLESS_CHARGE] = 1,
		[ActorTalents.T_BRUTALITY] = 1,
	},
	copy_add = { life_rating = 2 },
}
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Maniac"] = "disallow"
