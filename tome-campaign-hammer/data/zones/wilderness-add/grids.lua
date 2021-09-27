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
	base="ZONE_DESERT", define_as = "BURIED_KINGDOM",
	name="Tunnel into the sands",
	color={r=200, g=255, b=55},
	add_mos={{image="terrain/ladder_down.png"}},
	change_zone="campaign-hammer+buried-kingdom",
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
			require("engine.ui.Dialog"):yesnoLongPopup(
				_t"The Final Battle",
				_t"Honestly, you are not prepared to get through the patrols, guards, and walls of the kingdom's capital.  But you could try.", 400,
				function(ret)
					if ret then
						game:changeLevel(1, "campaign-hammer+fields-of-hope")
					end
			end)
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

-- TODO hide these until the right time.
newEntity{
	
}

newEntity{
	base="ZONE_PLAINS", define_as = "SHELLSEA_HIDEOUT",
	name="Road to a flooded city",
	color=colors.WHITE,
	add_displays={class.new{image="terrain/underwater/subsea_cave_entrance_01.png", z=4, display_h=2, display_y=-1}},
	change_zone="campaign-hammer+shellsea-hideout",
}

newEntity{
	base="ZONE_PLAINS", define_as = "ANGOLWEN_BATTLE",
	name = "Demonic Teleportation Gate - Attack on Angolwen",
	add_displays = {
		class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
		class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
	},
	desc = "From their base here, the demons hold back the wizards of Angolwen.",
	change_level_check = function()
		local p = game.party:findMember{main=true}
		if p:hasQuest("campaign-hammer+demon-main") and p:isQuestStatus("campaign-hammer+demon-main", engine.Quest.DONE) then
			return false
		else
			game.log("If you went in here now, you would die instantly and uselessly.  Defeat all other threats first.")
			return true
		end
		return false
	end,
	change_zone="campaign-hammer+angolwen",
	change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true,
}

newEntity{
	define_as = "INFINITE_SHORTCUT",
	name = "way into the infinite dungeon", image = "terrain/maze_floor.png", add_mos={{image = "terrain/stair_down.png"}},
	display = '>', color=colors.VIOLET, back_color=colors.DARK_GREY,
	always_remember = true,
	on_move = function(self, x, y, who)
		if not who.player then return end
		local p = game:getPlayer(true)
		if p.winner then
			require("engine.ui.Dialog"):yesnoLongPopup(
				_t"Infinite Dungeon",
				_t"The stairway to the infinite dungeon is a one-way trip. If you proceed, there is no way back. But there is a sher'tul down there, and someone, someday, is going to have to track him down and kill him.  Will it be you?", 400,
				function(ret)
					if ret then
						game.player.max_level = nil
						game.player.no_points_on_levelup = function(self)
							self.unused_stats = self.unused_stats + 1
							if self.level % 2 == 0 then
								self.unused_talents = self.unused_talents + 1
							elseif self.level % 3 == 0 then
								self.unused_generics = self.unused_generics + 1
							end
						end,
						game:changeLevel(math.ceil(game.player.level * 1.5), "infinite-dungeon")
					end
			end)
		else
			require("engine.ui.Dialog"):simplePopup(_t"Infinite Dungeon", _t"You should not go there. There is no way back. Ever. Maybe later when you have done all you must do.")
		end
	end,
}
