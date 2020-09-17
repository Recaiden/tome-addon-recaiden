local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

steam_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
steam_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
steam_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
steam_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
steam_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
steam_req_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
steam_req_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
steam_req_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
steam_req_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
steam_req_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

if not Talents.talents_types_def["steamtech/explosives"] then
	newTalentType{ allow_random=true, is_steam=true, type="steamtech/explosives", name = "Explosives", description = "Tick, tick, tick, tick, tick, tick, BOOM!" }
	load("/data-classdemolisher/talents/explosives.lua")
end

if not Talents.talents_types_def["steamtech/drones"] then
	newTalentType{ allow_random=true, is_steam=true, type="steamtech/drones", name = "Drones", description = "Aiming, healing...boring.  Let the machines do it for you." }
	load("/data-classdemolisher/talents/drones.lua")
end

-- if not Talents.talents_types_def["demented/polarity"] then
--    newTalentType{ allow_random=true, is_mind=true, generic=true, type="demented/polarity", name = "Polarity", description = "Dive into the madness; power comes at the price of sanity" }
--    load("/data-classdemolisher/talents/polarity.lua")
-- end

-- for heavy guns
--newTalentType{ is_steam=true, type="inscriptions/implants", name = "implants", hide = true, description = "Steamtech directly embedded on the skin." }

-- if not Talents.talents_types_def["demented/revelation"] then
--    newTalentType{ allow_random=true, is_mind=true, type="demented/revelation", name = "Revelation", min_lev = 10, description = "You see the world as it truly is, Eyal in the Age of Scourge.  The world is horrid, but the truth has power." }
--    load("/data-classdemolisher/talents/revelation.lua")
-- end