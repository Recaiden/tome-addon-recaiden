load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "ARMOR_STORE",
	name="Armoury",
	display='2', color=colors.UMBER,
	resolvers.store("DEMON_ARMOR", "fearscape", "store/shop_door2.png", "store/shop_sign_armory.png"),
	resolvers.chatfeature("campaign-hammer+demon-armor-store", "fearscape"),
}

newEntity{ base = "BASE_STORE", define_as = "WEAPON_STORE",
	name="Forge",
	display='3', color=colors.UMBER,
	resolvers.store("DEMON_WEAPON", "fearscape", "store/shop_door2.png", "store/shop_sign_slash_dash.png"),
	resolvers.chatfeature("campaign-hammer+demon-weapon-store", "fearscape"),
}

newEntity{ base = "BASE_STORE", define_as = "INSCRIPTION_STORE",
	name="Inscriptor",
	display='4', color=colors.LIGHT_BLUE,
	resolvers.store("DEMON_POTION", "fearscape", "store/shop_door.png", "store/shop_sign_saras_herbal_infusions.png"),
}

newEntity{ base = "BASE_STORE", define_as = "TOOL_STORE",
	name="Quartermaster",
	display='5', color=colors.UMBER,
	resolvers.store("DEMON_TOOL", "fearscape", "store/shop_door.png", "store/shop_sign_utility_store.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ARTIFACT_STORE",
	name="Spoils of War",
	display='7', color=colors.BLUE,
	resolvers.store("DEMON_TREASURE", "fearscape", "store/shop_door.png", "store/shop_sign_alchemist.png"),
}

newEntity{ base = "BASE_STORE", define_as = "JEWELRY_STORE",
	name="Gemcarver",
	display='6', color=colors.UMBER, z=17,
	resolvers.store("DEMON_JEWELRY", "fearscape", "store/shop_door.png", "store/shop_sign_rings.png"),
	--resolvers.chatfeature("jewelry-store", "fearscape"),
}
