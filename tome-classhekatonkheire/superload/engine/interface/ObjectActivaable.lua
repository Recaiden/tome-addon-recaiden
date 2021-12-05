local _M = loadPrevious(...)

local base_useObject = _M.useObject
function _M:useObject(who, ...)
	local ret = base_useObject(self, who, ...)

	if ret and ret.used and who and who.knowTalent and who:knowTalent(who.T_REK_HEKA_PAGE_FLIP) then
		who:callTalent(who.T_REK_HEKA_PAGE_FLIP, "doCharm")
	end
	
	return ret
end


return _M
