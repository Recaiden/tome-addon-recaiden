local _M = loadPrevious(...)

local base_preUseTalent = _M.preUseTalent
function _M:preUseTalent(ab, silent, fake)
   local oldRestriction = nil
   local oldForbiddance = 0

   if self:knowTalent(self.T_REK_WIGHT_DODGE) then
      if ab.is_inscription and ab.is_nature then
         if self.inscription_forbids then
            oldRestriction = self.inscription_forbids["inscriptions/infusions"]
         end
         oldForbiddance = self:attr("forbid_nature")
         self.inscription_forbids["inscriptions/infusions"] = nil
         self:attr("forbid_nature", -1 * oldForbiddance)
      end
   end

   local ret = base_preUseTalent(self, ab, silent, fake)
   if oldRestriction then
      self.inscription_forbids["inscriptions/infusions"] = oldRestriction
   end
   if oldForbiddance then
      self:attr("forbid_nature", oldForbiddance)
   end
   return ret
end

local base_canSeeNoCache = _M.canSeeNoCache
function _M:canSeeNoCache(actor, def, def_pct)
   if not actor then return false, 0 end
   
   if actor.is_dreadlord_minion and self:knowTalent(self.T_REK_DREAD_SUMMON_DREAD) then
      return true, 100
   end

   return base_canSeeNoCache(self, actor, def, def_pct)
end

return _M
