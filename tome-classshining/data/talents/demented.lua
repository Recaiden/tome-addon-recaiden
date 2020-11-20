local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = Talents.main_env.damDesc

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
   newTalentType{ allow_random=true, is_spell=true, type="demented/sunlight", name = "Sunlight", description = "Summon the true power of the Sun to burn your foes." }
   load("/data-classshining/talents/sunlight.lua")
end

if not Talents.talents_types_def["demented/inner-power"] then
   newTalentType{ allow_random=true, is_spell=true, type="demented/inner-power", name = "Inner Power", description = "Emulate the sun, becoming an all-burning furnace." }
   load("/data-classshining/talents/nuclear.lua")
end

if not Talents.talents_types_def["demented/prism"] then
   newTalentType{ allow_random=true, type="demented/prism", name = "Prism", description = "And I, only one of three", is_spell=true }
   load("/data-classshining/talents/prism.lua")
end

if not Talents.talents_types_def["demented/core-gate"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/core-gate", name = "Core Gate", min_lev = 10, description = "Shandral is but a young and timid sun.  There are far greater powers, if you know to look for them." }
   load("/data-classshining/talents/core-gate.lua")
end

if not Talents.talents_types_def["demented/incinerator"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/incinerator", name = "Incinerator", min_lev = 10, description = "There will be nothing left but ash." }
   load("/data-classshining/talents/incinerator.lua")
end
