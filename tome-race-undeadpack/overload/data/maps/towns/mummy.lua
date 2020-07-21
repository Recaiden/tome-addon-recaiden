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

defineTile('<', "TOMUMMYDUNGEON")
defineTile('~', "DEEP_WATER")
defineTile('.', "FLOOR")
defineTile('#', "HARDWALL")
defineTile('g', "DECO_FLOOR_MUMMY_TABLE")

defineTile('a', "CANOPICJAR-LIVER")
defineTile('b', "CANOPICJAR-STOMACH")
defineTile('c', "CANOPICJAR-INTESTINE")
defineTile('d', "CANOPICJAR-LUNG")
defineTile('f', "MUMMY_RITUAL")

startx = 1
starty = 6

-- addZone section

-- ASCII map section
return [[
#############################################
#############################################
##.........................................##
##....................######...............##
##....................#abcd#...............##
##.........................................##
#<.........................................##
##.........................................##
##.........................................##
##......................fg.................##
##.........................................##
##.........................................##
##.........................................##
#############################################
#############################################]]
