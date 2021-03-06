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

load("/data/general/objects/objects-maj-eyal.lua")
load("/data/general/objects/mummy-wrappings.lua")

newEntity{ define_as = "CLOAK_DECEPTION",
	   power_source = {arcane=true},
	   unique = true, quest=true,
	   slot = "CLOAK",
	   type = "armor", subtype="cloak",
	   unided_name = "black cloak", image = "object/artifact/black_cloak.png",
	   moddable_tile = "cloak_%s_05", moddable_tile_hood = true,
	   name = "Cloak of Deception",
	   display = ")", color=colors.DARK_GREY,
	   encumber = 1,
	   desc = [[A black cloak, with subtle illusion enchantments woven into its very fabric.]],
	   
	   wielder = {
	      combat_spellpower = 5,
	      combat_mindpower = 5,
	      combat_dam = 5,
	   },
	   
	   on_wear = function(self, who)
	      if game.party:hasMember(who) then
		 for m, _ in pairs(game.party.members) do
		    m:setEffect(m.EFF_CLOAK_OF_DECEPTION, 1, {})
		 end
		 game.logPlayer(who, "#LIGHT_BLUE#An illusion appears around %s, making them appear human.", who.name:capitalize())
	      end
	   end,
	   on_takeoff = function(self, who)
	      if self.upgraded_cloak then return end
	      if game.party:hasMember(who) then
		 for m, _ in pairs(game.party.members) do
		    m:removeEffect(m.EFF_CLOAK_OF_DECEPTION, true, true)
		 end
		 game.logPlayer(who, "#LIGHT_BLUE#The illusionary covering %s disappears", who.name:capitalize())
	      end
	   end,
}

for i = 1, 3 do
   newEntity{ base = "BASE_LORE",
	      define_as = "NOTE"..i,
	      name = "ancient papyrus scroll", lore="mummy-crypt-ruins-note-"..i,
	      desc = [[This seems to fragments from the work of a great necromancer.]],
	      rarity = false,
   }
end
