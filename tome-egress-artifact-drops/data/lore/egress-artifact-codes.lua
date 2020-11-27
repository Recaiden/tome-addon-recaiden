-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2018 Nicolas Casalini
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

local CultsDLC = require "mod.class.CultsDLC"


function displayGlyphsSequence(effect_id)
   local str = ""
   if game.state.cults_glyphs_sequences_rev[effect_id] == nil then
      return "(the sequence that used to be written here has vanished)"
   end
   for i, glyph in ipairs(CultsDLC.tableGlyphSequence(game.state.cults_glyphs_sequences_rev[effect_id])) do
      str = str..CultsDLC.getGlyphEntityString(glyph, false)
   end
   return str
end

newLore{
	id = "cults-egress-artifact-1",
	category = "Forbidden Cults", not_shareable = true,
	name = "Geometric Musings",
	lore = function() return [[(This appears to be a page from some mages's notes.  Much of it is meaningless to you, but one thing stands out.)

If my calculations are correct, the sequence ]]..displayGlyphsSequence("RANDOM_ARTIFACT1")..[[ is of cosmic significance.  Why it uses only half of the universal octagon is unclear.  Perhaps there is a secondary sequence that matches it?]] end,
}

newLore{
	id = "cults-egress-artifact-2",
	category = "Forbidden Cults", not_shareable = true,
	name = "Ranger Antress's Report",
	lore = function() return [[-we found the village abandoned, supplies taken as if everybody had embarked on a long journey.  In the village square we found rocks piled to form simple symbols. 
 ]]..displayGlyphsSequence("RANDOM_ARTIFACT2") end,
}

newLore{
	id = "cults-egress-artifact-3",
	category = "Forbidden Cults", not_shareable = true,
	name = "Strip of marked leather",
	lore = function() return [[A strip of thin leather with clasps to be worn as a bracelet, marked with a series of runes ]]..displayGlyphsSequence("RANDOM_ARTIFACT3") end,
}
