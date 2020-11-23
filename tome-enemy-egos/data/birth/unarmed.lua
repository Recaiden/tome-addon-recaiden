
newBirthDescriptor{
	name = "Pugilist", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {technique=true},
	stats = { dex=3, str=3 },
	talents_types = {
		["technique/pugilism"]={true, 0.3},
		["technique/finishing-moves"]={true, 0.3},
		["technique/unarmed-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_UPPERCUT] = 1,
		[ActorTalents.T_DOUBLE_STRIKE] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_UNARMED_MASTERY] = 1,
	},
	
	copy = {
		resolvers.auto_equip_filters{-- will not try to equip weapons
																 MAINHAND = {type="none"}, OFFHAND = {type="none"}
																},
		resolvers.equipbirth{
			id=true,
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
												},
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Pugilist"] = "disallow"

newBirthDescriptor{
	name = "Grappler", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {technique=true},
	stats = { dex=3, str=3 },
	talents_types = {
		["cunning/tactical"]={true, 0.3},
		["technique/grappling"]={true, 0.3},
		["technique/unarmed-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_CLINCH] = 1,
		[ActorTalents.T_TACTICAL_EXPERT] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_UNARMED_MASTERY] = 1,
	},
	
	copy = {
		resolvers.auto_equip_filters{-- will not try to equip weapons
																 MAINHAND = {type="none"}, OFFHAND = {type="none"}
																},
		resolvers.equipbirth{
			id=true,
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
												},
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Grappler"] = "disallow"

newBirthDescriptor{
	name = "Martial Artist", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {technique=true},
	stats = { dex=3, str=3 },
	talents_types = {
		["technique/pugilism"]={true, 0.3},
		["technique/unarmed-discipline"]={false, 0.3},
		["technique/unarmed-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_BREATH_CONTROL] = 1,
		[ActorTalents.T_DOUBLE_STRIKE] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_UNARMED_MASTERY] = 1,
	},
	
	copy = {
		resolvers.auto_equip_filters{-- will not try to equip weapons
																 MAINHAND = {type="none"}, OFFHAND = {type="none"}
																},
		resolvers.equipbirth{
			id=true,
			{type="armor", subtype="hands", name="rough leather gloves", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
												},
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Martial Artist"] = "disallow"