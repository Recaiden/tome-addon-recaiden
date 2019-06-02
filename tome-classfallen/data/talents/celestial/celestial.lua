local ActorTalents = require "engine.interface.ActorTalents"

-- Not the best way to do this, might clean up later
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

divi_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
divi_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
divi_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
divi_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
divi_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
divi_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
divi_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
divi_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
divi_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
divi_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
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


if not Talents.talents_types_def["celestial/dirges"] then
   newTalentType{ allow_random=false, no_silence=true, is_spell=true, type="celestial/dirges", name = "Dirges", description = "The songs the Fallen sing." }
end

if not Talents.talents_types_def["celestial/darkside"] then
   newTalentType{ allow_random=false, no_silence=true, is_spell=true, type="celestial/darkside", name = "Darkside", description = "Signature magics of the Fallen.  The sun shines for the guilty and the innocent alike." }
   load("/data-classfallen/talents/celestial/darkside.lua")
end

if not Talents.talents_types_def["celestial/black-sun"] then
   newTalentType{ allow_random=false, no_silence=true, is_spell=true, type="celestial/black-sun", name = "Black Sun", description = "Celestial combat techniques inspired by the dark places that are not empty." }
   load("/data-classfallen/talents/celestial/black-sun.lua")
end

if not Talents.talents_types_def["celestial/dirge"] then
   newTalentType{ allow_random=false, no_silence=true, is_spell=true, generic=true, type="celestial/dirge", name = "Dirges", description = "Sing of death and damnation" }
   load("/data-classfallen/talents/celestial/dirge.lua")
end
