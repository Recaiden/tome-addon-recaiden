local mage_equip_filters = resolvers.auto_equip_filters{
	MAINHAND = {type="weapon", subtype="staff"},
	OFFHAND = {special=function(e, filter) -- only allow if there is a 1H weapon in MAINHAND
		local who = filter._equipping_entity
		if who then
			local mh = who:getInven(who.INVEN_MAINHAND) mh = mh and mh[1]
			if mh and (not mh.slot_forbid or not who:slotForbidCheck(e, who.INVEN_MAINHAND)) then return true end
		end
		return false
	end}
}

local copy_elemage = {
	mana_regen = 0.5,
	mana_rating = 7,
	resolvers.inscription("RUNE:_MANASURGE", {cooldown=15, dur=10, mana=820}, 3),
	mage_equip_filters,
	resolvers.equipbirth{ id=true,
												{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
												{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
	}
}

newBirthDescriptor{
	name = "Golemancer", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
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
		mage_equip_filters,
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
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/fire"]={true, 0.3},
		["spell/wildfire"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_FLAME] = 1,
	},
	
	copy = copy_elemage,
	copy_add = { life_rating = -1 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Pyromancer"] = "disallow"

newBirthDescriptor{
	name = "Cryomancer", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/ice"]={true, 0.3},
		["spell/water"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_ICE_SHARDS] = 1,
	},
	
	copy = copy_elemage,
	copy_add = { life_rating = -1 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Cryomancer"] = "disallow"

newBirthDescriptor{
	name = "Tempest", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["spell/air"]={true, 0.3},
		["spell/storm"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_LIGHTNING] = 1,
	},
	
	copy = copy_elemage,
	copy_add = { life_rating = -1 },
}
getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Tempest"] = "disallow"

-- celestial
newBirthDescriptor{
	name = "Sunmage", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["celestial/sunlight"]={true, 0.3},
		["celestial/chants"]={true, 0.3},
		["celestial/light"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_BARRIER] = 1,
	},
	
	copy = {
		mage_equip_filters,
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
													{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		}
	},
}
getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Sunmage"] = "disallow"

newBirthDescriptor{
	name = "Moonmage", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["celestial/star-fury"]={true, 0.3},
		["celestial/hymns"]={true, 0.3},
		["celestial/light"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_MOONLIGHT_RAY] = 1,
		[ActorTalents.T_BARRIER] = 1,
	},
	
	copy = {
		mage_equip_filters,
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
													{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		}
	},
}
getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Moonmage"] = "disallow"


newBirthDescriptor{
	name = "Eclipsed", type = "subclass", desc = "",
	enemy_ego_point_cost = 4,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["celestial/sunlight"]={true, 0.3},
		["celestial/star-fury"]={true, 0.3},
		["celestial/eclipse"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_MOONLIGHT_RAY] = 1,
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_CORONA] = 1,
		[ActorTalents.T_BLOOD_RED_MOON] = 1,
		[ActorTalents.T_TWILIGHT_SURGE] = 1,
		[ActorTalents.T_TWILIGHT] = 1,

	},
	
	copy = {
		mage_equip_filters,
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
													{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		}
	},
}
getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Eclipsed"] = "disallow"


newBirthDescriptor{
	name = "Starsinger", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	power_source = {arcane=true},
	stats = { mag=5 },
	talents_types = {
		["celestial/chants"]={true, 0.3},
		["celestial/hymns"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_CHANT_ACOLYTE] = 1,
		[ActorTalents.T_HYMN_ACOLYTE] = 1,
	},
	
	copy = {
	},
}
getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Starsinger"] = "disallow"

-- defilers
newBirthDescriptor{
	name = "Plaguebearer", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { cun=5 },
	talents_types = {
		["corruption/plague"]={true, 0.3},
		["corruption/blight"]={true, 0.3},
		["corruption/vim"]={true, 0.3},
		["corruption/torment"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_VIRTULENT_DISEASE] = 1,
		[ActorTalents.T_DARK_RITUAL] = 1,
		[ActorTalents.T_SOUL_ROT] = 1,
	},
	
	copy = {
		mage_equip_filters,
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
													{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		}
	},
}
getBirthDescriptor("class", "Defiler").descriptor_choices.subclass["Plaguebearer"] = "disallow"

newBirthDescriptor{
	name = "Bloodmage", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "staff",
	power_source = {arcane=true},
	stats = { cun=5 },
	talents_types = {
		["corruption/plague"]={true, 0.3},
		["corruption/blood"]={true, 0.3},
		["corruption/bone"]={true, 0.3},
		["corruption/torment"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_VIRTULENT_DISEASE] = 1,
		[ActorTalents.T_BLOOD_SPRAY] = 1,
		[ActorTalents.T_BONE_SHIELD] = 1,
	},
	
	copy = {
		mage_equip_filters,
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
													{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		}
	},
}
getBirthDescriptor("class", "Defiler").descriptor_choices.subclass["Bloodmage"] = "disallow"
