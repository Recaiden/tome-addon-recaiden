local ActorTalents = require "engine.interface.ActorTalents"

damDesc = ActorTalents.main_env.damDesc

wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
wil_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
wil_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
wil_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
wil_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
wil_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
wil_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

if not Talents.talents_types_def["chronomancy/geosynchrony"] then
	newTalentType{ generic=true, allow_random=true, no_silence=true, is_spell=true, type="chronomancy/geosynchrony", name = "Geosynchrony", description = "Manipulate the gravitational attraction of Eyal." }
	load("/data-classgravwyrm/talents/geosynchrony.lua")
end
