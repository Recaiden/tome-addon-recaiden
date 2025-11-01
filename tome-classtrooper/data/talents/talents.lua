local ActorTalents = require "engine.interface.ActorTalents"

archery_range = ActorTalents.main_env.archery_range

damDesc = Talents.main_env.damDesc

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
mastery_cun_req = {
	stat = { cun=function(level) return 10 + (level-1) * 6 end },
	level = function(level) return 0 + (level-1)  end,
}
cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cun_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
cun_req_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cun_req_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cun_req_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cun_req_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

newTalent{
	name = "Battery Pool",
	type = {"base/class", 1},
	info = "Allows you to use carbine talents.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
	passives = function(self, t, p)
	end,
}

if not Talents.talents_types_def["occultech/carbine"] then
	newTalentType{ allow_random=true, type="occultech/carbine", name = "Carbine", description = "Light-based technological attacks." }
	load("/data-classtrooper/talents/carbine.lua")
end

if not Talents.talents_types_def["occultech/voidsuit"] then
	newTalentType{ allow_random=true, type="occultech/voidsuit", name = "Voidsuit", description = "Electro-technical defenses." }
	load("/data-classtrooper/talents/voidsuit.lua")
end

if not Talents.talents_types_def["technique/trooper"] then
	newTalentType{ allow_random=true, type="technique/trooper", name = "Trooper", description = "Tough-earned combat techniques." }
	load("/data-classtrooper/talents/trooper.lua")
end


-- if not Talents.talents_types_def["technique/psychic-shots"] then
-- 	newTalentType{ allow_random=true, is_mind=true, type="technique/psychic-shots", name = "Psychic Shots", description = "Special Psi-aimed archery techniques" }
-- 	load("/data-classtrooper/talents/psychic-shots.lua")
-- end

-- if not Talents.talents_types_def["psionic/idol"] then
-- 	newTalentType{ allow_random=true, is_mind=true, type="psionic/idol", name = "Idol", description = "You're the best, and deep down everyone knows it." }
-- 	load("/data-classtrooper/talents/idol.lua")
-- end

-- if not Talents.talents_types_def["psionic/noumena"] then
-- 	newTalentType{ allow_random=true, is_mind=true, type="psionic/noumena", name = "Noumena", description = "Sometimes things happen that don't belong here.  Things that no one can explain." }
-- 	load("/data-classtrooper/talents/noumena.lua")
-- end

-- if not Talents.talents_types_def["psionic/mindshaped-material"] then
-- 	newTalentType{ allow_random=true, is_mind=true, generic = true, type="psionic/mindshaped-material", name = "Mindshaped Materials", description = "Manipulate the battlefield with minutely mind-molded matter." }
-- 	load("/data-classtrooper/talents/material.lua")
-- end

-- if not Talents.talents_types_def["psionic/mindprison"] then
-- 	newTalentType{ allow_random=true, is_mind=true, generic = true, type="psionic/mindprison", name = "Mindprison", description = "You are vast; you can contain multitudes." }
-- 	load("/data-classtrooper/talents/mindprison.lua")
-- end

-- if not Talents.talents_types_def["psionic/unleash-abomination"] then
-- 	newTalentType{ allow_random=true, is_mind=true, min_lev = 10, type="psionic/unleash-abomination", name = "Unleash Abomination", description = "Let the source of your power act more freely." }
-- 	load("/data-classtrooper/talents/abomination.lua")
-- end

-- if not Talents.talents_types_def["psionic/unleash-nightmare"] then
-- 	newTalentType{ allow_random=true, is_mind=true, min_lev = 10, type="psionic/unleash-nightmare", name = "Unleash Nightmare", description = "Let the source of your power awaken." }
-- 	load("/data-classtrooper/talents/nightmare.lua")
-- end

-- if not Talents.talents_types_def["technique/arrowstorm"] then
-- 	newTalentType{ allow_random=true, is_mind=true, min_lev = 10, type="technique/arrowstorm", name = "Arrowstorm", description = "Let the winds of beyond carry your quarrels - and remember, killing should be done up close and personal." }
-- 	load("/data-classtrooper/talents/arrowstorm.lua")
-- end

-- if not Talents.talents_def["REK_EVOLUTION_GLR_STORM"] then
-- 	load("/data-classtrooper/talents/uber.lua")
-- end
