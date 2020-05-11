local _M = loadPrevious(...)

function _M:insanityEffect(min, max)
   local madness = rng.range(self:insanityEffectForce(min), self:insanityEffectForce(max))
   if self:knowTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS) then
      local minUp = self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getMinBonus") * max / 50
      local minDown = self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getMinPenalty") * min / 50
      -- make sure you're insane enough to trigger Deeper Shadows so we don't get caught in an infinite loop
      if minUp < max and minDown > min then return 0 end
      while madness <= minDown or madness >= minUp do
         madness = rng.range(self:insanityEffectForce(min), self:insanityEffectForce(max))
      end
   end
   return madness
end

local base_getTalentCooldown = _M.getTalentCooldown
function _M:getTalentCooldown(t, base)
   local cd = t.cooldown or 0
   if type(cd) == "function" then cd = cd(self, t) end
   
   local eff = self:hasEffect(self.EFF_REK_MTYR_DEMENTED)
   if eff and not self:attr("talent_reuse") and not (t.fixed_cooldown or base) then
      return cd + math.ceil(cd * eff.power)
   end
   
   return base_getTalentCooldown(self, t, base)
end

return _M
