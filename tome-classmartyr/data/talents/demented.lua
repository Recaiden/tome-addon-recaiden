local ActorTalents = require "engine.interface.ActorTalents"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

amSane = function(self)
   return self:getInsanity() <= 40
end

amInsane = function(self)
   return self:getInsanity() >= 60
end

martyr_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
martyr_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
martyr_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
martyr_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
martyr_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
martyr_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
martyr_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
martyr_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
martyr_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
martyr_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
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

martyr_mirror_req1 = {
   stat = { str=function(level) return 12 + (level-1) * 2 end },
   level = function(level) return 0 + (level-1) end,
   special = {
      desc="Cannot learn this talent directly",
      fct=function(self) return false end
   },
}

martyr_mirror_req2 = {
   stat = { str=function(level) return 20 + (level-1) * 2 end },
   level = function(level) return 4 + (level-1) end,
   special = {
      desc="Cannot learn this talent directly",
      fct=function(self) return false end
   },
}

martyr_mirror_req3 = {
   stat = { str=function(level) return 28 + (level-1) * 2 end },
   level = function(level) return 8 + (level-1) end,
   special = {
      desc="Cannot learn this talent directly",
      fct=function(self) return false end
   },
}

martyr_mirror_req4 = {
   stat = { str=function(level) return 36 + (level-1) * 2 end },
   level = function(level) return 12 + (level-1) end,
   special = {
      desc="Cannot learn this talent directly",
      fct=function(self) return false end
   },
}

archerPreUse = Talents.main_env.archerPreUse

if not Talents.talents_types_def["demented/unsettling"] then
   newTalentType{ allow_random=false, type="demented/unsettling", name = "Unsettling Words", description = "Distort your enemies' perceptions and fray their sanity.", is_mind=true }
   load("/data-classmartyr/talents/unsettling.lua")
end

if not Talents.talents_types_def["demented/whispers"] then
   newTalentType{ allow_random=false, type="demented/whispers", name = "Beinagrind Whispers", description = "Exist on the edge of madness", is_mind=true }
   load("/data-classmartyr/talents/whispers.lua")
end

if not Talents.talents_types_def["demented/polarity"] then
   newTalentType{ allow_random=false, generic=true, type="demented/polarity", name = "Polarity", description = "Dive into the madness; power comes at the price of sanity" }
   load("/data-classmartyr/talents/polarity.lua")
end

if not Talents.talents_types_def["demented/scourge"] then
   newTalentType{ allow_random=false, is_mind=true, type="demented/scourge", name = "Scourge", description = "We will fight; you are but a vessel." }
   load("/data-classmartyr/talents/scourge.lua")
end

if not Talents.talents_types_def["demented/chivalry"] then
   newTalentType{ allow_random=false, is_mind=true, type="demented/chivalry", name = "Chivalry", description = "Onward, to greater challenges, for glory!" }
   load("/data-classmartyr/talents/chivalry.lua")
end

if not Talents.talents_types_def["demented/vagabond"] then
   newTalentType{ allow_random=false, is_mind=true, type="demented/vagabond", name = "Vagabond", description = "I'm not the only one seeing this, right?" }
   load("/data-classmartyr/talents/vagabond.lua")
end