require "engine.Game"

local _M = loadPrevious(...)

Talents.talents_def.T_TENTACLED_WINGS.on_learn = function(self, t)
   self:learnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
end

Talents.talents_def.T_TENTACLED_WINGS.on_unlearn = function(self, t)
   self:unlearnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
end

return _M
