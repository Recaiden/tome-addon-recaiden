local _M = loadPrevious(...)

local base_blightedSummoning_info = Talents.talents_def.T_BLIGHTED_SUMMONING.info
Talents.talents_def.T_BLIGHTED_SUMMONING.info = function(self, t)
	return ([[%s#LIGHT_BLUE#Elemental Minions:#LAST#
	- Faeros: Burning Hex
	- Shivgoroth: Corrosive Vapor
	- Gwelgoroth: Flame of Urh'rok
	- Nenagoroth: Blood Spray
	- Losgoroth: Corrupted Negation
	- Manaworm: Corrosive Manaworm
	- Teluvorta: Dark Portal]]):format(base_blightedSummoning_info(self, t))
end

local doBaseSummon = Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon
Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon = function(self, t, who)
	local tlevel = 3
	local retval = true
	
	if who.is_blighted_summon or not self:knowTalent(self.T_BLIGHTED_SUMMONING) then return false end
	
	if who.type == "elemental" then
		who:learnTalent(who.T_BONE_SHIELD, true, 3, {no_unlearn=true})
		who:forceUseTalent(who.T_BONE_SHIELD, {ignore_energy=true})
		
		who.is_blighted_summon = true
		
		if who.subtype == "fire" then
			who:learnTalent(who.T_BURNING_HEX,true,tlevel)
		elseif who.subtype == "air" then
			who:learnTalent(who.T_FLAME_OF_URH_ROK,true,tlevel)
			who:forceUseTalent(who.T_FLAME_OF_URH_ROK, {ignore_energy=true})
		elseif who.subtype == "cold" then
			who:learnTalent(who.T_WANDER_CORROSIVE_VAPOUR,true,tlevel)
		elseif who.subtype == "water" then
			who:learnTalent(who.T_BLOOD_SPRAY,true,tlevel)
		elseif who.name == "Losgoroth" then
			who:learnTalent(who.T_CORRUPTED_NEGATION,true,tlevel)
		elseif who.name == "Manaworm" then
			who:learnTalent(who.T_WANDER_BLIGHTED_MANAWORM,true,tlevel)
		elseif who.subtype == "time" then
			who:learnTalent(who.T_DARK_PORTAL,true,tlevel)
		else
			who:addTemporaryValue("all_damage_convert", DamageType.BLIGHT)
			who:addTemporaryValue("all_damage_convert_percent", 10)
			who:learnTalent(who.T_VIRULENT_DISEASE, true, 3, {no_unlearn=true})
		end
		who:incVim(who:getMaxVim())
	else
		retval = doBaseSummon(self, t, who)
	end
	return retval
end

return _M
