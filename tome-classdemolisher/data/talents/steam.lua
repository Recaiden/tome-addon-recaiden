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

steam_req_mastery = {
	stat = { cun=function(level) return 12 + (level-1) * 6 end },
	level = function(level) return 0 + (level-1)  end,
}
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
	newTalentType{ allow_random=true, is_steam=true, type="steamtech/explosives", name = _t"Explosives", description = _t"Tick, tick, tick, tick, tick, tick, BOOM!" }
	load("/data-classdemolisher/talents/explosives.lua")
end

if not Talents.talents_types_def["steamtech/drones"] then
	newTalentType{ allow_random=true, is_steam=true, type="steamtech/drones", name = _t"Drones", description = _t"Aiming, dodging...boring.  Let the machines do it for you." }
	load("/data-classdemolisher/talents/drones.lua")
end

if not Talents.talents_types_def["steamtech/pilot"] then
	newTalentType{ allow_random=true, is_steam=true, type="steamtech/pilot", name = _t"Piloting", description = _t"Fight from behind the wheel." }
	load("/data-classdemolisher/talents/pilot.lua")
end

if not Talents.talents_types_def["steamtech/demo-engine"] then
	newTalentType{ allow_random=true, is_steam=true, type="steamtech/demo-engine", name = _t"Engine", description = _t"There's no point in any machine that does not go fast." }
	load("/data-classdemolisher/talents/engine.lua")
end

if not Talents.talents_types_def["steamtech/battlewagon"] then
   newTalentType{ allow_random=true, is_steam=true, type="steamtech/battlewagon", name = _t"Battlewagon", min_lev = 10, description = _t"Blast and trample enemies with your war machine." }
   load("/data-classdemolisher/talents/battlewagon.lua")
	 newTalentType{ allow_random=false, is_steam=true, type="steamtech/battlewagon-guns", hide=true, name = _t"Main Guns", min_lev = 10, description = _t"Armament used by demolisher wagons" }
	 load("/data-classdemolisher/talents/main_guns.lua")
end

if not Talents.talents_types_def["steamtech/pyromaniac"] then
   newTalentType{ allow_random=true, is_steam=true, type="steamtech/pyromaniac", name = _t"Pyromaniac", min_lev = 10, description = _t"Water, air, and earth are all the same. But fire is a true wonder." }
   load("/data-classdemolisher/talents/pyromaniac.lua")
end

updateSteelRider = function(self)
	if not self:hasEffect(self.EFF_REK_DEML_RIDE) then return end
	local pin = 0
	local knock = 0
	local armor = 0
	local speed = 0
	local def = 0
	if self:knowTalent(self.T_REK_DEML_PILOT_AUTOMOTOR) then
		pin = self:callTalent(self.T_REK_DEML_PILOT_AUTOMOTOR, "getPinImmune")
	end
	if self:knowTalent(self.T_REK_DEML_PILOT_PATCH) then
		armor = self:callTalent(self.T_REK_DEML_PILOT_PATCH, "getArmor")
	end
	if self:knowTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
		speed = self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "getMovement")
	end
	if self:knowTalent(self.T_REK_EVOLUTION_DEML_RAM) then
		speed = speed + self:callTalent(self.T_REK_EVOLUTION_DEML_RAM, "getMovement")
	end	
	if self:knowTalent(self.T_REK_DEML_ENGINE_DRIFT_NOZZLES) then
		def = self:callTalent(self.T_REK_DEML_ENGINE_DRIFT_NOZZLES, "getDefense")
	end
	if self:knowTalent(self.T_REK_DEML_BATTLEWAGON_HEAVY) then
		knock = self:callTalent(self.T_REK_DEML_BATTLEWAGON_HEAVY, "getKnockImmune")
	end
	self:setEffect(self.EFF_REK_DEML_RIDE, 10, {src=self, pin=pin, armor=armor, speed=speed, def=def, knock=knock})
	game:playSoundNear(self, "talents/clinking")
end


if not Talents.talents_def["REK_EVOLUTION_DEML_DRONE"] then
	load("/data-classdemolisher/talents/uber.lua")
end
