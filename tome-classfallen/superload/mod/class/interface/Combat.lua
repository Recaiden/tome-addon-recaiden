local _M = loadPrevious(...)
local base_combatSpellpower = _M.combatSpellpower
local base_combatMindpower = _M.combatMindpower

function _M:combatSpellpower(mod, add)
   add = add or 0
   if self:knowTalent(self.T_FLN_DARKSIDE_POWER) then
      add = add + self:callTalent(self.T_FLN_DARKSIDE_POWER,"getSpellpower") * self:getWil() / 100
   end
   
   -- execute the original function
   return base_combatSpellpower(self, mod, add)
end

function _M:combatMindpower(mod, add)
   add = add or 0
   if self:knowTalent(self.T_FLN_DARKSIDE_POWER) then
      add = add + self:callTalent(self.T_FLN_DARKSIDE_POWER,"getMindpower") * self:getMag() / 100
   end
   
   -- execute the original function
   return base_combatMindpower(self, mod, add)
end

return _M
