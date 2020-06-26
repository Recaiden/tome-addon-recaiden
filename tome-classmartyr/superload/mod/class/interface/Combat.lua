local _M = loadPrevious(...)
local base_combatSpellpower = _M.combatSpellpower
local base_combatMindpower = _M.combatMindpower

_M:addCombatTraining("sling", "T_REK_MTYR_VAGABOND_SLING_PRACTICE")

local base_attackTargetWith = _M.attackTargetWith
function _M:attackTargetWith(target, weapon, damtype, mult, force_dam)
   if self:hasEffect(self.EFF_REK_MTYR_MOMENT_WIELD) then
      if self:knowTalent(self.T_REK_MTYR_MOMENT_STOP) then
         local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_STOP)
         weapon = t.getFinalMoment(self, t)
      end
   end
   return base_attackTargetWith(self, target, weapon, damtype, mult, force_dam)
end 

return _M
