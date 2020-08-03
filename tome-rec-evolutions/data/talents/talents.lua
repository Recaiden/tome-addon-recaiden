local ActorTalents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 12 + (level-1)  end,
}

if not Talents.talents_types_def["spell/shadow-destruction"] then
   newTalentType{ type="spell/shadow-destruction", name = "Shadow Destruction", is_spell=true, description = "The power to destroy the world with fire and storm is yours again!"}
   newTalentType{ type="spell/shadow-magic", name = "Shadow Magic", is_spell=true, description = "Contort space and safety, life and death."}
   load("/data-rec-evolutions/talents/destruction.lua")
   load("/data-rec-evolutions/talents/magic.lua")
   load("/data-rec-evolutions/talents/uber.lua")
end
