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
	level = function(level) return 8 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

mummy_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
mummy_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
mummy_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
mummy_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
mummy_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

high_undeads_req1 = { level = function(level) return 25 + (level-1)  end }
high_undeads_req2 = { level = function(level) return 28 + (level-1)  end }
high_undeads_req3 = { level = function(level) return 30 + (level-1)  end }
high_undeads_req4 = { level = function(level) return 32 + (level-1)  end }

dreads_req1 = { level = function(level) return 20 + (level-1)  end }
dreads_req2 = { level = function(level) return 24 + (level-1)  end }
dreads_req3 = { level = function(level) return 28 + (level-1)  end }
dreads_req4 = { level = function(level) return 32 + (level-1)  end }

if not Talents.talents_types_def["undead/banshee"] then
   newTalentType{ type="undead/banshee", name = "banshee", is_spell=true, generic = true, description = "The various racial bonuses an undead banshee character can have."}
   load("/data-race-undeadpack/talents/banshee.lua")
end

if not Talents.talents_types_def["undead/wight"] then
   newTalentType{ type="undead/wight", name = "wight", is_spell=true, generic = true, description = "The various racial bonuses an undead wight character can have."}
   load("/data-race-undeadpack/talents/wight.lua")
end

if not Talents.talents_types_def["undead/mummy"] then
   newTalentType{ type="undead/mummy", name = "mummy", is_spell=true, generic = true, description = "The various racial bonuses a mummified undead character can have."}
newTalentType{ type="undead/mummified", name = "mummified", is_spell=true, generic = true, description = "The special bonuses owed to preserved body parts."}
   load("/data-race-undeadpack/talents/mummy.lua")
end

if not Talents.talents_types_def["undead/dreadlord"] then
   newTalentType{ type="undead/dreadlord", name = "dreadlord", is_spell=true, generic = true, description = "The various racial bonuses a dark spirit can have."}
   newTalentType{ type="undead/dreadmaster", name = "dreadmaster", is_spell=true, description = "Summon undead minions of pure darkness to harass your foes."}
   load("/data-race-undeadpack/talents/dreadlord.lua")
   load("/data-race-undeadpack/talents/uber.lua")
end
