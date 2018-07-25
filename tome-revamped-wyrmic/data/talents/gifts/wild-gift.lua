local ActorTalents = require "engine.interface.ActorTalents"

damDesc = Talents.damDesc

gifts_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
gifts_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
gifts_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
gifts_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
gifts_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
gifts_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
gifts_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
gifts_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
gifts_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
gifts_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

color_req_1 = {
   stat = { wil=function(level) return 10 + (level-1) * 10 end },
   level = function(level) return 0 + (level-1) * 6 end,
}

aspect_req_1 = {
   stat = { wil=function(level) return 10 + (level-1) * 4 end },
   level = function(level) return 0 + (level-1) * 3 end,
}

function aspectIsActive(self, name)
   local possibles = self.rek_wyrmic_dragon_type or {}

   for k, element in pairs(possibles) do
      if element.name == name then
	 return true
      end
   end
   return false
end

if not Talents.talents_types_def["demented/wyrmic"] then
   newTalentType{ allow_random=false, is_spell=true, no_silence=true,
		  type="demented/wyrmic",
		  name = "Tentacle Dragon",
		  description = "Wyrmic techniques used when infested with otherworldly tentacles" }
end

if not Talents.talents_types_def["wild-gift/draconic-energy"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-energy",
		  name = "Draconic Energy",
		  description = "Fire breath, freezing claws - strike with the elemental power of a dragon." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-energy.lua")
end

if not Talents.talents_types_def["wild-gift/draconic-combat"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-combat",
		  name = "Draconic Combat",
		  description = "Fight like a dragon, with fang and claw." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-combat.lua")
end

if not Talents.talents_types_def["wild-gift/draconic-body"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-body",
		  name = "Draconic Body",
		  description = "Scales and heart, the strength of the dragons." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-body.lua")
end

if not Talents.talents_types_def["wild-gift/draconic-aspects"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-aspects",
		  name = "Dragon Aspects",
		  description = "Fire, Ice, Storm, Acid, Venom, and Sand." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-aspects.lua")
end

if not Talents.talents_types_def["wild-gift/prismatic-dragon"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/prismatic-dragon", name = "Prismatic Aspect", min_lev = 10, description = "Take on the power of the mighty multi-hued wyrms." }
   load("/data-revamped-wyrmic/talents/gifts/prismatic.lua")
end
