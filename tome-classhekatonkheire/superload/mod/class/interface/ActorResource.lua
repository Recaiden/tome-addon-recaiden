local _M = loadPrevious(...)

local base_regenResources = _M.regenResources
function _M:regenResources()
	local hro = self.hands_regen
	if hro then self.hand_Rege = self.hands_regen * self.global_speed end
	base_regenResources()
	if hro then self.hands_regen = hro end
end

return _M
