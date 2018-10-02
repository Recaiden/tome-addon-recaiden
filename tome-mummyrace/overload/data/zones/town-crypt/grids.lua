-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/water.lua")

local grass_editer = { method="borders_def", def="grass"}

newEntity{ define_as = "TOMUMMYDUNGEON",
	name = "Stairs Up",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/stair_up.png", z=8}},
	change_zone="mummy-crypt-ruins", change_level = 3, change_zone_auto_stairs = true, force_down = true,
}

newEntity { define_as = "DECO_FLOOR_MUMMY_TABLE",
	    image="terrain/marble_floor.png",
	    add_displays = {class.new{z=3, image="terrain/ruins/floor_operating_table.png", display_y=-1, display_h=2, display_w=3}},
	    name = "embalming table"}

newEntity{ define_as = "MUMMY_RITUAL",
	   image="terrain/marble_floor.png",
	   add_displays = {class.new{z=3, image="terrain/floor_pentagram.png", display_y=-1, display_h=5, display_w=5,}},
	   name = "ritual circle"}

newEntity{ define_as = "CANOPICJAR-LIVER",
	name = "Canopic Jar - Liver",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/terrain_pot_01_01_64.png", z=8}},
	does_block_move = true,
}

newEntity{ define_as = "CANOPICJAR-STOMACH",
	name = "Canopic Jar - Stomach",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/terrain_pot_01_01_64.png", z=8}},
	does_block_move = true,
}

newEntity{ define_as = "CANOPICJAR-INTESTINE",
	name = "Canopic Jar - Intestines",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/terrain_pot_01_01_64.png", z=8}},
	does_block_move = true,
}

newEntity{ define_as = "CANOPICJAR-LUNG",
	name = "Canopic Jar - Lungs",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/terrain_pot_01_01_64.png", z=8}},
	does_block_move = true,
}
