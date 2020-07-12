local _M = loadPrevious(...)


local base_incInsanity = _M.incInsanity
function _M:incInsanity(amount, no_enemy_check)
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
   if eff and util.getval(ab.no_energy, self, ab) ~= (true or "fake") then      
      if not eff.allow_talent[ab.id] then
         return false
      end
   end

   local ret = base_preUseTalent(self, ab, silent, fake)
   return ret
end

local base_insanityEffect = _M.insanityEffect
function _M:insanityEffect(min, max)

   local madness = base_insanityEffect(self, max, min)
   if self:knowTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS) then
      -- reroll negative effects up to once
      if madness < 0 and rng.percent(self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getRerollChance")) then
         madness = base_insanityEffect(self, max, min)
      end
      local minUp = self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getMinBonus")
      local minDown = -1 * self:callTalent(self.T_REK_MTYR_POLARITY_DEEPER_SHADOWS, "getMinPenalty")
      if madness < 0 and madness > minDown then
         madness = minDown
      elseif madness > 0 and madness < minUp then
         madness = minUp
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
