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

name = "Waking Up"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have been resurrected as an undead by your own dark powers.\n"
	desc[#desc+1] = "However, the ritual failed in some way.  Time has flown by and your memories are shattered. You need to find the way out of your laboratory-tomb and see if you can carve a place for yourself in this world.\n"
	if self:isCompleted("black-cloak") then
	   desc[#desc+1] = "You have retrieved a very special cloak that was made to help you walk among the living without trouble."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
      who:setQuestStatus(self.id, engine.Quest.DONE)
      who:grantQuest("start-mummy")
   end
end
