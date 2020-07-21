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
load("/data/general/grids/autumn_forest.lua")
load("/data/general/grids/water.lua")

local grass_editer = { method="borders_def", def="grass"}

newEntity{ base = "FLOOR", define_as = "DIRT",
	name="dirt road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{ define_as = "TOCRYPT",
	name = "Stairs down",
	display = '>', color = colors.YELLOW,
	image="terrain/maze_floor.png", add_displays = {class.new{image="terrain/stair_down.png", z=8}},
	change_zone="town-crypt", change_level = 1, change_zone_auto_stairs = true,
}
