newBirthDescriptor{
	name = "Golemancer", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/golemancy"]={true, 0.3},
		["spell/advanced-golemancy"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_REFIT_GOLEM] = 1,
		[ActorTalents.T_CREATE_ALCHEMIST_GEMS] = 1,
		[ActorTalents.T_CHANNEL_STAFF] = 1,
	},
	
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=15, dur=10, mana=820}, 3),
		resolvers.auto_equip_filters{QUIVER = {type="alchemist-gem"}},
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = { life_rating = 2 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Golemancer"] = "disallow"

newBirthDescriptor{
	name = "Pyromancer", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/fire"]={true, 0.3},
		["spell/wildfire"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_FLAME] = 1,
	},
	
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=15, dur=10, mana=820}, 3),
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = { life_rating = -1 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Pyromancer"] = "disallow"

newBirthDescriptor{
	name = "Cryomancer", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/ice"]={true, 0.3},
		["spell/water"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_ICE_SHARDS] = 1,
	},
	
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=15, dur=10, mana=820}, 3),
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = { life_rating = -1 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Cryomancer"] = "disallow"

newBirthDescriptor{
	name = "Tempest", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/air"]={true, 0.3},
		["spell/storm"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_LIGHTNING] = 1,
	},
	
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=15, dur=10, mana=820}, 3),
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = { life_rating = -1 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Tempest"] = "disallow"
