local _M = loadPrevious(...)


-- allow pickaxes in mainhand
local base_getObjectOffslot = _M.getObjectOffslot
function _M:getObjectOffslot(o)
	if o.subtype == "digger" and o.type == "tool" and self:knowTalent(self.T_REK_OCLT_TOOL_RESERVE) then return "MAINHAND" end
	return base_getObjectOffslot(self, o)
end


--- apply combatStatsToPicks
local base_onAddObject = _M.onAddObject
function _M:onAddObject(o, inven_id, slot)
	if o.subtype == "digger" and self:knowTalent(self.T_REK_OCLT_TOOL_RESERVE) then
		local t = self:getTalentFromId(self.T_REK_OCLT_TOOL_RESERVE)
		t.modifyPick(self, t, o)
	end

	return base_onAddObject(self, o, inven_id, slot)
end


return _M
