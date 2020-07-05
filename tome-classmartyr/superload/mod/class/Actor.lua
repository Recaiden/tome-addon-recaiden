local _M = loadPrevious(...)


local base_incInsanity = _M.incInsanity
function _M:incInsanity(amount, no_enemy_check)
   -- if self:knowTalent(self.T_REK_MTYR_WHISPERS_SLIPPING_PSYCHE) then
   --    game.logPlayer(self, "DEBUG insanity alter %s + %s", self.insanity, amount)
   --    if self.insanity > 40 and self.insanity+amount < 40 then
   --       self:callTalent(self.T_REK_MTYR_WHISPERS_SLIPPING_PSYCHE, "doRevealTentacles")
   --    end
   -- end
   base_incInsanity(self, amount, no_enemy_check)
   if self:knowTalent(self.T_REK_MTYR_MOMENT_STOP) then
      if self.insanity == self:getMaxInsanity() then
         local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_STOP)
         t.doStop(self, t)
      end
   end
end

local base_incFeedback = _M.incFeedback
function _M:incFeedback(v, set)
   if not set and self:knowTalent(self.T_REK_MTYR_CRUCIBLE_OVERFLOW) then
      local t = self:getTalentFromId(self.T_REK_MTYR_CRUCIBLE_OVERFLOW)
      local consumed = 0
      local overcharge = math.floor((v + self:getFeedback() - self:getMaxFeedback()))
      if overcharge > 0 then
         local cost = self:callTalent(self.T_REK_MTYR_CRUCIBLE_OVERFLOW, "getEfficiency")
         local t1 = self:getTalentFromId(self.T_REK_MTYR_CRUCIBLE_SHARE_PAIN)
         local t2 = self:getTalentFromId(self.T_REK_MTYR_CRUCIBLE_MEMENTO)
         local t3 = self:getTalentFromId(self.T_REK_MTYR_CRUCIBLE_RESONATION)
         local talents = {
            self.T_REK_MTYR_CRUCIBLE_SHARE_PAIN,
            self.T_REK_MTYR_CRUCIBLE_MEMENTO,
            self.T_REK_MTYR_CRUCIBLE_RESONATION,
            self.T_RESONANCE_FIELD,
            self.T_CONVERSION,
            self.T_FOCUSED_WRATH,
            self.T_K_CHARGED_SHOT,
            self.T_K_DOMINATION_SHOT,
            self.T_K_RESONANCE_LINK
         }
         local idxT = 1
         while overcharge do
            if self:isTalentCoolingDown(self:getTalentFromId(talents[idxT])) then
               self:alterTalentCoolingdown(talents[idxT], -1)
               consumed = consumed + math.min(overcharge, cost)
               overcharge = math.max(0, overcharge - cost)
            elseif idxT > #talents then
               break
            else
               idxT = idxT + 1
            end
         end
         v = v - consumed
      end
   end
   return base_incFeedback(self, v, set)
end

-- prevent horror-transformed enemies using any talents except the approved horror ones
local base_preUseTalent = _M.preUseTalent
function _M:preUseTalent(ab, silent, fake)
   local eff = self:hasEffect(self.EFF_REK_MTYR_ABYSSAL_LUMINOUS)
   if eff then --and util.getval(ab.no_energy, self, ab) ~= (true or "fake") then
      game.logPlayer(self, "DEBUG testing abyssal talent %s", ab.id)
      for k, v in pairs(eff.allow_talent) do
         game.logPlayer(self, "DEBUG vs %s: %s", k, v)
      end
      
      if not eff.allow_talent[ab.id] then
         return false
      end
   end

   local ret = base_preUseTalent(self, ab, silent, fake)
   return ret
end

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
