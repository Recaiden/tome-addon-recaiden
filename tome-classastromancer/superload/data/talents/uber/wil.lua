local _M = loadPrevious(...)

local base_MeteoricCrashTrigger = Talents.talents_def.T_METEORIC_CRASH.trigger
Talents.talents_def.T_METEORIC_CRASH.trigger = function(self, t, target)
	base_MeteoricCrashTrigger(self, t, target)
	
	if self:knowTalent(self.T_WANDER_METEOR_VOID_SUMMONS) then
		local tal_vs = self:getTalentFromId(self.T_WANDER_METEOR_VOID_SUMMONS)
		if rng.percent(50) then
			tal_vs.callLosgoroth(self, tal_vs, target.x, target.y, target)
		else
			tal_vs.callManaworm(self, tal_vs, target.x, target.y, target)
		end
	end
	return true
end

local base_MeteoricCrashInfo = Talents.talents_def.T_METEORIC_CRASH.info
Talents.talents_def.T_METEORIC_CRASH.info = function(self, t)
	local extra = ""
	if self:knowTalent(self.T_WANDER_METEOR_VOID_SUMMONS) then
		extra = [[


The meteor has a 100% chance to trigger Void Summons]]
	end
	return ([[%s%s]]):format(base_MeteoricCrashInfo(self, t), extra)
end

return _M
