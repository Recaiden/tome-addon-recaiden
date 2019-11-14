local _M = loadPrevious(...)

Talents.talents_def.T_GOLEM_ARMOUR.passives = function(self, t, p)
   if self:hasHeavyArmor() then
      self:talentTemporaryValue(p, "ignore_direct_crits", t.getCriticalChanceReduction(self, t))
   end
end
Talents.talents_def.T_GOLEM_ARMOUR.callbackOnWear = function (self, t, o, bypass_set)
   self:updateTalentPassives(t.id)
end
Talents.talents_def.T_GOLEM_ARMOUR.callbackOnTakeoff = function (self, t, o, bypass_set)
   self:updateTalentPassives(t.id)
end

return _M
