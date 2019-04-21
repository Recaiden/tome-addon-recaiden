local _M = loadPrevious(...)

local doBaseLearn = Talents.talents_def.T_SWIFT_HANDS.on_learn

-- Don't accidentally make items worse if we also know Possession is Proficiency, which replicates 1/3 of this prodigy's effect.
Talents.talents_def.T_SWIFT_HANDS.on_learn = function(self, t)
   doBaseLearn(self, t)
   if self:attr("quick_equip_cooldown") then
      self:attr("quick_equip_cooldown", -1 * self:attr("quick_equip_cooldown") )
      self:attr("quick_equip_cooldown", 1)
   end
end

return _M
