
newBirthDescriptor{
	name = "Oozing", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "mindstars",
	power_source = {nature=true},
	stats = { cun=5 },
	talents_types = {
		["wild-gift/oozing-blades"]={true, 0.3},
		["wild-gift/mucus"]={true, 0.3},
		["wild-gift/ooze"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_OOZEBEAM] = 1,
		[ActorTalents.T_MUCUS] = 1,
		[ActorTalents.T_MITOSIS] = 1,
		[ActorTalents.T_CALL_OF_THE_OOZE] = 1,
		[ActorTalents.T_LIVING_MUCUS] = 1,
	},
	copy = {
		equipFilter_Mindstars,
	},
}
getBirthDescriptor("class", "Wilder").descriptor_choices.subclass["Oozing"] = "disallow"

newBirthDescriptor{
	name = "Slimy", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "mindstars",
	power_source = {nature=true},
	stats = { cun=5 },
	talents_types = {
		["wild-gift/slime"]={true, 0.3},
		["wild-gift/fungus"]={true, 0.3},
		["wild-gift/corrosive-blades"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SLIME_SPIT] = 1,
		[ActorTalents.T_SLIME_ROOTS] = 1,
		[ActorTalents.T_ACIDBEAM] = 1,
	},
	copy = {
		equipFilter_Mindstars,
	},
}
getBirthDescriptor("class", "Wilder").descriptor_choices.subclass["Slimy"] = "disallow"

newBirthDescriptor{
	name = "Magehunter", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {antimagic=true},
	stats = { wil=5 },
	talents_types = {
		["wild-gift/antimagic"]={true, 0.3},
		["wild-gift/eyals-fury"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_AURA_OF_SILENCE] = 1,
		[ActorTalents.T_ANTIMAGIC_SHIELD] = 1,
		[ActorTalents.T_EYAL_S_WRATH] = 1,
	},
	copy = {
	},
}
getBirthDescriptor("class", "Wilder").descriptor_choices.subclass["Magehunter"] = "disallow"
