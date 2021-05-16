--------------------------------------------------------------------------------
-- Zones
--------------------------------------------------------------------------------

newEntity{ base="TOWN", define_as = "TOWN_FEARSCAPE",
	name = "Return to the Fearscape", add_displays = {class.new{z=7, image="terrain/worldmap/worldmap.png"}},
	desc = "A portal back to your home",
	change_zone="campaign-hammer+town-fearscape",
}

newEntity{ base="ZONE_PLAINS", define_as = "BURIED_KINGDOM",
	name="Tunnel into the sands",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+buried-kingdom",
}

newEntity{ base="ZONE_PLAINS", define_as = "DAIKARA_HIDEOUT",
	name="Pass into the mountains",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+daikara-hideout",
}

newEntity{ base="ZONE_PLAINS", define_as = "DERTH_INVASION",
	name="City of Derth",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+derth-invasion",
}

newEntity{ base="ZONE_PLAINS", define_as = "DERTHFIELDS_LANDING_SITE",
	name="Landing Site",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+landing-site",
}

newEntity{ base="ZONE_PLAINS", define_as = "FIELDS_OF_HOPE",
	name="Fields of Hope",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+fields-of-hope",
}

newEntity{ base="ZONE_PLAINS", define_as = "LAKE_OF_NUR",
	name="Path to the Lake",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+lake-of-nur",
}

newEntity{ base="ZONE_PLAINS", define_as = "SCINTILLATING_CAVERNS",
	name="Scintillating Cave",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+scintillating-caverns",
}
