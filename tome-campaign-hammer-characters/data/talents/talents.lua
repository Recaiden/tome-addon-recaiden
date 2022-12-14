local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"
local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = Talents.main_env.damDesc

racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

-- races
if not Talents.talents_types_def["race/ruby"] then
	newTalentType{ type="race/ruby", name = "Ruby Mal'Rokka", is_spell=true, generic = true, description = "The various racial bonuses a demon child of ruby can have."}
   load("/data-campaign-hammer-characters/talents/ruby.lua")
end

if not Talents.talents_types_def["race/emerald"] then
	newTalentType{ type="race/emerald", name = "Emerald Mal'Rokka", generic = true, description = "The various racial bonuses a demon child of emerald can have."}
	load("/data-campaign-hammer-characters/talents/emerald.lua")
	load("/data-campaign-hammer-characters/talents/titan.lua")
end

if not Talents.talents_types_def["race/onyx"] then
	newTalentType{ type="race/onyx", name = "Onyx Mal'Rokka", generic = true, description = "The various racial bonuses a demon child of onyx can have."}
   load("/data-campaign-hammer-characters/talents/onyx.lua")
end

-- TODO blackhoof if EoR


mag_req_slow = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)*4  end,
}
mag_req_slow2 = {
	stat = { mag=function(level) return 20 + (level-1) * 6 end },
	level = function(level) return 4 + (level-1)*5  end,
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

-- impling class

if not Talents.talents_types_def["corruption/imp-claws"] then
	newTalentType{ allow_random=true, is_spell=true, is_unarmed = true, generic=true, type="corruption/imp-claws", name = _t("Imp Claws", "talent type"), description = "Kindle your hands with everburning flames.  Although these are spells, Flame Thrower can be used while silenced." }
	load("/data-campaign-hammer-characters/talents/imp-claws.lua")
end

if not Talents.talents_types_def["corruption/fearscape-formation"] then
	newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="corruption/fearscape-formation", name = _t("Fearscape Formation", "talent type"), description = "Burn the ground itself and everythingupon it." }
	load("/data-campaign-hammer-characters/talents/imp-fearscape-formation.lua")
end
