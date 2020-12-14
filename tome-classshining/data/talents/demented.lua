local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = Talents.main_env.damDesc

mag_req_slow = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)*4  end,
}
mag_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
mag_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
mag_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
mag_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
mag_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
mag_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
mag_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
mag_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
mag_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
mag_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

if not Talents.talents_types_def["demented/sunlight"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="demented/sunlight", name = "Sunlight", description = "Summon the true power of the Sun to burn your foes." }
   load("/data-classshining/talents/sunlight.lua")
end

if not Talents.talents_types_def["demented/inner-power"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="demented/inner-power", name = "Inner Power", description = "Emulate the sun, becoming an all-burning furnace." }
   load("/data-classshining/talents/nuclear.lua")
end

if not Talents.talents_types_def["demented/prism"] then
   newTalentType{ allow_random=true, no_silence=true, type="demented/prism", name = "Prism", description = "-and I, only one of three.", is_spell=true }
   load("/data-classshining/talents/prism.lua")
end

if not Talents.talents_types_def["celestial/shining-mantras"] then
	newTalentType{ allow_random=false, no_silence=true, type="celestial/shining-mantra-mantras", name = "Mantras", description = "Three truths of the sun", generic=true, is_spell=true }
	newTalentType{ allow_random=true, no_silence=true, type="celestial/shining-mantras", name = "Mantras", description = "Simple sounds spoken over and over and over.", generic=true, is_spell=true, on_mastery_change = function(self, m, tt) self.talents_types_mastery["celestial/shining-mantra-mantras"] = self.talents_types_mastery[tt] end }
	
	load("/data-classshining/talents/mantra.lua")
end

if not Talents.talents_types_def["demented/core-gate"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/core-gate", name = "Core Gate", min_lev = 10, description = "Shandral is but the nearest of countless suns.  Reach out further." }
   load("/data-classshining/talents/core-gate.lua")
end

if not Talents.talents_types_def["celestial/incinerator"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="celestial/incinerator", name = "Incinerator", min_lev = 10, description = "There will be nothing left but ash." }
   load("/data-classshining/talents/incinerator.lua")
end

if not Talents.talents_types_def["celestial/seals"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="celestial/seals", name = "Seals", min_lev = 10, description = "Bind the power of the sun into magical seals beneath your feet." }
   load("/data-classshining/talents/seals.lua")
end
