local _M = loadPrevious(...)

getParadoxCost = function(self, t, value)
   local pm = getParadoxModifier(self)
   local multi = 1
   if self:attr("paradox_cost_multiplier") then
      multi = 1 - self:attr("paradox_cost_multiplier")
   end
   return (value * pm^2) * multi
end

-- Instead of multiplying effective spellpower, multiply MAG as used for spellpower
getParadoxSpellpower = function(self, t, mod, add)
   local pm = 1  --getParadoxModifier(self)
   local mod = mod or 1

   local paradox = self:getParadox()
   local paradadd = math.sqrt(paradox / 300) * self:getMag()
   
   -- Empower?
   local p = self:isTalentActive(self.T_EMPOWER)
   if p and p.talent == t.id then
      pm = pm + self:callTalent(self.T_EMPOWER, "getPower")
   end
   
   local spellpower = self:combatSpellpower(mod * pm, add+paradadd)
   return spellpower
end

return _M
