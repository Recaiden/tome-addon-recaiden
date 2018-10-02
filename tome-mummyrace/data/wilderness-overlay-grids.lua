-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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


local p = game.party:findMember{main=true}
-- Mummies skip down to the bottom, others enter at the top
if p.descriptor and p.descriptor.race and p.descriptor.subrace == "Mummy"
then
   newEntity{
   base="ZONE_PLAINS", define_as = "MUMMY_CRYPT",
   name="Entrance to a half-buried pyramid",
   color=colors.GREY,
   add_displays = {class.new{image="terrain/mummy_pyramid.png", z=8, display_h=1, display_y=0}},
   change_zone = "town-crypt",
}
else
   newEntity{
   base="ZONE_PLAINS", define_as = "MUMMY_CRYPT",
   name="Entrance to a half-buried pyramid",
   color=colors.GREY,
   add_displays = {class.new{image="terrain/mummy_pyramid.png", z=8, display_h=1, display_y=0}},
   change_zone = "mummy-crypt-ruins",
}
end
