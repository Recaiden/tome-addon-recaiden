local _M = loadPrevious(...)

local base_equilibriumChance = _M.equilibriumChance
function _M:equilibriumChance(eq)
	local realroll = eq
	local passed, chance = base_equilibriumChance(self, eq)
	if realroll and self.paradox_from_eq and not passed then
		self:paradoxDoAnomaly(100, math.ceil(realroll/2))--math.sqrt(self:getEquilibrium()))
	end
	return passed, chance
end

local base_incParadox = _M.incParadox
function _M:incParadox(paradox)
	self:incEquilibrium(paradox/2)
	return base_incParadox(self, paradox)
end

local Talents = require "engine.interface.ActorTalents"
local base_spacetime_tuning_callback = Talents.talents_def.T_SPACETIME_TUNING.callbackOnWait
Talents.talents_def.T_SPACETIME_TUNING.callbackOnWait = function(self, t)
	local ret = base_spacetime_tuning_callback(self, t)
	if not ret then 
		local eq = self:getEquilibrium()
		local dis = eq - self:getMinEquilibrium()
		if dis > 0 then
			local power = t.getTuning(self, t)
			local duration = math.ceil(dis/power)
			duration = math.max(1, duration)
			self:setEffect(self.EFF_SPACETIME_TUNING, duration, {power=power})
			return true
		end
	end
	return ret
end

return _M
