local _M = loadPrevious(...)

local doBaseSummon = Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon

Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon = function(self, t, who)
  
   local tlevel = 3
   local retval = true

   if who.is_blighted_summon or not self:knowTalent(self.T_BLIGHTED_SUMMONING) then return false end
   
   if who.type == "elemental" then
      who:learnTalent(who.T_BONE_SHIELD, true, 3, {no_unlearn=true})
      who:forceUseTalent(who.T_BONE_SHIELD, {ignore_energy=true})

      who:incVim(who:getMaxVim())
      who.is_blighted_summon = true
      
      if who.name == "Faeros" then
	 who:learnTalent(who.T_BURNING_HEX,true,tlevel)
      elseif who.name == "Gwelgoroth" then
	 who:learnTalent(who.T_FLAME_OF_URH_ROK,true,tlevel)
      elseif who.name == "Shivgoroth" then
	 who:learnTalent(who.T_CORROSIVE_VAPOUR,true,tlevel)
      elseif who.name == "Losgoroth" then
	 who:learnTalent(who.T_CORRUPTED_NEGATION,true,tlevel)
      elseif who.name == "Manaworm" then
	 who:learnTalent(who.T_CORROSIVE_WORM,true,tlevel)
      elseif who.name == "Teluvorta" then
	 who:learnTalent(who.T_DARK_PORTAL,true,tlevel)
      else
         who:addTemporaryValue("all_damage_convert", DamageType.BLIGHT)
         who:addTemporaryValue("all_damage_convert_percent", 10)
         who:learnTalent(who.T_VIRULENT_DISEASE, true, 3, {no_unlearn=true})
      end  
   else
      retval = doBaseSummon(self, t, who)
   end
   return retval
end

return _M
