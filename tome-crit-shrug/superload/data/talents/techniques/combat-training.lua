local _M = loadPrevious(...)

Talents.talents_def.T_ARMOUR_TRAINING.passives = function(self, t, p)
   if self:hasHeavyArmor() then
      self:talentTemporaryValue(p, "ignore_direct_crits", t.getCriticalChanceReduction(self, t))
   end
end
Talents.talents_def.T_ARMOUR_TRAINING.callbackOnWear = function (self, t, o, bypass_set)
   self:updateTalentPassives(t.id)
end
Talents.talents_def.T_ARMOUR_TRAINING.callbackOnTakeoff = function (self, t, o, bypass_set)
   self:updateTalentPassives(t.id)
end

Talents.talents_def.T_ARMOUR_TRAINING.info = function(self, t)
   local hardiness = t.getArmorHardiness(self, t)
   local armor = t.getArmor(self, t)
   local criticalreduction = t.getCriticalChanceReduction(self, t)
   local classrestriction = ""
   if self.descriptor and self.descriptor.subclass == "Brawler" then
      classrestriction = "(Note that brawlers will be unable to perform many of their talents in massive armour.)"
   end
   if self:knowTalent(self.T_STEALTH) then
      classrestriction = "(Note that wearing mail or plate armour will interfere with stealth.)"
   end
   return ([[You become better at using your armour to deflect blows and protect your vital areas. With your current body armour, increases Armour value by %d, Armour hardiness by %d%%, and critical hits against you have a %d%% lower critical multiplier (but always do at least normal damage).
		(This talent only provides bonuses for heavy mail or massive plate armour.)
		At level 1, it allows you to wear heavy mail armour, gauntlets, helms, and heavy boots.
		At level 2, it allows you to wear shields.
		At level 3, it allows you to wear massive plate armour.
		%s]]):format(armor, hardiness, criticalreduction, classrestriction)
end

return _M
