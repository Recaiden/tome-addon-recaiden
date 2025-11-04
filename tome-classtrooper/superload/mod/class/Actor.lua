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

local base_regenResources = _M.regenResources
function _M:regenResources()
	local battery_lock = self.battery
	base_regenResources(self)
	if self.oclt_battery_overheat then
		self.battery = battery_lock
		self.oclt_battery_overheat = self.oclt_battery_overheat - 1
		if self.oclt_battery_overheat <= 0 then
			self.oclt_battery_overheat = nil
		end
	end
end

--todo rework after 1.8 resource consolidation
-- local base_regenBattery = _M.regenBattery
-- function _M:regenBattery(fake, force)
-- 	if not self.oclt_battery_overheat then
-- 		return base_regenBattery(self, fake, force)
-- 	end
-- end

return _M
