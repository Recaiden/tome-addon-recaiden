--------------------------------------------------------------------------------
-- Zones
--------------------------------------------------------------------------------

newEntity{
	base="CHARRED_SCAR", define_as = "TOWN_FEARSCAPE",
	name = "Return to the Fearscape",
	--add_displays = {class.new{z=7, image="terrain/worldmap/worldmap.png"}},
	add_displays = {
		class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
		class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
	},
	desc = "A portal back to your home",
	change_zone="campaign-hammer+town-fearscape",
	change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true,
}

newEntity{
	base="ZONE_PLAINS", define_as = "BURIED_KINGDOM",
	name="Tunnel into the sands",
	color={r=200, g=255, b=55},
	add_mos={{image="terrain/ladder_down.png"}},
	change_zone="campaign-hammer+buried-kingdom",
}

newEntity{
	base="ZONE_PLAINS", define_as = "DAIKARA_HIDEOUT",
	name="Pass into the mountains",
	color=colors.WHITE,
	add_displays={mod.class.Grid.new{image="terrain/road_upwards_01.png", display_h=2, display_y=-1}},
	change_zone="campaign-hammer+daikara-hideout",
}

newEntity{ base="ZONE_PLAINS", define_as = "DERTH_INVASION",
	name="Town of Derth",  add_mos = {{image="terrain/village_01.png"}},
	desc = _t"A quiet town at the crossroads of the north",
	change_zone="campaign-hammer+derth-invasion",
}

newEntity{ base="CHARRED_SCAR", define_as = "DERTHFIELDS_LANDING_SITE",
	name="Landing Site",
	color={r=0, g=255, b=0},
	add_displays={class.new{image="terrain/road_going_right_01.png", display_w=2}},
	change_zone="campaign-hammer+derthfields-landing-site",
	change_level=3, force_down = true, glow=true, display='>', color=colors.VIOLET, notice = true,
}

newEntity{ base="ZONE_PLAINS", define_as = "FIELDS_OF_HOPE",
	name="Last Hope", add_displays = {class.new{image="terrain/last_hope.png", display_w=2, display_x=-0.5, z=5}, class.new{image="terrain/last_hope_up.png", display_w=2, display_x=-0.5, display_h=2, display_y=-2, z=16}},
	desc = _t"Capital city of the Allied Kingdoms ruled by King Tolak",
	change_level_check = function()
		local p = game.party:findMember{main=true}
		if p:hasQuest("campaign-hammer+demon-ruins") and p:isQuestStatus("campaign-hammer+demon-ruins", engine.Quest.DONE) then
			return false
		else
			game.log("There is no way you could get through the patrols, guards, and walls of the kingdom's capital.")
			return true
		end
		return false
	end,
	change_zone="campaign-hammer+fields-of-hope",
}

newEntity{
	base="ZONE_PLAINS", define_as = "LAKE_OF_NUR",
	name="Path to the Lake",
	color={r=0, g=180, b=0},
	add_displays={class.new{image="terrain/road_going_right_01.png", display_w=2}},
	change_zone="campaign-hammer+lake-of-nur",
}

newEntity{
	base="ZONE_PLAINS", define_as = "SCINTILLATING_CAVERNS",
	name="Scintillating Cave",
	color={r=0, g=255, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="campaign-hammer+scintillating-caverns",
}
