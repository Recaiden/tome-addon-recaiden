local _M = loadPrevious(...)

local doBaseSummon = Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon

Talents.talents_def.T_BLIGHTED_SUMMONING.doBlightedSummon = function(self, t, who)
   -- test for all built-in summons
   local retval = doBaseSummon(self, t, who)

   local tlevel = self:callTalent(self.T_BLIGHTED_SUMMONING, "bonusTalentLevel")

   if retval == false and who.type == "elemental" then
      if who.name == "Faeros" then
	 who:learnTalent(who.T_BURNING_HEX,true,tlevel)
      elseif who.name == "Gwelgoroth" then
	 who:learnTalent(who.T_FLAME_OF_URH_ROK,true,tlevel)
      elseif who.name == "Shivgoroth" then
	 who:learnTalent(who.T_CORROSIVE_VAPOUR,true,tlevel)
      elseif who.name == "Losgoroth" then
	 who:learnTalent(who.T_CORRUPTED_NEGATION,true,tlevel)
      elseif who.name == "Manaworm" then
	 who:learnTalent(who.T_WORM_ROT,true,tlevel)
      elseif who.name == "Teluvorta" then
	 who:learnTalent(who.T_DARK_PORTAL,true,tlevel)
      end
      retval = true
   end
   return retval
end

return _M
