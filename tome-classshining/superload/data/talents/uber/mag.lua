local _M = loadPrevious(...)

local base_blightedSummoning_info = Talents.talents_def.T_BLIGHTED_SUMMONING.info
Talents.talents_def.T_BLIGHTED_SUMMONING.info = function(self, t)
	return ([[%s
#GOLD#Prism Reflections:#LAST# Burning Hex]]):format(base_blightedSummoning_info(self, t))
end

local doBaseSummon = Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon
Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon = function(self, t, who)
	local tlevel = 3
	local retval = true
	
	if who.is_blighted_summon or not self:knowTalent(self.T_BLIGHTED_SUMMONING) then return false end
	
	if who.is_luminous_reflection then
		who:learnTalent(who.T_BONE_SHIELD, true, 3, {no_unlearn=true})
		who:forceUseTalent(who.T_BONE_SHIELD, {ignore_energy=true})
		who:learnTalent(who.T_BURNING_HEX,true,tlevel)
		
		who.is_blighted_summon = true
		
		who:incVim(who:getMaxVim())
	else
		retval = doBaseSummon(self, t, who)
	end
	return retval
end

return _M
