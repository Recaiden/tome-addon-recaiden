local _M = loadPrevious(...)

local base_atEnd = _M.atEnd
function _M:atEnd(v)
	if v == "created" and not self.ui_by_ui[self.c_ok].hidden then
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_ONE, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_TWO, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_THREE, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_FOUR, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_FIVE, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_MANAGE, true)
	end
	return base_atEnd(self, v)
end

return _M
