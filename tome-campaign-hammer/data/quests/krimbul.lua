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

name = "Clan of the Unicorn"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Metash has asked you to investigate the Krimbul Clan, south of the peninsula."
	desc[#desc+1] = "A whitehoof turned mad with power is trying to lead them in a war against Kruk Pride."
	desc[#desc+1] = ""
	if self:isStatus(self.DONE) then
		desc[#desc+1] = "#LIGHT_GREEN#* You have stopped the pitiful Nektosh, ensuring one less threat for the Pride and a future for the Whitehooves.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
