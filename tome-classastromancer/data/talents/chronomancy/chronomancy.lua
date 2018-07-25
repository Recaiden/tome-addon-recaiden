-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local ActorTalents = require "engine.interface.ActorTalents"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

-- Generic requires for spells based on talent level
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
spells_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

if not Talents.talents_types_def["celestial/ponx"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/ponx", name = "Ponx", description = "Celestial spellcasting drawn from the whirling gas giant Ponx on the middle reaches of the solar system." }
   load("/data-classastromancer/talents/celestial/ponx.lua")
end

if not Talents.talents_types_def["celestial/luxam"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/luxam", name = "Luxam", description = "Celestial spellcasting drawn from the icy world of Luxam in the dark depths of space." }
   load("/data-classastromancer/talents/celestial/luxam.lua")
end

if not Talents.talents_types_def["celestial/kolal"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/kolal", name = "Kolal", description = "Celestial spellcasting drawn from Eyal's nearest neighbor, the fiery wasteland of Kolal." }
   load("/data-classastromancer/talents/celestial/kolal.lua")
end

if not Talents.talents_types_def["celestial/unity"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/terrestrial_unity", name = "Terrestrial Unity", description = "Celestial augmentations based on keeping the planets in harmonious balance." }
   load("/data-classastromancer/talents/celestial/unity.lua")
end

if not Talents.talents_types_def["celestial/meteor"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/meteor", name = "Meteor", description = "Celestial combat magic that calls down meteors from above." }
   load("/data-classastromancer/talents/celestial/meteor.lua")
end

-- if not Talents.talents_types_def["celestial/comet"] then
--    newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/comet", name = "Comet", description = "The approach of a comet to Shandral always heralds great changes." }
--    load("/data-classastromancer/talents/celestial/comet.lua")
-- end
