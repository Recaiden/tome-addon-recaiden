local _M = loadPrevious(...)

local base_atEnd = _M.atEnd
function _M:atEnd(v)
	if v == "created" and not self.ui_by_ui[self.c_ok].hidden then
		self.actor_base:attr("never_attack", 1)
	end
	return base_atEnd(self, v)
end

return _M
