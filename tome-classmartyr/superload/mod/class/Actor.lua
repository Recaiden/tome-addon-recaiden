local _M = loadPrevious(...)

local base_insanityEffect = _M.insanityEffect
function _M:insanityEffect(min, max)
   --game.logPlayer(self, "DEBUG Deeper Shadows generating insanity between %d%% and %d%%", self:insanityEffectForce(min), self:insanityEffectForce(max))
   local madness = base_insanityEffect(self, max, min)
   if self:knowTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS) then
      local minUp = self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getMinBonus")
      local minDown = -1 * self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getMinPenalty")
      --game.logPlayer(self, "DEBUG Deeper Shadows Check with madness %d, %d%% < x < %d%%", madness, minDown, minUp)
      -- make sure you're insane enough to trigger Deeper Shadows so we don't get caught in an infinite loop
      local canUp = minUp < self:insanityEffectForce(max)
      local canDown = minDown > self:insanityEffectForce(min)
      if not canUp and not canDown then return 0 end
      if canUp and not canDown then
         madness = rng.range(minUp, self:insanityEffectForce(max))
         --game.logPlayer(self, "DEBUG Deeper Shadows succeeded with power %d", madness)
         return madness
      elseif not canUp and canDown then
         madness = rng.range(self:insanityEffectForce(min), minDown)
         --game.logPlayer(self, "DEBUG Deeper Shadows succeeded with power %d", madness)
         return madness
      end
      local count = 0
      while madness > minDown and madness < minUp do
         --game.logPlayer(self, "DEBUG Deeper Shadows rerolling %d - try: %d", madness, count)
         madness = base_insanityEffect(self, max, min)
         count = count + 1
         if count >= 50 then return 0 end
      end
   end
   --game.logPlayer(self, "DEBUG Deeper Shadows succeeded with power %d", madness)
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
