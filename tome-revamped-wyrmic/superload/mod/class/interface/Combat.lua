local _M = loadPrevious(...)

local base_attackTargetWith = _M.attackTargetWith
function _M:attackTargetWith(target, weapon, damtype, mult, force_dam)
   if self:knowTalent(self.T_REK_WYRMIC_ELEMENT_EXPLOIT) and target:hasEffect(target.EFF_REK_WYRMIC_ELEMENT_EXPLOIT) then
      mult = (mult or 1.0) + self:callTalent(self.T_REK_WYRMIC_ELEMENT_EXPLOIT, "getDamage")
      game:onTickEnd(
         function()
            if target then
               if target:hasEffect(target.EFF_REK_WYRMIC_ELEMENT_EXPLOIT) then
                  target:removeEffect(target.EFF_REK_WYRMIC_ELEMENT_EXPLOIT)
               end
            end 
         end)
   end
   return base_attackTargetWith(self, target, weapon, damtype, mult, force_dam)
end

return _M
