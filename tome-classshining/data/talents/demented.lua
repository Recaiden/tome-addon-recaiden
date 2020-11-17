local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

-- Not the best way to do this, might clean up later
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

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
cun_req_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
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

if not Talents.talents_types_def["demented/sunlight"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/sunlight", name = "Sunlight", description = "Summon the true power of the Sun to burn your foes." }
   load("/data-classshining/talents/sunlight.lua")
end

-- if not Talents.talents_types_def["demented/vagabond"] then
--    newTalentType{ allow_random=true, is_mind=true, type="demented/vagabond", name = "Vagabond", description = "I'm not the only one seeing this, right?" }
--    load("/data-classshining/talents/vagabond.lua")
-- end

-- if not Talents.talents_types_def["demented/whispers"] then
--    newTalentType{ allow_random=true, type="demented/whispers", name = "Beinagrind Whispers", description = "Exist on the edge of madness", is_mind=true }
--    load("/data-classshining/talents/whispers.lua")
-- end

-- if not Talents.talents_types_def["demented/unsettling"] then
--    newTalentType{ allow_random=true, type="demented/unsettling", name = "Unsettling Words", description = "Distort your enemies' perceptions and fray their sanity.", is_mind=true }
--    load("/data-classshining/talents/unsettling.lua")
-- end

-- if not Talents.talents_types_def["demented/polarity"] then
--    newTalentType{ allow_random=true, is_mind=true, generic=true, type="demented/polarity", name = "Polarity", description = "Dive into the madness; power comes at the price of sanity" }
--    load("/data-classshining/talents/polarity.lua")
-- end

-- if not Talents.talents_types_def["demented/scourge"] then
--    newTalentType{ allow_random=true, is_mind=true, type="demented/scourge", name = "Scourge", description = "We will fight; you are but a vessel." }
--    load("/data-classshining/talents/scourge.lua")
-- end

-- if not Talents.talents_types_def["demented/standard-bearer"] then
--    newTalentType{ allow_random=true, is_mind=true, type="demented/standard-bearer", name = "Standard-Bearer", description = "To he who is victorious, ever more victories will flow!" }
--    load("/data-classshining/talents/standard-bearer.lua")
-- end

-- if not Talents.talents_types_def["demented/moment"] then
--    newTalentType{ allow_random=true, is_mind=true, type="demented/moment", name = "Final Moment", min_lev = 10, description = "Wield the blade of the ancient kings, and you will never be late nor lost." }
--    load("/data-classshining/talents/moment.lua")
-- end

-- if not Talents.talents_types_def["psionic/crucible"] then
--    newTalentType{ allow_random=true, is_mind=true, type="psionic/crucible", name = "Crucible", min_lev = 10, description = "Pain brings clarity.  To see clearly is painful." }
--    load("/data-classshining/talents/crucible.lua")
-- end

-- if not Talents.talents_types_def["demented/revelation"] then
--    newTalentType{ allow_random=true, is_mind=true, type="demented/revelation", name = "Revelation", min_lev = 10, description = "You see the world as it truly is, Eyal in the Age of Scourge.  The world is horrid, but the truth has power." }
--    load("/data-classshining/talents/revelation.lua")
-- end