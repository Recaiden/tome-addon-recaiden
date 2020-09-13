local _M = loadPrevious(...)

local base_learnTalent = _M.learnTalent
local base_unlearnTalent = _M.unlearnTalent

function _M:learnTalent(t_id, v)
   self.talents_learned[t_id] = self.talents_learned[t_id] or 0
   local t = self.actor:getTalentFromId(t_id)
   local category = t.type[1]
   local t_type, t_index = "class", "unused_talents"
   if t.generic then t_type, t_index = "generic", "unused_generics" end

   local countVagabond = self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_VAGABOND_SLING_PRACTICE)
      + self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_VAGABOND_STAGGER_SHOT)
      + self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_VAGABOND_TAINTED_BULLETS)
      + self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_VAGABOND_HOLLOW_SHELL)
   
   local countChivalry = self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_CHIVALRY_CHAMPIONS_FOCUS)
      + self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_CHIVALRY_LANCERS_CHARGE)
      + self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_CHIVALRY_EXECUTIONERS_ONSLAUGHT)
      + self.actor:getTalentLevelRaw(self.actor.T_REK_MTYR_CHIVALRY_HEROS_RESOLVE)

   local lvl_orig = self.actor:getTalentLevelRaw(t_id)
   if v then
      local mtyr_talent_flag = false
      if category == "demented/chivalry" and countChivalry < countVagabond then
         mtyr_talent_flag = true
         self.actor[t_index] = self.actor[t_index] + 1
      end

      base_learnTalent(self, t_id, v)
   
      if mtyr_talent_flag and self.actor:getTalentLevelRaw(t_id) == lvl_orig then
         self.actor[t_index] = self.actor[t_index] - 1
      end
   else
      if category == "demented/vagabond" and countChivalry >= countVagabond then
         self:subtleMessage("Impossible", "You must unlearn some Chivalry talents first!", subtleMessageErrorColor)
         return
      end
			base_learnTalent(self, t_id, v)
			local lvl = self.actor:getTalentLevelRaw(t_id)
			--self:subtleMessage("DEBUG", ("%d -> %d"):format(lvl_orig, lvl), subtleMessageErrorColor)
      if category == "demented/chivalry" and (lvl ~= lvl_orig) then
         self.actor[t_index] = self.actor[t_index] - 1
      end
   end
end

return _M