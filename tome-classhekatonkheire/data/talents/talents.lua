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

str_req_slow = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)*4  end,
}
str_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
str_req_high1 = {
	stat = { str=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
str_req_high2 = {
	stat = { str=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
str_req_high3 = {
	stat = { str=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
str_req_high4 = {
	stat = { str=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
str_req_high5 = {
	stat = { str=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

if not Talents.talents_types_def["spell/shambler"] then
   newTalentType{ allow_random=true, is_spell=true, type="spell/shambler", name = "Shambler", description = "Walk steadily forward.  Don't worry; they will come to you." }
   load("/data-classhekatonkheire/talents/shambler.lua")
end

if not Talents.talents_types_def["technique/titanic-blows"] then
   newTalentType{ allow_random=true, type="technique/titanic-blows", name = "Titanic Blows", description = "Crush your enemies with slow heavy hits." }
   load("/data-classhekatonkheire/talents/titanic.lua")
end

if not Talents.talents_types_def["technique/helping-hands"] then
   newTalentType{ allow_random=true, is_spell=true, type="technique/helping-hands", name = "Helpig Hands", description = "Many hands make light work." }
   load("/data-classhekatonkheire/talents/helping-hands.lua")
end

-- if not Talents.talents_types_def["celestial/seals"] then
--    newTalentType{ allow_random=true, is_spell=true, type="celestial/seals", name = "Seals", min_lev = 10, description = "Bind the power of the sun into magical seals beneath your feet." }
--    load("/data-classshining/talents/seals.lua")
-- end
